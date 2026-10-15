import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/card_container.dart';
import '../../data/licenses_repository.dart';

/// Avoimen lähdekoodin lisenssit -näkymä.
///
/// Näyttää sekä backendin (SBOM /licenses) että frontendin
/// (Flutter [LicenseRegistry]) käyttämät kolmannen osapuolen lisenssit.
class LicensesPage extends StatefulWidget {
  const LicensesPage({super.key});

  @override
  State<LicensesPage> createState() => _LicensesPageState();
}

class _LicensesPageState extends State<LicensesPage>
    with SingleTickerProviderStateMixin {
  final LicensesRepository _repo = LicensesRepository();
  late final TabController _tabs;

  Future<LicenseSbom>? _sbomFuture;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _sbomFuture = _repo.fetchSbom();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _sbomFuture = _repo.fetchSbom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardContainer(
            title: 'Avoin lähdekoodi — Third-Party Notices',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tämä sovellus hyödyntää useita avoimen lähdekoodin '
                  'kirjastoja. Alla on listaus käytetyistä riippuvuuksista '
                  'lisenssitietoineen (SBOM). Attribuutiovaatimusten '
                  'täyttämiseksi voit ladata yhdistetyn NOTICE-tiedoston '
                  'alta.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _downloadNotices,
                      icon: const Icon(Icons.download_outlined, size: 14),
                      label: const Text('Lataa NOTICE (backend)'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _showFlutterLicensePage,
                      icon: const Icon(Icons.flutter_dash, size: 14),
                      label: const Text('Flutter-lisenssinäkymä'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh, size: 14),
                      label: const Text('Päivitä'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          CardContainer(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  child: TabBar(
                    controller: _tabs,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: AppTheme.textSecondary,
                    indicatorColor: AppTheme.primaryColor,
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelStyle: const TextStyle(fontSize: 12),
                    tabs: const [
                      Tab(text: 'Backend'),
                      Tab(text: 'Frontend (Flutter)'),
                    ],
                  ),
                ),
                SizedBox(
                  height: 520,
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _BackendTab(
                        future: _sbomFuture!,
                        onPackageTap: _showPackageDetails,
                        onRetry: _reload,
                      ),
                      const _FrontendTab(),
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

  Future<void> _downloadNotices() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final text = await _repo.fetchNoticesText();
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('THIRD-PARTY NOTICES'),
          content: SizedBox(
            width: 720,
            height: 520,
            child: SingleChildScrollView(
              child: SelectableText(
                text,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: text));
                messenger.showSnackBar(
                  const SnackBar(content: Text('Kopioitu leikepöydälle')),
                );
              },
              child: const Text('Kopioi leikepöydälle'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Sulje'),
            ),
          ],
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('NOTICE-tiedoston haku epäonnistui: $e')),
      );
    }
  }

  void _showFlutterLicensePage() {
    showLicensePage(
      context: context,
      applicationName: 'JKR Tiedonhallinta',
      applicationLegalese: '© Lahden seudun jätehuoltoviranomainen',
    );
  }

  Future<void> _showPackageDetails(LicenseDependency dep) async {
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => _PackageDetailsDialog(
        dep: dep,
        repo: _repo,
        onError: (e) => messenger.showSnackBar(
          SnackBar(content: Text('Lisenssitekstin haku epäonnistui: $e')),
        ),
      ),
    );
  }
}

// ─── Backend-välilehti ───────────────────────────────────────────────────────

class _BackendTab extends StatelessWidget {
  final Future<LicenseSbom> future;
  final ValueChanged<LicenseDependency> onPackageTap;
  final VoidCallback onRetry;

