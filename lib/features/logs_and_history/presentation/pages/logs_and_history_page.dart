import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/card_container.dart';
import '../../data/models/logs_and_history_models.dart';
import '../../data/repositories/logs_and_history_repository.dart';

/// Valittavat lokirivien hakumäärät. `null` = kaikki.
const List<int?> _logLimitOptions = [25, 50, 100, 250, 500, null];
const int _defaultLogLimit = 50;

/// Leveys, jonka ylittyessä lokit näytetään rinnakkain.
const double _sideBySideBreakpoint = 1100;
const double _logListHeight = 520;

class LogsAndHistoryPage extends StatefulWidget {
  final String title;
  const LogsAndHistoryPage({super.key, required this.title});

  @override
  State<LogsAndHistoryPage> createState() => _LogsAndHistoryPageState();
}

class _LogsAndHistoryPageState extends State<LogsAndHistoryPage> {
  final LogsAndHistoryRepository _repository = LogsAndHistoryRepository();
  final ScrollController _pageScrollController = ScrollController();

  int? _eventLimit = _defaultLogLimit;
  int? _importLogLimit = _defaultLogLimit;
  late Future<List<LogEventItem>> _eventsFuture;
  late Future<List<LogHistoryImportLogItem>> _importLogFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _loadEvents();
    _importLogFuture = _loadImportLog();
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  Future<List<LogEventItem>> _loadEvents() {
    final limit = _eventLimit;
    return limit == null
        ? _repository.fetchSystemEvents(kaikki: true)
        : _repository.fetchSystemEvents(limit: limit);
  }

  Future<List<LogHistoryImportLogItem>> _loadImportLog() {
    final limit = _importLogLimit;
    return limit == null
        ? _repository.fetchImportLog(kaikki: true)
        : _repository.fetchImportLog(limit: limit);
  }

  Future<void> _reloadAll() async {
    setState(() {
      _eventsFuture = _loadEvents();
      _importLogFuture = _loadImportLog();
    });
    await Future.wait<void>([
      _eventsFuture.then((_) {}, onError: (_) {}),
      _importLogFuture.then((_) {}, onError: (_) {}),
    ]);
  }

  Future<void> _reloadEvents() async {
    setState(() {
      _eventsFuture = _loadEvents();
    });
    await _eventsFuture.then((_) {}, onError: (_) {});
  }

  Future<void> _reloadImportLog() async {
    setState(() {
      _importLogFuture = _loadImportLog();
    });
    await _importLogFuture.then((_) {}, onError: (_) {});
  }

  void _onEventLimitChanged(int? limit) {
    if (limit == _eventLimit) {
      return;
    }
    _eventLimit = limit;
    _reloadEvents();
  }

  void _onImportLogLimitChanged(int? limit) {
    if (limit == _importLogLimit) {
      return;
    }
    _importLogLimit = limit;
    _reloadImportLog();
  }

  @override
  Widget build(BuildContext context) {
    final eventsCard = _SystemEventsCard(
      future: _eventsFuture,
      limit: _eventLimit,
      onLimitChanged: _onEventLimitChanged,
      onRetry: _reloadEvents,
    );
    final importLogCard = _ImportLogCard(
      future: _importLogFuture,
      limit: _importLogLimit,
      onLimitChanged: _onImportLogLimitChanged,
      onRetry: _reloadImportLog,
    );

    return RefreshIndicator(
      onRefresh: _reloadAll,
      child: Scrollbar(
        controller: _pageScrollController,
        thumbVisibility: true,
        child: ListView(
          controller: _pageScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(22),
          children: [
            _LogsHeader(title: widget.title, onRefresh: _reloadAll),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= _sideBySideBreakpoint) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: eventsCard),
                      const SizedBox(width: 14),
                      Expanded(child: importLogCard),
                    ],
                  );
                }

