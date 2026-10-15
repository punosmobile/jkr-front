import '../../../../core/config/env_config.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/protected_api_client.dart';
import '../models/sharepoint_item.dart';

class SharepointRepository {
  final ProtectedApiClient _api = getIt<ProtectedApiClient>();

  /// Check whether SharePoint integration is configured on the backend.
  Future<SharepointStatus> fetchStatus() async {
    final response = await _api.get('/sharepoint/status');
    return SharepointStatus.fromJson(response.data as Map<String, dynamic>);
  }

  /// List files and folders in the given SharePoint [folder].
  Future<List<SharepointItem>> fetchFiles({String? folder}) async {
    final queryParams = <String, dynamic>{};
    if (folder != null && folder.isNotEmpty) {
      queryParams['folder'] = folder;
    }
    final response = await _api.get(
      '/sharepoint/files',
      queryParameters: queryParams,
    );
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => SharepointItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get the download URL for a SharePoint file at [filePath].
  /// Returns the full URL to stream/download from the backend.
  String getDownloadUrl(String filePath) {
    return '${EnvConfig.apiBaseUrl}/sharepoint/download?path=${Uri.encodeQueryComponent(filePath)}';
  }

  /// Pull files from SharePoint to the backend server's /data/input directory.
  /// [paths] is a list of SharePoint file paths to download.
  /// [subfolder] is an optional target subfolder within /data/input.
  /// This uses the backend's task mode to avoid request timeouts.
  Future<SharepointPullTaskResponse> pullToServer({
    required List<String> paths,
    String? subfolder,
  }) async {
    final queryParams = <String, dynamic>{
      'paths': paths,
      'mode': 'task',
    };
    if (subfolder != null && subfolder.isNotEmpty) {
      queryParams['subfolder'] = subfolder;
    }
    final response = await _api.post(
      '/sharepoint/pull',
      queryParameters: queryParams,
    );
    return SharepointPullTaskResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<({bool isFinished, bool hasError, String? errorOutput})> fetchTaskStatus(
    String taskId,
  ) async {
    final response = await _api.get('/tasks/$taskId');
    final data = response.data as Map<String, dynamic>;
    final status = data['status'] as String? ?? '';
    final isFinished = status != 'pending' && status != 'running';
    final exitCode = data['exit_code'] as int?;
    final errorText = data['error'] as String? ?? '';
    final hasError = (exitCode != null && exitCode != 0) || errorText.isNotEmpty;
    final errorOutput = hasError ? errorText : null;
    return (
      isFinished: isFinished,
      hasError: hasError,
      errorOutput: errorOutput,
    );
  }
}
