import 'dart:ui';

import '../../l10n/app_localizations.dart';

// Resolve report-localized strings without requiring a BuildContext.
AppLocalizations currentReportLocalizations([Locale? locale]) {
  final requestedLocale = locale ?? PlatformDispatcher.instance.locale;
  final resolvedLocale = AppLocalizations.supportedLocales.firstWhere(
    (supportedLocale) => supportedLocale.languageCode == requestedLocale.languageCode,
    orElse: () => const Locale('fi'),
  );

  return lookupAppLocalizations(resolvedLocale);
}