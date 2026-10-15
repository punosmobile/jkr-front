import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/dashboard_overview.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../../../shared/widgets/card_container.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../../../../shared/widgets/responsive_grid.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardRepository _repository = DashboardRepository();
  final ScrollController _pageScrollController = ScrollController();
  late Future<_DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboardData();
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _dashboardFuture = _loadDashboardData();
    });
    await _dashboardFuture;
  }

  Future<_DashboardData> _loadDashboardData() async {
    final results = await Future.wait<dynamic>([
      _repository.fetchOverview(),
      _repository.fetchImportLog(),
    ]);

    return _DashboardData(
      overview: results[0] as DashboardOverview,
      importLog: results[1] as List<DashboardImportLogItem>,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<_DashboardData>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          return Scrollbar(
            controller: _pageScrollController,
            thumbVisibility: true,
            child: ListView(
              controller: _pageScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(22),
              children: [
                _DashboardHeader(onRefresh: _reload),
                const SizedBox(height: 14),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const _DashboardLoading()
                else if (snapshot.hasError)
                  _DashboardError(
                    onRetry: _reload,
                    message: l10n.dashboardLoadError,
                  )
                else if (!snapshot.hasData)
                  const _DashboardEmptyState()
                else
                  _DashboardContent(data: snapshot.data!),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.navDashboard,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.dashboardHeaderDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh, size: 16),
          label: Text(l10n.dashboardRefresh),
        ),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.data});

  final _DashboardData data;

  @override
  Widget build(BuildContext context) {
    final overview = data.overview;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveGrid(
          minChildWidth: 190,
          spacing: 10,
          children: [
            _SummaryMetricCard(
              label: l10n.dashboardSummaryObligationCheckRan,
              item: overview.velvoitetarkistusAjettu,
            ),
            _SummaryMetricCard(
              label: l10n.dashboardSummaryLatestReportGenerated,
              item: overview.viimeisinRaporttiGeneroitu,
            ),
            _SummaryMetricCard(
              label: l10n.dashboardSummaryLatestDecisionInDatabase,
              item: overview.uusinPaatosKannassa,
            ),
            _SummaryMetricCard(
              label: l10n.dashboardSummaryLatestCompostingNotice,
              item: overview.uusinKompostointiIlmoitus,
            ),
            _SummaryMetricCard(
              label: l10n.dashboardSummarySludgeTransportLatestEmptying,
              item: overview.lietekuljetusViimeisinTyhjennys,
            ),
            _SummaryMetricCard(
              label: l10n.dashboardSummaryFixedTransportLatestQuarter,
              item: overview.kiinteaKuljetusViimeisinKvartaali,
              formatter: (value) => _formatQuarterLabel(l10n, value),
            ),
            _SummaryMetricCard(
              label: l10n.dashboardSummaryLatestImport,
              item: overview.viimeisinTuonti,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ActivityCard(events: overview.viimeisimmatJarjestelmatapahtumat),
        const SizedBox(height: 14),
        _ImportLogCard(entries: data.importLog),
      ],
    );
  }
}

class _DashboardData {
  const _DashboardData({
    required this.overview,
    required this.importLog,
  });

  final DashboardOverview overview;
  final List<DashboardImportLogItem> importLog;
}

class _SummaryMetricCard extends StatelessWidget {
  const _SummaryMetricCard({
    required this.label,
    required this.item,
    this.formatter,
  });

  final String label;
  final DashboardSummaryItem item;
  final String Function(DateTime?)? formatter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final value = formatter != null
        ? formatter!(item.occurredAt)
        : _formatDateTimeValue(l10n, item.occurredAt);

    return MetricCard(
      label: label,
      value: value,
      height: 112,
      valueFontSize: 14,
      valueColor: _statusColor(item.status),
      sub: _buildSummarySubline(l10n, item),
      subColor: _statusColor(item.status),
      onTap: () => _showSummaryDetailsDialog(context, label: label, item: item),
      trailingIcon: Icons.open_in_full_rounded,
      trailingTooltip: l10n.dashboardViewDetailsTooltip,
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.event,
    this.isLast = false,
  });

  final DashboardEventItem event;
  final bool isLast;

  Color get _dotColor => switch (event.status) {
    'completed' => const Color(0xFF22C55E),
    'failed' => const Color(0xFFEF4444),
    'running' => const Color(0xFFD97706),
    'pending' => const Color(0xFFD97706),
    _ => AppTheme.textTertiary,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: isLast
          ? null
          : BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.10), width: 0.5))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(shape: BoxShape.circle, color: _dotColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                if ((event.detail ?? '').isNotEmpty || (event.runner ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _buildEventDetail(l10n, event),
                    style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatEventTime(event.occurredAt),
            style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.events});

  final List<DashboardEventItem> events;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CardContainer(
      title: l10n.dashboardLatestSystemEvents,
      child: events.isEmpty
          ? Text(
              l10n.dashboardNoSystemEvents,
              style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
            )
          : SizedBox(
              // ~6 tapahtumaa kerrallaan, loput scrollaamalla (kuten tuontiloki),
              // jottei koko dashboard-näkymä täyty järjestelmätapahtumilla.
              height: 200,
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  primary: false,
                  itemCount: events.length,
                  itemBuilder: (context, index) => _ActivityRow(
                    event: events[index],
                    isLast: index == events.length - 1,
                  ),
                ),
              ),
            ),
    );
  }
}

