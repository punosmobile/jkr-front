import 'package:flutter_bloc/flutter_bloc.dart';

class TaskActivityState {
  const TaskActivityState({
    this.isImportActive = false,
    this.isReportActive = false,
  });

  final bool isImportActive;
  final bool isReportActive;

  TaskActivityState copyWith({
    bool? isImportActive,
    bool? isReportActive,
  }) {
    return TaskActivityState(
      isImportActive: isImportActive ?? this.isImportActive,
      isReportActive: isReportActive ?? this.isReportActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is TaskActivityState &&
        other.isImportActive == isImportActive &&
        other.isReportActive == isReportActive;
  }

  @override
  int get hashCode => Object.hash(isImportActive, isReportActive);
}

class TaskActivityCubit extends Cubit<TaskActivityState> {
  TaskActivityCubit() : super(const TaskActivityState());

  void update({
    required bool isImportActive,
    required bool isReportActive,
  }) {
    final nextState = state.copyWith(
      isImportActive: isImportActive,
      isReportActive: isReportActive,
    );

    if (nextState != state) {
      emit(nextState);
    }
  }
}