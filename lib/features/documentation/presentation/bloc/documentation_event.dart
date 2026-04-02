import 'package:equatable/equatable.dart';

abstract class DocumentationEvent extends Equatable {
  const DocumentationEvent();

  @override
  List<Object?> get props => [];
}

class DocumentationLoadRequested extends DocumentationEvent {
  const DocumentationLoadRequested();
}

class DocumentationSearchChanged extends DocumentationEvent {
  final String query;
  const DocumentationSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}
