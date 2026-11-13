import 'package:cinescope/data/models/app_exception.dart';
import 'package:cinescope/data/repositories/show_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('ShowRepository', () {
    test('fetches online shows and stores them in the cache', () async {
      final cache = FakeShowCache();
      final api = FakeShowApi(shows: [sampleShow()]);
      final repository = ShowRepository(
        api: api,
        cache: cache,
        connectivity: FakeConnectivity(true),
      );

      final page = await repository.getShows(0);

      expect(page.fromCache, isFalse);
      expect(page.hasMore, isTrue);
      expect(page.shows, hasLength(1));
      expect(cache.hasList('shows_page_0'), isTrue);
      expect(api.getShowsCalls, 1);
    });

    test('returns cached shows when offline', () async {
      final cache = FakeShowCache();
      await cache.writeShows('shows_page_0', [sampleShow()]);
      final repository = ShowRepository(
        api: FakeShowApi(shouldThrow: true),
        cache: cache,
        connectivity: FakeConnectivity(false),
      );

      final page = await repository.getShows(0);

      expect(page.fromCache, isTrue);
      expect(page.hasMore, isFalse);
      expect(page.shows.single.name, 'Under the Dome');
    });

    test('throws OfflineException when offline without cache', () async {
      final repository = ShowRepository(
        api: FakeShowApi(),
        cache: FakeShowCache(),
        connectivity: FakeConnectivity(false),
      );

      expect(() => repository.getShows(0), throwsA(isA<OfflineException>()));
    });

    test('falls back to cache when the network request fails', () async {
      final cache = FakeShowCache();
      await cache.writeShows('shows_page_0', [sampleShow()]);
      final repository = ShowRepository(
        api: FakeShowApi(shouldThrow: true),
        cache: cache,
        connectivity: FakeConnectivity(true),
      );

      final page = await repository.getShows(0);

      expect(page.fromCache, isTrue);
      expect(page.shows, hasLength(1));
    });

    test('throws AppException when network fails and cache is empty', () async {
      final repository = ShowRepository(
        api: FakeShowApi(shouldThrow: true),
        cache: FakeShowCache(),
        connectivity: FakeConnectivity(true),
      );

      expect(() => repository.getShows(0), throwsA(isA<AppException>()));
    });

    test('searches using a normalized cache key', () async {
      final cache = FakeShowCache();
      final api = FakeShowApi(searchResults: [sampleShow()]);
      final repository = ShowRepository(
        api: api,
        cache: cache,
        connectivity: FakeConnectivity(true),
      );

      final page = await repository.searchShows('  Dark  ');

      expect(api.lastSearchQuery, 'Dark');
      expect(page.shows, hasLength(1));
      expect(cache.hasList('search_dark'), isTrue);
    });

    test('returns cached search results when offline', () async {
      final cache = FakeShowCache();
      await cache.writeShows('search_dark', [sampleShow()]);
      final repository = ShowRepository(
        api: FakeShowApi(shouldThrow: true),
        cache: cache,
        connectivity: FakeConnectivity(false),
      );

      final page = await repository.searchShows('Dark');

      expect(page.fromCache, isTrue);
      expect(page.shows, hasLength(1));
    });

    test('fetches show details and caches them', () async {
      final cache = FakeShowCache();
      final api = FakeShowApi(detail: sampleShow(name: 'Detailed Show'));
      final repository = ShowRepository(
        api: api,
        cache: cache,
        connectivity: FakeConnectivity(true),
      );

      final show = await repository.getShow(1);

      expect(show.name, 'Detailed Show');
      expect(cache.hasShow('show_1'), isTrue);
    });

    test('returns cached details when offline', () async {
      final cache = FakeShowCache();
      await cache.writeShow('show_1', sampleShow());
      final repository = ShowRepository(
        api: FakeShowApi(shouldThrow: true),
        cache: cache,
        connectivity: FakeConnectivity(false),
      );

      final show = await repository.getShow(1);

      expect(show.id, 1);
    });
  });
}
