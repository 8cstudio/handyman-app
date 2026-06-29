enum AppFlavor { dev, staging, prod }

class FlavorConfig {
  final AppFlavor flavor;
  final String baseUrl;
  final int connectionTimeout;
  final int receiveTimeout;
  final bool useMockAuth;

  const FlavorConfig({
    required this.flavor,
    required this.baseUrl,
    required this.connectionTimeout,
    required this.receiveTimeout,
    required this.useMockAuth,
  });

  static late FlavorConfig instance;

  static void initialize({
    required AppFlavor flavor,
    required String baseUrl,
    required int connectionTimeout,
    required int receiveTimeout,
    required bool useMockAuth,
  }) {
    instance = FlavorConfig(
      flavor: flavor,
      baseUrl: baseUrl,
      connectionTimeout: connectionTimeout,
      receiveTimeout: receiveTimeout,
      useMockAuth: useMockAuth,
    );
  }
}
