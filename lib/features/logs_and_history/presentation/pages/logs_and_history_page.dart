import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/card_container.dart';
import '../../data/models/logs_and_history_models.dart';

class LogsAndHistoryPage extends StatelessWidget {
  final String title;
  const LogsAndHistoryPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: CardContainer(
        title: title,
        child: Text(
          'TEST.',
          style: TextStyle(color: AppTheme.amber, fontSize: 11, height: 1.55),
        ),
      ),
    );
  }
}
/* 
class _ImportLogRow extends StatelessWidget {
  const _ImportLogRow({
    required this.entry,
    this.isLast = false,
  });

  final LogHistoryImportLogItem entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showImportLogDetailsDialog(context, entry),
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.background2,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: isLast
              ? null
              : BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black.withValues(alpha: 0.10),
                      width: 0.5,
                    ),
                  ),
                ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.tyyppi ?? l10n.dashboardImportLogTypeOther,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (_buildImportLogDetail(l10n, entry).isNotEmpty) ...[
                      const SizedBox(height: 2),
                      RichText(
                        text: _buildImportLogDetailSpan(l10n, entry),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.open_in_full_rounded,
                    size: 14,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatImportLogTime(entry),
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} */