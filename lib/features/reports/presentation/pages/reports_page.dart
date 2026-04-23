import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/card_container.dart';
import '../../../../shared/widgets/responsive_grid.dart';
import '../../data/repositories/reports_repository.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportsBloc(repository: ReportsRepository())
        ..add(const ReportsInitializeRequested()),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatefulWidget {
  const _ReportsView();

  @override
  State<_ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<_ReportsView> {
  late final TextEditingController _dateController;
  static const _fieldContentPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 16,
  );

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        final bloc = context.read<ReportsBloc>();
        final l10n = AppLocalizations.of(context)!;
        if (_dateController.text != state.tarkastelupvm) {
          _dateController.value = TextEditingValue(
            text: state.tarkastelupvm,
            selection: TextSelection.collapsed(offset: state.tarkastelupvm.length),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reportsPageTitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.reportsPageDescription,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.reportsFiltersTitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ResponsiveGrid(
                      minChildWidth: 220,
                      spacing: 12,
                      children: [
                        _buildDateField(
                          context,
                          label: l10n.reportsFieldDate,
                          controller: _dateController,
                          selectedValue: state.tarkastelupvm,
                          onChanged: (value) => bloc.add(ReportsDateChanged(value)),
                        ),
                        _buildDropdownField<String>(
                          label: l10n.reportsFieldMunicipality,
                          value: state.kunta,
                          enabled: true,
                          items: _municipalities(l10n),
                          onChanged: (value) => bloc.add(ReportsMunicipalityChanged(value)),
                        ),
                        _buildDropdownField<int>(
                          label: l10n.reportsFieldApartmentCount,
                          value: state.huoneistomaara,
                          enabled: true,
                          items: _apartmentOptions(l10n),
                          onChanged: (value) => bloc.add(ReportsApartmentCountChanged(value)),
                        ),
                        _buildDropdownField<int>(
                          label: l10n.reportsFieldUrbanArea,
                          value: state.taajama,
                          enabled: true,
                          items: _urbanAreaOptions(l10n),
                          onChanged: (value) => bloc.add(ReportsUrbanAreaChanged(value)),
                        ),
                        _buildDropdownField<int>(
                          label: l10n.reportsFieldPropertyType,
                          value: state.kohdeTyyppi,
                          enabled: true,
                          items: _propertyTypes(l10n),
                          onChanged: (value) => bloc.add(ReportsPropertyTypeChanged(value)),
                        ),
                        _buildDropdownField<int>(
                          label: l10n.reportsFieldSewer,
                          value: state.onkoViemari,
                          enabled: true,
                          items: _sewerOptions(l10n),
                          onChanged: (value) => bloc.add(ReportsSewerChanged(value)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.reportsInfoParallelRuns,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.45,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => bloc.add(const ReportsRunRequested()),
                          icon: const Icon(Icons.table_chart_outlined, size: 16),
                          label: Text(
                            state.reportRuns.isEmpty
                                ? l10n.reportsRunButton
                                : l10n.reportsRunNewButton,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (state.reportRuns.isNotEmpty) const SizedBox(height: 16),
              ..._sortedReportRuns(state.reportRuns).map((run) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ReportRunCard(
                    key: ValueKey(run.id),
                    run: run,
                    onDismiss: () => bloc.add(ReportsRunDismissed(run.id)),
                    onCancel: () => _confirmCancel(context, run.id),
                    onToggleCollapse: () =>
                        bloc.add(ReportsRunCollapseToggled(run.id)),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmCancel(BuildContext context, String runId) async {
    final bloc = context.read<ReportsBloc>();
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.reportsCancelDialogTitle),
          content: Text(
            l10n.reportsCancelDialogContent,
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.reportsCancelDialogContinue),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.red),
              child: Text(l10n.reportsCancelDialogConfirm),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      bloc.add(ReportsCancelRequested(runId));
    }
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String selectedValue,
    required ValueChanged<String> onChanged,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(context, selectedValue, onChanged),
          decoration: _fieldDecoration(
            hintText: l10n.reportsDateNoFilter,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedValue.isNotEmpty)
                  IconButton(
                    tooltip: l10n.reportsDateClearTooltip,
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
                IconButton(
                  tooltip: l10n.reportsDateSelectTooltip,
                  onPressed: () => _selectDate(context, selectedValue, onChanged),
                  icon: const Icon(Icons.calendar_month_outlined, size: 18),
                ),
              ],
            ),
          ),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    String selectedValue,
    ValueChanged<String> onChanged,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _parseDate(selectedValue) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: l10n.reportsDatePickerHelp,
      cancelText: l10n.reportsDatePickerCancel,
      confirmText: l10n.reportsDatePickerConfirm,
    );

    if (!mounted || selectedDate == null) {
      return;
    }

    onChanged(DateFormat('dd.MM.yyyy').format(selectedDate));
  }

  DateTime? _parseDate(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    try {
      return DateFormat('dd.MM.yyyy').parseStrict(value.trim());
    } catch (_) {
      return null;
    }
  }

  static Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required bool enabled,
    required List<_DropdownItem<T>> items,
    required ValueChanged<T> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          decoration: _fieldDecoration(),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item.value,
                  child: Text(item.label, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: enabled
              ? (newValue) {
                  if (newValue != null) {
                    onChanged(newValue);
                  }
                }
              : null,
        ),
      ],
    );
  }

  static InputDecoration _fieldDecoration({
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      isDense: false,
      contentPadding: _fieldContentPadding,
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(
        minHeight: 48,
        minWidth: 48,
      ),
    );
  }

  List<ReportRunState> _sortedReportRuns(List<ReportRunState> runs) {
    final indexedRuns = runs.indexed.toList(growable: false);
    indexedRuns.sort((a, b) {
      final priorityCompare =
          _runPriority(a.$2).compareTo(_runPriority(b.$2));
      if (priorityCompare != 0) {
        return priorityCompare;
      }
      return a.$1.compareTo(b.$1);
    });
    return indexedRuns.map((entry) => entry.$2).toList(growable: false);
  }

  int _runPriority(ReportRunState run) {
    return switch (run.runStatus) {
      ReportsRunStatus.submitting ||
      ReportsRunStatus.running ||
      ReportsRunStatus.cancelling => 0,
      ReportsRunStatus.completed when run.isWaitingForResultUrl => 1,
      ReportsRunStatus.completed => 2,
      ReportsRunStatus.failed => 3,
      ReportsRunStatus.idle => 4,
    };
  }

  List<_DropdownItem<String>> _municipalities(AppLocalizations l10n) {
    return [
      _DropdownItem(value: '0', label: l10n.reportsAllMunicipalities),
      const _DropdownItem(value: 'Asikkala', label: 'Asikkala'),
      const _DropdownItem(value: 'Heinola', label: 'Heinola'),
      const _DropdownItem(value: 'Hollola', label: 'Hollola'),
      const _DropdownItem(value: 'Kärkölä', label: 'Kärkölä'),
      const _DropdownItem(value: 'Lahti', label: 'Lahti'),
      const _DropdownItem(value: 'Myrskylä', label: 'Myrskylä'),
      const _DropdownItem(value: 'Orimattila', label: 'Orimattila'),
      const _DropdownItem(value: 'Padasjoki', label: 'Padasjoki'),
      const _DropdownItem(value: 'Pukkila', label: 'Pukkila'),
    ];
  }

  List<_DropdownItem<int>> _propertyTypes(AppLocalizations l10n) {
    return [
      _DropdownItem(value: 0, label: l10n.reportsPropertyTypeAll),
      _DropdownItem(value: 7, label: l10n.reportsPropertyTypeResidential),
      _DropdownItem(value: 5, label: l10n.reportsPropertyTypeHapa),
      _DropdownItem(value: 6, label: l10n.reportsPropertyTypeBiohapa),
      _DropdownItem(value: 8, label: l10n.reportsPropertyTypeOther),
    ];
  }

  List<_DropdownItem<int>> _sewerOptions(AppLocalizations l10n) {
    return [
      _DropdownItem(value: 0, label: l10n.reportsSewerAll),
      _DropdownItem(value: 1, label: l10n.reportsSewerConnected),
      _DropdownItem(value: 2, label: l10n.reportsSewerNotConnected),
    ];
  }

  List<_DropdownItem<int>> _apartmentOptions(AppLocalizations l10n) {
    return [
      _DropdownItem(value: 0, label: l10n.reportsApartmentsAll),
      _DropdownItem(value: 4, label: l10n.reportsApartmentsMaxFour),
      _DropdownItem(value: 5, label: l10n.reportsApartmentsMinFive),
    ];
  }

  List<_DropdownItem<int>> _urbanAreaOptions(AppLocalizations l10n) {
    return [
      _DropdownItem(value: 0, label: l10n.reportsUrbanAreaNone),
      _DropdownItem(value: 1, label: l10n.reportsUrbanAreaOver200),
      _DropdownItem(value: 2, label: l10n.reportsUrbanAreaOver10000),
      _DropdownItem(value: 3, label: l10n.reportsUrbanAreaBoth),
    ];
  }
}

