import 'dart:convert';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:package_info_plus/package_info_plus.dart';

import '../../core/auth/auth_bloc.dart';
import '../../core/auth/auth_event.dart';
import '../../core/auth/auth_service.dart';
import '../../core/config/env_config.dart';
import '../../core/di/injection.dart';
import '../../core/network/dio_client.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../features/backups/presentation/pages/backups_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/help/presentation/pages/help_page.dart';
import '../../features/import/data/repositories/import_repository.dart';
import '../../features/import/presentation/bloc/import_bloc.dart';
import '../../features/import/presentation/bloc/import_event.dart';
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
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with SingleTickerProviderStateMixin {
  String _importRunner = '';
  String _importDescription = '';
  bool _dbConnected = false;
  String? _backendVersion;
  Timer? _healthTimer;
  ImportBloc? _importBloc;
  late final AnimationController _sidebarAnimCtrl;
  late final Animation<double> _sidebarAnimation;
  bool _sidebarCollapsed = false;
  bool _importActive = false;

  static const double _sidebarWidth = 240;
  static const double _collapsedWidth = 48;
  static const _animDuration = Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    _sidebarAnimCtrl = AnimationController(vsync: this, duration: _animDuration);
    _sidebarAnimation = CurvedAnimation(
      parent: _sidebarAnimCtrl,
      curve: Curves.easeInOut,
    );
    _importBloc = ImportBloc(repository: ImportRepository())
      ..add(const ImportLoadFiles());
    _checkHealth();
    _checkTasks();
    _healthTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        _checkHealth();
        _checkTasks();
      },
    );
  }

  @override
  void dispose() {
    _healthTimer?.cancel();
    _sidebarAnimCtrl.dispose();
    _importBloc?.close();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() => _sidebarCollapsed = !_sidebarCollapsed);
    if (_sidebarCollapsed) {
      _sidebarAnimCtrl.forward();
    } else {
      _sidebarAnimCtrl.reverse();
    }
  }

  Future<void> _checkHealth() async {
    try {
      final dio = getIt<DioClient>().dio;
      final response = await dio.get('/health');
      final data = response.data as Map<String, dynamic>;
      final db = data['database'] as Map<String, dynamic>?;
      final connected = db?['connected'] == true;
      final version = data['version'] as String?;
      if (mounted && (connected != _dbConnected || version != _backendVersion)) {
        setState(() {
          _dbConnected = connected;
          _backendVersion = version;
        });
      }
    } catch (_) {
      if (mounted && _dbConnected) {
        setState(() => _dbConnected = false);
      }
    }
  }

  Future<void> _checkTasks() async {
    try {
      final dio = getIt<DioClient>().dio;
      final response = await dio.get('/tasks');
      final tasks = response.data as List<dynamic>;
      final running = tasks
          .cast<Map<String, dynamic>>()
          .where((t) => t['status'] == 'running')
          .toList();
      final isActive = running.isNotEmpty;
      final runner = isActive ? (running.first['runner'] as String? ?? '') : '';
      final description = isActive ? (running.first['description'] as String? ?? '') : '';
      if (mounted && (isActive != _importActive || runner != _importRunner || description != _importDescription)) {
        setState(() {
          _importActive = isActive;
          _importRunner = runner;
          _importDescription = description;
        });
      }
      _importBloc?.add(ImportTaskStatusChanged(isActive));
    } catch (_) {}
  }


  /// Derive active view ID from the current route location.
  String _activeViewId(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final segment = location.startsWith('/') ? location.substring(1) : location;
    return segment.isEmpty ? 'dashboard' : segment;
  }

  /// Look up page title from sidebar sections.
  String _pageTitle(BuildContext context, String viewId) {
    final l10n = AppLocalizations.of(context)!;
    for (final section in AppSidebar.buildSections(l10n)) {
      for (final item in section.items) {
        if (item.id == viewId) return item.label;
      }
    }
    return viewId;
  }


  String _parseUsername() {
    final authService = getIt<AuthService>();
    final accountJson = authService.accountJson;
    if (accountJson == null) return '';
    try {
      final data = jsonDecode(accountJson) as Map<String, dynamic>;
      return data['username'] as String? ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 800;
    final activeView = _activeViewId(context);

    _importBloc ??= ImportBloc(repository: ImportRepository())
      ..add(const ImportLoadFiles());
    return BlocProvider.value(
      value: _importBloc!,
      child: Builder(builder: (context) => Scaffold(
      backgroundColor: AppTheme.background3,
      drawer: isNarrow
          ? Drawer(
              child: AppSidebar(
                activeViewId: activeView,
                userName: _parseUsername(),
                appVersion: getIt<PackageInfo>().version,
                appBuildNumber: getIt<PackageInfo>().buildNumber,
                backendVersion: _backendVersion,
                environment: Environment.current,
                dbConnected: _dbConnected,
                onNavigate: (id) {
                  context.go('/$id');
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
            AnimatedBuilder(
              animation: _sidebarAnimation,
              builder: (context, child) {
                final t = _sidebarAnimation.value;
                final width = _sidebarWidth + (_collapsedWidth - _sidebarWidth) * t;
                // Button position: expanded top-right → collapsed center
                const expandedLeft = _sidebarWidth - 16 - 20; // 204
                const collapsedLeft = (_collapsedWidth - 20) / 2; // 14
                final btnLeft = expandedLeft + (collapsedLeft - expandedLeft) * t;
                return SizedBox(
                  width: width,
                  child: ClipRect(
                    child: Stack(
                      children: [
                        // Full sidebar — clipped by SizedBox+ClipRect
                        OverflowBox(
                          alignment: Alignment.centerLeft,
                          minWidth: _sidebarWidth,
                          maxWidth: _sidebarWidth,
                          child: child!,
                        ),
                        // Text cover — same color as sidebar bg, fades in to hide text
                        if (t > 0)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Container(
                                color: Environment.current.color.withValues(
                                  alpha: t,
                                ),
                              ),
                            ),
                          ),
                        // Animated collapse/expand button
                        Positioned(
                          left: btnLeft,
                          top: 14,
                          child: GestureDetector(
                            onTap: _toggleSidebar,
                            child: Transform.rotate(
                              angle: 3.14159 * t,
                              child: Icon(
                                Icons.chevron_left,
                                size: 20,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: AppSidebar(
                activeViewId: activeView,
                userName: _parseUsername(),
                appVersion: getIt<PackageInfo>().version,
                appBuildNumber: getIt<PackageInfo>().buildNumber,
                backendVersion: _backendVersion,
                environment: Environment.current,
                dbConnected: _dbConnected,
                onNavigate: (id) => context.go('/$id'),
                onLogout: () =>
                    context.read<AuthBloc>().add(const AuthLogoutRequested()),
                onCollapse: _toggleSidebar,
              ),
            ),
          // Main content area
          Expanded(
            child: Column(
              children: [
                _Topbar(
                  title: _pageTitle(context, activeView),
                  userName: _parseUsername(),
                  isNarrow: isNarrow,
                ),
                if (_importActive) _buildImportBanner(_importRunner),
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    )));
  }

  Widget _buildImportBanner(String runner) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      color: const Color(0xFFD97706),
      child: Row(
        children: [
          const _PulsingDot(),
          const SizedBox(width: 10),
          Text(
            'Tietojen syöttö käynnissä — $runner',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '', // TODO lisää arvioitu valmistumisaikalaskelma tähän
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
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
  const _PulsingDot();

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

