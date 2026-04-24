import 'package:flutter/material.dart';

import '../../core/config/env_config.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// Navigation item definition for the sidebar.
class SidebarNavItem {
  final String id;
  final String label;
  final IconData icon;
  final bool isPlanned;

  const SidebarNavItem({
    required this.id,
    required this.label,
    required this.icon,
    this.isPlanned = false,
  });
}

/// Section header + items grouping.
class SidebarSection {
  final String? header;
  final List<SidebarNavItem> items;

  const SidebarSection({this.header, required this.items});
}

class AppSidebar extends StatelessWidget {
  final String activeViewId;
  final String userName;
  final String appVersion;
  final String appBuildNumber;
  final String? backendVersion;
  final Environment environment;
  final bool dbConnected;
  final ValueChanged<String> onNavigate;
  final VoidCallback? onLogout;
  final VoidCallback? onCollapse;

  const AppSidebar({
    super.key,
    required this.activeViewId,
    required this.userName,
    required this.appVersion,
    required this.appBuildNumber,
    this.backendVersion,
    required this.environment,
    required this.dbConnected,
    required this.onNavigate,
    this.onLogout,
    this.onCollapse,
  });

  static List<SidebarSection> buildSections(AppLocalizations l10n) => [
    SidebarSection(items: [
      SidebarNavItem(id: 'dashboard', label: l10n.navDashboard, icon: Icons.dashboard_outlined),
      SidebarNavItem(id: 'import', label: l10n.navImport, icon: Icons.download_outlined),
      SidebarNavItem(id: 'realogi', label: l10n.navRealtimeLog, icon: Icons.play_arrow_outlined),
      SidebarNavItem(id: 'raportit', label: l10n.navReports, icon: Icons.grid_view_outlined),
    ]),
    SidebarSection(header: l10n.navPlannedFeatures, items: [
      SidebarNavItem(id: 'kohteet', label: l10n.navTargets, icon: Icons.apartment_outlined, isPlanned: true),
      SidebarNavItem(id: 'kartta', label: l10n.navMap, icon: Icons.map_outlined, isPlanned: true),
      SidebarNavItem(id: 'tietokanta', label: l10n.navDatabase, icon: Icons.storage_outlined, isPlanned: true),
      SidebarNavItem(id: 'lokit', label: l10n.navLogs, icon: Icons.list_alt_outlined, isPlanned: true),
      SidebarNavItem(id: 'dbdocs', label: l10n.navDbDocs, icon: Icons.menu_book_outlined),
      SidebarNavItem(id: 'varmuuskopiot', label: l10n.navBackups, icon: Icons.backup_outlined),
      SidebarNavItem(id: 'ohjeet', label: l10n.navHelp, icon: Icons.help_outline),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: 240,
      color: environment.color,
      child: Column(
        children: [
          _buildLogoArea(l10n),
          _buildDbStatus(l10n),
          Expanded(child: _buildNavigation(l10n)),
          _buildBottomArea(l10n),
        ],
      ),
    );
  }

  Widget _buildLogoArea(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reserve space for the collapse button (rendered by AppShell)
          if (onCollapse != null) const SizedBox(height: 20),
          Text(
            l10n.sidebarOrgName,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            l10n.sidebarAppName,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Frontend v$appVersion+$appBuildNumber',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
          if (backendVersion != null)
            Text(
              'Backend v$backendVersion',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          const SizedBox(height: 2),
          // Pieni, huomaamaton linkki avoimen lähdekoodin lisensseihin.
          InkWell(
            onTap: () => onNavigate('lisenssit'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.copyright_outlined,
                    size: 10,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Lisenssit',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.45),
                      decoration: TextDecoration.underline,
                      decorationColor:
                          Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              environment.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDbStatus(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dbConnected ? const Color(0xFF4ADE80) : AppTheme.red,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            dbConnected ? l10n.dbConnectionOk : l10n.dbNoConnection,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(AppLocalizations l10n) {
    final sections = buildSections(l10n);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 6),
      children: [
        for (final section in sections) ...[
          if (section.header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 3),
              child: Text(
                section.header!.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.35),
                  letterSpacing: 0.6,
                ),
              ),
            ),
          for (final item in section.items)
            _NavItemWidget(
              item: item,
              isActive: activeViewId == item.id,
              onTap: () => onNavigate(item.id),
            ),
        ],
      ],
    );
  }

  Widget _buildBottomArea(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Logout button
          _SidebarButton(
            icon: Icons.logout,
            label: l10n.logout,
            onTap: onLogout,
            hasBorder: true,
          ),
        ],
      ),
    );
  }
}

class _NavItemWidget extends StatelessWidget {
  final SidebarNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: Colors.white.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withValues(alpha: 0.14) : null,
            border: Border(
              left: BorderSide(
                width: 2,
                color: isActive
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.transparent,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 16,
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: item.isPlanned ? 0.38 : 0.7),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: item.isPlanned ? 0.38 : 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool hasBorder;

  const _SidebarButton({
    required this.icon,
    required this.label,
    this.onTap,
    required this.hasBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        hoverColor: Colors.white.withValues(alpha: 0.1),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: hasBorder
                ? Border.all(color: Colors.white.withValues(alpha: 0.18))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 13,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
