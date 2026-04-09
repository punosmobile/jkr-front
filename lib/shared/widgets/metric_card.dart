import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final double valueFontSize;
  final Color? valueColor;
  final String? sub;
  final Color? subColor;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.valueFontSize = 18,
    this.valueColor,
    this.sub,
    this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border.all(color: Colors.black.withValues(alpha: 0.10), width: 0.5),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 3),
            Text(sub!, style: TextStyle(fontSize: 11, color: subColor ?? AppTheme.textTertiary)),
          ],
        ],
      ),
    );
  }
}
