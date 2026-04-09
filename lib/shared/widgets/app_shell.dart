import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/auth/auth_bloc.dart';
import '../../core/auth/auth_event.dart';
import '../../core/auth/auth_service.dart';
import '../../core/di/injection.dart';
import '../../core/network/dio_client.dart';
import '../../core/theme/app_theme.dart';
import '../../features/backups/presentation/pages/backups_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/help/presentation/pages/help_page.dart';
import '../../features/import/presentation/pages/import_page.dart';
import '../../features/import/presentation/pages/sharepoint_browser_page.dart';
import '../../features/planned/presentation/pages/planned_feature_page.dart';
import '../../features/realtime_log/presentation/pages/realtime_log_page.dart';
import '../../features/documentation/presentation/pages/documentation_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import 'app_sidebar.dart';

/// Main application shell with sidebar navigation and content area.
/// This is the primary layout for the authenticated user.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String _activeView = 'dashboard';
  bool _importActive = false;
  bool _dbConnected = false;
  Timer? _healthTimer;

  @override
  void initState() {
    super.initState();
    _checkHealth();
    _healthTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkHealth(),
    );
  }

  @override
  void dispose() {
    _healthTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkHealth() async {
    try {
      final dio = getIt<DioClient>().dio;
      final response = await dio.get('/health');
      final data = response.data as Map<String, dynamic>;
      final db = data['database'] as Map<String, dynamic>?;
      final connected = db?['connected'] == true;
      if (mounted && connected != _dbConnected) {
        setState(() => _dbConnected = connected);
      }
    } catch (_) {
      if (mounted && _dbConnected) {
        setState(() => _dbConnected = false);
      }
    }
  }

  String get _pageTitle {
    const titles = {
      'dashboard': 'Dashboard',
      'import': 'Tietojen tuonti',
      'realogi': 'Reaaliaikainen loki',
      'raportit': 'Raportit',
      'varmuuskopiot': 'Varmuuskopiot',
      'ohjeet': 'Ohjeet & tuki',
      'kohteet': 'Kohteet',
      'kartta': 'Karttanäkymä',
      'tietokanta': 'Tietokanta-työkalu',
      'lokit': 'Lokit & historia',
      'sharepoint': 'SharePoint-tiedostot',
      'dbdocs': 'Tietokantadokumentaatio',
    };
    return titles[_activeView] ?? _activeView;
  }

  String _parseUsername() {
    final authService = getIt<AuthService>();
    final accountJson = authService.accountJson;
    if (accountJson == null) return '';
    final nameMatch =
        RegExp(r'"username"\s*:\s*"([^"]*)"').firstMatch(accountJson);
    return nameMatch?.group(1) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 800;

    return Scaffold(
      backgroundColor: AppTheme.background3,
      drawer: isNarrow
          ? Drawer(
              child: AppSidebar(
                activeViewId: _activeView,
                userName: _parseUsername(),
                envLabel: 'Tuotanto',
                dbConnected: _dbConnected,
                onNavigate: (id) {
                  setState(() => _activeView = id);
                  Navigator.of(context).pop();
                },
                onLogout: () =>
                    context.read<AuthBloc>().add(const AuthLogoutRequested()),
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar — hidden on narrow screens (use drawer instead)
          if (!isNarrow)
            AppSidebar(
              activeViewId: _activeView,
              userName: _parseUsername(),
              envLabel: 'Tuotanto',
              dbConnected: _dbConnected,
              onNavigate: (id) => setState(() => _activeView = id),
              onLogout: () =>
                  context.read<AuthBloc>().add(const AuthLogoutRequested()),
            ),
          // Main content area
          Expanded(
            child: Column(
              children: [
                _Topbar(
                  title: _pageTitle,
                  userName: _parseUsername(),
                  isNarrow: isNarrow,
                ),
                if (_importActive) _buildImportBanner(),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      color: const Color(0xFFD97706),
      child: Row(
        children: [
          _PulsingDot(),
          const SizedBox(width: 10),
          const Text(
            'Tietojen syöttö käynnissä — Matti Meikäläinen',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            'Arvioitu valmistumisaika: 4 min',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Lazy-load the right view based on activeView
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: _getViewWidget(),
    );
  }

  Widget _getViewWidget() {
    switch (_activeView) {
      case 'dashboard':
        return const DashboardPage(key: ValueKey('dashboard'));
      case 'import':
        return const ImportPage(key: ValueKey('import'));
      case 'realogi':
        return const RealtimeLogPage(key: ValueKey('realogi'));
      case 'raportit':
        return const ReportsPage(key: ValueKey('raportit'));
      case 'varmuuskopiot':
        return const BackupsPage(key: ValueKey('varmuuskopiot'));
      case 'sharepoint':
        return const SharepointBrowserPage(key: ValueKey('sharepoint'));
      case 'dbdocs':
        return const DocumentationPage(key: ValueKey('dbdocs'));
      case 'ohjeet':
        return const HelpPage(key: ValueKey('ohjeet'));
      default:
        return PlannedFeaturePage(
          key: ValueKey(_activeView),
          title: _pageTitle,
        );
    }
  }
}

// ─── TOPBAR ──────────────────────────────────────────────────────────────────

class _Topbar extends StatelessWidget {
  final String title;
  final String userName;
  final bool isNarrow;

  const _Topbar({
    required this.title,
    required this.userName,
    required this.isNarrow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: 0.10),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (isNarrow)
            IconButton(
              icon: const Icon(Icons.menu, size: 20),
              onPressed: () => Scaffold.of(context).openDrawer(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (isNarrow) const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            userName,
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── PULSING DOT ─────────────────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 0.9).animate(_ctrl),
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }
}

