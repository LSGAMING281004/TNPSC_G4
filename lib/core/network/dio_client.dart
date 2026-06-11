import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';


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

    _setupSecurityContext();
  }

  void _setupSecurityContext() {
    final securityContext = SecurityContext(withTrustedRoots: true);
    // Note: To enforce strict pinning, add the trusted PEM certificate:
    // ByteData certBytes = await rootBundle.load('assets/certs/gemini.pem');
    // securityContext.setTrustedCertificatesBytes(certBytes.buffer.asUint8List());

    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        return HttpClient(context: securityContext)
          ..badCertificateCallback = (X509Certificate cert, String host, int port) {
            // Additional custom hash-based pinning could be added here
            return false; // Reject all bad certificates
          };
      },
    );
  }

  Dio get dio => _dio;

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