                return Column(
                  children: [
                    eventsCard,
                    const SizedBox(height: 14),
                    importLogCard,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LogsHeader extends StatelessWidget {
  const _LogsHeader({required this.title, required this.onRefresh});

  final String title;
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
                title,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.logsHeaderDescription,
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

class _CardTitleRow extends StatelessWidget {
  const _CardTitleRow({
    required this.title,
    this.count,
    this.trailing,
  });

  final String title;
  final int? count;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 32,
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Text(
              l10n.logsEntryCount(count!),
              style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
            ),
          ],
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _LogLimitSelector extends StatelessWidget {
  const _LogLimitSelector({
    required this.value,
    required this.onChanged,
  });

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${l10n.logsLimitLabel}:',
          style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
        ),
        const SizedBox(width: 6),
        DropdownButtonHideUnderline(
          child: DropdownButton<int?>(
            value: value,
            isDense: true,
            borderRadius: BorderRadius.circular(8),
            style: TextStyle(fontSize: 12, color: AppTheme.textPrimary),
            items: [
              for (final option in _logLimitOptions)
                DropdownMenuItem<int?>(
                  value: option,
                  child: Text(option?.toString() ?? l10n.logsLimitAll),
                ),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _SystemEventsCard extends StatelessWidget {
  const _SystemEventsCard({
    required this.future,
    required this.limit,
    required this.onLimitChanged,
    required this.onRetry,
  });

  final Future<List<LogEventItem>> future;
  final int? limit;
  final ValueChanged<int?> onLimitChanged;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<List<LogEventItem>>(
      future: future,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final events = snapshot.data;

        return CardContainer(
          titleWidget: _CardTitleRow(
            title: l10n.logsSystemEvents,
            count: isLoading ? null : events?.length,
            trailing: _LogLimitSelector(value: limit, onChanged: onLimitChanged),
          ),
          child: SizedBox(
            height: _logListHeight,
            child: isLoading
                ? const _LogLoading()
                : snapshot.hasError
                    ? _LogError(message: l10n.logsSystemEventsLoadError, onRetry: onRetry)
                    : (events ?? const []).isEmpty
                        ? _LogEmpty(message: l10n.dashboardNoSystemEvents)
                        : _ScrollableLogList(
                            itemCount: events!.length,
                            itemBuilder: (context, index) => _EventRow(
                              event: events[index],
                              isLast: index == events.length - 1,
                            ),
                          ),
          ),
        );
      },
    );
  }
}

class _ImportLogCard extends StatelessWidget {
  const _ImportLogCard({
    required this.future,
    required this.limit,
    required this.onLimitChanged,
    required this.onRetry,
  });

  final Future<List<LogHistoryImportLogItem>> future;
  final int? limit;
  final ValueChanged<int?> onLimitChanged;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<List<LogHistoryImportLogItem>>(
      future: future,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final entries = snapshot.data;

        return CardContainer(
          titleWidget: _CardTitleRow(
            title: l10n.dashboardImportLog,
            count: isLoading ? null : entries?.length,
            trailing: _LogLimitSelector(value: limit, onChanged: onLimitChanged),
          ),
          child: SizedBox(
            height: _logListHeight,
            child: isLoading
                ? const _LogLoading()
                : snapshot.hasError
                    ? _LogError(message: l10n.logsImportLogLoadError, onRetry: onRetry)
                    : (entries ?? const []).isEmpty
                        ? _LogEmpty(message: l10n.dashboardNoImportLog)
                        : _ScrollableLogList(
                            itemCount: entries!.length,
                            itemBuilder: (context, index) => _ImportLogRow(
                              entry: entries[index],
                              isLast: index == entries.length - 1,
                            ),
                          ),
          ),
        );
      },
    );
  }
}

/// Kiinteäkorkuinen, oman scrollbarinsa omaava lista sivun scrollin sisällä.
class _ScrollableLogList extends StatefulWidget {
  const _ScrollableLogList({
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  State<_ScrollableLogList> createState() => _ScrollableLogListState();
}

class _ScrollableLogListState extends State<_ScrollableLogList> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      child: ListView.builder(
        controller: _controller,
        primary: false,
        padding: const EdgeInsets.only(right: 12),
        itemCount: widget.itemCount,
        itemBuilder: widget.itemBuilder,
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.event,
    this.isLast = false,
  });

  final LogEventItem event;
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
    final detail = _buildEventDetail(l10n, event);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showEventDetailsDialog(context, event),
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
                    if (detail.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
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
                    _formatEventTime(event.occurredAt),
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

class _ImportLogRow extends StatelessWidget {
  const _ImportLogRow({
    required this.entry,
    this.isLast = false,
  });

  final LogHistoryImportLogItem entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final command = _shortenCommand(entry.komento);

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
                    Row(
                      children: [
                        Text(
                          entry.tyyppi ?? l10n.dashboardImportLogTypeOther,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (command.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Tooltip(
                              message: entry.komento!.trim(),
                              waitDuration: const Duration(milliseconds: 500),
                              child: Text(
                                command,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textTertiary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (_buildImportLogDetail(l10n, entry).isNotEmpty) ...[
                      const SizedBox(height: 2),
                      RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

class _LogLoading extends StatelessWidget {
  const _LogLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _LogError extends StatelessWidget {
  const _LogError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class _LogEmpty extends StatelessWidget {
  const _LogEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Text(
        message,
        style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
      ),
    );
  }
}

String _buildEventDetail(AppLocalizations l10n, LogEventItem event) {
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

  return DateFormat('d.M.yyyy HH:mm').format(occurredAt);
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

/// Lyhentää tuontilokin komennon riville: polut korvataan tiedostonimillä,
/// jotta saman tyypin rivit (esim. ilmoitukset vs. lopetusilmoitukset)
/// erottuvat toisistaan. Koko komento näkyy tooltipissa ja lisätiedoissa.
String _shortenCommand(String? komento) {
  final trimmed = (komento ?? '').trim();
  if (trimmed.isEmpty) {
    return '';
  }

  return trimmed.split(RegExp(r'\s+')).map(_shortenCommandToken).join(' ');
}

String _shortenCommandToken(String token) {
  // --tiedosto=/polku/tiedosto.csv → --tiedosto=tiedosto.csv
  final eq = token.indexOf('=');
  if (token.startsWith('-') && eq > 0) {
    return '${token.substring(0, eq + 1)}${_shortenCommandToken(token.substring(eq + 1))}';
  }

  // URL:t (esim. postgresql://...) jätetään ennalleen.
  if (!token.contains('/') || token.contains('://')) {
    return token;
  }

  final quote = RegExp(r'''^["']|["']$''');
  final segments = token.replaceAll(quote, '').split('/').where((s) => s.isNotEmpty);
  return segments.isEmpty ? token : segments.last;
}

String _formatImportLogTime(LogHistoryImportLogItem entry) {
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

String _buildImportLogDetail(AppLocalizations l10n, LogHistoryImportLogItem entry) {
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

TextSpan _buildImportLogDetailSpan(AppLocalizations l10n, LogHistoryImportLogItem entry) {
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

Future<void> _showEventDetailsDialog(
  BuildContext context,
  LogEventItem event,
) {
  final l10n = AppLocalizations.of(context)!;

  return _showLogDetailsDialog(
    context,
    title: l10n.logsEventDetailsTitle,
    subtitle: '${event.title} • ${_formatEventTime(event.occurredAt)}',
    rows: [
      _DetailRow(label: l10n.dashboardFieldId, value: event.id),
      _DetailRow(
        label: l10n.dashboardFieldDate,
        value: event.occurredAt != null ? DateFormat('d.M.yyyy').format(event.occurredAt!) : null,
      ),
      _DetailRow(
        label: l10n.dashboardFieldTime,
        value: event.occurredAt != null ? DateFormat('HH:mm:ss').format(event.occurredAt!) : null,
      ),
      _DetailRow(label: l10n.logsFieldEvent, value: event.title, multiline: true),
      _DetailRow(label: l10n.logsFieldTaskType, value: event.taskType),
      _DetailRow(
        label: l10n.dashboardFieldStatus,
        value: _statusLabel(l10n, event.status),
        valueColor: _statusColor(event.status),
        bold: true,
      ),
      _DetailRow(label: l10n.dashboardFieldRunner, value: event.runner),
      _DetailRow(label: l10n.dashboardFieldDetails, value: event.detail, multiline: true),
    ],
  );
}

Future<void> _showImportLogDetailsDialog(
  BuildContext context,
  LogHistoryImportLogItem entry,
) {
  final l10n = AppLocalizations.of(context)!;

  return _showLogDetailsDialog(
    context,
    title: l10n.dashboardImportDetailsTitle,
    subtitle: '${entry.tyyppi ?? l10n.dashboardImportLogTypeOther} • ${_formatImportLogTime(entry)}',
    rows: [
      _DetailRow(label: l10n.dashboardFieldId, value: entry.id.toString()),
      _DetailRow(
        label: l10n.dashboardFieldDate,
        value: entry.paiva != null ? DateFormat('d.M.yyyy').format(entry.paiva!) : null,
      ),
      _DetailRow(label: l10n.dashboardFieldTime, value: entry.kellonaika),
      _DetailRow(label: l10n.dashboardFieldType, value: entry.tyyppi),
      _DetailRow(
        label: l10n.dashboardFieldStatus,
        value: _importStatusLabel(l10n, entry.status),
        valueColor: _importStatusColor(entry.status),
        bold: true,
      ),
      _DetailRow(label: l10n.dashboardFieldResult, value: entry.tulos, multiline: true),
      _DetailRow(
        label: l10n.dashboardFieldCommand,
        value: entry.komento,
        multiline: true,
        monospace: true,
      ),
    ],
  );
}

Future<void> _showLogDetailsDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  required List<_DetailRow> rows,
}) {
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
                            title,
                            style: Theme.of(dialogContext).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
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
                Flexible(
                  child: SingleChildScrollView(
                    child: SelectionArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: rows,
                      ),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.multiline = false,
    this.monospace = false,
    this.bold = false,
  });

  final String label;
  final String? value;
  final Color? valueColor;
  final bool multiline;
  final bool monospace;
  final bool bold;

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
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                fontFamily: monospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
