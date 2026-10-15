import 'package:dio/dio.dart';

import 'package:jkrfront/core/di/injection.dart';
import 'package:jkrfront/core/network/protected_api_client.dart';
import 'package:jkrfront/features/backups/data/models/backup_info.dart';
import 'package:jkrfront/features/backups/data/web_file_helper.dart';

/// Yksittäisen taustatehtävän tilannevedos (pollausta varten).
class BackupTaskSnapshot {
  const BackupTaskSnapshot({
    required this.status,
    this.message,
    this.output = '',
    this.error = '',
  });

  final String status;
  final String? message;
  final String output;
  final String error;

  bool get isFinished => status != 'pending' && status != 'running';
  bool get isFailed => status == 'failed';

  /// Yhdistetty loki (stdout + stderr) virhetilanteen tarkempaa analyysiä varten.
  String get combinedLog => '$output\n$error';
}

/// Palvelimella käynnissä oleva dump/restore-operaatio (indikaattorin palautus).
class BackupActiveOperation {
  const BackupActiveOperation({
    required this.taskId,
    required this.kind,
    this.filename,
    this.message,
  });

  /// "dump" tai "restore".
  final String kind;
  final String taskId;
  final String? filename;
  final String? message;

  bool get isRestore => kind == 'restore';
}

/// API-sovitin varmuuskopiointien hallintaan (pg_dump / pg_restore).
class BackupsRepository {
  final ProtectedApiClient _api = getIt<ProtectedApiClient>();

  /// Listaa olemassa olevat varmuuskopiot (uusin ensin).
  Future<List<BackupInfo>> listBackups() async {
    try {
      final response = await _api.get<List<dynamic>>('/db/dumps');
      final data = response.data ?? const [];
      return data
          .whereType<Map>()
          .map((item) => BackupInfo.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (error) {
      throw Exception(_errorMessage(error, 'Varmuuskopioiden haku epäonnistui'));
    }
  }

  /// Käynnistää uuden varmuuskopion (pg_dump). Palauttaa tehtävän id:n.
  Future<String> createDump() async {
    try {
      final response = await _api.post<Map<String, dynamic>>('/db/dump');
      return _taskId(response.data);
    } on DioException catch (error) {
      throw Exception(_errorMessage(error, 'Varmuuskopion luonti epäonnistui'));
    }
  }

  /// Palauttaa tietokannan annetusta varmuuskopiosta (pg_restore).
  /// Palauttaa tehtävän id:n.
  Future<String> restoreBackup(String filename) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/db/restore',
        data: {'filename': filename},
      );
      return _taskId(response.data);
    } on DioException catch (error) {
      throw Exception(_errorMessage(error, 'Varmuuskopion palautus epäonnistui'));
    }
  }

  /// Poistaa varmuuskopiotiedoston.
  Future<void> deleteBackup(String filename) async {
    try {
      await _api.delete<Map<String, dynamic>>(
        '/db/dumps/${Uri.encodeComponent(filename)}',
      );
    } on DioException catch (error) {
      throw Exception(_errorMessage(error, 'Varmuuskopion poisto epäonnistui'));
    }
  }

  /// Vie valitun tiedoston palvelimen /dbdumps-kansioon.
  Future<void> uploadBackup(PickedFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(file.bytes, filename: file.name),
      });
      await _api.post<Map<String, dynamic>>('/db/dumps/upload', data: formData);
    } on DioException catch (error) {
      throw Exception(_errorMessage(error, 'Varmuuskopion vienti epäonnistui'));
    }
  }

  /// Palauttaa palvelimella käynnissä olevan dump/restore-operaation tai `null`.
  /// Käytetään edistymisindikaattorin palauttamiseen sivulle saavuttaessa.
  Future<BackupActiveOperation?> fetchActiveOperation() async {
    try {
      final response = await _api.get<dynamic>('/db/active-operation');
      final data = response.data;
      if (data is! Map) {
        return null;
      }
      final map = Map<String, dynamic>.from(data);
      final taskId = map['task_id'] as String?;
      if (taskId == null || taskId.isEmpty) {
        return null;
      }
      return BackupActiveOperation(
        taskId: taskId,
        kind: (map['kind'] as String?) ?? 'dump',
        filename: map['filename'] as String?,
        message: map['message'] as String?,
      );
    } on DioException catch (error) {
      throw Exception(_errorMessage(error, 'Aktiivisen operaation haku epäonnistui'));
    }
  }

  /// Hakee yksittäisen tehtävän tilan pollausta varten.
  Future<BackupTaskSnapshot> fetchTask(String taskId) async {
    try {
      final response = await _api.get<Map<String, dynamic>>('/tasks/$taskId');
      final data = response.data ?? const {};
      final status = data['status'] as String? ?? 'failed';
      final output = data['output'] as String? ?? '';
      final error = data['error'] as String? ?? '';
      return BackupTaskSnapshot(
        status: status,
        message: _lastNonEmptyLine(error) ?? _lastNonEmptyLine(output),
        output: output,
        error: error,
      );
    } on DioException catch (error) {
      throw Exception(_errorMessage(error, 'Tehtävän tilan haku epäonnistui'));
    }
  }

  String _taskId(Map<String, dynamic>? data) {
    return (data?['task_id'] ?? data?['id']) as String? ?? '';
  }

  static String? _lastNonEmptyLine(String source) {
    final lines = source
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    return lines.isEmpty ? null : lines.last;
  }

  String _errorMessage(DioException error, String fallback) {
    final responseData = error.response?.data;
    if (responseData is Map) {
      final detail = responseData['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        'Yhteys aikakatkaistiin',
      DioExceptionType.connectionError => 'Yhteysvirhe palvelimeen',
      _ => fallback,
    };
  }
}
