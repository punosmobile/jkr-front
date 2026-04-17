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

    final response = await _dio.post('/sharepoint/pull', 
      queryParameters: {'paths': filePaths}
    );

    final analyzedResponse = SharepointPullResult.fromJson(response.data as Map<String, dynamic>);

    List<ImportFile> sortedFiles = [];
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
              newCount: 7357,
              updateCount: 7357,
            ),
            pathOnServer: analyzedFile?.targetPath,
            fileType: analyzedFile?.fileType as String
          );
      }).toList();

      // Sort the files based on predetermined order
      sortedFiles = analyzed
        .where((f) =>
            f.analysisStatus == AnalysisStatus.analyzed &&
            f.analysis?.hasError != true)
        .toList()
      ..sort((a, b) {
          final aIndex = FileType.values.indexWhere((e) => e.type == a.type);
          final bIndex = FileType.values.indexWhere((e) => e.type == b.type);
          final aOrder = aIndex == -1 ? FileType.values.length : aIndex;
          final bOrder = bIndex == -1 ? FileType.values.length : bIndex;
          return aOrder.compareTo(bOrder);
        });
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

    return files.map((file) => ImportQueueItem(
          id: file.id,
          fileName: file.name,
          totalCount: file.analysis?.rowCount ?? 0,
        )).toList();
  }

  /// Run velvoitetarkistus for a given date.
  Future<void> runVelvoitetarkistus(String date) async {
    // TODO: Replace with real API call
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Set velvoitteet based on imported data.
  Future<void> setVelvoitteet() async {
    // TODO: Replace with real API call
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
