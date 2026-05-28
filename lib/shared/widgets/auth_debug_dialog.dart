import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/di/injection.dart';
import '../../core/network/protected_api_client.dart';
import '../../core/theme/app_theme.dart';

/// Avaa dialogin joka hakee /auth/debug -endpointin ja näyttää
/// tokenista puretut tiedot + roolimäärityksen diagnostiikan.
Future<void> showAuthDebugDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _AuthDebugDialog(),
  );
}

class _AuthDebugDialog extends StatefulWidget {
  const _AuthDebugDialog();

  @override
  State<_AuthDebugDialog> createState() => _AuthDebugDialogState();
}

class _AuthDebugDialogState extends State<_AuthDebugDialog> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = getIt<ProtectedApiClient>();
      final resp = await client.get<dynamic>('/auth/debug');
      if (!mounted) return;
      setState(() {
        _data = Map<String, dynamic>.from(resp.data as Map);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _copyJson() async {
    if (_data == null) return;
    final pretty = const JsonEncoder.withIndent('  ').convert(_data);
    await Clipboard.setData(ClipboardData(text: pretty));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('JSON kopioitu leikepöydälle'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final width = (media.width * 0.85).clamp(420.0, 900.0);
    final maxHeight = media.height * 0.85;

    return Dialog(
      backgroundColor: AppTheme.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width, maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(context),
            const Divider(height: 1),
            Flexible(child: _body(context)),
            const Divider(height: 1),
            _footer(context),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
      child: Row(
        children: [
          Icon(Icons.bug_report_outlined, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 10),
          const Text(
            'Tunnistautumistiedot (debug)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            tooltip: 'Päivitä',
            onPressed: _loading ? null : _load,
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            tooltip: 'Sulje',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '/auth/debug -kutsu epäonnistui',
              style: TextStyle(color: AppTheme.red, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SelectableText(
              _error!,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }
    final data = _data;
    if (data == null) return const SizedBox.shrink();

    final summary = (data['summary'] as Map?)?.cast<String, dynamic>() ?? {};
    final diag = (data['role_diagnostics'] as Map?)?.cast<String, dynamic>() ?? {};
    final meta = (data['token_metadata'] as Map?)?.cast<String, dynamic>() ?? {};
    final serverConfig = (data['server_config'] as Map?)?.cast<String, dynamic>() ?? {};
    final appReg = (data['app_registration'] as Map?)?.cast<String, dynamic>() ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _section(
            title: 'Yhteenveto',
            child: _kvTable([
              _Kv('Nimi', summary['name']?.toString() ?? ''),
              _Kv('Sähköposti', summary['email']?.toString() ?? ''),
              _Kv('Object ID', summary['oid']?.toString() ?? ''),
              _Kv('Roolit', (summary['roles_resolved'] as List?)?.join(', ') ?? '(ei roolia)'),
              _Kv('is_admin', '${summary['is_admin'] ?? false}'),
              _Kv('is_viewer', '${summary['is_viewer'] ?? false}'),
            ]),
          ),
          const SizedBox(height: 14),
          _section(
            title: 'Roolimäärityksen diagnostiikka',
            highlight: _diagnosticsHighlight(diag),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _resolvedViaPill('Admin', diag['admin_resolved_via']?.toString() ?? ''),
                const SizedBox(height: 2),
                _resolvedViaPill('Viewer', diag['viewer_resolved_via']?.toString() ?? ''),
                const SizedBox(height: 10),
                _subHeader('Reitti A — groups-claim'),
                _diagRow(
                  'Admin Group ID',
                  diag['admin_group_id_configured']?.toString() ?? '',
                  _boolFlag(diag['admin_group_in_token']),
                  flagLabel: 'tokenissa',
                ),
                _diagRow(
                  'Viewer Group ID',
                  diag['viewer_group_id_configured']?.toString() ?? '',
                  _boolFlag(diag['viewer_group_in_token']),
                  flagLabel: 'tokenissa',
                ),
                _diagInfo('groups-claim tokenissa', diag['token_has_groups_claim']),
                _diagInfo('groups-listan koko', diag['token_groups_count']),
                if (diag['token_groups_overage'] == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.amberBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: AppTheme.amber, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'GROUPS OVERAGE: käyttäjä kuuluu liian moneen ryhmään, '
                              'Azure AD ei lähetä groups-claimia. App Roles -reitti '
                              '(reitti B) toimii silti jos se on konfiguroitu.',
                              style: TextStyle(fontSize: 12, color: AppTheme.amber),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                _subHeader('Reitti B — App Roles (roles-claim)'),
                _diagRow(
                  'Admin App Role',
                  diag['admin_app_role_configured']?.toString() ?? '',
                  _boolFlag(diag['admin_app_role_in_token']),
                  flagLabel: 'tokenissa',
                ),
                _diagRow(
                  'Viewer App Role',
                  diag['viewer_app_role_configured']?.toString() ?? '',
                  _boolFlag(diag['viewer_app_role_in_token']),
                  flagLabel: 'tokenissa',
                ),
                _diagInfo(
                  'roles-claim tokenissa',
                  (diag['token_app_roles'] as List?)?.join(', ') ?? '(tyhjä)',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _section(
            title: 'Tokenin metatiedot',
            child: _kvTable([
              _Kv('issuer (iss)', meta['issuer']?.toString() ?? ''),
              _Kv('audience (aud)', meta['audience']?.toString() ?? ''),
              _Kv('tenant id (tid)', meta['tenant_id_in_token']?.toString() ?? ''),
              _Kv('app id (appid)', meta['app_id_in_token']?.toString() ?? ''),
              _Kv('scopes (scp)', meta['scopes']?.toString() ?? ''),
              _Kv('app roles (roles)',
                  (meta['app_roles_in_token'] as List?)?.join(', ') ?? '(ei)'),
              _Kv('expires (exp)', _formatTimestamp(meta['expires_at'])),
              _Kv('issued (iat)', _formatTimestamp(meta['issued_at'])),
            ]),
          ),
          const SizedBox(height: 14),
          _section(
            title: 'Palvelimen konfiguraatio',
            child: _kvTable([
              _Kv('AZURE_TENANT_ID', serverConfig['azure_tenant_id']?.toString() ?? ''),
              _Kv('AZURE_CLIENT_ID', serverConfig['azure_client_id']?.toString() ?? ''),
              _Kv('AZURE_ADMIN_GROUP_ID', serverConfig['azure_admin_group_id']?.toString() ?? ''),
              _Kv('AZURE_VIEWER_GROUP_ID', serverConfig['azure_viewer_group_id']?.toString() ?? ''),
            ]),
          ),
          const SizedBox(height: 14),
          _appRegistrationSection(appReg),
          const SizedBox(height: 14),
          _rawJsonExpander(data),
        ],
      ),
    );
  }

  Widget _section({required String title, required Widget child, Color? highlight}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight ?? AppTheme.background2,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Color? _diagnosticsHighlight(Map<String, dynamic> diag) {
    // Päätelmä siitä, saiko käyttäjä YHTÄKÄÄN roolia kummasta tahansa reitistä.
    final adminVia = diag['admin_resolved_via']?.toString() ?? '';
    final viewerVia = diag['viewer_resolved_via']?.toString() ?? '';
    final hasAdmin = adminVia.isNotEmpty && adminVia != '(ei mitään)';
    final hasViewer = viewerVia.isNotEmpty && viewerVia != '(ei mitään)';
    if (hasAdmin || hasViewer) return null;
    // Ei mitään roolia → punainen, koska tämä on tilanne jota tutkitaan.
    return AppTheme.redBg;
  }

  Widget _subHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _resolvedViaPill(String label, String via) {
    final isResolved = via.isNotEmpty && via != '(ei mitään)';
    final color = isResolved ? AppTheme.green : AppTheme.red;
    final bg = isResolved ? AppTheme.greenBg : AppTheme.redBg;
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        const Text('myönnetty reitin kautta: ',
            style: TextStyle(fontSize: 12)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            via,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _kvTable(List<_Kv> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows.map((r) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 180,
                child: Text(
                  r.k,
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ),
              Expanded(
                child: SelectableText(
                  r.v.isEmpty ? '—' : r.v,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _diagRow(String label, String value, _Flag flag, {required String flagLabel}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            child: SelectableText(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: flag.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(flag.icon, size: 12, color: flag.fg),
                const SizedBox(width: 4),
                Text(
                  flagLabel,
                  style: TextStyle(fontSize: 11, color: flag.fg, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _diagInfo(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(
              '${value ?? '—'}',
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appRegistrationSection(Map<String, dynamic> appReg) {
    final error = appReg['error']?.toString();
    if (error != null && error.isNotEmpty) {
      final permNeeded = appReg['permission_needed']?.toString();
      return _section(
        title: 'App Registration & Role assignments (Microsoft Graph)',
        highlight: AppTheme.amberBg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: AppTheme.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    error,
                    style: TextStyle(fontSize: 12, color: AppTheme.amber),
                  ),
                ),
              ],
            ),
            if (permNeeded != null && permNeeded.isNotEmpty) ...[
              const SizedBox(height: 8),
              SelectableText(
                'Lisättävä Graph-oikeus: $permNeeded',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ],
          ],
        ),
      );
    }

    final appRoles = (appReg['app_roles_defined'] as List?)?.cast<dynamic>() ?? [];
    final assignments = (appReg['app_role_assignments'] as List?)?.cast<dynamic>() ?? [];

    return _section(
      title: 'App Registration & Role assignments (Microsoft Graph)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _kvTable([
            _Kv('Display name', appReg['app_display_name']?.toString() ?? ''),
            _Kv('App ID (client)', appReg['app_id']?.toString() ?? ''),
            _Kv('Object ID', appReg['app_object_id']?.toString() ?? ''),
            _Kv('signInAudience', appReg['sign_in_audience']?.toString() ?? ''),
            _Kv(
              'groupMembershipClaims',
              appReg['group_membership_claims']?.toString() ?? '(ei asetettu)',
            ),
            _Kv('Service Principal ID', appReg['service_principal_id']?.toString() ?? ''),
          ]),
          const SizedBox(height: 10),
          Text(
            'Määritellyt App Roles (${appRoles.length})',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          if (appRoles.isEmpty)
            Text(
              'Ei App Roles -määrityksiä.',
              style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
            )
          else
            ...appRoles.map((r) {
              final role = (r as Map).cast<String, dynamic>();
              final enabled = role['isEnabled'] == true;
              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: enabled ? AppTheme.greenBg : AppTheme.redBg,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        role['value']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                          color: enabled ? AppTheme.green : AppTheme.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role['displayName']?.toString() ?? '',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          if ((role['description']?.toString() ?? '').isNotEmpty)
                            Text(
                              role['description'].toString(),
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      ((role['allowedMemberTypes'] as List?) ?? const []).join(', '),
                      style: TextStyle(fontSize: 10, color: AppTheme.textTertiary),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 12),
          Text(
            'Role assignments (${assignments.length})',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          if (assignments.isEmpty)
            Text(
              'Ei assignmentteja.',
              style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
            )
          else
            ...assignments.map((a) {
              final asg = (a as Map).cast<String, dynamic>();
              final isDefault = asg['app_role_id']?.toString() ==
                  '00000000-0000-0000-0000-000000000000';
              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            asg['principal_display_name']?.toString() ?? '(nimetön)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${asg['principal_type'] ?? ''} · ${asg['principal_id'] ?? ''}',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              color: AppTheme.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDefault ? AppTheme.background2 : AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        asg['app_role_value']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                          color: isDefault ? AppTheme.textSecondary : AppTheme.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _rawJsonExpander(Map<String, dynamic> data) {
    final pretty = const JsonEncoder.withIndent('  ').convert(data);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Text(
          'Näytä kaikki token-claimit (raaka JSON)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background2,
              borderRadius: BorderRadius.circular(6),
            ),
            child: SelectableText(
              pretty,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace', height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          TextButton.icon(
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Kopioi JSON'),
            onPressed: _data == null ? null : _copyJson,
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Sulje'),
          ),
        ],
      ),
    );
  }

  static _Flag _boolFlag(dynamic v) {
    final ok = v == true;
    return ok
        ? _Flag(Icons.check_circle, AppTheme.green, AppTheme.greenBg)
        : _Flag(Icons.cancel, AppTheme.red, AppTheme.redBg);
  }

  static String _formatTimestamp(dynamic value) {
    if (value == null) return '';
    final n = value is int ? value : int.tryParse('$value');
    if (n == null) return '$value';
    final dt = DateTime.fromMillisecondsSinceEpoch(n * 1000, isUtc: true).toLocal();
    final iso = dt.toIso8601String().split('.').first;
    return '$iso  ($value)';
  }
}

class _Kv {
  final String k;
  final String v;
  const _Kv(this.k, this.v);
}

class _Flag {
  final IconData icon;
  final Color fg;
  final Color bg;
  const _Flag(this.icon, this.fg, this.bg);
}
