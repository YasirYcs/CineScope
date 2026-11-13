import 'dart:io';

import 'package:cinescope/data/models/saved_show.dart';
import 'package:cinescope/data/repositories/collection_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../helpers/fakes.dart';

void main() {
  late Directory tempDir;
  late Box<String> box;
  late CollectionRepository repository;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('cinescope_hive_test');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    box = await Hive.openBox<String>('collection_test');
    await box.clear();
    repository = CollectionRepository(box);
  });

  tearDown(() async {
    repository.dispose();
    await box.close();
  });

  tearDownAll(() async {
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {
      // Windows can briefly lock Hive files; the OS temp folder is cleaned up.
    }
  });

  test('adds a show to the collection', () async {
    await repository.add(sampleShow());

    expect(repository.getAll(), hasLength(1));
    expect(repository.isSaved(1), isTrue);
    expect(repository.findById(1)?.name, 'Under the Dome');
  });

  test('updates notes and watch status', () async {
    await repository.add(sampleShow());
    final saved = repository.findById(1)!;

    await repository.update(
      saved.copyWith(
        notes: 'Loved the finale.',
        watchStatus: WatchStatus.completed,
      ),
    );

    final updated = repository.findById(1)!;
    expect(updated.notes, 'Loved the finale.');
    expect(updated.watchStatus, WatchStatus.completed);
  });

  test('deletes a saved show', () async {
    await repository.add(sampleShow());

    await repository.delete(1);

    expect(repository.getAll(), isEmpty);
    expect(repository.isSaved(1), isFalse);
    expect(repository.findById(1), isNull);
  });

  test('toggle adds a missing show and removes an existing one', () async {
    final added = await repository.toggle(sampleShow());
    expect(added, isTrue);
    expect(repository.isSaved(1), isTrue);

    final removed = await repository.toggle(sampleShow());
    expect(removed, isFalse);
    expect(repository.isSaved(1), isFalse);
  });

  test('persists the collection to Hive', () async {
    await repository.add(
      sampleShow(),
      notes: 'Saved in Hive.',
      watchStatus: WatchStatus.watching,
    );

    final raw = box.get('1');
    expect(raw, isNotNull);

    final parsed = SavedShow.tryParse(raw!)!;
    expect(parsed.notes, 'Saved in Hive.');
    expect(parsed.watchStatus, WatchStatus.watching);
  });
}
