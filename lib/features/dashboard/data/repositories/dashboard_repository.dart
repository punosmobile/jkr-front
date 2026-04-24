import 'package:jkrfront/core/di/injection.dart';
import 'package:jkrfront/core/network/dio_client.dart';

import '../models/dashboard_overview.dart';

class DashboardRepository {
  final _dio = getIt<DioClient>().dio;

  Future<DashboardOverview> fetchOverview() async {
    final response = await _dio.get('/dashboard/overview');
    return DashboardOverview.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<DashboardImportLogItem>> fetchImportLog() async {
    final response = await _dio.get('/tuontiloki');
    return (response.data as List<dynamic>? ?? const [])
        .map((item) => DashboardImportLogItem.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}