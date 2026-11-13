import 'package:flutter/material.dart';

import 'app.dart';
import 'core/network/dio_client.dart';
import 'data/repositories/collection_repository.dart';
import 'data/repositories/show_repository.dart';
import 'data/services/app_storage.dart';
import 'data/services/connectivity_service.dart';
import 'data/services/hive_show_cache.dart';
import 'data/services/tvmaze_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await AppStorage.open();
  final api = TvMazeApi(createDio());

  final showRepository = ShowRepository(
    api: api,
    cache: HiveShowCache(storage.cacheBox),
    connectivity: ConnectivityPlusService(),
  );

  final collectionRepository = CollectionRepository(storage.collectionBox);

  runApp(
    CineScopeApp(
      showRepository: showRepository,
      collectionRepository: collectionRepository,
    ),
  );
}
