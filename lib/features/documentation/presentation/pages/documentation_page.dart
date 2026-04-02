import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tietokantadokumentaatio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context
                .read<DocumentationBloc>()
                .add(const DocumentationLoadRequested()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Hakukenttä
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Hae skeemaa, taulua tai kenttää...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => context
                  .read<DocumentationBloc>()
                  .add(DocumentationSearchChanged(value)),
            ),
          ),
          // Tilastot
          BlocBuilder<DocumentationBloc, DocumentationState>(
            buildWhen: (prev, curr) =>
                prev.schemaCount != curr.schemaCount ||
                prev.tableCount != curr.tableCount ||
                prev.columnCount != curr.columnCount ||
                prev.status != curr.status,
            builder: (context, state) {
              if (state.status == DocumentationStatus.loaded) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _StatChip(
                        label: 'Skeemat',
                        count: state.schemaCount,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'Taulut',
                        count: state.tableCount,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'Kentät',
                        count: state.columnCount,
                        color: colorScheme.tertiary,
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 8),
          // Sisältö
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
                          Icon(Icons.error_outline,
                              size: 48, color: colorScheme.error),
                          const SizedBox(height: 16),
                          Text('Virhe: ${state.errorMessage}'),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => context
                                .read<DocumentationBloc>()
                                .add(const DocumentationLoadRequested()),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Yritä uudelleen'),
                          ),
                        ],
                      ),
                    );
                  case DocumentationStatus.loaded:
                    if (state.schemas.isEmpty) {
                      return const Center(
                        child: Text('Ei tuloksia'),
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

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        child: Text(
          '$count',
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SchemaListView extends StatelessWidget {
  final List<SchemaDoc> schemas;
  final bool expandAll;

  const _SchemaListView({required this.schemas, this.expandAll = false});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        initiallyExpanded: expandAll,
        leading: Icon(Icons.schema, color: colorScheme.primary),
        title: Text(
          schema.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${schema.tables.length} taulua'),
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
    final theme = Theme.of(context);

    return ExpansionTile(
      initiallyExpanded: expandAll,
      tilePadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Row(
        children: [
          const Icon(Icons.table_chart, size: 18),
          const SizedBox(width: 8),
          Text(table.name, style: const TextStyle(fontWeight: FontWeight.w500)),
          if (table.comment != null && table.comment!.isNotEmpty) ...[
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                table.comment!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
            headingRowHeight: 36,
            dataRowMinHeight: 32,
            dataRowMaxHeight: 56,
            columns: const [
              DataColumn(label: Text('Kenttä', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              DataColumn(label: Text('Tyyppi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              DataColumn(label: Text('NULL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              DataColumn(label: Text('Kommentti', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              DataColumn(label: Text('Geometria', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            ],
            rows: table.columns.map((col) => _buildColumnRow(context, col)).toList(),
          ),
        ),
      ],
    );
  }

  DataRow _buildColumnRow(BuildContext context, DbColumnDoc col) {
    final colorScheme = Theme.of(context).colorScheme;

    return DataRow(cells: [
      DataCell(Text(
        col.kentta,
        style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w500),
      )),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          col.tyyppi ?? '',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Colors.amber.shade700,
          ),
        ),
      )),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: col.isNotNull
              ? colorScheme.error.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          col.isNotNull ? 'NOT NULL' : 'YES',
          style: TextStyle(
            fontSize: 11,
            color: col.isNotNull ? colorScheme.error : colorScheme.onSurfaceVariant,
          ),
        ),
      )),
      DataCell(Text(
        col.kentanKommentti ?? '',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
      )),
      DataCell(col.geometryInfo != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                col.geometryInfo!,
                style: TextStyle(fontSize: 11, color: Colors.green.shade700),
              ),
            )
          : const SizedBox.shrink()),
    ]);
  }
}
