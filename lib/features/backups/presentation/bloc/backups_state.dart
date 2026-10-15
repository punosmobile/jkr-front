import 'package:equatable/equatable.dart';

import 'package:jkrfront/features/backups/data/models/backup_info.dart';

/// Listan latauksen tila.
enum BackupsListStatus { initial, loading, loaded, error }

/// Käynnissä olevan operaation laji.
enum BackupOpKind { dump, restore }

/// Käynnissä olevan operaation tila.
enum BackupOpStatus { running, completed, failed }

const _unset = Object();

/// Käynnissä olevan (tai juuri valmistuneen) pg_dump/pg_restore-operaation tila.
class BackupOperation extends Equatable {
  const BackupOperation({
    required this.kind,
    required this.status,
    this.taskId,
    this.filename,
    this.message,
  });

  final BackupOpKind kind;
  final BackupOpStatus status;
  final String? taskId;
  final String? filename;
  final String? message;

  bool get isRunning => status == BackupOpStatus.running;

  BackupOperation copyWith({
    BackupOpKind? kind,
    BackupOpStatus? status,
    Object? taskId = _unset,
    Object? filename = _unset,
    Object? message = _unset,
  }) {
    return BackupOperation(
      kind: kind ?? this.kind,
      status: status ?? this.status,
      taskId: identical(taskId, _unset) ? this.taskId : taskId as String?,
      filename: identical(filename, _unset) ? this.filename : filename as String?,
      message: identical(message, _unset) ? this.message : message as String?,
    );
  }

  @override
  List<Object?> get props => [kind, status, taskId, filename, message];
}

/// Kertaluonteinen palaute käyttäjälle (snackbar).
class BackupFeedback extends Equatable {
  const BackupFeedback({
    required this.id,
    required this.message,
    required this.isError,
  });

  final int id;
  final String message;
  final bool isError;

  @override
  List<Object?> get props => [id, message, isError];
}

/// Varmuuskopionäkymän tila.
class BackupsState extends Equatable {
  const BackupsState({
    this.listStatus = BackupsListStatus.initial,
    this.backups = const [],
    this.listError,
    this.operation,
    this.busyFilenames = const {},
    this.isUploading = false,
    this.feedback,
  });

  final BackupsListStatus listStatus;
  final List<BackupInfo> backups;
  final String? listError;

  /// Käynnissä oleva tai viimeksi valmistunut dump/restore-operaatio.
  final BackupOperation? operation;

  /// Tiedostonimet, joille on käynnissä poisto/lataus.
  final Set<String> busyFilenames;

  final bool isUploading;

  final BackupFeedback? feedback;

  bool get isOperationActive => operation?.isRunning ?? false;

  BackupsState copyWith({
    BackupsListStatus? listStatus,
    List<BackupInfo>? backups,
    Object? listError = _unset,
    Object? operation = _unset,
    Set<String>? busyFilenames,
    bool? isUploading,
    Object? feedback = _unset,
  }) {
    return BackupsState(
      listStatus: listStatus ?? this.listStatus,
      backups: backups ?? this.backups,
      listError: identical(listError, _unset) ? this.listError : listError as String?,
      operation: identical(operation, _unset) ? this.operation : operation as BackupOperation?,
      busyFilenames: busyFilenames ?? this.busyFilenames,
      isUploading: isUploading ?? this.isUploading,
      feedback: identical(feedback, _unset) ? this.feedback : feedback as BackupFeedback?,
    );
  }

  @override
  List<Object?> get props => [
        listStatus,
        backups,
        listError,
        operation,
        busyFilenames,
        isUploading,
        feedback,
      ];
}
