import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/card_container.dart';
import '../../data/models/sharepoint_item.dart';
import '../../data/repositories/sharepoint_repository.dart';
import '../bloc/sharepoint_bloc.dart';
import '../bloc/sharepoint_event.dart';
import '../bloc/sharepoint_state.dart';

class SharepointBrowserPage extends StatelessWidget {
  const SharepointBrowserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SharepointBloc(repository: SharepointRepository())
        ..add(const SharepointInitRequested()),
      child: const _SharepointBrowserView(),
    );
  }
}

class _SharepointBrowserView extends StatelessWidget {
  const _SharepointBrowserView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SharepointBloc, SharepointState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              _Toolbar(state: state),
              const SizedBox(height: 14),
              Expanded(child: _buildContent(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, SharepointState state) {
    return switch (state.status) {
      SharepointPageStatus.initial ||
      SharepointPageStatus.loading =>
        const Center(child: CircularProgressIndicator()),
      SharepointPageStatus.notConfigured => _NotConfiguredView(),
      SharepointPageStatus.error => _ErrorView(message: state.errorMessage),
      SharepointPageStatus.loaded => _FolderContentView(state: state),
    };
  }
}

// ─── TOOLBAR ─────────────────────────────────────────────────────────────────

class _Toolbar extends StatelessWidget {
  final SharepointState state;
  const _Toolbar({required this.state});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_outlined, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 7),
              Text(
                'SharePoint',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (state.siteId != null) ...[
                const SizedBox(width: 8),
                Text(
                  state.siteId!,
                  style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                ),
              ],
              const Spacer(),
              if (state.status == SharepointPageStatus.loaded) ...[
                Text(
                  '${state.folderCount} kansiota · ${state.fileCount} tiedostoa',
                  style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                ),
                const SizedBox(width: 10),
              ],
              OutlinedButton.icon(
                onPressed: () => context
                    .read<SharepointBloc>()
                    .add(const SharepointRefreshRequested()),
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text('Päivitä'),
              ),
            ],
          ),
          if (state.status == SharepointPageStatus.loaded &&
              state.breadcrumbs.isNotEmpty) ...[
            const SizedBox(height: 8),
            _Breadcrumb(state: state),
          ],
        ],
      ),
    );
  }
}

// ─── BREADCRUMB ──────────────────────────────────────────────────────────────

class _Breadcrumb extends StatelessWidget {
  final SharepointState state;
  const _Breadcrumb({required this.state});

