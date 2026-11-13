import 'package:dio/dio.dart';

import '../models/app_exception.dart';
import '../models/show.dart';
import '../models/show_page.dart';
import '../services/connectivity_service.dart';
import '../services/hive_show_cache.dart';
import '../services/tvmaze_api.dart';

/// The single source of truth for show data.
///
/// Flow: UI -> Repository -> TVMaze API / Hive cache.
/// The repository decides whether to use the network or previously cached
/// data, so screens never need to know where a show came from.
class ShowRepository {
  ShowRepository({
    required this.api,
    required this.cache,
    required this.connectivity,
  });

  final ShowApi api;
  final ShowCacheService cache;
  final ConnectivityService connectivity;

  Future<ShowPage> getShows(int page) async {
    final cacheKey = 'shows_page_$page';

    if (!await connectivity.isOnline) {
      final cached = await cache.readShows(cacheKey);
      if (cached != null) {
        return ShowPage(shows: cached, fromCache: true, hasMore: false);
      }
      throw const OfflineException();
    }

    try {
      final shows = await api.getShows(page);
      await cache.writeShows(cacheKey, shows);
      return ShowPage(
        shows: shows,
        fromCache: false,
        hasMore: shows.isNotEmpty,
      );
    } catch (error) {
      final cached = await cache.readShows(cacheKey);
      if (cached != null) {
        return ShowPage(shows: cached, fromCache: true, hasMore: false);
      }
      throw AppException(_friendlyMessage(error));
    }
  }

  Future<ShowPage> searchShows(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const ShowPage(shows: [], fromCache: false, hasMore: false);
    }

    final cacheKey = 'search_${trimmed.toLowerCase()}';

    if (!await connectivity.isOnline) {
      final cached = await cache.readShows(cacheKey);
      if (cached != null) {
        return ShowPage(shows: cached, fromCache: true, hasMore: false);
      }
      throw const OfflineException(
        'You are offline and this search has not been cached yet.',
      );
    }

    try {
      final shows = await api.searchShows(trimmed);
      await cache.writeShows(cacheKey, shows);
      return ShowPage(shows: shows, fromCache: false, hasMore: false);
    } catch (error) {
      final cached = await cache.readShows(cacheKey);
      if (cached != null) {
        return ShowPage(shows: cached, fromCache: true, hasMore: false);
      }
      throw AppException(_friendlyMessage(error));
    }
  }

  Future<Show> getShow(int id) async {
    final cacheKey = 'show_$id';

    if (!await connectivity.isOnline) {
      final cached = await cache.readShow(cacheKey);
      if (cached != null) return cached;
      throw const OfflineException(
        'You are offline and this show has not been cached yet.',
      );
    }

    try {
      final show = await api.getShow(id);
      await cache.writeShow(cacheKey, show);
      return show;
    } catch (error) {
      final cached = await cache.readShow(cacheKey);
      if (cached != null) return cached;
      throw AppException(_friendlyMessage(error));
    }
  }

  String _friendlyMessage(Object error) {
    if (error is AppException) return error.message;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.transformTimeout:
          return 'The request timed out. Check your connection and try again.';
        case DioExceptionType.connectionError:
          return 'Could not reach TVMaze. Check your internet connection.';
        case DioExceptionType.badResponse:
          final status = error.response?.statusCode;
          return status == null
              ? 'TVMaze returned an unexpected response.'
              : 'TVMaze returned an error (HTTP $status). Please try again.';
        case DioExceptionType.cancel:
          return 'The request was cancelled.';
        case DioExceptionType.badCertificate:
          return 'The secure connection to TVMaze failed.';
        case DioExceptionType.unknown:
          return 'Something went wrong while loading shows. Please try again.';
      }
    }

    return 'Something went wrong while loading shows. Please try again.';
  }
}
