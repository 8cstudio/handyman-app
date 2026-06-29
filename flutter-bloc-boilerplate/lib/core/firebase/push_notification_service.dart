import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:my_bloc_app/core/config/flavors/flavors.dart';
import 'package:my_bloc_app/core/firebase/push_notification_navigation.dart';
import 'package:my_bloc_app/data/data_sources/remote/apis/handyman/handyman_api.dart';
import 'package:my_bloc_app/di/service_locator.dart';
import 'package:my_bloc_app/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    return;
  }
  if (kDebugMode) {
    debugPrint('[FCM background] ${message.messageId} ${message.notification?.title}');
  }
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static bool get isEnabled {
    if (FlavorConfig.instance.useMockAuth) return false;
    try {
      return DefaultFirebaseOptions.currentPlatform.projectId.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  String? _currentToken;
  RemoteMessage? _pendingMessage;

  Future<void> initialize() async {
    if (!isEnabled) {
      if (kDebugMode) {
        debugPrint('[FCM] Disabled — run `flutterfire configure` (see FIREBASE_SETUP.md)');
      }
      return;
    }

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;
    await _requestPermission(messaging);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);
    messaging.onTokenRefresh.listen(_syncTokenToBackend);

    _currentToken = await messaging.getToken();
    if (kDebugMode && _currentToken != null) {
      debugPrint('[FCM] Token: ${_currentToken!.substring(0, 20)}...');
    }

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _pendingMessage = initialMessage;
    }
  }

  void handlePendingNotification() {
    final message = _pendingMessage;
    if (message == null) return;
    _pendingMessage = null;
    PushNotificationNavigation.handle(message);
  }

  Future<void> syncTokenAfterAuth() async {
    if (!isEnabled) return;
    _currentToken ??= await FirebaseMessaging.instance.getToken();
    await _syncTokenToBackend(_currentToken);
  }

  Future<void> unregisterToken() async {
    if (!isEnabled) return;
    final token = _currentToken ?? await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;

    try {
      await getIt<HandymanApi>().unregisterDeviceToken(token);
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] unregister failed: $e');
    }

    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}

    _currentToken = null;
  }

  Future<void> _requestPermission(FirebaseMessaging messaging) async {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (kDebugMode) {
      debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
    }
  }

  Future<void> _syncTokenToBackend(String? token) async {
    if (!isEnabled || token == null || token.isEmpty) return;

    _currentToken = token;
    final platform = Platform.isIOS
        ? 'ios'
        : Platform.isAndroid
            ? 'android'
            : 'unknown';
    if (platform == 'unknown') return;

    try {
      await getIt<HandymanApi>().registerDeviceToken(
        token: token,
        platform: platform,
      );
      if (kDebugMode) debugPrint('[FCM] Token registered with backend');
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] Token registration failed: $e');
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint(
        '[FCM foreground] ${message.notification?.title}: ${message.notification?.body}',
      );
    }
  }

  void _onMessageOpened(RemoteMessage message) {
    PushNotificationNavigation.handle(message);
  }
}
