import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityService {
  Future<bool> get isOnline;
}

class ConnectivityPlusService implements ConnectivityService {
  ConnectivityPlusService([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> get isOnline async {
    try {
      final results = await _connectivity.checkConnectivity();
      return !results.contains(ConnectivityResult.none);
    } catch (_) {
      // If the platform cannot report connectivity, let the request try.
      return true;
    }
  }
}
