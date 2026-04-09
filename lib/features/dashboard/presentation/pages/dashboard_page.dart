import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/card_container.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../../../../shared/widgets/responsive_grid.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metric cards row 1
          ResponsiveGrid(
            minChildWidth: 180,
            spacing: 10,
            children: [
              MetricCard(
                label: 'Viimeisin tuonti',
                value: '24.3.2025',
                valueFontSize: 14,
                sub: 'Onnistui',
                subColor: AppTheme.green,
              ),
              MetricCard(
                label: 'Kohdentuneet',
                value: '18 432',
                sub: '94,2 %',
                subColor: AppTheme.green,
              ),
              MetricCard(
                label: 'Kohdentumattomat',
                value: '1 128',
                valueColor: AppTheme.amber,
                sub: '5,8 %',
                subColor: AppTheme.amber,
              ),
              MetricCard(
                label: 'Velvoitepuutteet',
                value: '342',
                valueColor: AppTheme.amber,
                sub: '↑ 12 viikosta',
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Metric cards row 2
          const ResponsiveGrid(
            minChildWidth: 160,
            spacing: 10,
            children: [
              MetricCard(label: 'Velvoitetarkistus ajettu', value: '20.3.2025', valueFontSize: 14, sub: 'klo 09:00'),
              MetricCard(label: 'Viimeisin raportti generoitu', value: '21.3.2025', valueFontSize: 14, sub: 'klo 10:45'),
              MetricCard(label: 'Uusin päätös kannassa', value: '18.3.2025', valueFontSize: 14, sub: '—'),
              MetricCard(label: 'Uusin kompostointi-ilmoitus', value: '15.3.2025', valueFontSize: 14, sub: '—'),
              MetricCard(label: 'Lietekulj. viimeisin tyhjennys', value: '12.3.2025', valueFontSize: 14, sub: '—'),
              MetricCard(label: 'Kiinteän kulj. viimeisin kvartaali', value: 'Q4 / 2024', valueFontSize: 14, sub: '—'),
            ],
          ),
          const SizedBox(height: 14),
          // Activity + Chart
          ResponsiveGrid(
            minChildWidth: 350,
            spacing: 14,
            children: [
              _buildActivityCard(),
              _buildChartAndFeedCard(),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildActivityCard() {
    final events = [
      _ActivityEvent(status: 'ok', text: 'DVV-aineisto tuotu (Q1/2025) — 1 938 riviä, 1 204 uutta kohdetta', time: '24.3. 08:14'),
      _ActivityEvent(status: 'ok', text: 'Varmuuskopio otettu automaattisesti — 412 Mt', time: '23.3. 22:00'),
      _ActivityEvent(status: 'ok', text: 'Raportti generoitu: velvoitepuutteet 31.3.2025 — viety Sharepointiin', time: '21.3. 10:45'),
      _ActivityEvent(status: 'warn', text: 'Velvoitetarkistus ajettu — 342 puutetta, 1 128 kohdentumatta', time: '20.3. 09:00'),
      _ActivityEvent(status: 'err', text: 'Päätöstiedot Q4/2024 — tuontivirhe, sarake "paatospvm" puuttuu', time: '20.3. 09:05'),
      _ActivityEvent(status: 'ok', text: 'Kuljetustiedot Q1/2025 tuotu — 12 479 riviä, 34 kohdentumatta', time: '18.3. 14:30'),
      _ActivityEvent(status: 'ok', text: 'Velvoitteet asetettu — 18 432 kohdetta käsitelty', time: '18.3. 10:00'),
      _ActivityEvent(status: 'ok', text: 'Varmuuskopio otettu automaattisesti — 408 Mt', time: '17.3. 22:00'),
      _ActivityEvent(status: 'ok', text: 'Kompostointi-ilmoitukset Q1/2025 tuotu — 412 riviä', time: '15.3. 11:20'),
      _ActivityEvent(status: 'warn', text: 'Kompostointi: 3 ilmoitusta ei kohdentuneet PRT-tunnukseen', time: '15.3. 11:21'),
    ];

    return CardContainer(
      title: 'Viimeisimmät järjestelmätapahtumat',
      child: Column(
        children: [
          for (int i = 0; i < events.length; i++)
            _ActivityRow(event: events[i], isLast: i == events.length - 1),
        ],
      ),
    );
  }

  static Widget _buildChartAndFeedCard() {
    return CardContainer(
      title: 'Velvoitepuutteet kunnittain',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart placeholder
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.background2,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const _BarChartPlaceholder(),
          ),
          const SizedBox(height: 14),
          Text(
            'Viimeisimmät kohdemerkinnät',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const _CrmFeedItem(icon: '✉', iconBg: Color(0xFFE0F2FE), iconColor: Color(0xFF075985), name: 'Asoy Koti (1002)', text: 'Huomautus puuttuvasta biojätesopimuksesta', time: '24.3. 09:02'),
          const _CrmFeedItem(icon: '☎', iconBg: Color(0xFFDCFCE7), iconColor: Color(0xFF166534), name: 'Liisa L. (1003)', text: 'Puhelinkeskustelu: tilaa kuljetuksen', time: '23.3. 14:20'),
          const _CrmFeedItem(icon: '!', iconBg: Color(0xFFFAE8FF), iconColor: Color(0xFF6B21A8), name: 'Asoy Puu (1004)', text: 'Kirjehuomautus lähetetty (Posti)', time: '21.3. 08:30'),
        ],
      ),
    );
  }
}

// ─── ACTIVITY ROW ────────────────────────────────────────────────────────────

class _ActivityEvent {
  final String status;
  final String text;
  final String time;
  const _ActivityEvent({required this.status, required this.text, required this.time});
}

class _ActivityRow extends StatelessWidget {
  final _ActivityEvent event;
  final bool isLast;
  const _ActivityRow({super.key, required this.event, this.isLast = false});

  Color get _dotColor => switch (event.status) {
    'ok' => const Color(0xFF22C55E),
    'warn' => const Color(0xFFD97706),
    'err' => const Color(0xFFEF4444),
    _ => const Color(0xFF22C55E),
  };

  @override
  Widget build(BuildContext context) {
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
            child: Text(event.text, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ),
          const SizedBox(width: 8),
          Text(event.time, style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
        ],
      ),
    );
  }
}

// ─── CRM FEED ITEM ───────────────────────────────────────────────────────────

class _CrmFeedItem extends StatelessWidget {
  final String icon;
  final Color iconBg;
  final Color iconColor;
  final String name;
  final String text;
  final String time;

  const _CrmFeedItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.name,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
            child: Center(child: Text(icon, style: TextStyle(fontSize: 10, color: iconColor))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: name, style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                TextSpan(text: ' — $text'),
              ]),
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Text(time, style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
        ],
      ),
    );
  }
}

// ─── BAR CHART PLACEHOLDER ───────────────────────────────────────────────────

class _BarChartPlaceholder extends StatelessWidget {
  const _BarChartPlaceholder();

  @override
  Widget build(BuildContext context) {
    final data = [
      ('Lahti', 142),
      ('Heinola', 87),
      ('Asikkala', 54),
      ('Padasjoki', 30),
      ('Hollola', 19),
      ('Nastola', 10),
    ];
    const maxVal = 142;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < data.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${data[i].$2}', style: TextStyle(fontSize: 9, color: AppTheme.textTertiary)),
                  const SizedBox(height: 4),
                  Container(
                    height: (data[i].$2 / maxVal) * 140,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data[i].$1,
                    style: TextStyle(fontSize: 9, color: AppTheme.textTertiary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
