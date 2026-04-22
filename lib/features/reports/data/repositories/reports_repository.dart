import 'package:dio/dio.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/protected_api_client.dart';
import '../models/report_task_info.dart';
import '../models/report_task_response.dart';

class ReportsRepository {
  final ProtectedApiClient _api = getIt<ProtectedApiClient>();

  Future<List<ReportTaskInfo>> fetchTasks() async {
    try {
      final response = await _api.get<List<dynamic>>('/tasks');
      final data = response.data ?? const [];
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map(ReportTaskInfo.fromJson)
          .toList();
    } on DioException catch (error) {
      throw Exception(_toFinnishError(error, 'Raporttitehtävien haku epäonnistui.'));
    } catch (_) {
      throw Exception('Raporttitehtävien haku epäonnistui.');
    }
  }

  Future<ReportTaskResponse> startReport({
    required String tarkastelupvm,
    required String kunta,
    required int huoneistomaara,
    required int taajama,
    required int kohdeTyyppi,
    required int onkoViemari,
  }) async {
    try {
      final response = await _api.post(
        '/jkr/raportti',
        data: {
          'tarkastelupvm': tarkastelupvm.isEmpty ? '0' : tarkastelupvm,
          'kunta': kunta.isEmpty ? '0' : kunta,
          'huoneistomaara': huoneistomaara,
          'taajama': taajama,
          'kohde_tyyppi': kohdeTyyppi,
          'onko_viemari': onkoViemari,
        },
      );
      return ReportTaskResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_toFinnishError(error, 'Raportin käynnistäminen epäonnistui.'));
    } catch (_) {
      throw Exception('Raportin käynnistäminen epäonnistui.');
    }
  }

  Future<ReportTaskInfo> fetchTask(String taskId) async {
    try {
      final response = await _api.get('/tasks/$taskId');
      return ReportTaskInfo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_toFinnishError(error, 'Raportin tilan haku epäonnistui.'));
    } catch (_) {
      throw Exception('Raportin tilan haku epäonnistui.');
    }
  }

  Future<String> cancelTask(String taskId) async {
    try {
      final response = await _api.delete<Map<String, dynamic>>(
        '/tasks/$taskId',
      );
      final data = response.data;
      return data?['message'] as String? ?? 'Raportin peruutus pyydetty.';
    } on DioException catch (error) {
      throw Exception(_toFinnishError(error, 'Raportin peruuttaminen epäonnistui.'));
    } catch (_) {
      throw Exception('Raportin peruuttaminen epäonnistui.');
    }
  }

  String _toFinnishError(DioException error, String fallback) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final detail = responseData['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout => 'Yhteys aikakatkaistiin. Yritä uudelleen.',
      DioExceptionType.connectionError => 'Yhteyttä palvelimeen ei saatu muodostettua.',
      _ => fallback,
    };
  }
}