import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/core/theme/theme_context.dart';
import 'package:my_bloc_app/domain/entities/booking/booking_entity.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_event.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_state.dart';
import 'package:my_bloc_app/presentation/blocs/theme/theme_cubit.dart';
import 'package:my_bloc_app/presentation/routes/app_routes.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_container.dart';

enum AppRole { customer, provider }

class RoleAppDrawer extends StatelessWidget {
  final AppRole role;

  const RoleAppDrawer({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final auth = context.watch<AuthBloc>().state;
    final userName = auth is AuthAuthenticated ? auth.user.name : AppText.appName;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: GlassContainer(
                blur: true,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: context.colors.primary,
                      child: Icon(
                        role == AppRole.customer ? Icons.person : Icons.handyman,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: appTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            role == AppRole.customer ? 'Customer' : 'Provider',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: appTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            if (role == AppRole.provider)
              ListTile(
                leading: const Icon(Icons.upload_file_outlined),
                title: const Text(AppText.uploadDocuments),
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoute.providerOnboarding.path);
                },
              ),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text(AppText.appearance),
              subtitle: BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, mode) => Text(
                  mode == ThemeMode.dark ? AppText.darkMode : AppText.lightMode,
                ),
              ),
              onTap: () {
                final cubit = context.read<ThemeCubit>();
                final next = cubit.state == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
                cubit.setThemeMode(next);
              },
            ),
            const Spacer(),
            ListTile(
              leading: Icon(Icons.logout, color: appTheme.error),
              title: Text(AppText.signOut, style: TextStyle(color: appTheme.error)),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(const SignOutRequested());
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppText.appName,
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: appTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum OrderStatusTab { pending, active, completed, cancelled }

extension OrderStatusTabX on OrderStatusTab {
  String get label => switch (this) {
        OrderStatusTab.pending => AppText.tabPending,
        OrderStatusTab.active => AppText.tabActive,
        OrderStatusTab.completed => AppText.tabCompleted,
        OrderStatusTab.cancelled => AppText.tabCancelled,
      };

  bool matches(BookingStatus status) => matchesForRole(status, AppRole.customer);

  bool matchesForRole(BookingStatus status, AppRole role) {
    if (role == AppRole.provider) {
      return switch (this) {
        OrderStatusTab.pending => status == BookingStatus.assigned,
        OrderStatusTab.active =>
          status == BookingStatus.accepted || status == BookingStatus.inProgress,
        OrderStatusTab.completed => status == BookingStatus.completed,
        OrderStatusTab.cancelled =>
          status == BookingStatus.cancelled || status == BookingStatus.rejected,
      };
    }

    return switch (this) {
      OrderStatusTab.pending => status == BookingStatus.pending,
      OrderStatusTab.active =>
        status == BookingStatus.assigned ||
            status == BookingStatus.accepted ||
            status == BookingStatus.inProgress,
      OrderStatusTab.completed => status == BookingStatus.completed,
      OrderStatusTab.cancelled =>
        status == BookingStatus.cancelled || status == BookingStatus.rejected,
    };
  }
}

List<BookingEntity> filterBookingsByTab(
  List<BookingEntity> bookings,
  OrderStatusTab tab,
  AppRole role,
) {
  return bookings.where((b) => tab.matchesForRole(b.status, role)).toList();
}

bool bookingSupportsChat(BookingStatus status) {
  return status == BookingStatus.accepted ||
      status == BookingStatus.inProgress ||
      status == BookingStatus.completed;
}

List<BookingEntity> activeChatBookings(List<BookingEntity> bookings) {
  return bookings.where((b) => bookingSupportsChat(b.status)).toList();
}

String statusLabel(BookingStatus status) {
  return switch (status) {
    BookingStatus.pending => 'Pending',
    BookingStatus.assigned => 'Assigned',
    BookingStatus.accepted => 'Accepted',
    BookingStatus.rejected => 'Rejected',
    BookingStatus.inProgress => 'In Progress',
    BookingStatus.completed => 'Completed',
    BookingStatus.cancelled => 'Cancelled',
  };
}

class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppText.notifications,
      onPressed: () {},
      icon: const Icon(Icons.notifications_outlined),
    );
  }
}

class ChatNavIcon extends StatelessWidget {
  final bool showUnreadDot;
  final bool selected;

  const ChatNavIcon({
    super.key,
    required this.showUnreadDot,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 26,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(
            selected ? Icons.chat : Icons.chat_outlined,
            size: 22,
          ),
          if (showUnreadDot)
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
