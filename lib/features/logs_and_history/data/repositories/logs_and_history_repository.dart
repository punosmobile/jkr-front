import 'package:jkrfront/core/di/injection.dart';
import 'package:jkrfront/core/network/dio_client.dart';

import '../models/logs_and_history_models.dart';

class DashboardRepository {
  final _dio = getIt<DioClient>().dio;

  Future<List<LogHistoryImportLogItem>> fetchImportLog() async {
    final response = await _dio.get('/tuontiloki');
    return (response.data as List<dynamic>? ?? const [])
        .map((item) => LogHistoryImportLogItem.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}