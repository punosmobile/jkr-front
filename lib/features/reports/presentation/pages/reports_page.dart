import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
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

  static const _municipalities = <_DropdownItem<String>>[
    _DropdownItem(value: '0', label: 'Kaikki kunnat'),
    _DropdownItem(value: 'Asikkala', label: 'Asikkala'),
    _DropdownItem(value: 'Heinola', label: 'Heinola'),
    _DropdownItem(value: 'Hollola', label: 'Hollola'),
    _DropdownItem(value: 'Kärkölä', label: 'Kärkölä'),
    _DropdownItem(value: 'Lahti', label: 'Lahti'),
    _DropdownItem(value: 'Myrskylä', label: 'Myrskylä'),
    _DropdownItem(value: 'Orimattila', label: 'Orimattila'),
    _DropdownItem(value: 'Padasjoki', label: 'Padasjoki'),
    _DropdownItem(value: 'Pukkila', label: 'Pukkila'),
  ];

  static const _propertyTypes = <_DropdownItem<int>>[
    _DropdownItem(value: 0, label: 'Kaikki / ei rajausta'),
    _DropdownItem(value: 7, label: 'Asuinkiinteistö'),
    _DropdownItem(value: 5, label: 'HAPA'),
    _DropdownItem(value: 6, label: 'Biohapa'),
    _DropdownItem(value: 8, label: 'Muu'),
  ];

  static const _sewerOptions = <_DropdownItem<int>>[
    _DropdownItem(value: 0, label: 'Kaikki'),
    _DropdownItem(value: 1, label: 'Viemäriverkostossa'),
    _DropdownItem(value: 2, label: 'Ei viemäriverkostossa'),
  ];

  static const _apartmentOptions = <_DropdownItem<int>>[
    _DropdownItem(value: 0, label: 'Kaikki huoneistomäärät'),
    _DropdownItem(value: 4, label: 'Enintään neljä'),
    _DropdownItem(value: 5, label: 'Vähintään viisi'),
  ];

  static const _urbanAreaOptions = <_DropdownItem<int>>[
    _DropdownItem(value: 0, label: 'Ei rajausta'),
    _DropdownItem(value: 1, label: 'Yli 200 asukasta'),
    _DropdownItem(value: 2, label: 'Yli 10 000 asukasta'),
    _DropdownItem(value: 3, label: 'Molemmat taajamarajaukset'),
  ];

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
                      'Excel-raportti',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Luo JKR-raportti valituilla rajauksilla. Valmis tiedosto tallennetaan oletuksena SharePointiin, ja raportin eteneminen näkyy tässä näkymässä reaaliajassa.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Rajaukset',
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
                        _buildTextField(
                          label: 'Tarkastelupäivämäärä',
                          hint: 'esim. 31.03.2025',
                          controller: _dateController,
                          enabled: !state.isBusy,
                          onChanged: (value) => bloc.add(ReportsDateChanged(value)),
                        ),
                        _buildDropdownField<String>(
                          label: 'Kunta',
                          value: state.kunta,
                          enabled: !state.isBusy,
                          items: _municipalities,
                          onChanged: (value) => bloc.add(ReportsMunicipalityChanged(value)),
                        ),
                        _buildDropdownField<int>(
                          label: 'Huoneistolukumäärä',
                          value: state.huoneistomaara,
                          enabled: !state.isBusy,
                          items: _apartmentOptions,
                          onChanged: (value) => bloc.add(ReportsApartmentCountChanged(value)),
                        ),
                        _buildDropdownField<int>(
                          label: 'Taajaman rajaus',
                          value: state.taajama,
                          enabled: !state.isBusy,
                          items: _urbanAreaOptions,
                          onChanged: (value) => bloc.add(ReportsUrbanAreaChanged(value)),
                        ),
                        _buildDropdownField<int>(
                          label: 'Kohdetyyppi',
                          value: state.kohdeTyyppi,
                          enabled: !state.isBusy,
                          items: _propertyTypes,
                          onChanged: (value) => bloc.add(ReportsPropertyTypeChanged(value)),
                        ),
                        _buildDropdownField<int>(
                          label: 'Viemäriverkosto',
                          value: state.onkoViemari,
                          enabled: !state.isBusy,
                          items: _sewerOptions,
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
                              'Raportin luonti käynnistyy taustalla. “Aja raportti” poistuu käytöstä ajon ajaksi, ja voit seurata tilaa muodostusnäkymässä. Peruuttaminen vaatii erillisen vahvistuksen.',
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
                          onPressed: state.isBusy
                              ? null
                              : () => bloc.add(const ReportsRunRequested()),
                          icon: state.isBusy
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.table_chart_outlined, size: 16),
                          label: Text(
                            state.isBusy ? 'Raporttia ajetaan...' : 'Aja raportti',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (state.runStatus != ReportsRunStatus.idle) ...[
                const SizedBox(height: 16),
                _ReportProgressCard(
                  state: state,
                  onDismiss: () => bloc.add(const ReportsDialogDismissed()),
                  onCancel: () => _confirmCancel(context),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final bloc = context.read<ReportsBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Peruuta raportin luonti?'),
          content: const Text(
            'Raportin muodostus on käynnissä. Haluatko varmasti lähettää peruutuspyynnön?',
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Jatka muodostusta'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.red),
              child: const Text('Peruuta raportti'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      bloc.add(const ReportsCancelRequested());
    }
  }

  static Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool enabled,
    required ValueChanged<String> onChanged,
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
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(hintText: hint),
          style: const TextStyle(fontSize: 12),
          onChanged: onChanged,
        ),
      ],
    );
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
          decoration: const InputDecoration(),
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
}

