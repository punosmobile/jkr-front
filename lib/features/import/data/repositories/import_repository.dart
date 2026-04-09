import '../models/import_file.dart';
import '../models/import_queue_item.dart';

/// Repository for import operations.
/// All methods return stub/dummy data for now — no backend calls.
class ImportRepository {
  /// Fetch available files from Sharepoint.
  Future<List<ImportFile>> fetchSharepointFiles() async {
    // TODO: Replace with real API call
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      ImportFile(
        id: '1',
        name: 'DVV_Q1_2025.csv',
        size: '2,4 Mt',
        badge: ImportFileBadge.uusi,
        selected: true,
      ),
      ImportFile(
        id: '2',
        name: 'Kuljetustiedot_Q1_2025.csv',
        size: '8,1 Mt',
        badge: ImportFileBadge.paivitys,
        selected: true,
      ),
      ImportFile(
        id: '3',
        name: 'Paatostiedot_Q4_2024.xlsx',
        size: '1,1 Mt',
        badge: ImportFileBadge.tarkista,
      ),
      ImportFile(
        id: '4',
        name: 'Kompostointi_Q1_2025.xlsx',
        size: '0,4 Mt',
        badge: ImportFileBadge.uusi,
      ),
    ];
  }

  /// Run pre-analysis on selected files.
  Future<List<ImportFile>> analyzeFiles(List<ImportFile> files) async {
    // TODO: Replace with real API call
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
