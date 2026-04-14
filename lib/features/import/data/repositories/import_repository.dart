import 'dart:async';

import 'package:dio/dio.dart';
import 'package:jkrfront/core/di/injection.dart';
import 'package:jkrfront/core/network/dio_client.dart';
import 'package:jkrfront/features/import/data/models/sharepoint_item.dart';

import '../models/import_file.dart';
import '../models/import_queue_item.dart';

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

    if (analyzedResponse.downloaded.isNotEmpty) {
      print(analyzedResponse.downloaded);

      var analyzed = files.map((f) {
      SharepointDownloadedFile? analyzedFile; 
        for (var file in analyzedResponse.downloaded) {
          if (file.filename == f.name) {
            analyzedFile = file;
            break;
          }
        }

        return f.copyWith(
            analysisStatus: AnalysisStatus.analyzed,
            analysis: const ImportAnalysis(
              rowCount: analyzedFile ? analyzedFile.rows : null,
              newCount: 7357,
              updateCount: 7357,
            ));
      });
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return files.map((f) {
      switch (f.name) {
        case 'DVV_Q1_2025.csv':
          return f.copyWith(
            analysisStatus: AnalysisStatus.analyzed,
            analysis: const ImportAnalysis(
              rowCount: 1938,
              newCount: 1204,
              updateCount: 3871,
            ),
          );
        case 'Kuljetustiedot_Q1_2025.csv':
          return f.copyWith(
            analysisStatus: AnalysisStatus.analyzed,
            analysis: const ImportAnalysis(
              rowCount: 12479,
              newCount: 0,
              updateCount: 12445,
              unmatchedCount: 34,
            ),
          );
        case 'Paatostiedot_Q4_2024.xlsx':
          return f.copyWith(
            analysisStatus: AnalysisStatus.error,
            analysis: const ImportAnalysis(
              rowCount: 0,
              errorMessage:
                  'Virhe otsikoissa: sarake "paatospvm" puuttuu tai väärässä muodossa',
            ),
          );
        default:
          return f.copyWith(
            analysisStatus: AnalysisStatus.analyzed,
            analysis: const ImportAnalysis(rowCount: 412, newCount: 412),
          );
      }
    }).toList();
  }

  /// Start import for analyzed files.
  Future<List<ImportQueueItem>> startImport(List<ImportFile> files) async {
    // TODO: Replace with real API call
    await Future.delayed(const Duration(milliseconds: 200));
    return files
        .where((f) =>
            f.analysisStatus == AnalysisStatus.analyzed &&
            f.analysis?.hasError != true)
        .map((f) => ImportQueueItem(
              id: f.id,
              fileName: f.name,
              totalCount: f.analysis?.rowCount ?? 0,
            ))
        .toList();
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
