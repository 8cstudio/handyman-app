import 'package:dio/dio.dart';
import 'package:my_bloc_app/core/dio/configs/dio_configs.dart';

class DioClient {
  final DioConfigs dioConfigs;
  final Dio _dio;

  DioClient({
    required Dio dio,
    required this.dioConfigs,
  }) : _dio = dio;

  factory DioClient.basic({required DioConfigs dioConfigs}) {
    return DioClient(
      dio: Dio()
        ..options.baseUrl = dioConfigs.baseUrl
        ..options.connectTimeout =
            Duration(milliseconds: dioConfigs.connectionTimeout)
        ..options.receiveTimeout =
            Duration(milliseconds: dioConfigs.receiveTimeout),
      dioConfigs: dioConfigs,
    );
  }

  Dio addInterceptors(Iterable<Interceptor> interceptors) {
    return _dio..interceptors.addAll(interceptors);
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
