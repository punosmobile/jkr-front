import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Service for securely storing sensitive data.
/// 
/// Uses platform-specific secure storage:
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences
/// - Web: Web Crypto API
@lazySingleton
class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  /// Write a value to secure storage
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  /// Write multiple values
  Future<void> writeAll(Map<String, String> values) async {
    for (final entry in values.entries) {
      await write(key: entry.key, value: entry.value);
    }
  }

  /// Read a value from secure storage
  Future<String?> read({required String key}) async {
    return _storage.read(key: key);
  }

  /// Read all values
  Future<Map<String, String>> readAll() async {
    return _storage.readAll();
  }

  /// Delete a value
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  /// Delete all values
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Check if key exists
  Future<bool> containsKey({required String key}) async {
    return _storage.containsKey(key: key);
  }
}
