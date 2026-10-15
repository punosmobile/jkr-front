import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/card_container.dart';
import '../../data/models/db_column_doc.dart';
import '../../data/repositories/documentation_repository.dart';
import '../bloc/documentation_bloc.dart';
import '../bloc/documentation_event.dart';
import '../bloc/documentation_state.dart';

class DocumentationPage extends StatelessWidget {
  const DocumentationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DocumentationBloc(repository: DocumentationRepository())
        ..add(const DocumentationLoadRequested()),
      child: const _DocumentationView(),
    );
  }
}

class _DocumentationView extends StatelessWidget {
  const _DocumentationView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          // Toolbar: search + refresh + stats
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 34,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Hae skeemaa, taulua tai kenttää...',
                            hintStyle: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
                            prefixIcon: Icon(Icons.search, size: 16, color: AppTheme.textTertiary),
                            prefixIconConstraints: const BoxConstraints(minWidth: 34),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.20)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.20)),
                            ),
                            filled: true,
                            fillColor: AppTheme.background2,
                          ),
                          style: const TextStyle(fontSize: 12),
                          onChanged: (value) => context
                              .read<DocumentationBloc>()
                              .add(DocumentationSearchChanged(value)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => context
                          .read<DocumentationBloc>()
                          .add(const DocumentationLoadRequested()),
                      icon: const Icon(Icons.refresh, size: 14),
                      label: const Text('Päivitä'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Stats chips
                BlocBuilder<DocumentationBloc, DocumentationState>(
                  buildWhen: (prev, curr) =>
                      prev.schemaCount != curr.schemaCount ||
                      prev.tableCount != curr.tableCount ||
                      prev.columnCount != curr.columnCount ||
                      prev.status != curr.status,
                  builder: (context, state) {
                    if (state.status == DocumentationStatus.loaded) {
                      return Row(
                        children: [
                          _StatBadge(label: 'Skeemat', count: state.schemaCount, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          _StatBadge(label: 'Taulut', count: state.tableCount, color: AppTheme.green),
                          const SizedBox(width: 8),
                          _StatBadge(label: 'Kentät', count: state.columnCount, color: AppTheme.amber),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Content
          Expanded(
            child: BlocBuilder<DocumentationBloc, DocumentationState>(
              builder: (context, state) {
                switch (state.status) {
                  case DocumentationStatus.initial:
                  case DocumentationStatus.loading:
                    return const Center(child: CircularProgressIndicator());
                  case DocumentationStatus.error:
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: AppTheme.red),
                          const SizedBox(height: 16),
                          Text('Virhe: ${state.errorMessage}',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => context
                                .read<DocumentationBloc>()
                                .add(const DocumentationLoadRequested()),
                            icon: const Icon(Icons.refresh, size: 14),
                            label: const Text('Yritä uudelleen'),
                          ),
                        ],
                      ),
                    );
                  case DocumentationStatus.loaded:
                    if (state.schemas.isEmpty) {
                      return Center(
                        child: Text('Ei tuloksia',
                            style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
                      );
                    }
                    return _SchemaListView(
                      schemas: state.schemas,
                      expandAll: state.searchQuery.isNotEmpty,
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── STAT BADGE ──────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}

// ─── SCHEMA LIST VIEW ────────────────────────────────────────────────────────

class _SchemaListView extends StatelessWidget {
  final List<SchemaDoc> schemas;
  final bool expandAll;

  const _SchemaListView({required this.schemas, this.expandAll = false});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: schemas.length,
      itemBuilder: (context, index) {
        final schema = schemas[index];
        return _SchemaExpansionTile(schema: schema, expandAll: expandAll);
      },
    );
  }
}

class _SchemaExpansionTile extends StatelessWidget {
  final SchemaDoc schema;
  final bool expandAll;

  const _SchemaExpansionTile({required this.schema, this.expandAll = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border.all(color: Colors.black.withValues(alpha: 0.10), width: 0.5),
        borderRadius: BorderRadius.circular(11),
      ),
      child: ExpansionTile(
        initiallyExpanded: expandAll,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        leading: Icon(Icons.schema, size: 18, color: AppTheme.primaryColor),
        title: Text(
          schema.name,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        subtitle: Text('${schema.tables.length} taulua',
            style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
        children: schema.tables.entries.map((entry) {
          final table = entry.value;
          return _TableExpansionTile(table: table, expandAll: expandAll);
        }).toList(),
      ),
    );
  }
}

class _TableExpansionTile extends StatelessWidget {
  final TableDoc table;
  final bool expandAll;

  const _TableExpansionTile({required this.table, this.expandAll = false});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: expandAll,
      tilePadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Row(
        children: [
          Icon(Icons.table_chart, size: 16, color: AppTheme.textTertiary),
          const SizedBox(width: 8),
          Text(table.name,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
          if (table.comment != null && table.comment!.isNotEmpty) ...[
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                table.comment!,
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textTertiary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            headingRowHeight: 32,
            dataRowMinHeight: 28,
            dataRowMaxHeight: 48,
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
            columns: const [
              DataColumn(label: Text('Kenttä')),
              DataColumn(label: Text('Tyyppi')),
              DataColumn(label: Text('NULL')),
              DataColumn(label: Text('Kommentti')),
              DataColumn(label: Text('Geometria')),
            ],
            rows: table.columns.map((col) => _buildColumnRow(col)).toList(),
          ),
        ),
      ],
    );
  }

  DataRow _buildColumnRow(DbColumnDoc col) {
    return DataRow(cells: [
      DataCell(Text(
        col.kentta,
        style: const TextStyle(fontFamily: 'DM Mono', fontWeight: FontWeight.w500, fontSize: 11),
      )),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.amber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          col.tyyppi ?? '',
          style: TextStyle(fontFamily: 'DM Mono', fontSize: 11, color: AppTheme.amber),
        ),
      )),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: col.isNotNull ? AppTheme.red.withValues(alpha: 0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          col.isNotNull ? 'NOT NULL' : 'YES',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: col.isNotNull ? AppTheme.red : AppTheme.textTertiary,
          ),
        ),
      )),
      DataCell(Text(
        col.kentanKommentti ?? '',
        style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textTertiary),
      )),
      DataCell(col.geometryInfo != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                col.geometryInfo!,
                style: TextStyle(fontSize: 10, color: AppTheme.green),
              ),
            )
          : const SizedBox.shrink()),
    ]);
  }
}
