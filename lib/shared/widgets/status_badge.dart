import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final String type;
  const StatusBadge({super.key, required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (type) {
      'new' => (AppTheme.greenBg, AppTheme.green),
      'update' => (AppTheme.primaryLight, AppTheme.primaryColor),
      'warn' => (AppTheme.amberBg, AppTheme.amber),
      'error' => (AppTheme.redBg, AppTheme.red),
      _ => (AppTheme.background2, AppTheme.textTertiary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}
