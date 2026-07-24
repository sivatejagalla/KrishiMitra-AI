import 'package:dio/dio.dart';

class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;

  ApiResponse({this.data, this.error, required this.success});

  factory ApiResponse.success(T data) {
    return ApiResponse(data: data, success: true);
  }

  factory ApiResponse.failure(String error) {
    return ApiResponse(error: error, success: false);
  }
}

class AppException implements Exception {
  final String message;
  AppException(this.message);

  factory AppException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.cancel:
        return AppException("Request was cancelled");
      case DioExceptionType.connectionTimeout:
        return AppException("Connection timeout");
      case DioExceptionType.sendTimeout:
        return AppException("Send timeout");
      case DioExceptionType.receiveTimeout:
        return AppException("Receive timeout");
      case DioExceptionType.badResponse:
        return AppException("Bad response: ${dioException.response?.statusCode}");
      default:
        return AppException("Unexpected error occurred");
    }
  }
  
  @override
  String toString() => message;
}
