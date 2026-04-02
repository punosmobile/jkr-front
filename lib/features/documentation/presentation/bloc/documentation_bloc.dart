import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/db_column_doc.dart';
import '../../data/repositories/documentation_repository.dart';
import 'documentation_event.dart';
import 'documentation_state.dart';

class DocumentationBloc extends Bloc<DocumentationEvent, DocumentationState> {
  final DocumentationRepository _repository;

  DocumentationBloc({required DocumentationRepository repository})
      : _repository = repository,
        super(const DocumentationState()) {
    on<DocumentationLoadRequested>(_onLoadRequested);
    on<DocumentationSearchChanged>(_onSearchChanged);
  }

  Future<void> _onLoadRequested(
    DocumentationLoadRequested event,
    Emitter<DocumentationState> emit,
  ) async {
    emit(state.copyWith(status: DocumentationStatus.loading));
    try {
      final rows = await _repository.fetchDocumentation();
      final schemas = DocumentationRepository.groupBySchema(rows);
      emit(state.copyWith(
        status: DocumentationStatus.loaded,
        allRows: rows,
        schemas: schemas,
        searchQuery: '',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DocumentationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSearchChanged(
    DocumentationSearchChanged event,
    Emitter<DocumentationState> emit,
  ) {
    final query = event.query.toLowerCase().trim();
    if (query.isEmpty) {
      final schemas = DocumentationRepository.groupBySchema(state.allRows);
      emit(state.copyWith(searchQuery: '', schemas: schemas));
      return;
    }

    final filtered = state.allRows.where((r) {
      return r.skeema.toLowerCase().contains(query) ||
          r.taulu.toLowerCase().contains(query) ||
          r.kentta.toLowerCase().contains(query) ||
          (r.taulunKommentti ?? '').toLowerCase().contains(query) ||
          (r.kentanKommentti ?? '').toLowerCase().contains(query) ||
          (r.tyyppi ?? '').toLowerCase().contains(query);
    }).toList();

    final schemas = DocumentationRepository.groupBySchema(filtered);
    emit(state.copyWith(searchQuery: query, schemas: schemas));
  }
}
