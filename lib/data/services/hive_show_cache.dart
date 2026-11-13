import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/show.dart';

abstract class ShowCacheService {
  Future<List<Show>?> readShows(String key);

  Future<void> writeShows(String key, List<Show> shows);

  Future<Show?> readShow(String key);

  Future<void> writeShow(String key, Show show);
}

/// Stores API responses as JSON strings inside a Hive box.
///
/// JSON keeps the cache simple and avoids generated Hive adapters, which makes
/// the app easier to explain.
class HiveShowCache implements ShowCacheService {
  HiveShowCache(this._box);

  final Box<String> _box;

  @override
  Future<List<Show>?> readShows(String key) async {
    final raw = _box.get(key);
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map && decoded['shows'] is List) {
        return (decoded['shows'] as List)
            .whereType<Map>()
            .map((item) => Show.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (_) {
      // Ignore a corrupt cache entry and fall back to the network.
    }
    return null;
  }

  @override
  Future<void> writeShows(String key, List<Show> shows) {
    final payload = {
      'cachedAt': DateTime.now().toIso8601String(),
      'shows': shows.map((show) => show.toJson()).toList(),
    };
    return _box.put(key, jsonEncode(payload));
  }

  @override
  Future<Show?> readShow(String key) async {
    final raw = _box.get(key);
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Show.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      // Ignore a corrupt cache entry.
    }
    return null;
  }

  @override
  Future<void> writeShow(String key, Show show) {
    return _box.put(key, jsonEncode(show.toJson()));
  }
}
