import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/services/storage/secure_storage_service.dart';
import '../../data/models/report_task_info.dart';
import '../../data/models/report_task_response.dart';
import '../../data/repositories/reports_repository.dart';
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
    on<ReportsDialogDismissed>(_onDialogDismissed);
  }

  final ReportsRepository _repository;
  final ReportActivityCoordinator _activityCoordinator =
      ReportActivityCoordinator.instance;
  final SecureStorageService _storage = getIt<SecureStorageService>();
  Timer? _pollTimer;
  Duration? _currentPollInterval;

  static const Duration _defaultPollInterval = Duration(seconds: 2);
  static const Duration _restoredPollInterval = Duration(seconds: 1);

  Future<void> _onInitializeRequested(
    ReportsInitializeRequested event,
    Emitter<ReportsState> emit,
  ) async {
    if (_hasTrackedTaskInState) {
      return;
    }

    try {
      final tasks = await _repository.fetchTasks();
      final activeTask = _selectActiveReportTask(tasks);
      if (activeTask != null) {
        await _rememberTrackedTask(activeTask.id);
        _emitRunningState(activeTask, emit);
        _setPollingInterval(_restoredPollInterval);
        return;
      }

      final trackedTaskId = await _readTrackedTaskId();
      if (trackedTaskId == null || trackedTaskId.isEmpty) {
        return;
      }

      final trackedTask = await _fetchTaskWithListData(trackedTaskId);
      await _rememberTrackedTask(trackedTask.id);
      _emitTaskState(trackedTask, emit);
    } catch (_) {
      // Ignore initialization failures and leave the page usable.
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
    _stopPolling();
    _activityCoordinator.show(
      title: 'Raporttia käynnistetään',
      status: 'Lähetetään pyyntöä palvelimelle...',
    );
    emit(state.copyWith(
      runStatus: ReportsRunStatus.submitting,
      statusMessage: 'Raporttia käynnistetään...',
      errorMessage: null,
      resultFileName: null,
      resultUrl: null,
      sharepointError: null,
      cancelRequested: false,
    ));

    try {
      final response = await _repository.startReport(
        tarkastelupvm: state.tarkastelupvm.trim().isEmpty ? '0' : state.tarkastelupvm.trim(),
        kunta: state.kunta,
        huoneistomaara: state.huoneistomaara,
        taajama: state.taajama,
        kohdeTyyppi: state.kohdeTyyppi,
        onkoViemari: state.onkoViemari,
      );

      emit(state.copyWith(
        runStatus: ReportsRunStatus.running,
        currentTaskId: response.taskId,
        currentDescription: response.description,
        statusMessage: response.message,
        errorMessage: null,
        resultFileName: null,
        resultUrl: null,
        sharepointError: null,
        cancelRequested: false,
      ));
      await _rememberTrackedTask(response.taskId);
      _activityCoordinator.show(
        title: 'Raportin luonti käynnissä',
        status: response.message,
        taskId: response.taskId,
      );
      _setPollingInterval(_defaultPollInterval);
    } catch (e) {
      _activityCoordinator.clear();
      emit(state.copyWith(
        runStatus: ReportsRunStatus.failed,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
        statusMessage: null,
        cancelRequested: false,
      ));
    }
  }

  Future<void> _onStatusPollRequested(
    ReportsStatusPollRequested event,
    Emitter<ReportsState> emit,
  ) async {
    final taskId = state.currentTaskId;
    if (taskId == null || taskId.isEmpty) {
      _stopPolling();
      return;
    }

    try {
      final task = await _fetchTaskWithListData(taskId);
      _emitTaskState(task, emit, cancelRequested: state.cancelRequested);
    } catch (e) {
      _stopPolling();
      _activityCoordinator.clear(taskId: taskId);
      emit(state.copyWith(
        runStatus: ReportsRunStatus.failed,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onCancelRequested(
    ReportsCancelRequested event,
    Emitter<ReportsState> emit,
  ) async {
    final taskId = state.currentTaskId;
    if (taskId == null || taskId.isEmpty) {
      return;
    }

    emit(state.copyWith(
      runStatus: ReportsRunStatus.cancelling,
      cancelRequested: true,
      statusMessage: 'Peruutetaan raportin luontia...',
      errorMessage: null,
    ));
    _activityCoordinator.show(
      title: 'Raporttia peruutetaan',
      status: 'Peruutetaan raportin luontia...',
      taskId: taskId,
    );

    try {
      final message = await _repository.cancelTask(taskId);
      _activityCoordinator.show(
        title: 'Raporttia peruutetaan',
        status: message,
        taskId: taskId,
      );
      emit(state.copyWith(
        runStatus: ReportsRunStatus.cancelling,
        cancelRequested: true,
        statusMessage: message,
      ));
      add(const ReportsStatusPollRequested());
    } catch (e) {
      _stopPolling();
      _activityCoordinator.clear(taskId: taskId);
      emit(state.copyWith(
        runStatus: ReportsRunStatus.failed,
        cancelRequested: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  void _onDialogDismissed(
    ReportsDialogDismissed event,
    Emitter<ReportsState> emit,
  ) {
    _stopPolling();
    _activityCoordinator.clear(taskId: state.currentTaskId);
    unawaited(_forgetTrackedTask());
    emit(state.copyWith(runStatus: ReportsRunStatus.idle, clearTransient: true));
  }

  bool get _hasTrackedTaskInState {
    final taskId = state.currentTaskId;
    return taskId != null && taskId.isNotEmpty;
  }

  void _setPollingInterval(Duration interval) {
    _startPollingInternal(interval: interval, triggerImmediately: true);
  }

  void _startPollingInternal({
    required Duration interval,
    required bool triggerImmediately,
  }) {
    if (_pollTimer != null && _currentPollInterval == interval) {
      if (triggerImmediately) {
        add(const ReportsStatusPollRequested());
      }
      return;
    }

    _stopPolling();
    _currentPollInterval = interval;
    _pollTimer = Timer.periodic(interval, (_) {
      add(const ReportsStatusPollRequested());
    });
    if (triggerImmediately) {
      add(const ReportsStatusPollRequested());
    }
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _currentPollInterval = null;
  }

  String _buildProgressMessage(ReportTaskInfo task, bool cancelRequested) {
    if (cancelRequested) {
      return task.latestOutputLine ?? 'Peruutuspyyntö lähetetty. Odotetaan palvelimen kuittausta...';
    }
    return task.latestOutputLine ??
        (task.description.isNotEmpty
            ? task.description
            : 'Raporttia muodostetaan...');
  }

  String _buildCompletedMessage(ReportTaskInfo task) {
    if (task.resultFile?.sharepointUrl != null) {
      return 'Raportti on luotu ja tallennettu SharePointiin.';
    }
    if (task.resultFile?.filename != null) {
      return 'Raportti on luotu. Odotetaan SharePoint-linkkiä...';
    }
    return task.latestOutputLine ?? 'Raportti on valmis. Odotetaan SharePoint-linkkiä...';
  }

  String _buildFailedMessage(ReportTaskInfo task) {
    return task.latestErrorLine ??
        task.latestOutputLine ??
        'Raportin luonti epäonnistui.';
  }

  void _emitTaskState(
    ReportTaskInfo task,
    Emitter<ReportsState> emit,
    {bool cancelRequested = false}
  ) {
    switch (task.status) {
      case ReportTaskStatus.pending:
      case ReportTaskStatus.running:
        if (_pollTimer == null) {
          _startPollingInternal(
            interval: _restoredPollInterval,
            triggerImmediately: false,
          );
        }
        _emitRunningState(task, emit, cancelRequested: cancelRequested);
        return;
      case ReportTaskStatus.completed:
        _emitCompletedState(task, emit);
        return;
      case ReportTaskStatus.failed:
        _emitFailedState(task, emit, cancelRequested: cancelRequested);
        return;
    }
  }

  void _emitRunningState(
    ReportTaskInfo task,
    Emitter<ReportsState> emit, {
    bool cancelRequested = false,
  }) {
    final progressMessage = _buildProgressMessage(task, cancelRequested);
    final runStatus = cancelRequested
        ? ReportsRunStatus.cancelling
        : ReportsRunStatus.running;

    _activityCoordinator.show(
      title: cancelRequested ? 'Raporttia peruutetaan' : 'Raportin luonti käynnissä',
      status: progressMessage,
      taskId: task.id,
    );
    emit(_copyTaskData(
      task,
      state.copyWith(
        runStatus: runStatus,
        statusMessage: progressMessage,
        errorMessage: null,
        cancelRequested: cancelRequested,
      ),
    ));
  }

  void _emitCompletedState(
    ReportTaskInfo task,
    Emitter<ReportsState> emit,
  ) {
    _activityCoordinator.clear(taskId: task.id);
    if (_hasSharepointUrl(task)) {
      _stopPolling();
    } else if (_currentPollInterval != _restoredPollInterval) {
      _startPollingInternal(
        interval: _restoredPollInterval,
        triggerImmediately: false,
      );
    }

    emit(_copyTaskData(
      task,
      state.copyWith(
        runStatus: ReportsRunStatus.completed,
        statusMessage: _buildCompletedMessage(task),
        errorMessage: null,
        cancelRequested: false,
      ),
    ));
  }

  void _emitFailedState(
    ReportTaskInfo task,
    Emitter<ReportsState> emit, {
    bool cancelRequested = false,
  }) {
    _stopPolling();
    _activityCoordinator.clear(taskId: task.id);
    final wasCancelled = cancelRequested ||
        task.error.contains('pysäytettiin käyttäjän pyynnöstä');

    emit(_copyTaskData(
      task,
      state.copyWith(
        runStatus: ReportsRunStatus.failed,
        statusMessage: null,
        errorMessage: wasCancelled
            ? 'Raportin luonti peruttiin.'
            : _buildFailedMessage(task),
        cancelRequested: false,
      ),
    ));
  }

  ReportsState _copyTaskData(ReportTaskInfo task, ReportsState nextState) {
    return nextState.copyWith(
      currentTaskId: task.id,
      currentDescription: task.description,
      resultFileName: task.resultFile?.filename,
      resultUrl: task.resultFile?.sharepointUrl,
      sharepointError: task.resultFile?.sharepointError,
    );
  }

  bool _hasSharepointUrl(ReportTaskInfo task) {
    final sharepointUrl = task.resultFile?.sharepointUrl;
    return sharepointUrl != null && sharepointUrl.isNotEmpty;
  }

  Future<ReportTaskInfo> _fetchTaskWithListData(String taskId) async {
    try {
      final tasks = await _repository.fetchTasks();
      for (final task in tasks) {
        if (task.id == taskId) {
          return task;
        }
      }
    } catch (_) {
      // Fall back to single-task fetch if list fetch fails.
    }

    return _repository.fetchTask(taskId);
  }

  Future<void> _rememberTrackedTask(String taskId) {
    return _storage.write(
      key: AppConstants.storageKeyTrackedReportTaskId,
      value: taskId,
    );
  }

  Future<String?> _readTrackedTaskId() {
    return _storage.read(key: AppConstants.storageKeyTrackedReportTaskId);
  }

  Future<void> _forgetTrackedTask() {
    return _storage.delete(key: AppConstants.storageKeyTrackedReportTaskId);
  }

  ReportTaskInfo? _selectActiveReportTask(List<ReportTaskInfo> tasks) {
    final activeTasks = tasks.where(_isActiveReportTask).toList();
    if (activeTasks.isEmpty) {
      return null;
    }

    for (final task in activeTasks) {
      if (task.status == ReportTaskStatus.running) {
        return task;
      }
    }

    return activeTasks.first;
  }

  bool _isActiveReportTask(ReportTaskInfo task) {
    final isActive = task.status == ReportTaskStatus.pending ||
        task.status == ReportTaskStatus.running;
    final isReportCommand = task.command.startsWith('jkr raportti ');
    final isReportDescription = task.description.startsWith('Raportti:');
    return isActive && (isReportCommand || isReportDescription);
  }

  @override
  Future<void> close() {
    _stopPolling();
    _activityCoordinator.clear(taskId: state.currentTaskId);
    return super.close();
  }
}