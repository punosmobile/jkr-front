import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

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
  final String envLabel;
  final bool dbConnected;
  final ValueChanged<String> onNavigate;
  final VoidCallback? onLogout;
  final VoidCallback? onSettingsPressed;

  const AppSidebar({
    super.key,
    required this.activeViewId,
    required this.userName,
    required this.envLabel,
    required this.dbConnected,
    required this.onNavigate,
    this.onLogout,
    this.onSettingsPressed,
  });

  static const List<SidebarSection> sections = [
    SidebarSection(items: [
      SidebarNavItem(id: 'dashboard', label: 'Dashboard', icon: Icons.dashboard_outlined),
      SidebarNavItem(id: 'import', label: 'Tietojen tuonti', icon: Icons.download_outlined),
      SidebarNavItem(id: 'realogi', label: 'Reaaliaikainen loki', icon: Icons.play_arrow_outlined),
      SidebarNavItem(id: 'raportit', label: 'Raportit', icon: Icons.grid_view_outlined),
      SidebarNavItem(id: 'varmuuskopiot', label: 'Varmuuskopiot', icon: Icons.backup_outlined),
      SidebarNavItem(id: 'dbdocs', label: 'Tietokantadok.', icon: Icons.menu_book_outlined),
      SidebarNavItem(id: 'ohjeet', label: 'Ohjeet & tuki', icon: Icons.help_outline),
    ]),
    SidebarSection(header: 'Suunnitellut ominaisuudet', items: [
      SidebarNavItem(id: 'kohteet', label: 'Kohteet', icon: Icons.apartment_outlined, isPlanned: true),
      SidebarNavItem(id: 'kartta', label: 'Karttanäkymä', icon: Icons.map_outlined, isPlanned: true),
      SidebarNavItem(id: 'tietokanta', label: 'Tietokanta', icon: Icons.storage_outlined, isPlanned: true),
      SidebarNavItem(id: 'lokit', label: 'Lokit & historia', icon: Icons.list_alt_outlined, isPlanned: true),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AppTheme.primaryColor,
      child: Column(
        children: [
          // Logo area
          _buildLogoArea(),
          // DB status
          _buildDbStatus(),
          // Navigation
          Expanded(child: _buildNavigation()),
          // Bottom area
          _buildBottomArea(),
        ],
      ),
    );
  }

  Widget _buildLogoArea() {
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
          Text(
            'Lahden seudun\njätehuoltoviranomainen',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            'JKR Tiedonhallinta',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'v0.7.5',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.35),
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
              envLabel,
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

  Widget _buildDbStatus() {
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
            dbConnected ? 'Kantayhteys OK' : 'Ei yhteyttä',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
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

  Widget _buildBottomArea() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Settings button
          _SidebarButton(
            icon: Icons.settings_outlined,
            label: 'Ympäristö värit',
            onTap: onSettingsPressed,
            hasBorder: false,
          ),
          const SizedBox(height: 6),
          // Logout button
          _SidebarButton(
            icon: Icons.logout,
            label: 'Kirjaudu ulos',
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
