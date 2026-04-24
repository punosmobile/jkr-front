enum AppTaskType {
  report,
  importTask,
  exportTask,
  sync,
  maintenance,
  generic,
  unknown;

  static AppTaskType fromApiValue(
    String? value, {
    String? command,
    String? description,
  }) {
    final normalized = value?.trim().toLowerCase();

    switch (normalized) {
      case 'report':
        return AppTaskType.report;
      case 'import':
        return AppTaskType.importTask;
      case 'export':
        return AppTaskType.exportTask;
      case 'sync':
        return AppTaskType.sync;
      case 'maintenance':
        return AppTaskType.maintenance;
      case 'generic':
        return AppTaskType.generic;
      case 'unknown':
        return AppTaskType.unknown;
    }

    // Legacy compatibility fallback while older task payloads are still in use.
    if (normalized == null || normalized.isEmpty) {
      final normalizedCommand = command?.trim().toLowerCase() ?? '';
      final normalizedDescription = description?.trim().toLowerCase() ?? '';
      if (normalizedCommand.startsWith('jkr raportti ') ||
          normalizedDescription.startsWith('raportti:')) {
        return AppTaskType.report;
      }
    }

    return AppTaskType.unknown;
  }

  bool get isReport => this == AppTaskType.report;

  String get apiValue {
    return switch (this) {
      AppTaskType.report => 'report',
      AppTaskType.importTask => 'import',
      AppTaskType.exportTask => 'export',
      AppTaskType.sync => 'sync',
      AppTaskType.maintenance => 'maintenance',
      AppTaskType.generic => 'generic',
      AppTaskType.unknown => 'unknown',
    };
  }
}