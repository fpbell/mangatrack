// services/secure_storage.service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'favourite_manga';

  static Future<void> saveFavourites(List<Map<String, dynamic>> data) async {
    await _storage.write(key: _key, value: jsonEncode(data));
  }

  static Future<List<Map<String, dynamic>>> loadFavourites() async {
    try {
      final raw = await _storage.read(key: _key);

      if (raw == null || raw.isEmpty) return []; // ← guard null and empty

      final decoded = jsonDecode(raw);

      if (decoded == null || decoded is! List) return []; // ← guard non-list

      return decoded
          .whereType<Map<String, dynamic>>() // ← safely cast each item
          .toList();
    } catch (_) {
      return []; // ← if anything fails, return empty instead of crashing
    }
  }

  static Future<void> clearFavourites() async {
    await _storage.delete(key: _key);
  }
}
