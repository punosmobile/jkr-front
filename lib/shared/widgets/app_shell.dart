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
import 'app_sidebar.dart';

/// Main application shell with sidebar navigation and content area.
/// This is the primary layout for the authenticated user.
class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _dbConnected = false;
  String? _backendVersion;
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

    return Scaffold(
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
            AppSidebar(
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
                Expanded(
                  child: widget.child,
                ),
              ],
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

