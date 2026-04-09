import 'package:dio/dio.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/dio_client.dart';
import '../models/sharepoint_item.dart';

class SharepointRepository {
  final Dio _dio = getIt<DioClient>().dio;

  /// Check whether SharePoint integration is configured on the backend.
  Future<SharepointStatus> fetchStatus() async {
    final response = await _dio.get('/sharepoint/status');
    return SharepointStatus.fromJson(response.data as Map<String, dynamic>);
  }

  /// List files and folders in the given SharePoint [folder].
  Future<List<SharepointItem>> fetchFiles({String? folder}) async {
    final queryParams = <String, dynamic>{};
    if (folder != null && folder.isNotEmpty) {
      queryParams['folder'] = folder;
    }
    final response = await _dio.get(
      '/sharepoint/files',
      queryParameters: queryParams,
    );
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => SharepointItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get the download URL for a SharePoint file at [path].
  /// Returns the full URL to stream/download from the backend.
  String getDownloadUrl(String path) {
    final baseUrl = _dio.options.baseUrl;
    return '$baseUrl/sharepoint/download?path=${Uri.encodeQueryComponent(path)}';
  }
}
