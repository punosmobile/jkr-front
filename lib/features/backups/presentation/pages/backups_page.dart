import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:jkrfront/core/theme/app_theme.dart';
import 'package:jkrfront/features/backups/data/models/backup_info.dart';
import 'package:jkrfront/features/backups/data/repositories/backups_repository.dart';
import 'package:jkrfront/features/backups/presentation/bloc/backups_bloc.dart';
import 'package:jkrfront/features/backups/presentation/bloc/backups_event.dart';
import 'package:jkrfront/features/backups/presentation/bloc/backups_state.dart';

/// Feature entry point that wires the backups page to its bloc.
class BackupsPage extends StatelessWidget {
  const BackupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          BackupsBloc(repository: BackupsRepository())..add(const BackupsStarted()),
      child: const _BackupsView(),
    );
  }
}

class _BackupsView extends StatelessWidget {
  const _BackupsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BackupsBloc, BackupsState>(
      listenWhen: (previous, current) => previous.feedback != current.feedback,
      listener: (context, state) {
        final feedback = state.feedback;
        if (feedback == null) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(feedback.message),
            backgroundColor: feedback.isError ? AppTheme.red : AppTheme.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      builder: (context, state) {
        final bloc = context.read<BackupsBloc>();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(state: state),
              const SizedBox(height: 14),
              if (state.operation != null) ...[
                _OperationBanner(operation: state.operation!),
                const SizedBox(height: 14),
              ],
              _BackupList(state: state),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => bloc.add(const BackupsRefreshed()),
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Päivitä', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final BackupsState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BackupsBloc>();
    final canStart = !state.isOperationActive;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Varmuuskopiot',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: state.isUploading
                  ? null
                  : () => bloc.add(const BackupsUploadRequested()),
              icon: state.isUploading
                  ? const _Spinner()
                  : const Icon(Icons.upload_file, size: 14),
              label: const Text('Vie tiedosto', style: TextStyle(fontSize: 11)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: canStart ? () => bloc.add(const BackupsDumpRequested()) : null,
              child: const Text('+ Ota varmuuskopio nyt'),
            ),
          ],
        ),
      ],
    );
  }
}

class _OperationBanner extends StatelessWidget {
  const _OperationBanner({required this.operation});

  final BackupOperation operation;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BackupsBloc>();
    final isDump = operation.kind == BackupOpKind.dump;
    final label = isDump ? 'Varmuuskopiointi' : 'Palautus';

    final Color bg;
    final Color fg;
    final Widget leading;
    switch (operation.status) {
      case BackupOpStatus.running:
        bg = AppTheme.amberBg;
        fg = AppTheme.amber;
        leading = const _Spinner();
        break;
      case BackupOpStatus.completed:
        bg = AppTheme.greenBg;
        fg = AppTheme.green;
        leading = Icon(Icons.check_circle, size: 16, color: AppTheme.green);
        break;
      case BackupOpStatus.failed:
        bg = AppTheme.redBg;
        fg = AppTheme.red;
        leading = Icon(Icons.error, size: 16, color: AppTheme.red);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  operation.filename != null ? '$label · ${operation.filename}' : label,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg),
                ),
                if (operation.message != null) ...[
                  const SizedBox(height: 2),
                  Text(operation.message!,
                      style: TextStyle(fontSize: 11, color: fg)),
                ],
              ],
            ),
          ),
          if (!operation.isRunning)
            IconButton(
              onPressed: () => bloc.add(const BackupsOperationDismissed()),
              icon: Icon(Icons.close, size: 16, color: fg),
              tooltip: 'Sulje',
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

class _BackupList extends StatelessWidget {
  const _BackupList({required this.state});

  final BackupsState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BackupsBloc>();

    if (state.listStatus == BackupsListStatus.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: _Spinner()),
      );
    }

    if (state.listStatus == BackupsListStatus.error) {
      return _MessageBox(
        icon: Icons.error_outline,
        color: AppTheme.red,
        message: state.listError ?? 'Varmuuskopioiden haku epäonnistui',
        action: TextButton(
          onPressed: () => bloc.add(const BackupsRefreshed()),
          child: const Text('Yritä uudelleen', style: TextStyle(fontSize: 11)),
        ),
      );
    }

    if (state.backups.isEmpty) {
      return _MessageBox(
        icon: Icons.inbox_outlined,
        color: AppTheme.textTertiary,
        message: 'Ei varmuuskopioita.',
      );
    }

    return Column(
      children: [
        for (final backup in state.backups) ...[
          _BackupRow(
            backup: backup,
            busy: state.busyFilenames.contains(backup.filename),
            disabled: state.isOperationActive,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _BackupRow extends StatelessWidget {
  const _BackupRow({
    required this.backup,
    required this.busy,
    required this.disabled,
  });

  final BackupInfo backup;
  final bool busy;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BackupsBloc>();
    final dateText = DateFormat('d.M.yyyy HH:mm').format(backup.createdAt.toLocal());
    final meta = '$dateText · ${backup.formattedSize}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.background2,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          Icon(Icons.archive_outlined, size: 14, color: AppTheme.textTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(backup.filename,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(meta, style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
              ],
            ),
          ),
          if (busy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: _Spinner(),
            )
          else ...[
            OutlinedButton(
              onPressed:
                  disabled ? null : () => _confirmRestore(context, bloc, backup.filename),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
              child: const Text('Palauta', style: TextStyle(fontSize: 11)),
            ),
            const SizedBox(width: 6),
            OutlinedButton(
              onPressed: () => bloc.add(BackupsDownloadRequested(backup.filename)),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
              child: const Text('Lataa', style: TextStyle(fontSize: 11)),
            ),
            const SizedBox(width: 6),
            OutlinedButton(
              onPressed:
                  disabled ? null : () => _confirmDelete(context, bloc, backup.filename),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                foregroundColor: AppTheme.red,
                side: BorderSide(color: AppTheme.red),
              ),
              child: const Text('Poista', style: TextStyle(fontSize: 11)),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmRestore(
    BuildContext context,
    BackupsBloc bloc,
    String filename,
  ) async {
    final confirmed = await _showConfirmDialog(
      context,
      title: 'Palauta tietokanta',
      message: 'Tietokanta palautetaan varmuuskopiosta:\n\n$filename\n\n'
          'HUOM: Nykyinen tietokannan sisältö korvataan. Toimintoa ei voi peruuttaa.',
      confirmLabel: 'Palauta',
      destructive: true,
    );
    if (confirmed) {
      bloc.add(BackupsRestoreRequested(filename));
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    BackupsBloc bloc,
    String filename,
  ) async {
    final confirmed = await _showConfirmDialog(
      context,
      title: 'Poista varmuuskopio',
      message: 'Poistetaanko varmuuskopio pysyvästi?\n\n$filename',
      confirmLabel: 'Poista',
      destructive: true,
    );
    if (confirmed) {
      bloc.add(BackupsDeleteRequested(filename));
    }
  }
}

Future<bool> _showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      content: Text(message, style: const TextStyle(fontSize: 12)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Peruuta', style: TextStyle(fontSize: 12)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: destructive
              ? ElevatedButton.styleFrom(backgroundColor: AppTheme.red)
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({
    required this.icon,
    required this.color,
    required this.message,
    this.action,
  });

  final IconData icon;
  final Color color;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.background2,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          if (action != null) ...[const SizedBox(height: 6), action!],
        ],
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 14,
      height: 14,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
