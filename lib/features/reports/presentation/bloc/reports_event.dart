import 'package:flutter/widgets.dart';

import 'package:equatable/equatable.dart';

// Base event types shared by the reports feature.
abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

// Generic value-change event used by simple filter fields.
abstract class ReportsValueChanged<T> extends ReportsEvent {
  const ReportsValueChanged(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

// Filter field events.
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

// Lifecycle and task events.
class ReportsInitializeRequested extends ReportsEvent {
  const ReportsInitializeRequested({this.locale});

  final Locale? locale;

  @override
  List<Object?> get props => [locale];
}

class ReportsRunRequested extends ReportsEvent {
  const ReportsRunRequested({this.locale});

  final Locale? locale;

  @override
  List<Object?> get props => [locale];
}

class ReportsStatusPollRequested extends ReportsEvent {
  const ReportsStatusPollRequested();
}

// Per-run UI interaction events.
class ReportsCancelRequested extends ReportsEvent {
  const ReportsCancelRequested(this.runId, {this.locale});

  final String runId;
  final Locale? locale;

  @override
  List<Object?> get props => [runId, locale];
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