import 'dart:async';

import 'package:dio/dio.dart';
import 'package:jkrfront/core/di/injection.dart';
import 'package:jkrfront/core/network/dio_client.dart';
import 'package:jkrfront/features/import/data/models/sharepoint_item.dart';

import '../models/import_file.dart';
import '../models/import_queue_item.dart';
import '../models/file_type_enum.dart';

/// Repository for import-related backend operations.
class ImportRepository {
  final Dio _dio = getIt<DioClient>().dio;

  /// Fetch available files from Sharepoint.
  FutureOr<List<ImportFile>> fetchSharepointFiles() async {
    final sharepointResponse = await _dio.get('/sharepoint/files');
    
    return (sharepointResponse.data as List)
      .map((e) => ImportFile.fromJson(e as Map<String, dynamic>))
      .toList();
  }

  /// Run pre-analysis on selected files.
  Future<List<ImportFile>> analyzeFiles(List<ImportFile> files) async {
    final filePaths = files.map((file) => file.path).toList();
    final response = await _dio.post('/sharepoint/pull', queryParameters: {'paths': filePaths});

    final analyzedResponse = SharepointPullResult.fromJson(response.data as Map<String, dynamic>);
    // Match backend results by full SharePoint path to avoid collisions
    // between files that happen to share the same filename.
    final downloadedByPath = {
      for (final file in analyzedResponse.downloaded)
        _normalizedLookupKey(file.sharepointPath ?? file.filename): file,
    };
    final errorsByPath = {
      for (final error in analyzedResponse.errors)
        _normalizedLookupKey(error.path): error,
    };

    final analyzed = files
        .map(
          (file) => _mapAnalyzedFile(
            file,
            downloadedByPath: downloadedByPath,
            errorsByPath: errorsByPath,
          ),
        )
        .toList();

    final runnableFiles = analyzed
        .where((file) => file.analysisStatus == AnalysisStatus.analyzed && file.analysis?.hasError != true)
        .toList()
      ..sort(_compareByFileTypeOrder);

    final erroredFiles = analyzed
        .where((file) => file.analysisStatus == AnalysisStatus.error || file.analysis?.hasError == true)
        .toList();

    return [...runnableFiles, ...erroredFiles];
  }
  

  /// Start import for analyzed files.
  Future<List<ImportQueueItem>> startImport(List<ImportFile> files) async {


    final response = await _dio.post('/jkr/batch_import',
      data: files.map((f) => {
          'filename': f.name,
          'type': f.type,
          'fileType': f.fileType,
          'target_path': f.pathOnServer,
        }).toList()
    );

    final taskId = (response.data as Map<String, dynamic>?)?['task_id'] as String?
        ?? (response.data as Map<String, dynamic>?)?['id'] as String?;

    return files.map((file) => ImportQueueItem(
          id: file.id,
          fileName: file.name,
          totalCount: file.analysis?.rowCount ?? 0,
          taskId: taskId,
        )).toList();
  }

  /// Fetch the status of a single backend task.
  Future<({bool isFinished, bool hasError, String? errorOutput})> fetchTaskStatus(String taskId) async {
    final response = await _dio.get('/tasks/$taskId');
    final data = response.data as Map<String, dynamic>;
    final status = data['status'] as String? ?? '';
    final isFinished = status != 'pending' && status != 'running';
    final exitCode = data['exit_code'] as int?;
    final errorText = data['error'] as String? ?? '';
    final hasError = (exitCode != null && exitCode != 0) || errorText.isNotEmpty;
    final errorOutput = hasError ? errorText : null;
    return (isFinished: isFinished, hasError: hasError, errorOutput: errorOutput);
  }

  /// Run velvoitetarkistus for a given date.
  Future<Response> runVelvoitetarkistus(String date) async {
    return await _dio.post('/psql/tallenna_velvoite_status', 
      data: {'pvm': date}
    );
  }

  /// Set velvoitteet based on imported data.
  Future<Response> setVelvoitteet() async {
    return await _dio.post('/psql/update_velvoitteet');
  }

  ImportFile _mapAnalyzedFile(
    ImportFile file, {
    required Map<String, SharepointDownloadedFile> downloadedByPath,
    required Map<String, SharepointPullError> errorsByPath,
  }) {
    final lookupKey = _normalizedLookupKey(file.path);
    final downloadedFile = downloadedByPath[lookupKey];
    final pullError = errorsByPath[lookupKey];

    if (pullError != null) {
      return _toErroredFile(file, errorMessage: pullError.error);
    }

    if (downloadedFile == null) {
      return _toErroredFile(
        file,
        errorCode: ImportAnalysisErrorCode.missingResult,
      );
    }

    // Backend marks files with runnable=false when they were downloaded but
    // should still be blocked from the import flow.
    if (!downloadedFile.runnable) {
      return _toErroredFile(
        file,
        errorCode: ImportAnalysisErrorCode.notRunnable,
        downloadedFile: downloadedFile,
      );
    }

    return file.copyWith(
      analysisStatus: AnalysisStatus.analyzed,
      analysis: ImportAnalysis(
        rowCount: downloadedFile.rows ?? 0,
        newCount: 0,
        updateCount: 0,
      ),
      pathOnServer: downloadedFile.targetPath,
      fileType: downloadedFile.fileType,
    );
  }

  ImportFile _toErroredFile(
    ImportFile file, {
    ImportAnalysisErrorCode? errorCode,
    String? errorMessage,
    SharepointDownloadedFile? downloadedFile,
  }) {
    return file.copyWith(
      analysisStatus: AnalysisStatus.error,
      analysis: ImportAnalysis(
        rowCount: downloadedFile?.rows ?? 0,
        errorCode: errorCode,
        errorMessage: errorMessage,
      ),
      pathOnServer: downloadedFile?.targetPath,
      fileType: downloadedFile?.fileType ?? file.fileType,
    );
  }
}

int _compareByFileTypeOrder(ImportFile a, ImportFile b) {
  final aIndex = FileType.values.indexWhere((e) => e.type == a.fileType);
  final bIndex = FileType.values.indexWhere((e) => e.type == b.fileType);
  final aOrder = aIndex == -1 ? FileType.values.length : aIndex;
  final bOrder = bIndex == -1 ? FileType.values.length : bIndex;
  return aOrder.compareTo(bOrder);
}

String _normalizedLookupKey(String path) {
  if (path.isEmpty) {
    return path;
  }

  final normalized = path.replaceAll('\\', '/');
  return normalized.trim();
}
