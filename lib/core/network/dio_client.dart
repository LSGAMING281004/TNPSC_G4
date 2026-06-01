import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// Configured Dio client for API calls
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('DIO: $obj'),
      ),
      _RetryInterceptor(_dio),
    ]);
  }

  Dio get dio => _dio;

  /// Claude API specific client
  Dio get claudeClient {
    final claudeDio = Dio(
      BaseOptions(
        baseUrl: AppConstants.claudeApiUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': AppConstants.claudeApiKey,
          'anthropic-version': '2023-06-01',
        },
      ),
    );
    return claudeDio;
  }
}

/// Retry interceptor for failed requests
class _RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int _maxRetries;

  _RetryInterceptor(this._dio, {int maxRetries = 3}) : _maxRetries = maxRetries;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err) && (err.requestOptions.extra['retryCount'] ?? 0) < _maxRetries) {
      final retryCount = (err.requestOptions.extra['retryCount'] ?? 0) + 1;
      err.requestOptions.extra['retryCount'] = retryCount;

      await Future.delayed(Duration(seconds: retryCount));

      try {
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // Fall through to handler.next
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.response?.statusCode ?? 0) >= 500;
  }
}
