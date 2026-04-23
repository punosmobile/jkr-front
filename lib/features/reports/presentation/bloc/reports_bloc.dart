import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/services/storage/secure_storage_service.dart';
import '../../data/models/report_task_info.dart';
import '../../data/models/report_task_response.dart';
import '../../data/repositories/reports_repository.dart';
import '../../report_localizations.dart';
import '../report_activity_coordinator.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  ReportsBloc({required ReportsRepository repository})
      : _repository = repository,
        super(const ReportsState()) {
    on<ReportsInitializeRequested>(_onInitializeRequested);
    on<ReportsDateChanged>(_onDateChanged);
    on<ReportsMunicipalityChanged>(_onMunicipalityChanged);
    on<ReportsApartmentCountChanged>(_onApartmentCountChanged);
    on<ReportsUrbanAreaChanged>(_onUrbanAreaChanged);
    on<ReportsPropertyTypeChanged>(_onPropertyTypeChanged);
    on<ReportsSewerChanged>(_onSewerChanged);
    on<ReportsRunRequested>(_onRunRequested);
    on<ReportsStatusPollRequested>(_onStatusPollRequested);
    on<ReportsCancelRequested>(_onCancelRequested);
    on<ReportsRunDismissed>(_onRunDismissed);
    on<ReportsRunCollapseToggled>(_onRunCollapseToggled);
  }

  final ReportsRepository _repository;
  final ReportActivityCoordinator _activityCoordinator =
      ReportActivityCoordinator.instance;
  final SecureStorageService _storage = getIt<SecureStorageService>();

  Timer? _pollTimer;
  int _localRunSequence = 0;

  static const Duration _pollInterval = Duration(seconds: 1);

  Future<void> _onInitializeRequested(
    ReportsInitializeRequested event,
    Emitter<ReportsState> emit,
  ) async {
    if (state.reportRuns.isNotEmpty) {
      return;
    }

    try {
      final tasks = await _repository.fetchTasks();
      final trackedTaskIds = await _readTrackedTaskIds();
      final trackedTaskParams = await _readTrackedTaskParameters();
      final trackedTaskUiState = await _readTrackedTaskUiState();
      final reportTasks = tasks.where(_isReportTask).toList();
      final reportTaskById = {
        for (final task in reportTasks) task.id: task,
      };

      final restoredRuns = <ReportRunState>[];
      final seenIds = <String>{};

      for (final task in reportTasks.where((task) => _shouldRestoreTask(task, trackedTaskIds))) {
        restoredRuns.add(
          _runFromTask(
            task,
            existing: _restoredRunState(
              task.id,
              trackedTaskParams[task.id],
              isCollapsed: trackedTaskUiState[task.id] ?? false,
            ),
          ),
        );
        seenIds.add(task.id);
      }

      for (final taskId in trackedTaskIds) {
        if (seenIds.contains(taskId)) {
          continue;
        }
        final task = reportTaskById[taskId] ?? await _tryFetchTask(taskId);
        if (task == null || !_isReportTask(task)) {
          continue;
        }
        restoredRuns.add(
          _runFromTask(
            task,
            existing: _restoredRunState(
              task.id,
              trackedTaskParams[task.id],
              isCollapsed: trackedTaskUiState[task.id] ?? false,
            ),
          ),
        );
        seenIds.add(task.id);
      }

      final nextState = state.copyWith(reportRuns: restoredRuns);
      _emitRunState(emit, nextState);
    } catch (_) {
      _syncActivityCoordinator(state);
    }
  }

  void _onDateChanged(
    ReportsDateChanged event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(tarkastelupvm: event.value));
  }

  void _onMunicipalityChanged(
    ReportsMunicipalityChanged event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(kunta: event.value));
  }

  void _onApartmentCountChanged(
    ReportsApartmentCountChanged event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(huoneistomaara: event.value));
  }

  void _onUrbanAreaChanged(
    ReportsUrbanAreaChanged event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(taajama: event.value));
  }

  void _onPropertyTypeChanged(
    ReportsPropertyTypeChanged event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(kohdeTyyppi: event.value));
  }

  void _onSewerChanged(
    ReportsSewerChanged event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(onkoViemari: event.value));
  }

  Future<void> _onRunRequested(
    ReportsRunRequested event,
    Emitter<ReportsState> emit,
  ) async {
    final localRunId = _nextLocalRunId();
    final l10n = currentReportLocalizations();
    final parameters = ReportRunParameters(
      tarkastelupvm: state.tarkastelupvm.trim(),
      kunta: state.kunta,
      huoneistomaara: state.huoneistomaara,
      taajama: state.taajama,
      kohdeTyyppi: state.kohdeTyyppi,
      onkoViemari: state.onkoViemari,
    );
    final submittingRun = ReportRunState(
      id: localRunId,
      parameters: parameters,
      runStatus: ReportsRunStatus.submitting,
      description: l10n.reportsBlocStartDescription,
      statusMessage: l10n.reportsBlocSubmittingStatus,
      lastUpdatedAt: DateTime.now(),
    );

    _emitRunState(
      emit,
      state.copyWith(reportRuns: [submittingRun, ...state.reportRuns]),
    );

    try {
      final response = await _repository.startReport(
        tarkastelupvm: state.tarkastelupvm.trim().isEmpty ? '0' : state.tarkastelupvm.trim(),
        kunta: state.kunta,
        huoneistomaara: state.huoneistomaara,
        taajama: state.taajama,
        kohdeTyyppi: state.kohdeTyyppi,
        onkoViemari: state.onkoViemari,
      );

      final nextState = _updateRun(
        localRunId,
        (run) => run.copyWith(
          taskId: response.taskId,
          description: response.description,
          parameters: parameters,
          runStatus: ReportsRunStatus.running,
          statusMessage: response.message,
          errorMessage: null,
          resultFileName: null,
          resultUrl: null,
          sharepointError: null,
          cancelRequested: false,
          isCollapsed: false,
          lastUpdatedAt: DateTime.now(),
        ),
      );
      _emitRunState(emit, nextState);
    } catch (e) {
      final nextState = _updateRun(
        localRunId,
        (run) => run.copyWith(
          runStatus: ReportsRunStatus.failed,
          statusMessage: null,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
          cancelRequested: false,
          lastUpdatedAt: DateTime.now(),
        ),
      );
      _emitRunState(emit, nextState);
    }
  }

  Future<void> _onStatusPollRequested(
    ReportsStatusPollRequested event,
    Emitter<ReportsState> emit,
  ) async {
    final trackedTaskIds = state.reportRuns
        .map((run) => run.taskId)
        .whereType<String>()
        .toSet();
    if (trackedTaskIds.isEmpty) {
      _syncPolling(state);
      return;
    }

    try {
      final tasks = await _repository.fetchTasks();
      final reportTaskById = {
        for (final task in tasks.where(_isReportTask)) task.id: task,
      };

      final missingTaskIds = trackedTaskIds.where((taskId) => !reportTaskById.containsKey(taskId));
      for (final taskId in missingTaskIds) {
        final task = await _tryFetchTask(taskId);
        if (task != null && _isReportTask(task)) {
          reportTaskById[taskId] = task;
        }
      }

      final updatedRuns = state.reportRuns.map((run) {
        final taskId = run.taskId;
        if (taskId == null || taskId.isEmpty) {
          return run;
        }
        final task = reportTaskById[taskId];
        if (task == null) {
          return run;
        }
        return _runFromTask(task, existing: run);
      }).toList(growable: false);

      _emitRunState(emit, state.copyWith(reportRuns: updatedRuns));
    } catch (_) {
      _syncPolling(state);
    }
  }

  Future<void> _onCancelRequested(
    ReportsCancelRequested event,
    Emitter<ReportsState> emit,
  ) async {
    final l10n = currentReportLocalizations();
    final run = _findRun(event.runId);
    final taskId = run?.taskId;
    if (run == null || taskId == null || taskId.isEmpty) {
      return;
    }

    _emitRunState(
      emit,
      _updateRun(
        event.runId,
        (current) => current.copyWith(
          runStatus: ReportsRunStatus.cancelling,
          cancelRequested: true,
          statusMessage: l10n.reportsBlocCancellingStatus,
          errorMessage: null,
          lastUpdatedAt: DateTime.now(),
        ),
      ),
    );

    try {
      final message = await _repository.cancelTask(taskId);
      _emitRunState(
        emit,
        _updateRun(
          event.runId,
          (current) => current.copyWith(
            runStatus: ReportsRunStatus.cancelling,
            cancelRequested: true,
            statusMessage: message,
            lastUpdatedAt: DateTime.now(),
          ),
        ),
      );
      add(const ReportsStatusPollRequested());
    } catch (e) {
      _emitRunState(
        emit,
        _updateRun(
          event.runId,
          (current) => current.copyWith(
            runStatus: ReportsRunStatus.failed,
            cancelRequested: false,
            statusMessage: null,
            errorMessage: e.toString().replaceFirst('Exception: ', ''),
            lastUpdatedAt: DateTime.now(),
          ),
        ),
      );
    }
  }

  void _onRunDismissed(
    ReportsRunDismissed event,
    Emitter<ReportsState> emit,
  ) {
    final nextRuns = state.reportRuns
        .where((run) => run.id != event.runId)
        .toList(growable: false);
    _emitRunState(emit, state.copyWith(reportRuns: nextRuns));
  }

  void _onRunCollapseToggled(
    ReportsRunCollapseToggled event,
    Emitter<ReportsState> emit,
  ) {
    final nextState = _updateRun(
      event.runId,
      (run) => run.copyWith(isCollapsed: !run.isCollapsed),
    );
    _emitRunState(emit, nextState);
  }

  ReportsState _updateRun(
    String runId,
    ReportRunState Function(ReportRunState run) update,
  ) {
    final nextRuns = state.reportRuns.map((run) {
      if (run.id != runId) {
        return run;
      }
      return update(run);
    }).toList(growable: false);

    return state.copyWith(reportRuns: nextRuns);
  }

  ReportRunState? _findRun(String runId) {
    for (final run in state.reportRuns) {
      if (run.id == runId) {
        return run;
      }
    }
    return null;
  }

  void _emitRunState(
    Emitter<ReportsState> emit,
    ReportsState nextState, {
    bool persistTrackedIds = true,
  }) {
    emit(nextState);
    _syncActivityCoordinator(nextState);
    _syncPolling(nextState);
    if (persistTrackedIds) {
      unawaited(_persistTrackedRunMetadata(nextState.reportRuns));
    }
  }

  ReportRunState _restoredRunState(
    String taskId,
    ReportRunParameters? parameters,
    {
    required bool isCollapsed,
  }
  ) {
    return ReportRunState(
      id: taskId,
      taskId: taskId,
      parameters: parameters,
      runStatus: ReportsRunStatus.idle,
      isCollapsed: isCollapsed,
      lastUpdatedAt: DateTime.now(),
    );
  }

  void _syncPolling(ReportsState nextState) {
    final shouldPoll = nextState.reportRuns.any(
      (run) => run.shouldPoll && run.taskId != null && run.taskId!.isNotEmpty,
    );

    if (!shouldPoll) {
      _stopPolling();
      return;
    }

    if (_pollTimer != null) {
      return;
    }

    _pollTimer = Timer.periodic(_pollInterval, (_) {
      add(const ReportsStatusPollRequested());
    });
    add(const ReportsStatusPollRequested());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _syncActivityCoordinator(ReportsState nextState) {
    final l10n = currentReportLocalizations();
    final activeRuns = nextState.reportRuns.where((run) => run.isActive).toList();
    if (activeRuns.isEmpty) {
      _activityCoordinator.clear();
      return;
    }

    final primaryRun = activeRuns.first;
    final title = activeRuns.length == 1
        ? (primaryRun.runStatus == ReportsRunStatus.submitting
        ? l10n.reportsRunStatusStarting
        : l10n.reportsBannerSingleActive)
      : l10n.reportsBannerMultipleActive(activeRuns.length);

    _activityCoordinator.show(
      title: title,
      status: primaryRun.statusMessage ?? primaryRun.description,
      taskId: primaryRun.taskId,
    );
  }

  ReportRunState _runFromTask(
    ReportTaskInfo task, {
    ReportRunState? existing,
  }) {
    final isCancelling = existing?.cancelRequested == true;

    switch (task.status) {
      case ReportTaskStatus.pending:
      case ReportTaskStatus.running:
        return ReportRunState(
          id: existing?.id ?? task.id,
          taskId: task.id,
          description: task.description,
          parameters: existing?.parameters,
          runStatus: isCancelling
              ? ReportsRunStatus.cancelling
              : ReportsRunStatus.running,
          statusMessage: _buildProgressMessage(task, isCancelling),
          errorMessage: null,
          resultFileName: task.resultFile?.filename,
          resultUrl: task.resultFile?.sharepointUrl,
          sharepointError: task.resultFile?.sharepointError,
          cancelRequested: isCancelling,
          isCollapsed: existing?.isCollapsed ?? false,
          lastUpdatedAt: DateTime.now(),
        );
      case ReportTaskStatus.completed:
        return ReportRunState(
          id: existing?.id ?? task.id,
          taskId: task.id,
          description: task.description,
          parameters: existing?.parameters,
          runStatus: ReportsRunStatus.completed,
          statusMessage: _buildCompletedMessage(task),
          errorMessage: null,
          resultFileName: task.resultFile?.filename,
          resultUrl: task.resultFile?.sharepointUrl,
          sharepointError: task.resultFile?.sharepointError,
          cancelRequested: false,
          isCollapsed: existing?.isCollapsed ?? false,
          lastUpdatedAt: DateTime.now(),
        );
      case ReportTaskStatus.failed:
        final wasCancelled = isCancelling ||
            task.error.contains('pysäytettiin käyttäjän pyynnöstä');
        return ReportRunState(
          id: existing?.id ?? task.id,
          taskId: task.id,
          description: task.description,
          parameters: existing?.parameters,
          runStatus: ReportsRunStatus.failed,
          statusMessage: null,
          errorMessage: wasCancelled
              ? currentReportLocalizations().reportsBlocCancelled
              : _buildFailedMessage(task),
          resultFileName: task.resultFile?.filename,
          resultUrl: task.resultFile?.sharepointUrl,
          sharepointError: task.resultFile?.sharepointError,
          cancelRequested: false,
          isCollapsed: existing?.isCollapsed ?? false,
          lastUpdatedAt: DateTime.now(),
        );
    }
  }

  String _buildProgressMessage(ReportTaskInfo task, bool cancelRequested) {
    final l10n = currentReportLocalizations();
    if (cancelRequested) {
      return task.latestOutputLine ??
          l10n.reportsBlocCancelPending;
    }
    return task.latestOutputLine ??
        (task.description.isNotEmpty
            ? task.description
            : l10n.reportsBlocProgressFallback);
  }

  String _buildCompletedMessage(ReportTaskInfo task) {
    final l10n = currentReportLocalizations();
    if (_hasSharepointUrl(task)) {
      return l10n.reportsBlocCompletedStoredSharepoint;
    }
    if (task.resultFile?.filename != null) {
      return l10n.reportsBlocCompletedWaitingLink;
    }
    return task.latestOutputLine ??
        l10n.reportsBlocCompletedReadyWaitingLink;
  }

  String _buildFailedMessage(ReportTaskInfo task) {
    final l10n = currentReportLocalizations();
    return task.latestErrorLine ??
        task.latestOutputLine ??
        l10n.reportsBlocFailedGeneric;
  }

  bool _shouldRestoreTask(ReportTaskInfo task, List<String> trackedTaskIds) {
    return _isActiveReportTask(task) || trackedTaskIds.contains(task.id);
  }

  bool _isActiveReportTask(ReportTaskInfo task) {
    return task.isActive && _isReportTask(task);
  }

  bool _isReportTask(ReportTaskInfo task) {
    return task.isReportTask;
  }

  bool _hasSharepointUrl(ReportTaskInfo task) {
    final sharepointUrl = task.resultFile?.sharepointUrl;
    return sharepointUrl != null && sharepointUrl.isNotEmpty;
  }

  String _nextLocalRunId() {
    _localRunSequence += 1;
    return 'local-report-run-$_localRunSequence';
  }

  Future<ReportTaskInfo?> _tryFetchTask(String taskId) async {
    try {
      return await _repository.fetchTask(taskId);
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> _readTrackedTaskIds() async {
    final rawValue = await _storage.read(
      key: AppConstants.storageKeyTrackedReportTaskId,
    );
    if (rawValue == null || rawValue.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is List) {
        return decoded.whereType<String>().where((value) => value.isNotEmpty).toList();
      }
    } catch (_) {
      // Fall back to the legacy single-id storage format.
    }

    return [rawValue];
  }

  Future<Map<String, ReportRunParameters>> _readTrackedTaskParameters() async {
    final rawValue = await _storage.read(
      key: AppConstants.storageKeyTrackedReportTaskParams,
    );
    if (rawValue == null || rawValue.isEmpty) {
      return const {};
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map) {
        return const {};
      }

      final result = <String, ReportRunParameters>{};
      for (final entry in decoded.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is! String || value is! Map) {
          continue;
        }
        result[key] = ReportRunParameters.fromJson(
          Map<String, dynamic>.from(value),
        );
      }
      return result;
    } catch (_) {
      return const {};
    }
  }

  Future<Map<String, bool>> _readTrackedTaskUiState() async {
    final rawValue = await _storage.read(
      key: AppConstants.storageKeyTrackedReportTaskUi,
    );
    if (rawValue == null || rawValue.isEmpty) {
      return const {};
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map) {
        return const {};
      }

      final result = <String, bool>{};
      for (final entry in decoded.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is! String || value is! bool) {
          continue;
        }
        result[key] = value;
      }
      return result;
    } catch (_) {
      return const {};
    }
  }

  Future<void> _persistTrackedRunMetadata(List<ReportRunState> runs) async {
    final taskIds = runs
        .map((run) => run.taskId)
        .whereType<String>()
        .where((taskId) => taskId.isNotEmpty)
        .toSet()
        .toList(growable: false);

    final taskParams = <String, Map<String, dynamic>>{};
    final taskUiState = <String, bool>{};
    for (final run in runs) {
      final taskId = run.taskId;
      if (taskId == null || taskId.isEmpty) {
        continue;
      }
      if (run.parameters != null) {
        taskParams[taskId] = run.parameters!.toJson();
      }
      taskUiState[taskId] = run.isCollapsed;
    }

    if (taskIds.isEmpty) {
      await _storage.delete(key: AppConstants.storageKeyTrackedReportTaskId);
      await _storage.delete(key: AppConstants.storageKeyTrackedReportTaskParams);
      await _storage.delete(key: AppConstants.storageKeyTrackedReportTaskUi);
      return;
    }

    await _storage.write(
      key: AppConstants.storageKeyTrackedReportTaskId,
      value: jsonEncode(taskIds),
    );
    await _storage.write(
      key: AppConstants.storageKeyTrackedReportTaskParams,
      value: jsonEncode(taskParams),
    );
    await _storage.write(
      key: AppConstants.storageKeyTrackedReportTaskUi,
      value: jsonEncode(taskUiState),
    );
  }

  @override
  Future<void> close() {
    _stopPolling();
    _activityCoordinator.clear();
    return super.close();
  }
}
