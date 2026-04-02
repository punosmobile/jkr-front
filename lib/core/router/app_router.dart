import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_bloc.dart';
import '../auth/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/documentation/presentation/pages/documentation_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

/// Application router configuration.
class AppRouter {
  static const String home = '/';
  static const String login = '/login';
  static const String documentation = '/documentation';

  static GoRouter createRouter(AuthBloc authBloc) {
    final refreshNotifier = _AuthBlocRefreshNotifier(authBloc);

    return GoRouter(
      initialLocation: home,
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
        if (isAuthenticated && isOnLogin) return home;
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
        GoRoute(
          path: home,
          name: 'home',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const HomePage(),
          ),
        ),
        GoRoute(
          path: documentation,
          name: 'documentation',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const DocumentationPage(),
          ),
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
                onPressed: () => context.go(home),
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
