import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class CardContainer extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsets? padding;

  const CardContainer({super.key, this.title, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border.all(color: Colors.black.withValues(alpha: 0.10), width: 0.5),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(title!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
            const SizedBox(height: 10),
          ],
          child,
        ],
      ),
    );
  }
}
