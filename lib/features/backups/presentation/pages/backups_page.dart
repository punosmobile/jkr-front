import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class BackupsPage extends StatelessWidget {
  const BackupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Varmuuskopiot', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ElevatedButton(onPressed: () {}, child: const Text('+ Ota varmuuskopio nyt')),
            ],
          ),
          const SizedBox(height: 14),
          const _BackupRow(name: 'jkr_backup_20250324_220000.dump', meta: '24.3.2025 22:00 · 412 Mt · automaattinen'),
          const SizedBox(height: 8),
          const _BackupRow(name: 'jkr_backup_20250323_220000.dump', meta: '23.3.2025 22:00 · 410 Mt · automaattinen'),
          const SizedBox(height: 8),
          const _BackupRow(name: 'jkr_backup_20250320_manual.dump', meta: '20.3.2025 09:12 · 408 Mt · manuaalinen — Matti M.'),
        ],
      ),
    );
  }
}

class _BackupRow extends StatelessWidget {
  final String name;
  final String meta;
  const _BackupRow({required this.name, required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.background2,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          Icon(Icons.radio_button_checked, size: 14, color: AppTheme.textTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(meta, style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
            child: const Text('Palauta', style: TextStyle(fontSize: 11)),
          ),
          const SizedBox(width: 6),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              foregroundColor: AppTheme.red,
              side: BorderSide(color: AppTheme.red),
            ),
            child: const Text('Poista', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
