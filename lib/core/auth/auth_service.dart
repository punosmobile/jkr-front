import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'msal_js_interop.dart';

/// Azure AD -autentikointipalvelu MSAL.js:n kautta (vain web).
@lazySingleton
class AuthService {
  String? _cachedToken;
  bool _initialized = false;

  /// Initializes MSAL once during app startup.
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final token = await MsalJsInterop.initialize();
      if (token != null && token.isNotEmpty) {
        _cachedToken = token;
      }
      _initialized = true;
    } catch (e) {
      debugPrint('MSAL initialization error: $e');
    }
  }

  /// Starts Azure AD sign-in via redirect.
  Future<bool> login() async {
    try {
      await MsalJsInterop.loginRedirect();
      // Redirect navigates away. The token is handled on the next startup.
      return true;
    } catch (e) {
      debugPrint('Azure AD login error: $e');
      return false;
    }
  }

  /// Starts Azure AD sign-out.
  Future<void> logout() async {
    _cachedToken = null;
    await MsalJsInterop.logout();
  }

  /// Gets an access token, preferring silent acquisition first.
  Future<String?> getAccessToken() async {
    try {
      final token = await MsalJsInterop.getAccessToken();
      _cachedToken = token;
      return token;
    } catch (e) {
      debugPrint('Azure AD getAccessToken error: $e');
      return null;
    }
  }

  /// Returns whether the current app session is authenticated.
  bool get isLoggedIn => MsalJsInterop.isLoggedIn;

  /// Returns the last cached token, if available.
  String? get cachedToken => _cachedToken;

  /// Returns the current account payload as JSON.
  String? get accountJson => MsalJsInterop.getAccountJson();
}
