import 'package:dio/dio.dart';

import '../models/show.dart';

abstract class ShowApi {
  Future<List<Show>> getShows(int page);

  Future<List<Show>> searchShows(String query);

  Future<Show> getShow(int id);
}

/// Thin wrapper around the free TVMaze API. No API key is required.
class TvMazeApi implements ShowApi {
  TvMazeApi(this._dio);

  final Dio _dio;

  @override
  Future<List<Show>> getShows(int page) async {
    final response = await _dio.get<dynamic>(
      '/shows',
      queryParameters: {'page': page},
    );
    return _parseShowList(response.data);
  }

  @override
  Future<List<Show>> searchShows(String query) async {
    final response = await _dio.get<dynamic>(
      '/search/shows',
      queryParameters: {'q': query},
    );
    final data = response.data;
    if (data is! List) return const [];

    return data
        .whereType<Map>()
        .map((item) {
          final show = item['show'];
          return show is Map
              ? Show.fromJson(Map<String, dynamic>.from(show))
              : null;
        })
        .whereType<Show>()
        .toList();
  }

  @override
  Future<Show> getShow(int id) async {
    final response = await _dio.get<dynamic>('/shows/$id');
    final data = response.data;
    if (data is! Map) {
      throw const FormatException('Unexpected response from TVMaze.');
    }
    return Show.fromJson(Map<String, dynamic>.from(data));
  }

  List<Show> _parseShowList(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => Show.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