class _ReportProgressCard extends StatelessWidget {
  const _ReportProgressCard({
    required this.state,
    required this.onDismiss,
    required this.onCancel,
  });

  final ReportsState state;
  final VoidCallback onDismiss;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final isRunning = state.runStatus == ReportsRunStatus.running ||
        state.runStatus == ReportsRunStatus.submitting ||
        state.runStatus == ReportsRunStatus.cancelling;
    final isCompleted = state.runStatus == ReportsRunStatus.completed;
    final isFailed = state.runStatus == ReportsRunStatus.failed;
    final hasResultUrl = state.resultUrl != null && state.resultUrl!.isNotEmpty;
    final isWaitingForResultUrl = isCompleted && !hasResultUrl;

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

    return CardContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      _title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ReportStepList(state: state),
          const SizedBox(height: 18),
          if (state.currentDescription != null && state.currentDescription!.isNotEmpty)
            _InfoRow(label: 'Tehtävä', value: state.currentDescription!),
          if (state.currentTaskId != null && state.currentTaskId!.isNotEmpty)
            _InfoRow(label: 'Tunniste', value: state.currentTaskId!),
          if (state.statusMessage != null && state.statusMessage!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _MessageBox(
              title: isCompleted ? 'Valmis' : 'Tilanne',
              message: state.statusMessage!,
              color: accentColor,
              background: accentBg,
            ),
          ],
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _MessageBox(
              title: 'Virhe',
              message: state.errorMessage!,
              color: AppTheme.red,
              background: AppTheme.redBg,
            ),
          ],
          if (state.resultFileName != null && state.resultFileName!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoRow(label: 'Tiedosto', value: state.resultFileName!),
          ],
          if (hasResultUrl) ...[
            const SizedBox(height: 8),
            _MessageBox(
              title: 'SharePoint-linkki saatavilla',
              message: state.runStatus == ReportsRunStatus.completed
                  ? 'Raportti on avattavissa SharePointissa.'
                  : 'Raportin SharePoint-linkki on jo saatavilla, vaikka ajo on vielä käynnissä.',
              color: AppTheme.primaryColor,
              background: AppTheme.primaryLight,
            ),
          ],
          if (state.sharepointError != null && state.sharepointError!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _MessageBox(
              title: 'SharePoint-huomio',
              message: state.sharepointError!,
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
                  label: const Text('Peruuta raportin luonti'),
                ),
              if (!isRunning)
                FilledButton(
                  onPressed: onDismiss,
                  child: Text(isCompleted ? 'OK' : 'Sulje'),
                ),
              if (hasResultUrl || isWaitingForResultUrl)
                _ReportResultActionButton(
                  resultUrl: state.resultUrl,
                  showLinkPending: isWaitingForResultUrl,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String get _title {
    return switch (state.runStatus) {
      ReportsRunStatus.submitting => 'Raporttia käynnistetään',
      ReportsRunStatus.running => 'Raporttia muodostetaan',
      ReportsRunStatus.cancelling => 'Raporttia peruutetaan',
      ReportsRunStatus.completed => 'Raportti on luotu',
      ReportsRunStatus.failed => 'Raportin luonti epäonnistui',
      ReportsRunStatus.idle => '',
    };
  }

  String get _subtitle {
    return switch (state.runStatus) {
      ReportsRunStatus.submitting || ReportsRunStatus.running =>
        'Palvelin muodostaa raporttia taustalla. Näet tähän näkymään raportin viimeisimmän etenemistiedon.',
      ReportsRunStatus.cancelling =>
        'Peruutuspyyntö on lähetetty. Odota, että palvelin vahvistaa raportin pysäyttämisen.',
      ReportsRunStatus.completed =>
        'Raportti valmistui onnistuneesti. Voit sulkea tämän näkymän OK-painikkeella.',
      ReportsRunStatus.failed =>
        'Raportin luonti pysähtyi virheeseen tai peruutukseen. Tarkista alla oleva viesti.',
      ReportsRunStatus.idle => '',
    };
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
        label: const Text('Haetaan linkkiä'),
      ),
    );
  }

  Widget _buildOpenButton() {
    return ElevatedButton.icon(
      key: const ValueKey('open-report-button'),
      onPressed: () => launchUrl(
        Uri.parse(widget.resultUrl!),
        mode: LaunchMode.externalApplication,
      ),
      icon: const Icon(Icons.open_in_new, size: 16),
      label: const Text('Avaa raportti'),
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
  const _ReportStepList({required this.state});

  final ReportsState state;

  static const _steps = <String>[
    'Haetaan kohdetiedot kannasta',
    'Sovelletaan velvoiterajaukset',
    'Muodostetaan raportti',
    'Viedään SharePointiin',
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = _activeStepIndex(state);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_steps.length, (index) {
        final status = _stepStatus(index, activeIndex);
        return Padding(
          padding: EdgeInsets.only(bottom: index == _steps.length - 1 ? 0 : 12),
          child: _ReportStepRow(
            label: _steps[index],
            status: status,
          ),
        );
      }),
    );
  }

  _ReportStepVisualStatus _stepStatus(int index, int activeIndex) {
    final isCompleted = state.runStatus == ReportsRunStatus.completed;
    final isFailed = state.runStatus == ReportsRunStatus.failed;

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

  int _activeStepIndex(ReportsState state) {
    if (state.runStatus == ReportsRunStatus.completed) {
      return _steps.length - 1;
    }

    final text = [
      state.statusMessage,
      state.currentDescription,
      state.sharepointError,
      state.resultFileName,
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
    if (state.runStatus == ReportsRunStatus.submitting) {
      return 0;
    }
    if (state.runStatus == ReportsRunStatus.cancelling) {
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
