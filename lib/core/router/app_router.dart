import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_bloc.dart';
import '../auth/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/backups/presentation/pages/backups_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/help/presentation/pages/help_page.dart';
import '../../features/import/presentation/pages/import_page.dart';
import '../../features/import/presentation/pages/sharepoint_browser_page.dart';
import '../../features/planned/presentation/pages/planned_feature_page.dart';
import '../../features/realtime_log/presentation/pages/realtime_log_page.dart';
import '../../features/documentation/presentation/pages/documentation_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../shared/widgets/app_shell.dart';

/// Application router configuration.
class AppRouter {
  static const String login = '/login';
  static const String dashboard = '/dashboard';

  static GoRouter createRouter(AuthBloc authBloc) {
    final refreshNotifier = _AuthBlocRefreshNotifier(authBloc);

    return GoRouter(
      initialLocation: dashboard,
      debugLogDiagnostics: true,
      refreshListenable: refreshNotifier,
      redirect: (context, state) {
        final authStatus = authBloc.state.status;
        final isOnLogin = state.matchedLocation == login;

        // Älä ohjaa mihinkään kun tila on vielä lataamassa
        if (authStatus == AuthStatus.initial ||
            authStatus == AuthStatus.loading) {
          return null;
        }

        final isAuthenticated = authStatus == AuthStatus.authenticated;

        if (!isAuthenticated && !isOnLogin) return login;
        if (isAuthenticated && isOnLogin) return dashboard;
        return null;
      },
      routes: [
        GoRoute(
          path: login,
          name: 'login',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const LoginPage(),
          ),
        ),
        // Redirect / to /dashboard
        GoRoute(
          path: '/',
          redirect: (_, __) => dashboard,
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              pageBuilder: (_, state) => const NoTransitionPage(
                child: DashboardPage(),
              ),
            ),
            GoRoute(
              path: '/import',
              name: 'import',
              pageBuilder: (_, state) => const NoTransitionPage(
                child: ImportPage(),
              ),
            ),
            GoRoute(
              path: '/realogi',
              name: 'realogi',
              pageBuilder: (_, state) => const NoTransitionPage(
                child: RealtimeLogPage(),
              ),
            ),
            GoRoute(
              path: '/raportit',
              name: 'raportit',
              pageBuilder: (_, state) => const NoTransitionPage(
                child: ReportsPage(),
              ),
            ),
            GoRoute(
              path: '/varmuuskopiot',
              name: 'varmuuskopiot',
              pageBuilder: (_, state) => const NoTransitionPage(
                child: BackupsPage(),
              ),
            ),
            GoRoute(
              path: '/dbdocs',
              name: 'dbdocs',
              pageBuilder: (_, state) => const NoTransitionPage(
                child: DocumentationPage(),
              ),
            ),
            GoRoute(
              path: '/ohjeet',
              name: 'ohjeet',
              pageBuilder: (_, state) => const NoTransitionPage(
                child: HelpPage(),
              ),
            ),
            // Suunnitellut ominaisuudet
            GoRoute(
              path: '/kohteet',
              name: 'kohteet',
              pageBuilder: (_, state) => const NoTransitionPage(
                child: PlannedFeaturePage(title: 'Kohteet'),
              ),
            ),
            GoRoute(
              path: '/kartta',
              name: 'kartta',
              pageBuilder: (_, state) => const NoTransitionPage(
                child: PlannedFeaturePage(title: 'Karttanäkymä'),
              ),
            ),
            GoRoute(
              path: '/tietokanta',
              name: 'tietokanta',
              pageBuilder: (_, state) => const NoTransitionPage(
                child: PlannedFeaturePage(title: 'Tietokanta-työkalu'),
              ),
            ),
            GoRoute(
              path: '/lokit',
              name: 'lokit',
              pageBuilder: (_, state) => const NoTransitionPage(
                child: PlannedFeaturePage(title: 'Lokit & historia'),
              ),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Page not found: ${state.uri.path}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(dashboard),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// GoRouter refreshListenable joka kuuntelee AuthBlocin tilan muutoksia
class _AuthBlocRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  _AuthBlocRefreshNotifier(AuthBloc authBloc) {
    _subscription = authBloc.stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
