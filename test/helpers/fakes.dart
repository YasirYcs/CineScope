import 'package:cinescope/data/models/show.dart';
import 'package:cinescope/data/services/connectivity_service.dart';
import 'package:cinescope/data/services/hive_show_cache.dart';
import 'package:cinescope/data/services/tvmaze_api.dart';

Map<String, dynamic> sampleShowJson({
  int id = 1,
  String name = 'Under the Dome',
}) {
  return {
    'id': id,
    'name': name,
    'type': 'Scripted',
    'language': 'English',
    'genres': ['Drama', 'Science-Fiction'],
    'status': 'Ended',
    'runtime': 60,
    'premiered': '2013-06-24',
    'ended': '2015-09-10',
    'officialSite': 'https://example.com/under-the-dome',
    'rating': {'average': 6.5},
    'image': {
      'medium': 'https://example.com/medium.jpg',
      'original': 'https://example.com/original.jpg',
    },
    'network': {'name': 'CBS'},
    'summary': '<p>Under the Dome is <b>a science-fiction drama</b>.</p>',
  };
}

Show sampleShow({int id = 1, String name = 'Under the Dome'}) {
  return Show.fromJson(sampleShowJson(id: id, name: name));
}

class FakeShowApi implements ShowApi {
  FakeShowApi({
    List<Show>? shows,
    List<Show>? searchResults,
    Show? detail,
    this.shouldThrow = false,
  }) : shows = shows ?? [sampleShow()],
       searchResults = searchResults ?? shows ?? [sampleShow()],
       detail =
           detail ?? (shows?.isNotEmpty ?? false ? shows!.first : sampleShow());

  final List<Show> shows;
  final List<Show> searchResults;
  final Show detail;
  final bool shouldThrow;

  int getShowsCalls = 0;
  int searchCalls = 0;
  int detailCalls = 0;
  String? lastSearchQuery;

  @override
  Future<List<Show>> getShows(int page) async {
    getShowsCalls++;
    if (shouldThrow) throw Exception('network failed');
    return shows;
  }

  @override
  Future<List<Show>> searchShows(String query) async {
    searchCalls++;
    lastSearchQuery = query;
    if (shouldThrow) throw Exception('network failed');
    return searchResults;
  }

  @override
  Future<Show> getShow(int id) async {
    detailCalls++;
    if (shouldThrow) throw Exception('network failed');
    return detail;
  }
}

class FakeShowCache implements ShowCacheService {
  final Map<String, List<Show>> lists = {};
  final Map<String, Show> details = {};

  bool hasList(String key) => lists.containsKey(key);

  bool hasShow(String key) => details.containsKey(key);

  @override
  Future<List<Show>?> readShows(String key) async => lists[key];

  @override
  Future<void> writeShows(String key, List<Show> shows) async {
    lists[key] = shows;
  }

  @override
  Future<Show?> readShow(String key) async => details[key];

  @override
  Future<void> writeShow(String key, Show show) async {
    details[key] = show;
  }
}

class FakeConnectivity implements ConnectivityService {
  FakeConnectivity(this.online);

  bool online;

  @override
  Future<bool> get isOnline async => online;
}
