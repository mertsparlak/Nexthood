import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8000', // Android emulator -> host machine
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await secureStorage.read(key: 'access_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (DioException e, handler) async {
      if (e.response?.statusCode == 401) {
        // Try to refresh the token
        final refreshToken = await secureStorage.read(key: 'refresh_token');
        if (refreshToken != null) {
          try {
            final refreshDio = Dio(BaseOptions(
              baseUrl: dio.options.baseUrl,
              contentType: 'application/json',
            ));
            final response = await refreshDio.post('/auth/refresh', data: {
              'refresh_token': refreshToken,
            });

            final newAccessToken = response.data['access_token'];
            final newRefreshToken = response.data['refresh_token'];

            await secureStorage.write(key: 'access_token', value: newAccessToken);
            await secureStorage.write(key: 'refresh_token', value: newRefreshToken);

            // Retry the original request with new token
            e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await dio.fetch(e.requestOptions);
            return handler.resolve(retryResponse);
          } catch (_) {
            // Refresh failed — clear tokens
            await secureStorage.delete(key: 'access_token');
            await secureStorage.delete(key: 'refresh_token');
          }
        }
      }
      return handler.next(e);
    },
  ));

  return dio;
});
