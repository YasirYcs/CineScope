import 'show.dart';

/// The result of a show request. [fromCache] tells the UI that the data was
/// served from Hive because the device is offline (or the request failed).
class ShowPage {
  const ShowPage({
    required this.shows,
    required this.fromCache,
    required this.hasMore,
  });

  final List<Show> shows;
  final bool fromCache;
  final bool hasMore;

  bool get isEmpty => shows.isEmpty;
}
