class DioConfigs {
  final String baseUrl;
  final int connectionTimeout;
  final int receiveTimeout;

  const DioConfigs({
    required this.baseUrl,
    required this.connectionTimeout,
    required this.receiveTimeout,
  });
}