class _ReportRunCard extends StatefulWidget {
  const _ReportRunCard({
    super.key,
    required this.run,
    required this.onDismiss,
    required this.onCancel,
    required this.onToggleCollapse,
  });

  final ReportRunState run;
  final VoidCallback onDismiss;
  final VoidCallback onCancel;
  final VoidCallback onToggleCollapse;

  @override
  State<_ReportRunCard> createState() => _ReportRunCardState();
}

class _ReportRunCardState extends State<_ReportRunCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _highlightController;
  _RunHighlightTone _highlightTone = _RunHighlightTone.none;

  ReportRunState get run => widget.run;
  VoidCallback get onDismiss => widget.onDismiss;
  VoidCallback get onCancel => widget.onCancel;
  VoidCallback get onToggleCollapse => widget.onToggleCollapse;

  @override
  void initState() {
    super.initState();
    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (_isNewlyStartedRun(run)) {
      _playHighlight(_RunHighlightTone.started);
    }
  }

  @override
  void didUpdateWidget(covariant _ReportRunCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.run.runStatus != ReportsRunStatus.completed &&
        run.runStatus == ReportsRunStatus.completed) {
      _playHighlight(_RunHighlightTone.completed);
    }
  }

  bool _isNewlyStartedRun(ReportRunState run) {
    return run.id.startsWith('local-report-run-') &&
        (run.runStatus == ReportsRunStatus.submitting ||
            run.runStatus == ReportsRunStatus.running);
  }

  void _playHighlight(_RunHighlightTone tone) {
    _highlightTone = tone;
    _highlightController
      ..stop()
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _highlightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRunning = run.runStatus == ReportsRunStatus.running ||
        run.runStatus == ReportsRunStatus.submitting ||
        run.runStatus == ReportsRunStatus.cancelling;
    final isCompleted = run.runStatus == ReportsRunStatus.completed;
    final isFailed = run.runStatus == ReportsRunStatus.failed;
    final hasResultUrl = run.hasResultUrl;
    final isWaitingForResultUrl = run.isWaitingForResultUrl;

    final accentColor = isCompleted
        ? AppTheme.green
        : isFailed
            ? AppTheme.red
            : AppTheme.primaryColor;

    final accentBg = isCompleted
        ? AppTheme.greenBg
        : isFailed
            ? AppTheme.redBg
            : AppTheme.primaryLight;

    final icon = isCompleted
        ? Icons.check_circle_outline
        : isFailed
            ? Icons.error_outline
            : Icons.hourglass_top_rounded;

    return AnimatedBuilder(
      animation: _highlightController,
      builder: (context, child) {
        final highlight = Curves.easeOutCubic.transform(
          1 - _highlightController.value,
        );
        final highlightColor = switch (_highlightTone) {
          _RunHighlightTone.started => AppTheme.primaryColor,
          _RunHighlightTone.completed => AppTheme.green,
          _RunHighlightTone.none => Colors.transparent,
        };

        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: highlight > 0
                ? [
                    BoxShadow(
                      color: highlightColor.withValues(alpha: 0.10 * highlight),
                      blurRadius: 26,
                      spreadRadius: 2 * highlight,
                    ),
                  ]
                : const [],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: highlightColor.withValues(alpha: 0.34 * highlight),
                width: highlight > 0 ? 1.2 : 0.5,
              ),
            ),
            child: child,
          ),
        );
      },
      child: CardContainer(
        padding: const EdgeInsets.all(20),
        child: AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          crossFadeState: run.isCollapsed
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: _buildCollapsedCard(
            context,
            accentBg: accentBg,
            accentColor: accentColor,
            icon: icon,
          ),
          secondChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accentBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: accentColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title(l10n),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (_parameterItems(l10n).isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _parameterItems(l10n).map((item) {
                              return _ParameterChip(
                                label: item.label,
                                value: item.value,
                                isHighlighted: item.isHighlighted,
                              );
                            }).toList(growable: false),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _subtitle(l10n),
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.45,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            if (isRunning)
                              _PollingStatusChip(lastUpdatedAt: run.lastUpdatedAt),
                            if (_highlightController.isAnimating &&
                                _highlightTone == _RunHighlightTone.completed)
                              _EventStatusChip(
                                label: l10n.reportsEventJustCompleted,
                                icon: Icons.auto_awesome_rounded,
                                color: AppTheme.green,
                                background: AppTheme.greenBg,
                              ),
                            if (_highlightController.isAnimating &&
                                _highlightTone == _RunHighlightTone.started)
                              _EventStatusChip(
                                label: l10n.reportsEventStarted,
                                icon: Icons.fiber_new_rounded,
                                color: AppTheme.primaryColor,
                                background: AppTheme.primaryLight,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onToggleCollapse,
                    tooltip: l10n.reportsCollapseTooltip,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.unfold_less_rounded, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _ReportStepList(run: run),
              const SizedBox(height: 18),
              if (run.description != null && run.description!.isNotEmpty)
                _InfoRow(label: l10n.reportsTaskLabel, value: run.description!),
              if (run.taskId != null && run.taskId!.isNotEmpty)
                _InfoRow(label: l10n.reportsIdentifierLabel, value: run.taskId!),
              if (run.statusMessage != null && run.statusMessage!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _MessageBox(
                  title: isCompleted
                      ? l10n.reportsStatusTitleReady
                      : l10n.reportsStatusTitleCurrent,
                  message: run.statusMessage!,
                  color: accentColor,
                  background: accentBg,
                ),
              ],
              if (run.errorMessage != null && run.errorMessage!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _MessageBox(
                  title: l10n.reportsErrorTitle,
                  message: run.errorMessage!,
                  color: AppTheme.red,
                  background: AppTheme.redBg,
                ),
              ],
              if (run.resultFileName != null && run.resultFileName!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoRow(label: l10n.reportsFileLabel, value: run.resultFileName!),
              ],
              if (hasResultUrl) ...[
                const SizedBox(height: 8),
                _MessageBox(
                  title: l10n.reportsSharepointLinkAvailableTitle,
                  message: run.runStatus == ReportsRunStatus.completed
                      ? l10n.reportsSharepointLinkAvailableCompleted
                      : l10n.reportsSharepointLinkAvailableRunning,
                  color: AppTheme.primaryColor,
                  background: AppTheme.primaryLight,
                ),
              ],
              if (run.sharepointError != null && run.sharepointError!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _MessageBox(
                  title: l10n.reportsSharepointNoticeTitle,
                  message: run.sharepointError!,
                  color: AppTheme.amber,
                  background: AppTheme.amberBg,
                ),
              ],
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (isRunning)
                    OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.close, size: 16),
                      label: Text(l10n.reportsCancelButton),
                    ),
                  if (!isRunning)
                    FilledButton(
                      onPressed: onDismiss,
                      child: Text(
                        isCompleted ? l10n.reportsOkButton : l10n.reportsCloseButton,
                      ),
                    ),
                  if (hasResultUrl || isWaitingForResultUrl)
                    _ReportResultActionButton(
                      resultUrl: run.resultUrl,
                      showLinkPending: isWaitingForResultUrl,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedCard({
    BuildContext context,
    required Color accentBg,
    required Color accentColor,
    required IconData icon,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final hasResultUrl = run.hasResultUrl;
    final isWaitingForResultUrl = run.isWaitingForResultUrl;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onToggleCollapse,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title(l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (_parameterItems(l10n).isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _parameterItems(l10n).map((item) {
                          return _ParameterChip(
                            label: item.label,
                            value: item.value,
                            isHighlighted: item.isHighlighted,
                          );
                        }).toList(growable: false),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasResultUrl || isWaitingForResultUrl) ...[
                    _ReportResultActionButton(
                      resultUrl: run.resultUrl,
                      showLinkPending: isWaitingForResultUrl,
                    ),
                    const SizedBox(width: 8),
                  ],
                  IconButton(
                    onPressed: onToggleCollapse,
                    tooltip: l10n.reportsExpandTooltip,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.unfold_more_rounded, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _title(AppLocalizations l10n) {
    return switch (run.runStatus) {
      ReportsRunStatus.submitting => l10n.reportsRunStatusStarting,
      ReportsRunStatus.running => l10n.reportsRunStatusRunning,
      ReportsRunStatus.cancelling => l10n.reportsRunStatusCancelling,
      ReportsRunStatus.completed => l10n.reportsRunStatusCompleted,
      ReportsRunStatus.failed => l10n.reportsRunStatusFailed,
      ReportsRunStatus.idle => '',
    };
  }

  String _subtitle(AppLocalizations l10n) {
    return switch (run.runStatus) {
      ReportsRunStatus.submitting || ReportsRunStatus.running =>
        l10n.reportsRunSubtitleRunning,
      ReportsRunStatus.cancelling =>
        l10n.reportsRunSubtitleCancelling,
      ReportsRunStatus.completed =>
        l10n.reportsRunSubtitleCompleted,
      ReportsRunStatus.failed =>
        l10n.reportsRunSubtitleFailed,
      ReportsRunStatus.idle => '',
    };
  }

  List<_ParameterSummaryItem> _parameterItems(AppLocalizations l10n) {
    final parameters = run.parameters;
    if (parameters == null) {
      return const [];
    }

    return [
      _ParameterSummaryItem(
        label: l10n.reportsParameterDayLabel,
        value: parameters.tarkastelupvm.isEmpty
            ? l10n.reportsParameterDayNotFiltered
            : parameters.tarkastelupvm,
        isHighlighted: parameters.tarkastelupvm.isNotEmpty,
      ),
      _ParameterSummaryItem(
        label: l10n.reportsParameterMunicipalityLabel,
        value: parameters.kunta == '0' ? l10n.reportsAllMunicipalities : parameters.kunta,
        isHighlighted: parameters.kunta != '0',
      ),
      _ParameterSummaryItem(
        label: l10n.reportsParameterApartmentsLabel,
        value: switch (parameters.huoneistomaara) {
          4 => l10n.reportsParameterApartmentsMaxFour,
          5 => l10n.reportsParameterApartmentsMinFive,
          _ => l10n.reportsParameterApartmentsAll,
        },
        isHighlighted: parameters.huoneistomaara != 0,
      ),
      _ParameterSummaryItem(
        label: l10n.reportsParameterUrbanAreaLabel,
        value: switch (parameters.taajama) {
          1 => l10n.reportsParameterUrbanAreaOver200,
          2 => l10n.reportsParameterUrbanAreaOver10000,
          3 => l10n.reportsParameterUrbanAreaBoth,
          _ => l10n.reportsParameterUrbanAreaNone,
        },
        isHighlighted: parameters.taajama != 0,
      ),
      _ParameterSummaryItem(
        label: l10n.reportsParameterPropertyTypeLabel,
        value: switch (parameters.kohdeTyyppi) {
          7 => l10n.reportsParameterPropertyTypeResidential,
          5 => l10n.reportsParameterPropertyTypeHapa,
          6 => l10n.reportsParameterPropertyTypeBiohapa,
          8 => l10n.reportsParameterPropertyTypeOther,
          _ => l10n.reportsParameterPropertyTypeAll,
        },
        isHighlighted: parameters.kohdeTyyppi != 0,
      ),
      _ParameterSummaryItem(
        label: l10n.reportsParameterSewerLabel,
        value: switch (parameters.onkoViemari) {
          1 => l10n.reportsParameterSewerConnected,
          2 => l10n.reportsParameterSewerNotConnected,
          _ => l10n.reportsParameterSewerAll,
        },
        isHighlighted: parameters.onkoViemari != 0,
      ),
    ].where((item) => item.isHighlighted).toList(growable: false);
  }

}

enum _RunHighlightTone { none, started, completed }

class _PollingStatusChip extends StatefulWidget {
  const _PollingStatusChip({required this.lastUpdatedAt});

  final DateTime? lastUpdatedAt;

  @override
  State<_PollingStatusChip> createState() => _PollingStatusChipState();
}

class _PollingStatusChipState extends State<_PollingStatusChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _EventStatusChip(
      label: _label(l10n),
      icon: Icons.sync,
      color: AppTheme.primaryColor,
      background: AppTheme.primaryLight,
      turns: _controller,
    );
  }

  String _label(AppLocalizations l10n) {
    final lastUpdatedAt = widget.lastUpdatedAt;
    if (lastUpdatedAt == null) {
      return l10n.reportsPollingUpdating;
    }

    final seconds = DateTime.now().difference(lastUpdatedAt).inSeconds;
    if (seconds <= 1) {
      return l10n.reportsPollingUpdatedJustNow;
    }
    if (seconds < 10) {
      return l10n.reportsPollingUpdatedSecondsAgo(seconds);
    }
    return l10n.reportsPollingUpdating;
  }
}

class _EventStatusChip extends StatelessWidget {
  const _EventStatusChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
    this.turns,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color background;
  final Animation<double>? turns;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: 14, color: color);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (turns != null)
            RotationTransition(turns: turns!, child: iconWidget)
          else
            iconWidget,
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParameterSummaryItem {
  const _ParameterSummaryItem({
    required this.label,
    required this.value,
    required this.isHighlighted,
  });

  final String label;
  final String value;
  final bool isHighlighted;
}

class _ParameterChip extends StatelessWidget {
  const _ParameterChip({
    required this.label,
    required this.value,
    required this.isHighlighted,
  });

  final String label;
  final String value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isHighlighted
        ? AppTheme.primaryLight
        : AppTheme.background2;
    final borderColor = isHighlighted
        ? AppTheme.primaryColor.withValues(alpha: 0.35)
        : Theme.of(context).colorScheme.outlineVariant;
    final labelColor = isHighlighted
        ? AppTheme.primaryDark
        : AppTheme.textSecondary;
    final valueColor = isHighlighted
        ? AppTheme.primaryDark
        : AppTheme.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 11,
            color: valueColor,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _ReportResultActionButton extends StatefulWidget {
  const _ReportResultActionButton({
    required this.resultUrl,
    required this.showLinkPending,
  });

  final String? resultUrl;
  final bool showLinkPending;

  @override
  State<_ReportResultActionButton> createState() =>
      _ReportResultActionButtonState();
}

class _ReportResultActionButtonState extends State<_ReportResultActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant _ReportResultActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showLinkPending != widget.showLinkPending) {
      _syncPulse();
    }
  }

  void _syncPulse() {
    if (widget.showLinkPending) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 1;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(animation);

        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axis: Axis.horizontal,
            axisAlignment: -1,
            child: SlideTransition(
              position: slide,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
                child: child,
              ),
            ),
          ),
        );
      },
      child: widget.showLinkPending
          ? _buildPendingButton(context)
          : _buildOpenButton(),
    );
  }

  Widget _buildPendingButton(BuildContext context) {
    final buttonTheme = Theme.of(context).elevatedButtonTheme.style;

    return AnimatedBuilder(
      key: const ValueKey('pending-link-button'),
      animation: _pulseController,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_pulseController.value);
        final scale = 1 + (t * 0.025);
        final glowOpacity = 0.10 + (t * 0.10);

        return Transform.scale(
          scale: scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: glowOpacity),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: ElevatedButton.icon(
        onPressed: null,
        style: buttonTheme?.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return AppTheme.primaryLight;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return AppTheme.primaryDark.withValues(alpha: 0.88);
          }),
          side: WidgetStatePropertyAll(
            BorderSide(
              color: AppTheme.primaryColor.withValues(alpha: 0.24),
            ),
          ),
          elevation: const WidgetStatePropertyAll(0),
        ),
        icon: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.primaryColor,
            ),
          ),
        ),
        label: Text(l10n.reportsButtonFetchingLink),
      ),
    );
  }

  Widget _buildOpenButton() {
    final l10n = AppLocalizations.of(context)!;
    return ElevatedButton.icon(
      key: const ValueKey('open-report-button'),
      onPressed: () => launchUrl(
        Uri.parse(widget.resultUrl!),
        mode: LaunchMode.externalApplication,
      ),
      icon: const Icon(Icons.open_in_new, size: 16),
      label: Text(l10n.reportsButtonOpenReport),
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({
    required this.title,
    required this.message,
    required this.color,
    required this.background,
  });

  final String title;
  final String message;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportStepList extends StatelessWidget {
  const _ReportStepList({required this.run});

  final ReportRunState run;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = _steps(l10n);
    final activeIndex = _activeStepIndex(run);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final status = _stepStatus(index, activeIndex);
        return Padding(
          padding: EdgeInsets.only(bottom: index == steps.length - 1 ? 0 : 12),
          child: _ReportStepRow(
            label: steps[index],
            status: status,
          ),
        );
      }),
    );
  }

  List<String> _steps(AppLocalizations l10n) {
    return [
      l10n.reportsStepFetchTargets,
      l10n.reportsStepApplyObligationFilters,
      l10n.reportsStepCreateReport,
      l10n.reportsStepExportSharepoint,
    ];
  }

  _ReportStepVisualStatus _stepStatus(int index, int activeIndex) {
    final isCompleted = run.runStatus == ReportsRunStatus.completed;
    final isFailed = run.runStatus == ReportsRunStatus.failed;

    if (isCompleted) {
      return _ReportStepVisualStatus.completed;
    }
    if (index < activeIndex) {
      return _ReportStepVisualStatus.completed;
    }
    if (index == activeIndex) {
      return isFailed
          ? _ReportStepVisualStatus.failed
          : _ReportStepVisualStatus.active;
    }
    return _ReportStepVisualStatus.pending;
  }

  int _activeStepIndex(ReportRunState run) {
    if (run.runStatus == ReportsRunStatus.completed) {
      return 3;
    }

    final text = [
      run.statusMessage,
      run.description,
      run.sharepointError,
      run.resultFileName,
    ].whereType<String>().join(' ').toLowerCase();

    if (text.contains('sharepoint')) {
      return 3;
    }
    if (text.contains('csv') ||
        text.contains('excel') ||
        text.contains('raportti') ||
        text.contains('muodost')) {
      return 2;
    }
    if (text.contains('velvoite') || text.contains('rajaus')) {
      return 1;
    }
    if (text.contains('kohde') || text.contains('kanta') || text.contains('hae')) {
      return 0;
    }
    if (run.runStatus == ReportsRunStatus.submitting) {
      return 0;
    }
    if (run.runStatus == ReportsRunStatus.cancelling) {
      return 2;
    }
    return 2;
  }
}

