import 'package:jkrfront/core/di/injection.dart';
import 'package:jkrfront/core/network/dio_client.dart';

import '../models/logs_and_history_models.dart';

class LogsAndHistoryRepository {
  final _dio = getIt<DioClient>().dio;

  /// Hakee tuontilokin rivit. [limit] ohitetaan, jos [kaikki] on tosi.
  Future<List<LogHistoryImportLogItem>> fetchImportLog({int limit = 50, bool kaikki = false}) async {
    final response = await _dio.get(
      '/tuontiloki',
      queryParameters: {
        'limit': limit,
        'kaikki': kaikki,
      },
    );
    return (response.data as List<dynamic>? ?? const [])
        .map((item) => LogHistoryImportLogItem.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Hakee järjestelmätapahtumat. [limit] ohitetaan, jos [kaikki] on tosi.
  Future<List<LogEventItem>> fetchSystemEvents({int limit = 50, bool kaikki = false}) async {
    final response = await _dio.get(
      '/jarjestelmatapahtumat',
      queryParameters: {
        'limit': limit,
        'kaikki': kaikki,
      },
    );
    return (response.data as List<dynamic>? ?? const [])
        .map((item) => LogEventItem.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