  const _BackendTab({
    required this.future,
    required this.onPackageTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LicenseSbom>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: AppTheme.red, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Lisenssilistauksen haku epäonnistui',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${snapshot.error}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('Yritä uudelleen'),
                ),
              ],
            ),
          );
        }
        final sbom = snapshot.data!;
        final deps = [...sbom.dependencies]
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: Text(
                'Backend-riippuvuudet (${sbom.count})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: deps.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final d = deps[i];
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(
                      d.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      [
                        if (d.version.isNotEmpty) 'v${d.version}',
                        if (d.license.isNotEmpty) d.license,
                      ].join(' • '),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 16),
                    onTap: () => onPackageTap(d),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Frontend-välilehti (Flutter LicenseRegistry) ────────────────────────────

class _FrontendTab extends StatefulWidget {
  const _FrontendTab();

  @override
  State<_FrontendTab> createState() => _FrontendTabState();
}

class _FrontendTabState extends State<_FrontendTab> {
  late final Future<Map<String, List<LicenseEntry>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _collect();
  }

  Future<Map<String, List<LicenseEntry>>> _collect() async {
    final Map<String, List<LicenseEntry>> byPackage = {};
    await for (final entry in LicenseRegistry.licenses) {
      for (final pkg in entry.packages) {
        byPackage.putIfAbsent(pkg, () => []).add(entry);
      }
    }
    return byPackage;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<LicenseEntry>>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final packages = snapshot.data!.keys.toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: Text(
                'Frontend-riippuvuudet (${packages.length})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: packages.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final pkg = packages[i];
                  final entries = snapshot.data![pkg]!;
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(
                      pkg,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '${entries.length} lisenssi${entries.length == 1 ? '' : 'ä'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 16),
                    onTap: () => _showEntries(context, pkg, entries),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEntries(
    BuildContext context,
    String pkg,
    List<LicenseEntry> entries,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(pkg),
        content: SizedBox(
          width: 720,
          height: 520,
          child: SingleChildScrollView(
            child: SelectableText(
              entries
                  .map((e) => e.paragraphs.map((p) => p.text).join('\n\n'))
                  .join('\n\n--- --- ---\n\n'),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Sulje'),
          ),
        ],
      ),
    );
  }
}

// ─── Paketin yksityiskohdat -dialogi (backend) ───────────────────────────────

class _PackageDetailsDialog extends StatefulWidget {
  final LicenseDependency dep;
  final LicensesRepository repo;
  final ValueChanged<Object> onError;

  const _PackageDetailsDialog({
    required this.dep,
    required this.repo,
    required this.onError,
  });

  @override
  State<_PackageDetailsDialog> createState() => _PackageDetailsDialogState();
}

class _PackageDetailsDialogState extends State<_PackageDetailsDialog> {
  late final Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    try {
      return await widget.repo.fetchPackage(widget.dep.name);
    } catch (e) {
      widget.onError(e);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dep;
    return AlertDialog(
      title: Text('${d.name}${d.version.isNotEmpty ? ' v${d.version}' : ''}'),
      content: SizedBox(
        width: 720,
        height: 520,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (ctx, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Text(
                  'Virhe: ${snap.error}',
                  style: TextStyle(fontSize: 11, color: AppTheme.red),
                ),
              );
            }
            final data = snap.data!;
            final licenseFiles =
                (data['license_files'] as List<dynamic>? ?? []);
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv('Lisenssi', d.license),
                  if (d.author != null && d.author!.isNotEmpty)
                    _kv('Tekijä', d.author!),
                  if (d.homepage != null && d.homepage!.isNotEmpty)
                    _kv('Kotisivu', d.homepage!),
                  if (d.summary != null && d.summary!.isNotEmpty)
                    _kv('Kuvaus', d.summary!),
                  const SizedBox(height: 12),
                  if (licenseFiles.isEmpty)
                    Text(
                      'Ei lisenssitekstitiedostoja.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                      ),
                    )
                  else
                    for (final f in licenseFiles)
                      _licenseFileBlock(f as Map<String, dynamic>),
                  if (kDebugMode) ...[
                    const SizedBox(height: 12),
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        'Raakavastaus (debug)',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      children: [
                        SelectableText(
                          data.toString(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Sulje'),
        ),
      ],
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(
            text: '$k: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          TextSpan(
            text: v,
            style: const TextStyle(fontSize: 11),
          ),
        ]),
      ),
    );
  }

  Widget _licenseFileBlock(Map<String, dynamic> f) {
    final name = (f['name'] ?? f['filename'] ?? 'LICENSE').toString();
    final content = (f['content'] ?? '').toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.background2,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.10),
                width: 0.5,
              ),
            ),
            child: SelectableText(
              content,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