enum _ReportStepVisualStatus {
  pending,
  active,
  completed,
  failed,
}

class _ReportStepRow extends StatelessWidget {
  const _ReportStepRow({
    required this.label,
    required this.status,
  });

  final String label;
  final _ReportStepVisualStatus status;

  @override
  Widget build(BuildContext context) {
    final isPending = status == _ReportStepVisualStatus.pending;
    final isActive = status == _ReportStepVisualStatus.active;
    final isCompleted = status == _ReportStepVisualStatus.completed;
    final isFailed = status == _ReportStepVisualStatus.failed;
    final neutralColor = Theme.of(context).colorScheme.outlineVariant;

    final accentColor = isFailed
        ? AppTheme.red
        : isCompleted
            ? AppTheme.green
            : AppTheme.primaryColor;
    final accentBackground = isFailed
        ? AppTheme.redBg
        : isCompleted
            ? AppTheme.greenBg
            : AppTheme.primaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isPending ? Colors.transparent : accentBackground,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isPending ? neutralColor : accentColor,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check, size: 12, color: AppTheme.green)
                    : isFailed
                        ? Icon(Icons.close, size: 12, color: AppTheme.red)
                        : isActive
                            ? SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryColor,
                                ),
                              )
                            : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isPending ? FontWeight.w400 : FontWeight.w500,
                  color: isPending ? AppTheme.textSecondary : AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 26),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: isPending ? 0 : isActive ? null : 1,
              backgroundColor: neutralColor,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownItem<T> {
  const _DropdownItem({required this.value, required this.label});

  final T value;
  final String label;
}
