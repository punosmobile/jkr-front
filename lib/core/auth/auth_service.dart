import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';

import '../constants/app_constants.dart';
import '../../shared/services/storage/secure_storage_service.dart';
import 'msal_js_interop.dart';

/// Azure AD -autentikointipalvelu MSAL.js:n kautta (vain web).
@lazySingleton
class AuthService {
  AuthService(this._storage);

  final SecureStorageService _storage;
  final StreamController<bool> _sessionStateController =
      StreamController<bool>.broadcast();
  bool _initialized = false;
  bool _hasValidatedSession = false;

  Stream<bool> get sessionStateChanges => _sessionStateController.stream;

  /// Initializes MSAL once during app startup.
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final wasExplicitlyLoggedOut = await _wasExplicitlyLoggedOut();
      final redirectToken = await MsalJsInterop.initialize();
      if (redirectToken != null && redirectToken.isNotEmpty) {
        await _clearExplicitLogoutFlag();
        _setValidatedSession(true);
        _initialized = true;
        return;
      }

      if (wasExplicitlyLoggedOut) {
        MsalJsInterop.clearSessionData();
        _setValidatedSession(false);
        _initialized = true;
        return;
      }

      if (!MsalJsInterop.hasAccount) {
        _setValidatedSession(false);
        _initialized = true;
        return;
      }

      MsalJsInterop.restoreActiveAccount();
      await getAccessTokenSilently(updateSessionState: true);
    } catch (e) {
      _setValidatedSession(false);
      debugPrint('MSAL initialization error: $e');
    } finally {
      _initialized = true;
    }
  }

  /// Starts Azure AD sign-in via redirect.
  Future<bool> login() async {
    try {
      await _clearExplicitLogoutFlag();
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
    _setValidatedSession(false, notify: false);
    await _markExplicitLogout();
    await MsalJsInterop.logout();
  }

  /// Gets an access token, preferring silent acquisition first.
  Future<String?> getAccessToken() async {
    try {
      final token = await MsalJsInterop.getAccessToken();
      _setValidatedSession(token != null && token.isNotEmpty);
      return token;
    } catch (e) {
      debugPrint('Azure AD getAccessToken error: $e');
      return null;
    }
  }

  /// Gets an access token using silent acquisition only.
  Future<String?> getAccessTokenSilently({bool updateSessionState = false}) async {
    try {
      final token = await MsalJsInterop.getAccessTokenSilently();
      if (token != null && token.isNotEmpty) {
        _setValidatedSession(true);
      } else if (updateSessionState) {
        _setValidatedSession(false);
      }
      return token;
    } catch (e) {
      if (updateSessionState) {
        _setValidatedSession(false);
      }
      debugPrint('Azure AD silent getAccessToken error: $e');
      return null;
    }
  }

  /// Marks the local app session invalid without terminating Microsoft SSO.
  void invalidateSession() {
    _setValidatedSession(false);
  }

  /// Returns whether the current app session is authenticated.
  bool get isLoggedIn => _hasValidatedSession;

  /// Returns the current account payload as JSON.
  String? get accountJson => MsalJsInterop.getAccountJson();

  Future<bool> _wasExplicitlyLoggedOut() async {
    final value = await _storage.read(key: AppConstants.storageKeyLoggedOut);
    return value == 'true';
  }

  Future<void> _markExplicitLogout() {
    return _storage.write(
      key: AppConstants.storageKeyLoggedOut,
      value: 'true',
    );
  }

  Future<void> _clearExplicitLogoutFlag() {
    return _storage.delete(key: AppConstants.storageKeyLoggedOut);
  }

  void _setValidatedSession(bool isAuthenticated, {bool notify = true}) {
    final changed = _hasValidatedSession != isAuthenticated;
    _hasValidatedSession = isAuthenticated;
    if (notify && changed) {
      _sessionStateController.add(isAuthenticated);
    }
  }
}
