import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/card_container.dart';
import '../../../../shared/widgets/responsive_grid.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          ResponsiveGrid(
            minChildWidth: 280,
            spacing: 14,
            children: [
              CardContainer(
                title: 'Järjestelmätiedot',
                child: Table(
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                  },
                  children: [
                    _infoRow('Versio', 'v0.7.5'),
                    _infoRow('Tietokanta', 'PostgreSQL 15 / PostGIS'),
                    _infoRow('Ympäristö', 'Tuotanto'),
                    _infoRow('Päivitetty', '25.11.2025'),
                  ],
                ),
              ),
              CardContainer(
                title: 'Pikaohjeet',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _helpItem('Tietojen tuonti', 'valitse Sharepoint-listalta tai tuo käsin, esianalysoi ennen ajoa.'),
                    const SizedBox(height: 5),
                    _helpItem('Tarkastelupäivämäärä', 'päivä, jonka mukaan velvoitteiden tila raportilla lasketaan.'),
                    const SizedBox(height: 5),
                    _helpItem('PRT', 'pysyvä rakennustunnus, yksilöi kiinteistön.'),
                    const SizedBox(height: 5),
                    _helpItem('Varmuuskopio', 'automaattinen ajo joka yö 22:00.'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          CardContainer(
            title: 'Tuki',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lähetä viesti järjestelmätuelle. Vastausaika 1–2 arkipäivää.',
                  style: TextStyle(fontSize: 11, color: AppTheme.textTertiary, height: 1.55),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 560,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Otsikko', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      const TextField(
                        decoration: InputDecoration(hintText: 'Lyhyt kuvaus ongelmasta'),
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Text('Viesti', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      const TextField(
                        decoration: InputDecoration(hintText: 'Kuvaile ongelma tarkemmin...'),
                        style: TextStyle(fontSize: 12),
                        maxLines: 4,
                        minLines: 3,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: () {}, child: const Text('Lähetä tukipyyntö')),
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

  static TableRow _infoRow(String label, String value) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        child: Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        child: Text(value, style: const TextStyle(fontSize: 12)),
      ),
    ]);
  }

  static Widget _helpItem(String title, String text) {
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: '$title — ', style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        TextSpan(text: text),
      ]),
      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.9),
    );
  }
}
