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