class _ImportLogCard extends StatelessWidget {
  const _ImportLogCard({required this.entries});

  final List<DashboardImportLogItem> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CardContainer(
      title: l10n.dashboardImportLog,
      child: entries.isEmpty
          ? Text(
              l10n.dashboardNoImportLog,
              style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
            )
          : SizedBox(
              height: 320,
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  primary: false,
                  itemCount: entries.length,
                  itemBuilder: (context, index) => _ImportLogRow(
                    entry: entries[index],
                    isLast: index == entries.length - 1,
                  ),
                ),
              ),
            ),
    );
  }
}

class _ImportLogRow extends StatelessWidget {
  const _ImportLogRow({
    required this.entry,
    this.isLast = false,
  });

  final DashboardImportLogItem entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showImportLogDetailsDialog(context, entry),
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.background2,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: isLast
              ? null
              : BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black.withValues(alpha: 0.10),
                      width: 0.5,
                    ),
                  ),
                ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.tyyppi ?? l10n.dashboardImportLogTypeOther,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (_buildImportLogDetail(l10n, entry).isNotEmpty) ...[
                      const SizedBox(height: 2),
                      RichText(
                        text: _buildImportLogDetailSpan(l10n, entry),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.open_in_full_rounded,
                    size: 14,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatImportLogTime(entry),
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return const CardContainer(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({
    required this.onRetry,
    required this.message,
  });

  final Future<void> Function() onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }
}

class _DashboardEmptyState extends StatelessWidget {
  const _DashboardEmptyState();

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Text(
        AppLocalizations.of(context)!.dashboardNoData,
        style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
      ),
    );
  }
}

String _formatDateTimeValue(AppLocalizations l10n, DateTime? value) {
  if (value == null) {
    return l10n.dashboardNoInfo;
  }

  return DateFormat('d.M.yyyy').format(value);
}

String _formatQuarterLabel(AppLocalizations l10n, DateTime? value) {
  if (value == null) {
    return l10n.dashboardNoInfo;
  }

  final quarter = ((value.month - 1) ~/ 3) + 1;
  return 'Q$quarter / ${value.year}';
}

String? _buildSummarySubline(AppLocalizations l10n, DashboardSummaryItem item) {
  final parts = <String>[];

  if (item.occurredAt != null) {
    parts.add(DateFormat('HH:mm').format(item.occurredAt!));
  }

  final statusLabel = _statusLabel(l10n, item.status);
  if (statusLabel != null) {
    parts.add(statusLabel);
  }

  if (parts.isEmpty) {
    return null;
  }

  return parts.join(' • ');
}

String _buildEventDetail(AppLocalizations l10n, DashboardEventItem event) {
  final parts = <String>[];

  final statusLabel = _statusLabel(l10n, event.status);
  if (statusLabel != null) {
    parts.add(statusLabel);
  }

  if ((event.runner ?? '').isNotEmpty) {
    parts.add(event.runner!);
  }

  if ((event.detail ?? '').isNotEmpty) {
    parts.add(event.detail!);
  }

  return parts.join(' • ');
}

String _formatEventTime(DateTime? occurredAt) {
  if (occurredAt == null) {
    return '—';
  }

  return DateFormat('d.M. HH:mm').format(occurredAt);
}

String? _statusLabel(AppLocalizations l10n, String? status) {
  return switch (status) {
    'completed' => l10n.dashboardStatusCompleted,
    'failed' => l10n.dashboardStatusFailed,
    'running' => l10n.dashboardStatusRunning,
    'pending' => l10n.dashboardStatusPending,
    null || '' => null,
    _ => status,
  };
}

Color? _statusColor(String? status) {
  return switch (status) {
    'completed' => AppTheme.green,
    'failed' => AppTheme.red,
    'running' => AppTheme.amber,
    'pending' => AppTheme.amber,
    _ => null,
  };
}

String _formatImportLogTime(DashboardImportLogItem entry) {
  final day = entry.paiva != null ? DateFormat('d.M.yyyy').format(entry.paiva!) : null;
  final time = (entry.kellonaika ?? '').trim();

  if (day != null && time.isNotEmpty) {
    return '$day $time';
  }

  if (day != null) {
    return day;
  }

  if (time.isNotEmpty) {
    return time;
  }

  return '—';
}

String _buildImportLogDetail(AppLocalizations l10n, DashboardImportLogItem entry) {
  final parts = <String>[];

  final status = _importStatusLabel(l10n, entry.status);
  if (status != null) {
    parts.add(status);
  }

  final result = (entry.tulos ?? '').trim();
  if (result.isNotEmpty) {
    parts.add(result);
  }

  return parts.join(' • ');
}

