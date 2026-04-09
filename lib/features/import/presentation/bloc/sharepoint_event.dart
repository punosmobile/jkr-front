abstract class SharepointEvent {
  const SharepointEvent();
}

/// Initial load: check status + load root folder.
class SharepointInitRequested extends SharepointEvent {
  const SharepointInitRequested();
}

/// Navigate into a folder.
class SharepointFolderOpened extends SharepointEvent {
  final String folder;
  const SharepointFolderOpened(this.folder);
}

/// Go back to parent folder.
class SharepointNavigatedBack extends SharepointEvent {
  const SharepointNavigatedBack();
}

/// Refresh current folder contents.
class SharepointRefreshRequested extends SharepointEvent {
  const SharepointRefreshRequested();
}

/// Toggle file selection (checkbox).
class SharepointFileToggled extends SharepointEvent {
  final String fileName;
  const SharepointFileToggled(this.fileName);
}

/// Toggle all files selection.
class SharepointAllFilesToggled extends SharepointEvent {
  final bool selected;
  const SharepointAllFilesToggled(this.selected);
}

/// Pull a single file from SharePoint to backend server.
class SharepointPullOneRequested extends SharepointEvent {
  final String filePath;
  const SharepointPullOneRequested(this.filePath);
}

/// Pull all selected files from SharePoint to backend server.
class SharepointPullSelectedRequested extends SharepointEvent {
  const SharepointPullSelectedRequested();
}
