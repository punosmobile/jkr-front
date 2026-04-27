abstract class ImportEvent {
  const ImportEvent();
}

/// Load available files from Sharepoint.
class ImportLoadFiles extends ImportEvent {
  const ImportLoadFiles();
}

/// Toggle file selection.
class ImportToggleFile extends ImportEvent {
  final String fileId;
  const ImportToggleFile(this.fileId);
}

/// Select or deselect all files.
class ImportSetAllSelected extends ImportEvent {
  const ImportSetAllSelected(this.selected);
  final bool selected;
}

/// Run pre-analysis on selected files.
class ImportAnalyzeFiles extends ImportEvent {
  const ImportAnalyzeFiles();
}

/// Remove a file from the analysis queue.
class ImportRemoveAnalyzedFile extends ImportEvent {
  final String fileId;
  const ImportRemoveAnalyzedFile(this.fileId);
}

/// Reorder analyzed files in the import queue.
class ImportReorderFiles extends ImportEvent {
  final int oldIndex;
  final int newIndex;
  const ImportReorderFiles(this.oldIndex, this.newIndex);
}

/// Start the import process.
class ImportStartImport extends ImportEvent {
  const ImportStartImport();
}

/// Run velvoitetarkistus.
class ImportRunVelvoitetarkistus extends ImportEvent {
  final String date;
  const ImportRunVelvoitetarkistus(this.date);
}

/// Set velvoitteet.
class ImportSetVelvoitteet extends ImportEvent {
  const ImportSetVelvoitteet();
}

/// Upload a file manually.
class ImportUploadFile extends ImportEvent {
  final String fileName;
  const ImportUploadFile(this.fileName);
}

/// Update import active status based on backend task polling.
class ImportTaskStatusChanged extends ImportEvent {
  const ImportTaskStatusChanged(this.isActive);
  final bool isActive;
}
