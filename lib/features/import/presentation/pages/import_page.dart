import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/card_container.dart';
import '../../../../shared/widgets/responsive_grid.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/term_line.dart';
import '../../data/models/import_file.dart';
import '../../data/models/import_queue_item.dart';
import '../../data/repositories/import_repository.dart';
import '../bloc/import_bloc.dart';
import '../bloc/import_event.dart';
import '../bloc/import_state.dart';

class ImportPage extends StatelessWidget {
  const ImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImportBloc(repository: ImportRepository())
        ..add(const ImportLoadFiles()),
      child: const _ImportPageView(),
    );
  }
}

class _ImportPageView extends StatelessWidget {
  const _ImportPageView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImportBloc, ImportState>(
      builder: (context, state) {
        if (state.status == ImportPageStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == ImportPageStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppTheme.red),
                const SizedBox(height: 16),
                Text('Virhe: ${state.errorMessage}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<ImportBloc>().add(const ImportLoadFiles()),
                  child: const Text('Yritä uudelleen'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              // Row 1: Sharepoint files + Manual upload
              ResponsiveGrid(
                minChildWidth: 320,
                spacing: 14,
                children: [
                  _SharepointFilesCard(files: state.sharepointFiles),
                  const _ManualUploadCard(),
                ],
              ),
              const SizedBox(height: 14),
              // Analysis card
              if (state.analyzedFiles.isNotEmpty || state.isAnalyzing)
                _AnalysisCard(
                  files: state.analyzedFiles,
                  isAnalyzing: state.isAnalyzing,
                  hasErrors: state.hasAnalysisErrors,
                  canStartImport: state.canStartImport,
                ),
              if (state.analyzedFiles.isNotEmpty || state.isAnalyzing)
                const SizedBox(height: 14),
              // Row 2: Velvoitetarkistus + Velvoitteiden asettaminen
              ResponsiveGrid(
                minChildWidth: 320,
                spacing: 14,
                children: [
                  _VelvoitetarkistusCard(
                    isRunning: state.isRunningVelvoite,
                  ),
                  _VelvoitteetCard(
                    isRunning: state.isRunningVelvoite,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Import queue
              if (state.queueItems.isNotEmpty || state.isImporting)
                _ImportQueueCard(
                  items: state.queueItems,
                  isImporting: state.isImporting,
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─── SHAREPOINT FILES CARD ───────────────────────────────────────────────────

class _SharepointFilesCard extends StatelessWidget {
  final List<ImportFile> files;
  const _SharepointFilesCard({required this.files});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      title: 'Saatavilla Sharepointissa — Valmis vietäväksi',
      child: Column(
        children: [
          for (final file in files)
            _SharepointFileRow(file: file),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: BlocBuilder<ImportBloc, ImportState>(
              buildWhen: (prev, curr) =>
                  prev.selectedFileCount != curr.selectedFileCount ||
                  prev.isAnalyzing != curr.isAnalyzing,
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state.selectedFileCount > 0 && !state.isAnalyzing
                      ? () => context
                          .read<ImportBloc>()
                          .add(const ImportAnalyzeFiles())
                      : null,
                  child: state.isAnalyzing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Esianalysoi valitut'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SharepointFileRow extends StatelessWidget {
  final ImportFile file;
  const _SharepointFileRow({required this.file});

  String get _badgeText => switch (file.badge) {
        ImportFileBadge.uusi => 'uusi',
        ImportFileBadge.paivitys => 'päivitys',
        ImportFileBadge.tarkista => 'tarkista',
      };

  String get _badgeType => switch (file.badge) {
        ImportFileBadge.uusi => 'new',
        ImportFileBadge.paivitys => 'update',
        ImportFileBadge.tarkista => 'warn',
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          context.read<ImportBloc>().add(ImportToggleFile(file.id)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black.withValues(alpha: 0.10),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            _FileCheckbox(checked: file.selected),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                file.name,
                style: TextStyle(fontSize: 12, color: AppTheme.textPrimary),
              ),
            ),
            StatusBadge(text: _badgeText, type: _badgeType),
            const SizedBox(width: 8),
            Text(
              file.size,
              style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileCheckbox extends StatelessWidget {
  final bool checked;
  const _FileCheckbox({required this.checked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: checked
              ? AppTheme.primaryColor
              : Colors.black.withValues(alpha: 0.20),
        ),
        color: checked ? AppTheme.primaryColor : AppTheme.background2,
      ),
      child: checked
          ? const Icon(Icons.check, size: 10, color: Colors.white)
          : null,
    );
  }
}

// ─── MANUAL UPLOAD CARD ──────────────────────────────────────────────────────

class _ManualUploadCard extends StatelessWidget {
  const _ManualUploadCard();

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      title: 'Tuo tiedosto käsin',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiedosto tuodaan erillään Sharepoint-jonosta.',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textTertiary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.20),
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              borderRadius: BorderRadius.circular(7),
              color: AppTheme.background2,
            ),
            child: Column(
              children: [
                Icon(Icons.upload_file, size: 22, color: AppTheme.textTertiary),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    text: 'Vedä tiedosto tähän tai ',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                    children: [
                      TextSpan(
                        text: 'selaa',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ANALYSIS CARD ───────────────────────────────────────────────────────────

class _AnalysisCard extends StatelessWidget {
  final List<ImportFile> files;
  final bool isAnalyzing;
  final bool hasErrors;
  final bool canStartImport;

  const _AnalysisCard({
    required this.files,
    required this.isAnalyzing,
    required this.hasErrors,
    required this.canStartImport,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      title: 'Esianalyysi ja tuontijärjestys',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Raahaa rivejä järjestyksen muuttamiseksi. Virheelliset tiedostot merkitty punaisella.',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textTertiary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 10),
          if (isAnalyzing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            for (int i = 0; i < files.length; i++) ...[
              if (i > 0) const SizedBox(height: 6),
              _AnalyzedFileRow(file: files[i]),
            ],
          ],
          if (hasErrors) ...[
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.redBg,
                border: Border.all(color: const Color(0xFFFCA5A5)),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, size: 16, color: AppTheme.red),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tietojen syöttöä ei voi aloittaa — jonossa on tiedostoja, joissa on virheitä. Poista tai korjaa virheelliset tiedostot ennen kuin jatkat.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.red,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Center(
            child: Opacity(
              opacity: canStartImport ? 1.0 : 0.4,
              child: ElevatedButton.icon(
                onPressed: canStartImport
                    ? () => context
                        .read<ImportBloc>()
                        .add(const ImportStartImport())
                    : null,
                icon: const Icon(Icons.download, size: 18),
                label: const Text(
                  'Aloita tietojen tuonti',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyzedFileRow extends StatelessWidget {
  final ImportFile file;
  const _AnalyzedFileRow({required this.file});

  String get _badgeText {
    if (file.analysis?.hasError == true) return 'Virhe';
    final a = file.analysis;
    if (a == null) return '—';
    return '${_formatNumber(a.rowCount)} riviä';
  }

  String get _badgeType {
    if (file.analysis?.hasError == true) return 'error';
    if (file.badge == ImportFileBadge.uusi) return 'new';
    return 'update';
  }

  String get _detail {
    final a = file.analysis;
    if (a == null) return '';
    if (a.hasError) return a.errorMessage!;
    final parts = <String>[];
    if (a.newCount > 0) parts.add('↑ ${_formatNumber(a.newCount)} uutta kohdetta');
    if (a.updateCount > 0) {
      parts.add('↻ ${_formatNumber(a.updateCount)} päivitystä');
    }
    if (a.unmatchedCount > 0) {
      parts.add('⚠ ${a.unmatchedCount} kohdentumatta');
    }
    return parts.join(' · ');
  }

  static String _formatNumber(int n) {
    if (n < 1000) return '$n';
    final str = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = file.analysis?.hasError == true;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background2,
        borderRadius: BorderRadius.circular(7),
        border: hasError
            ? Border(left: BorderSide(color: AppTheme.red, width: 3))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.drag_indicator, size: 14, color: AppTheme.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        file.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    StatusBadge(text: _badgeText, type: _badgeType),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      onPressed: () => context
                          .read<ImportBloc>()
                          .add(ImportRemoveAnalyzedFile(file.id)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        foregroundColor: AppTheme.red,
                        side: BorderSide(color: AppTheme.red),
                      ),
                      child:
                          const Text('Poista', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _detail,
                  style: TextStyle(
                    fontSize: 11,
                    color: hasError ? AppTheme.red : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── VELVOITETARKISTUS CARD ──────────────────────────────────────────────────

class _VelvoitetarkistusCard extends StatefulWidget {
  final bool isRunning;
  const _VelvoitetarkistusCard({required this.isRunning});

  @override
  State<_VelvoitetarkistusCard> createState() =>
      _VelvoitetarkistusCardState();
}

class _VelvoitetarkistusCardState extends State<_VelvoitetarkistusCard> {
  final _dateController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      title: 'Velvoitetarkistus',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aja velvoitetarkistus valitulle päivämäärälle tuonnin jälkeen.',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textTertiary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tarkastuspäivämäärä',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 160,
                    child: TextField(
                      controller: _dateController,
                      decoration:
                          const InputDecoration(hintText: '31.03.2025'),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: widget.isRunning
                    ? null
                    : () {
                        final date = _dateController.text.trim();
                        if (date.isNotEmpty) {
                          context
                              .read<ImportBloc>()
                              .add(ImportRunVelvoitetarkistus(date));
                        }
                      },
                child: widget.isRunning
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Aja velvoitetarkistus'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── VELVOITTEET CARD ────────────────────────────────────────────────────────

class _VelvoitteetCard extends StatelessWidget {
  final bool isRunning;
  const _VelvoitteetCard({required this.isRunning});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      title: 'Velvoitteiden asettaminen',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aseta velvoitteet tuotujen kohteiden perusteella.',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textTertiary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: isRunning
                ? null
                : () => context
                    .read<ImportBloc>()
                    .add(const ImportSetVelvoitteet()),
            child: isRunning
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Aseta velvoitteet'),
          ),
        ],
      ),
    );
  }
}

// ─── IMPORT QUEUE CARD ───────────────────────────────────────────────────────

class _ImportQueueCard extends StatelessWidget {
  final List<ImportQueueItem> items;
  final bool isImporting;

  const _ImportQueueCard({
    required this.items,
    required this.isImporting,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      title: 'Tuontijono',
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _ImportProgressRow(item: items[i]),
          ],
          const SizedBox(height: 10),
          // Terminal
          Container(
            width: double.infinity,
            height: 110,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1117),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TermLine(
                    color: Color(0xFF444444),
                    text: '[08:14:01] Aloitetaan tuonti...',
                  ),
                  TermLine(
                    color: Color(0xFF4ADE80),
                    text: '[08:14:02] Tiedosto ladattu',
                  ),
                  TermLine(
                    color: Color(0xFF4ADE80),
                    text: '[08:14:03] Kohteiden käsittely aloitettu',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportProgressRow extends StatelessWidget {
  final ImportQueueItem item;
  const _ImportProgressRow({required this.item});

  String get _statusText => switch (item.status) {
        ImportQueueStatus.waiting => 'Jonossa',
        ImportQueueStatus.running =>
          'Käynnissä · ${(item.progress * 100).toInt()} %',
        ImportQueueStatus.completed => 'Valmis',
        ImportQueueStatus.error => 'Virhe',
      };

  Color get _color => switch (item.status) {
        ImportQueueStatus.waiting => const Color(0xFFD97706),
        ImportQueueStatus.running => AppTheme.primaryMid,
        ImportQueueStatus.completed => AppTheme.green,
        ImportQueueStatus.error => AppTheme.red,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background2,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.fileName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _statusText,
                style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: item.progress,
              backgroundColor: Colors.black.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation(_color),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.totalCount > 0
                    ? '${item.processedCount} / ${item.totalCount} kohdetta'
                    : 'Odottaa',
                style:
                    TextStyle(fontSize: 11, color: AppTheme.textTertiary),
              ),
              if (item.estimatedTime != null)
                Text(
                  item.estimatedTime!,
                  style:
                      TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
