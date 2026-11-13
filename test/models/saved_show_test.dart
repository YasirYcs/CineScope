import 'dart:convert';

import 'package:cinescope/data/models/saved_show.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('SavedShow', () {
    test('creates a saved show from a Show', () {
      final saved = SavedShow.fromShow(
        sampleShow(),
        watchStatus: WatchStatus.watching,
        notes: 'Great first season.',
      );

      expect(saved.id, 1);
      expect(saved.name, 'Under the Dome');
      expect(saved.watchStatus, WatchStatus.watching);
      expect(saved.notes, 'Great first season.');
      expect(saved.genres, ['Drama', 'Science-Fiction']);
      expect(saved.year, '2013');
    });

    test('serializes and deserializes from Hive JSON', () {
      final saved = SavedShow.fromShow(
        sampleShow(),
        watchStatus: WatchStatus.completed,
        notes: 'Finished it.',
      );

      final restored = SavedShow.tryParse(jsonEncode(saved.toJson()));

      expect(restored, isNotNull);
      expect(restored!.id, saved.id);
      expect(restored.name, saved.name);
      expect(restored.notes, 'Finished it.');
      expect(restored.watchStatus, WatchStatus.completed);
      expect(restored.savedAt, saved.savedAt);
    });

    test('copyWith updates notes and watch status only', () {
      final saved = SavedShow.fromShow(sampleShow());

      final updated = saved.copyWith(
        notes: 'Re-watching this.',
        watchStatus: WatchStatus.watching,
      );

      expect(updated.notes, 'Re-watching this.');
      expect(updated.watchStatus, WatchStatus.watching);
      expect(updated.id, saved.id);
      expect(updated.name, saved.name);
      expect(updated.savedAt, saved.savedAt);
    });

    test('converts back to a Show for the details screen', () {
      final saved = SavedShow.fromShow(sampleShow());
      final show = saved.toShow();

      expect(show.id, saved.id);
      expect(show.name, saved.name);
      expect(show.summary, saved.summary);
      expect(show.imageOriginal, saved.imageOriginal);
    });

    test('ignores corrupt stored JSON', () {
      expect(SavedShow.tryParse('not-json'), isNull);
      expect(SavedShow.tryParse('[]'), isNull);
    });

    test('maps unknown watch status names to the default', () {
      expect(WatchStatus.fromName('unknown'), WatchStatus.planToWatch);
      expect(WatchStatus.fromName(null), WatchStatus.planToWatch);
      expect(WatchStatus.fromName('dropped'), WatchStatus.dropped);
    });
  });
}
