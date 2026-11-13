import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/saved_show.dart';
import '../models/show.dart';

/// Local CRUD for the user's collection. Hive is the only source of truth.
class CollectionRepository extends ChangeNotifier {
  CollectionRepository(this._box) {
    _subscription = _box.watch().listen((_) => notifyListeners());
  }

  final Box<String> _box;
  StreamSubscription<BoxEvent>? _subscription;

  List<SavedShow> getAll() {
    final shows = _box.values
        .map(SavedShow.tryParse)
        .whereType<SavedShow>()
        .toList();
    shows.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return shows;
  }

  SavedShow? findById(int id) {
    final raw = _box.get('$id');
    if (raw == null) return null;
    return SavedShow.tryParse(raw);
  }

  bool isSaved(int id) => _box.containsKey('$id');

  Future<void> add(
    Show show, {
    WatchStatus watchStatus = WatchStatus.planToWatch,
    String notes = '',
  }) {
    final saved = SavedShow.fromShow(
      show,
      watchStatus: watchStatus,
      notes: notes,
    );
    return _box.put('${show.id}', jsonEncode(saved.toJson()));
  }

  Future<void> update(SavedShow show) {
    return _box.put('${show.id}', jsonEncode(show.toJson()));
  }

  Future<void> delete(int id) => _box.delete('$id');

  /// Adds the show when it is missing, removes it when it is already saved.
  Future<bool> toggle(Show show) async {
    if (isSaved(show.id)) {
      await delete(show.id);
      return false;
    }
    await add(show);
    return true;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
