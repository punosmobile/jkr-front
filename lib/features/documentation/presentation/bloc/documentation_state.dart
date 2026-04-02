import 'package:equatable/equatable.dart';

import '../../data/models/db_column_doc.dart';

enum DocumentationStatus { initial, loading, loaded, error }

class DocumentationState extends Equatable {
  final DocumentationStatus status;
  final List<DbColumnDoc> allRows;
  final List<SchemaDoc> schemas;
  final String searchQuery;
  final String? errorMessage;

  const DocumentationState({
    this.status = DocumentationStatus.initial,
    this.allRows = const [],
    this.schemas = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  int get schemaCount => schemas.length;
  int get tableCount => schemas.fold(0, (sum, s) => sum + s.tables.length);
  int get columnCount => allRows.length;

  DocumentationState copyWith({
    DocumentationStatus? status,
    List<DbColumnDoc>? allRows,
    List<SchemaDoc>? schemas,
    String? searchQuery,
    String? errorMessage,
  }) {
    return DocumentationState(
      status: status ?? this.status,
      allRows: allRows ?? this.allRows,
      schemas: schemas ?? this.schemas,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, allRows, schemas, searchQuery, errorMessage];
}
