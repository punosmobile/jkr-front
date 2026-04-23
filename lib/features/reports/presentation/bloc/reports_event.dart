import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

abstract class ReportsValueChanged<T> extends ReportsEvent {
  const ReportsValueChanged(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

class ReportsDateChanged extends ReportsValueChanged<String> {
  const ReportsDateChanged(super.value);
}

class ReportsMunicipalityChanged extends ReportsValueChanged<String> {
  const ReportsMunicipalityChanged(super.value);
}

class ReportsApartmentCountChanged extends ReportsValueChanged<int> {
  const ReportsApartmentCountChanged(super.value);
}

class ReportsUrbanAreaChanged extends ReportsValueChanged<int> {
  const ReportsUrbanAreaChanged(super.value);
}

class ReportsPropertyTypeChanged extends ReportsValueChanged<int> {
  const ReportsPropertyTypeChanged(super.value);
}

class ReportsSewerChanged extends ReportsValueChanged<int> {
  const ReportsSewerChanged(super.value);
}

class ReportsInitializeRequested extends ReportsEvent {
  const ReportsInitializeRequested();
}

class ReportsRunRequested extends ReportsEvent {
  const ReportsRunRequested();
}

class ReportsStatusPollRequested extends ReportsEvent {
  const ReportsStatusPollRequested();
}

class ReportsCancelRequested extends ReportsEvent {
  const ReportsCancelRequested(this.runId);

  final String runId;

  @override
  List<Object?> get props => [runId];
}

class ReportsRunDismissed extends ReportsEvent {
  const ReportsRunDismissed(this.runId);

  final String runId;

  @override
  List<Object?> get props => [runId];
}

class ReportsRunCollapseToggled extends ReportsEvent {
  const ReportsRunCollapseToggled(this.runId);

  final String runId;

  @override
  List<Object?> get props => [runId];
}