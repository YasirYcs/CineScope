class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OfflineException extends AppException {
  const OfflineException([
    super.message = 'You are offline and no saved data is available yet.',
  ]);
}
