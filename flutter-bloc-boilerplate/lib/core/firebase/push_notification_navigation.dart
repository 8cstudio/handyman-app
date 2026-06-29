import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:my_bloc_app/di/service_locator.dart';
import 'package:my_bloc_app/domain/entities/user/user_entity.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_state.dart';
import 'package:my_bloc_app/presentation/routes/app_router.dart';
import 'package:my_bloc_app/presentation/routes/app_routes.dart';

class PushNotificationNavigation {
  PushNotificationNavigation._();

  static void handle(RemoteMessage message) {
    final data = message.data;
    final type = data['type']?.trim();
    final bookingId = data['booking_id']?.trim();

    if (type == null || type.isEmpty || bookingId == null || bookingId.isEmpty) {
      return;
    }

    final authState = getIt<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final user = authState.user;
    if (kDebugMode) {
      debugPrint('[FCM navigate] type=$type bookingId=$bookingId');
    }

    switch (type) {
      case 'chat':
        _openChat(user: user, bookingId: bookingId);
      case 'booking_status':
        _openBookingStatus(user: user, bookingId: bookingId, status: data['status']);
      default:
        return;
    }
  }

  static void _openChat({required UserEntity user, required String bookingId}) {
    if (user.isCustomer) {
      appRouter.push(AppRoute.customerChat.path.replaceFirst(':bookingId', bookingId));
      return;
    }
    if (user.isProvider) {
      appRouter.push(AppRoute.providerChat.path.replaceFirst(':bookingId', bookingId));
    }
  }

  static void _openBookingStatus({
    required UserEntity user,
    required String bookingId,
    String? status,
  }) {
    const chatStatuses = {'accepted', 'in_progress', 'completed'};
    if (status != null && chatStatuses.contains(status)) {
      _openChat(user: user, bookingId: bookingId);
      return;
    }

    if (user.isCustomer) {
      appRouter.go('${AppRoute.customerHome.path}?tab=orders');
      return;
    }
    if (user.isProvider) {
      appRouter.go('${AppRoute.providerHome.path}?tab=orders');
    }
  }
}
