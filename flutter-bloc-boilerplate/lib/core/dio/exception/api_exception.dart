import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Connection timeout. Please try again.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String? serverMessage;
        if (data is Map<String, dynamic>) {
          serverMessage =
              data['message'] as String? ?? data['error'] as String?;
        }
        return ApiException(
          message: serverMessage ?? 'Server error occurred.',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return const ApiException(message: 'Request was cancelled.');
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'No internet connection. Please check your network.',
        );
      default:
        return ApiException(message: error.message ?? 'Unexpected error.');
    }
  }

  @override
  String toString() => message;
}

void debugLogDioError(DioException error) {
  if (kDebugMode) {
    debugPrint('[DioError] ${error.type}: ${error.message}');
  }
}