TextSpan _buildImportLogDetailSpan(AppLocalizations l10n, DashboardImportLogItem entry) {
  final children = <InlineSpan>[];
  final status = _importStatusLabel(l10n, entry.status);
  final result = (entry.tulos ?? '').trim();

  if (status != null) {
    children.add(
      TextSpan(
        text: status,
        style: TextStyle(
          fontSize: 11,
          color: _importStatusColor(entry.status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  if (result.isNotEmpty) {
    if (children.isNotEmpty) {
      children.add(
        TextSpan(
          text: ' • ',
          style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
        ),
      );
    }

    children.add(
      TextSpan(
        text: result,
        style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
      ),
    );
  }

  return TextSpan(children: children);
}

String? _importStatusLabel(AppLocalizations l10n, String? status) {
  final normalized = status?.trim().toLowerCase();
  return switch (normalized) {
    'valmis' => l10n.dashboardStatusCompleted,
    'virhe' => l10n.dashboardStatusFailed,
    'käynnissä' => l10n.dashboardStatusRunning,
    'kaynnissa' => l10n.dashboardStatusRunning,
    null || '' => null,
    _ => status,
  };
}

Color _importStatusColor(String? status) {
  final normalized = status?.trim().toLowerCase();
  return switch (normalized) {
    'valmis' => AppTheme.green,
    'virhe' => AppTheme.red,
    'käynnissä' => AppTheme.amber,
    'kaynnissa' => AppTheme.amber,
    _ => AppTheme.textTertiary,
  };
}

Future<void> _showImportLogDetailsDialog(
  BuildContext context,
  DashboardImportLogItem entry,
) {
  final l10n = AppLocalizations.of(context)!;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 560),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.dashboardImportDetailsTitle,
                            style: Theme.of(dialogContext).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${entry.tyyppi ?? l10n.dashboardImportLogTypeOther} • ${_formatImportLogTime(entry)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.dashboardCloseTooltip,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SummaryDetailRow(
                          label: l10n.dashboardFieldId,
                          value: entry.id?.toString(),
                        ),
                        _SummaryDetailRow(
                          label: l10n.dashboardFieldDate,
                          value: entry.paiva != null
                              ? DateFormat('d.M.yyyy').format(entry.paiva!)
                              : null,
                        ),
                        _SummaryDetailRow(
                          label: l10n.dashboardFieldTime,
                          value: entry.kellonaika,
                        ),
                        _SummaryDetailRow(
                          label: l10n.dashboardFieldType,
                          value: entry.tyyppi,
                        ),
                        _SummaryDetailRow(
                          label: l10n.dashboardFieldStatus,
                          value: _importStatusLabel(l10n, entry.status),
                          valueColor: _importStatusColor(entry.status),
                        ),
                        _SummaryDetailRow(
                          label: l10n.dashboardFieldResult,
                          value: entry.tulos,
                          multiline: true,
                        ),
                        _SummaryDetailRow(
                          label: l10n.dashboardFieldCommand,
                          value: entry.komento,
                          multiline: true,
                          monospace: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n.dashboardCloseButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _showSummaryDetailsDialog(
  BuildContext context, {
  required String label,
  required DashboardSummaryItem item,
}) {
  final l10n = AppLocalizations.of(context)!;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 520),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: Theme.of(dialogContext).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.dashboardSummaryDetailsDescription,
                            style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.dashboardCloseTooltip,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SummaryDetailRow(
                          label: l10n.dashboardFieldDate,
                          value: item.occurredAt != null
                              ? DateFormat('d.M.yyyy').format(item.occurredAt!)
                              : null,
                        ),
                        _SummaryDetailRow(
                          label: l10n.dashboardFieldTime,
                          value: item.occurredAt != null
                              ? DateFormat('HH:mm').format(item.occurredAt!)
                              : null,
                        ),
                        _SummaryDetailRow(
                          label: l10n.dashboardFieldStatus,
                          value: _statusLabel(l10n, item.status),
                          valueColor: _statusColor(item.status),
                        ),
                        _SummaryDetailRow(
                          label: l10n.dashboardFieldRunner,
                          value: item.runner,
                        ),
                        _SummaryDetailRow(
                          label: l10n.dashboardFieldDetails,
                          value: item.detail,
                          multiline: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n.dashboardCloseButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _SummaryDetailRow extends StatelessWidget {
  const _SummaryDetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.multiline = false,
    this.monospace = false,
  });

  final String label;
  final String? value;
  final Color? valueColor;
  final bool multiline;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayValue = (value ?? '').trim().isEmpty ? l10n.dashboardNoInfo : value!.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              displayValue,
              maxLines: multiline ? null : 1,
              overflow: multiline ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: valueColor ?? AppTheme.textPrimary,
                fontWeight: label == l10n.dashboardFieldStatus ? FontWeight.w700 : FontWeight.w500,
                fontFamily: monospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
