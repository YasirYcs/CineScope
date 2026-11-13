import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

Dio createDio() {
  return Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 15),
      headers: const {'Accept': 'application/json'},
    ),
  );
}
