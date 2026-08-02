import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

/// Thin wrapper around [FlutterSecureStorage] scoped to exactly the values
/// this app needs to persist. Nothing outside `core/storage` should touch
/// [FlutterSecureStorage] directly.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // Set when the caller opts out of "remember me": tokens still work for
  // the rest of this run (every read below falls back to these), but never
  // touch disk, so the next app launch finds no session to restore. Sticky
  // across token refreshes — a refresh doesn't pass `remember` explicitly,
  // so it must reuse whatever the original login chose.
  String? _memoryAccessToken;
  String? _memoryRefreshToken;
  bool _remember = true;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    bool? remember,
  }) async {
    _remember = remember ?? _remember;
    if (!_remember) {
      _memoryAccessToken = accessToken;
      _memoryRefreshToken = refreshToken;
      return;
    }
    _memoryAccessToken = null;
    _memoryRefreshToken = null;
    await Future.wait([
      _storage.write(key: StorageKeys.accessToken, value: accessToken),
      _storage.write(key: StorageKeys.refreshToken, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() async =>
      _memoryAccessToken ?? await _storage.read(key: StorageKeys.accessToken);

  Future<String?> getRefreshToken() async =>
      _memoryRefreshToken ?? await _storage.read(key: StorageKeys.refreshToken);

  Future<void> clearTokens() async {
    _memoryAccessToken = null;
    _memoryRefreshToken = null;
    _remember = true;
    await Future.wait([
      _storage.delete(key: StorageKeys.accessToken),
      _storage.delete(key: StorageKeys.refreshToken),
    ]);
  }

  Future<bool> hasValidSession() async {
    final refreshToken = await getRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  const storage = FlutterSecureStorage();
  return SecureStorageService(storage);
});
