import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final double valueFontSize;
  final Color? valueColor;
  final String? sub;
  final Color? subColor;
  final double? height;
  final int labelMaxLines;
  final int valueMaxLines;
  final int subMaxLines;
  final VoidCallback? onTap;
  final IconData? trailingIcon;
  final String? trailingTooltip;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.valueFontSize = 18,
    this.valueColor,
    this.sub,
    this.subColor,
    this.height,
    this.labelMaxLines = 2,
    this.valueMaxLines = 1,
    this.subMaxLines = 2,
    this.onTap,
    this.trailingIcon,
    this.trailingTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border.all(color: Colors.black.withValues(alpha: 0.10), width: 0.5),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: labelMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: trailingTooltip ?? '',
                  child: Icon(
                    trailingIcon,
                    size: 14,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: valueMaxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 3),
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  sub!,
                  maxLines: subMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: subColor ?? AppTheme.textTertiary),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        hoverColor: AppTheme.background2,
        child: card,
      ),
    );
  }
}
