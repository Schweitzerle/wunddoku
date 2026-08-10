import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provides the key material for the encrypted database.
///
/// The key never touches SharedPreferences or a plain file — the concrete
/// implementation stores it in the platform keystore/keychain. The interface
/// exists so tests can substitute a fake without touching platform channels.
abstract interface class DatabaseKeyStore {
  /// The stored key, or a freshly generated one on first use.
  ///
  /// Generating on first read means there is no unencrypted window: the
  /// database is created encrypted or not at all.
  Future<String> obtainKey();
}

/// Stores the database key in the Android Keystore / iOS Keychain via
/// [FlutterSecureStorage].
class SecureDatabaseKeyStore implements DatabaseKeyStore {
  SecureDatabaseKeyStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _keyName = 'wunddoku.database_key.v1';

  final FlutterSecureStorage _storage;

  @override
  Future<String> obtainKey() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null) return existing;

    final key = generateKey();
    await _storage.write(key: _keyName, value: key);
    return key;
  }

  /// 32 random bytes as 64 lowercase hex characters.
  static String generateKey({Random? random}) {
    final rng = random ?? Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < 32; i++) {
      buffer.write(rng.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