  @override
  Widget build(BuildContext context) {
    final segments = state.breadcrumbs;
    return Row(
      children: [
        // Back button
        if (state.folderHistory.isNotEmpty)
          InkWell(
            onTap: () => context
                .read<SharepointBloc>()
                .add(const SharepointNavigatedBack()),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.arrow_back, size: 14, color: AppTheme.primaryColor),
            ),
          ),
        if (state.folderHistory.isNotEmpty) const SizedBox(width: 6),
        // Root
        InkWell(
          onTap: state.folderHistory.isNotEmpty
              ? () {
                  // Navigate back to root
                  final root = state.rootFolder ?? '';
                  context
                      .read<SharepointBloc>()
                      .add(SharepointFolderOpened(root));
                }
              : null,
          child: Text(
            'Juuri',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Segments
        for (int i = 0; i < segments.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(Icons.chevron_right, size: 14, color: AppTheme.textTertiary),
          ),
          if (i < segments.length - 1)
            InkWell(
              onTap: () {
                final path = segments.sublist(0, i + 1).join('/');
                context
                    .read<SharepointBloc>()
                    .add(SharepointFolderOpened(path));
              },
              child: Text(
                segments[i],
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            Text(
              segments[i],
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ],
    );
  }
}

// ─── FOLDER CONTENT VIEW ─────────────────────────────────────────────────────

class _FolderContentView extends StatelessWidget {
  final SharepointState state;
  const _FolderContentView({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 48, color: AppTheme.textTertiary),
            const SizedBox(height: 12),
            Text(
              'Kansio on tyhjä',
              style: TextStyle(fontSize: 13, color: AppTheme.textTertiary),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border.all(color: Colors.black.withValues(alpha: 0.10), width: 0.5),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.background2,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                _headerCell('Nimi', flex: 4),
                _headerCell('Tyyppi', flex: 1),
                _headerCell('Koko', flex: 1),
                _headerCell('Muokattu', flex: 2),
                _headerCell('', flex: 1),
              ],
            ),
          ),
          // Table body
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return _FileRow(
                  item: item,
                  currentFolder: state.currentFolder,
                  isLast: index == state.items.length - 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppTheme.textTertiary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── FILE ROW ────────────────────────────────────────────────────────────────

class _FileRow extends StatelessWidget {
  final SharepointItem item;
  final String currentFolder;
  final bool isLast;

  const _FileRow({
    required this.item,
    required this.currentFolder,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.isFolder
          ? () {
              final path = currentFolder.isEmpty
                  ? item.name
                  : '$currentFolder/${item.name}';
              context
                  .read<SharepointBloc>()
                  .add(SharepointFolderOpened(path));
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.black.withValues(alpha: 0.06),
                    width: 0.5,
                  ),
                ),
        ),
        child: Row(
          children: [
            // Name
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Icon(
                    item.isFolder ? Icons.folder : _fileIcon(item.name),
                    size: 16,
                    color: item.isFolder
                        ? const Color(0xFFFBBF24)
                        : AppTheme.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: item.isFolder ? FontWeight.w600 : FontWeight.w400,
                        color: item.isFolder
                            ? AppTheme.primaryColor
                            : AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Type
            Expanded(
              flex: 1,
              child: Text(
                item.isFolder ? 'Kansio' : _fileExtension(item.name),
                style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
              ),
            ),
            // Size
            Expanded(
              flex: 1,
              child: Text(
                item.isFolder
                    ? (item.childCount != null
                        ? '${item.childCount} kohdetta'
                        : '—')
                    : _formatBytes(item.size),
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ),
            // Modified
            Expanded(
              flex: 2,
              child: Text(
                _formatDate(item.lastModified),
                style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
              ),
            ),
            // Actions
            Expanded(
              flex: 1,
              child: item.isFolder
                  ? const SizedBox.shrink()
                  : Row(
                      children: [
                        InkWell(
                          onTap: () => _downloadFile(context),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.download, size: 13, color: AppTheme.primaryColor),
                                const SizedBox(width: 3),
                                Text(
                                  'Lataa',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadFile(BuildContext context) {
    final path = currentFolder.isEmpty
        ? item.name
        : '$currentFolder/${item.name}';
    final url = SharepointRepository().getDownloadUrl(path);
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  static IconData _fileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    return switch (ext) {
      'xlsx' || 'xls' || 'csv' => Icons.table_chart,
      'pdf' => Icons.picture_as_pdf,
      'doc' || 'docx' => Icons.description,
      'zip' || 'gz' || 'tar' => Icons.archive,
      'shp' || 'geojson' => Icons.map,
      'sql' => Icons.code,
      'png' || 'jpg' || 'jpeg' || 'gif' => Icons.image,
      _ => Icons.insert_drive_file,
    };
  }

  static String _fileExtension(String name) {
    final parts = name.split('.');
    if (parts.length < 2) return '';
    return '.${parts.last.toUpperCase()}';
  }

  static String _formatBytes(int? bytes) {
    if (bytes == null) return '—';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  static String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '—';
    // Expect ISO format: 2024-03-26T08:35:26...
    return dateStr.replaceFirst('T', ' ').substring(0, 19);
  }
}

// ─── NOT CONFIGURED VIEW ─────────────────────────────────────────────────────

class _NotConfiguredView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 48, color: AppTheme.textTertiary),
          const SizedBox(height: 16),
          Text(
            'SharePoint-integraatio ei ole konfiguroitu',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aseta SHAREPOINT_SITE_ID, AZURE_CLIENT_ID ja\nAZURE_CLIENT_SECRET ympäristömuuttujat backendille.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.textTertiary, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ─── ERROR VIEW ──────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String? message;
  const _ErrorView({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppTheme.red),
          const SizedBox(height: 16),
          Text(
            'Virhe ladattaessa SharePoint-sisältöä',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context
                .read<SharepointBloc>()
                .add(const SharepointInitRequested()),
            icon: const Icon(Icons.refresh, size: 14),
            label: const Text('Yritä uudelleen'),
          ),
        ],
      ),
    );
  }
}
