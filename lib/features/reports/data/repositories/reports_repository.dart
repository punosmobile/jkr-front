import 'package:dio/dio.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/protected_api_client.dart';
import '../../report_localizations.dart';
import '../models/report_task_info.dart';
import '../models/report_task_response.dart';

// API adapter for report-related task endpoints.
class ReportsRepository {
  final ProtectedApiClient _api = getIt<ProtectedApiClient>();

  // Fetch all backend tasks so the feature can restore and poll report runs.
  Future<List<ReportTaskInfo>> fetchTasks() async {
    final l10n = currentReportLocalizations();
    try {
      final response = await _api.get<List<dynamic>>('/tasks');
      final data = response.data ?? const [];
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map(ReportTaskInfo.fromJson)
          .toList();
    } on DioException catch (error) {
      throw Exception(_toLocalizedError(error, l10n.reportsRepoFetchTasksFailed));
    } catch (_) {
      throw Exception(l10n.reportsRepoFetchTasksFailed);
    }
  }

  // Start a new report task with the selected filter values.
  Future<ReportTaskResponse> startReport({
    required String tarkastelupvm,
    required String kunta,
    required int huoneistomaara,
    required int taajama,
    required int kohdeTyyppi,
    required int onkoViemari,
  }) async {
    final l10n = currentReportLocalizations();
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
      throw Exception(_toLocalizedError(error, l10n.reportsRepoStartFailed));
    } catch (_) {
      throw Exception(l10n.reportsRepoStartFailed);
    }
  }

  // Fetch a single task when it is missing from the list endpoint.
  Future<ReportTaskInfo> fetchTask(String taskId) async {
    final l10n = currentReportLocalizations();
    try {
      final response = await _api.get('/tasks/$taskId');
      return ReportTaskInfo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_toLocalizedError(error, l10n.reportsRepoFetchStatusFailed));
    } catch (_) {
      throw Exception(l10n.reportsRepoFetchStatusFailed);
    }
  }

  // Request cancellation for an active report task.
  Future<String> cancelTask(String taskId) async {
    final l10n = currentReportLocalizations();
    try {
      final response = await _api.delete<Map<String, dynamic>>(
        '/tasks/$taskId',
      );
      final data = response.data;
      return data?['message'] as String? ?? l10n.reportsRepoCancelRequested;
    } on DioException catch (error) {
      throw Exception(_toLocalizedError(error, l10n.reportsRepoCancelFailed));
    } catch (_) {
      throw Exception(l10n.reportsRepoCancelFailed);
    }
  }

  // Normalize Dio failures into user-facing localized error messages.
  String _toLocalizedError(DioException error, String fallback) {
    final l10n = currentReportLocalizations();
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
      DioExceptionType.sendTimeout => l10n.reportsRepoConnectionTimeout,
      DioExceptionType.connectionError => l10n.reportsRepoConnectionError,
      _ => fallback,
    };
  }
}