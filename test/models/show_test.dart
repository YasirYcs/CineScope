import 'package:cinescope/data/models/show.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('Show', () {
    test('parses a TVMaze JSON object', () {
      final show = Show.fromJson(sampleShowJson());

      expect(show.id, 1);
      expect(show.name, 'Under the Dome');
      expect(show.type, 'Scripted');
      expect(show.language, 'English');
      expect(show.status, 'Ended');
      expect(show.genres, ['Drama', 'Science-Fiction']);
      expect(show.rating, 6.5);
      expect(show.runtime, 60);
      expect(show.network, 'CBS');
      expect(show.premiered, '2013-06-24');
      expect(show.thumbnailUrl, 'https://example.com/medium.jpg');
      expect(show.posterUrl, 'https://example.com/original.jpg');
    });

    test('handles missing optional fields safely', () {
      final show = Show.fromJson({'id': 7});

      expect(show.id, 7);
      expect(show.name, 'Untitled');
      expect(show.genres, isEmpty);
      expect(show.rating, isNull);
      expect(show.ratingText, 'N/A');
      expect(show.year, 'TBA');
      expect(show.plainSummary, isEmpty);
    });

    test('strips HTML from the summary', () {
      final show = Show.fromJson(sampleShowJson());

      expect(show.plainSummary, 'Under the Dome is a science-fiction drama.');
    });

    test('round-trips through JSON for offline caching', () {
      final original = Show.fromJson(sampleShowJson());
      final restored = Show.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.genres, original.genres);
      expect(restored.rating, original.rating);
      expect(restored.summary, original.summary);
      expect(restored.imageOriginal, original.imageOriginal);
      expect(restored.network, original.network);
    });

    test('formats dates and metadata', () {
      final show = Show.fromJson(sampleShowJson());

      expect(show.year, '2013');
      expect(show.premiereDate, '24 Jun 2013');
      expect(show.ratingText, '6.5');
      expect(show.genreText, 'Drama / Science-Fiction');
    });
  });
}
