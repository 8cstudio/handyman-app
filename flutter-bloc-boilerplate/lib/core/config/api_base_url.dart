import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Resolves [API_BASE_URL] for the current device.
///
/// Set [API_DEVICE_HOST] in `.env` to your computer's LAN IP when testing on a
/// physical phone/tablet (same Wi‑Fi). Leave it empty for Android emulator
/// (uses 10.0.2.2 automatically).
Future<String> resolveApiBaseUrl() async {
  var configured = dotenv.env['API_BASE_URL']?.trim() ?? '';
  if (configured.isEmpty) configured = 'http://localhost:3000/api/v1';

  final uri = Uri.tryParse(configured);
  if (uri == null || uri.host.isEmpty) return configured;

  final isLocalHost = uri.host == 'localhost' || uri.host == '127.0.0.1';
  if (!isLocalHost || kIsWeb) return configured;

  final deviceHost = dotenv.env['API_DEVICE_HOST']?.trim() ?? '';
  if (deviceHost.isNotEmpty) {
    return uri.replace(host: deviceHost).toString();
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return uri.replace(host: '10.0.2.2').toString();
  }

  return configured;
}
