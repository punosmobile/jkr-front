import 'dart:async';

import 'package:dio/dio.dart';
import 'package:jkrfront/core/di/injection.dart';
import 'package:jkrfront/core/network/dio_client.dart';
import 'package:jkrfront/features/import/data/models/sharepoint_item.dart';

import '../models/import_file.dart';
import '../models/import_queue_item.dart';
import '../models/file_type_enum.dart';

/// Repository for import operations.
/// All methods return stub/dummy data for now — no backend calls.
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

    var filePaths = files.map((file) => file.path).toList();
    List<ImportFile> sortedFiles = [];
    try {
      final response = await _dio.post('/sharepoint/pull', 
        queryParameters: {'paths': filePaths}
      );

      final analyzedResponse = SharepointPullResult.fromJson(response.data as Map<String, dynamic>);
      
      if (analyzedResponse.downloaded.isNotEmpty) {
        List<ImportFile> analyzed = [];
        analyzed = files.map((f) {
          SharepointDownloadedFile? analyzedFile; 
          for (var file in analyzedResponse.downloaded) {

            if (file.filename == f.name) {
              analyzedFile = file;
              break;
            }
          }

          return f.copyWith(
              analysisStatus: AnalysisStatus.analyzed,
              analysis: ImportAnalysis(
                rowCount: analyzedFile?.rows ?? 0,
                newCount: 0, // Näiden selvittäminen käytännössä vaatisi aineiston sisäänlukua. Ei käsitellä vielä
                updateCount: 0,
              ),
              pathOnServer: analyzedFile?.targetPath,
              fileType: analyzedFile?.fileType as String
          );
        }).toList();

        // Sort the files based on predetermined order in the FileType enum
        sortedFiles = analyzed
          .where((f) =>
              f.analysisStatus == AnalysisStatus.analyzed &&
              f.analysis?.hasError != true)
          .toList()
        ..sort((a, b) {
            final aIndex = FileType.values.indexWhere((e) => e.type == a.fileType);
            final bIndex = FileType.values.indexWhere((e) => e.type == b.fileType);
            final aOrder = aIndex == -1 ? FileType.values.length : aIndex;
            final bOrder = bIndex == -1 ? FileType.values.length : bIndex;
            return aOrder.compareTo(bOrder);
          });
      }
    } catch (e) {
      print(e);
      print(StackTrace.current);
    }

    return sortedFiles;
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
}
