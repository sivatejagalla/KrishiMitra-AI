import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage_service.dart';
import '../models/api_response.dart';

final apiClientProvider = StateProvider<String>((ref) => 'http://10.0.2.2:8000/api/v1');

final dioProvider = Provider<DioApiClient>((ref) {
  final baseUrl = ref.watch(apiClientProvider);
  final storage = ref.watch(storageServiceProvider);
  return DioApiClient(baseUrl: baseUrl, storageService: storage);
});

class DioApiClient {
  late Dio _dio;
  final StorageService storageService;

  DioApiClient({required String baseUrl, required this.storageService}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  Future<ApiResponse<T>> get<T>(String path, {Map<String, dynamic>? queryParameters, T Function(dynamic)? parser}) async {
    return _request(() => _dio.get(path, queryParameters: queryParameters), parser);
  }

  Future<ApiResponse<T>> post<T>(String path, {dynamic data, T Function(dynamic)? parser}) async {
    return _request(() => _dio.post(path, data: data), parser);
  }

  Future<ApiResponse<T>> _request<T>(Future<Response> Function() requestFunc, T Function(dynamic)? parser, {int retries = 3}) async {
    int attempt = 0;
    while (attempt < retries) {
      try {
        final response = await requestFunc();
        final data = parser != null ? parser(response.data) : response.data as T;
        return ApiResponse.success(data);
      } on DioException catch (e) {
        attempt++;
        if (attempt >= retries || !_isNetworkError(e)) {
          return ApiResponse.failure(AppException.fromDioException(e).message);
        }
        await Future.delayed(Duration(seconds: attempt * 2));
      } catch (e) {
        return ApiResponse.failure(e.toString());
      }
    }
    return ApiResponse.failure('Unknown error');
  }

  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.unknown;
  }
}
