import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/collection_repository.dart';
import 'data/repositories/show_repository.dart';
import 'presentation/screens/splash_screen.dart';

class CineScopeApp extends StatelessWidget {
  const CineScopeApp({
    super.key,
    required this.showRepository,
    required this.collectionRepository,
  });

  final ShowRepository showRepository;
  final CollectionRepository collectionRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineScope',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: SplashScreen(
        showRepository: showRepository,
        collectionRepository: collectionRepository,
      ),
    );
  }
}
