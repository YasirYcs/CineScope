class AppConstants {
  const AppConstants._();

  static const String appName = 'CineScope';
  static const String tagline = 'Discover. Track. Binge.';
  static const String apiBaseUrl = 'https://api.tvmaze.com';
  static const String apiAttribution = 'Data provided by TVMaze';

  static const int showsPerPage = 250;
  static const Duration searchDebounce = Duration(milliseconds: 450);
  static const Duration splashDuration = Duration(milliseconds: 2200);
}
