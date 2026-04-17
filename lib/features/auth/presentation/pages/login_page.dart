import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/auth_bloc.dart';
import '../../../../core/auth/auth_event.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/card_container.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.background3,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error && state.errorCode != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_localizedAuthError(l10n, state)),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 960;
            final wideLayoutHeight =
                (constraints.maxHeight - 48).clamp(680.0, 900.0).toDouble();

            return Stack(
              children: [
                const Positioned(
                  top: -140,
                  left: -90,
                  child: _BackgroundOrb(
                    size: 320,
                    color: Color(0x3347A3C3),
                  ),
                ),
                const Positioned(
                  right: -120,
                  bottom: -120,
                  child: _BackgroundOrb(
                    size: 360,
                    color: Color(0x1F004F71),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: isCompact
                            ? const _CompactLoginLayout()
                            : SizedBox(
                                height: wideLayoutHeight,
                                child: const _WideLoginLayout(),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WideLoginLayout extends StatelessWidget {
  const _WideLoginLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        Expanded(flex: 11, child: _BrandPanel()),
        SizedBox(width: 24),
        Expanded(flex: 8, child: _LoginCard()),
      ],
    );
  }
}

class _CompactLoginLayout extends StatelessWidget {
  const _CompactLoginLayout();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CompactBrandHeader(),
        SizedBox(height: 18),
        _LoginCard(),
      ],
    );
  }
}

class _CompactBrandHeader extends StatelessWidget {
  const _CompactBrandHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CardContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandBadge(),
          const SizedBox(height: 16),
          Text(
            'JKR',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.loginCompactDescription,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A5D83), Color(0xFF003552)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.22),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -18,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            left: 120,
            bottom: -90,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BrandBadge(inverted: true),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Icon(
                            Icons.grid_view_rounded,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          l10n.loginBrandTitle,
                          style: const TextStyle(
                            fontSize: 40,
                            height: 1.05,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          l10n.loginBrandDescription,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Color(0xD9FFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return CardContainer(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.lock_person_outlined,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Spacer(),
              _EnvironmentChip(environment: Environment.current),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            l10n.loginTitle,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.loginDescription,
            style: TextStyle(
              fontSize: 14,
              height: 1.55,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state.status == AuthStatus.loading;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => context
                              .read<AuthBloc>()
                              .add(const AuthLoginRequested()),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.login_rounded),
                      label: Text(
                        isLoading
                            ? l10n.loginButtonLoading
                            : l10n.loginButton,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.loginBrowserHint,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EnvironmentChip extends StatelessWidget {
  const _EnvironmentChip({required this.environment});

  final Environment environment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: environment.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: environment.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            switch (environment) {
              Environment.development => l10n.loginEnvironmentDevelopment,
              Environment.test => l10n.loginEnvironmentTest,
              Environment.production => l10n.loginEnvironmentProduction,
            },
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: environment.color,
            ),
          ),
        ],
      ),
    );
  }
}

String _localizedAuthError(AppLocalizations l10n, AuthState state) {
  return switch (state.errorCode) {
    AuthErrorCode.loginFailed => l10n.loginErrorFailed,
    AuthErrorCode.loginError => l10n.loginErrorGeneric,
    null => l10n.loginErrorGeneric,
  };
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge({this.inverted = false});

  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: inverted ? Colors.white.withValues(alpha: 0.10) : AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.apartment_rounded,
            size: 16,
            color: inverted ? Colors.white : AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            l10n.loginBrandBadge,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: inverted ? Colors.white : AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
