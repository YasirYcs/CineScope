import 'package:hive_flutter/hive_flutter.dart';

/// Opens the two Hive boxes used by CineScope:
/// - [cacheBox] stores previously fetched TVMaze data for offline use.
/// - [collectionBox] stores the user's personal collection.
class AppStorage {
  const AppStorage._({required this.cacheBox, required this.collectionBox});

  static const String cacheBoxName = 'cinescope_cache';
  static const String collectionBoxName = 'cinescope_collection';

  final Box<String> cacheBox;
  final Box<String> collectionBox;

  static Future<AppStorage> open() async {
    await Hive.initFlutter();
    final cacheBox = await Hive.openBox<String>(cacheBoxName);
    final collectionBox = await Hive.openBox<String>(collectionBoxName);
    return AppStorage._(cacheBox: cacheBox, collectionBox: collectionBox);
  }
}
