import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/card_container.dart';
import '../../../../shared/widgets/responsive_grid.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Raporttipohjat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDropdown(['— Omat pohjat —', 'Velvoitepuutteet kunnittain', 'Kohdentumattomat Q1']),
                    _buildDropdown(['— Jaetut pohjat —', 'Vuosiraportti', 'Kuljetusvertailu']),
                  ],
                ),
                const SizedBox(height: 18),
                Text('Rajaukset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                const SizedBox(height: 10),
                ResponsiveGrid(
                  minChildWidth: 200,
                  spacing: 12,
                  children: [
                    _buildFormField('Tarkastelupäivämäärä', '31.03.2025'),
                    _buildSelectField('Kohdetyyppi', ['Kaikki / ei rajausta', 'Asuinkiinteistö', 'HAPA', 'Biohapa', 'Muu']),
                    _buildSelectField('Viemäriverkosto', ['Kaikki', 'Viemäriverkostossa', 'Ei viemäriverkostossa']),
                    _buildFormField('Kunta', 'Kaikki kunnat'),
                    _buildSelectField('Huoneistolukumäärä', ['Kaikki huoneistomäärät', 'Enintään neljä', 'Vähintään viisi']),
                    _buildFormField('Velvoitteen tallennuspäivämäärä', ''),
                    _buildSelectField('Taajaman rajaus', ['Ei rajausta', 'Yli 200 asukasta', 'Yli 10 000 asukasta', 'Kaikki taajamat']),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(onPressed: () {}, child: const Text('Aja raportti')),
                    OutlinedButton(onPressed: () {}, child: const Text('Tallenna pohjaksi')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDropdown(List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withValues(alpha: 0.20)),
        borderRadius: BorderRadius.circular(7),
        color: AppTheme.background,
      ),
      child: DropdownButton<String>(
        value: items.first,
        isDense: true,
        underline: const SizedBox.shrink(),
        style: TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontFamily: AppTheme.fontFamily),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (_) {},
      ),
    );
  }

  static Widget _buildFormField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(hintText: hint),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  static Widget _buildSelectField(String label, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black.withValues(alpha: 0.20)),
            borderRadius: BorderRadius.circular(7),
            color: AppTheme.background,
          ),
          child: DropdownButton<String>(
            value: options.first,
            isDense: true,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            style: TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontFamily: AppTheme.fontFamily),
            items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (_) {},
          ),
        ),
      ],
    );
  }
}
