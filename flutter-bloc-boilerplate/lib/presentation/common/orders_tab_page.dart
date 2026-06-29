import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/domain/entities/booking/booking_entity.dart';
import 'package:my_bloc_app/presentation/blocs/handyman/handyman_cubit.dart';
import 'package:my_bloc_app/presentation/common/role_shell_widgets.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_container.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_style.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_style.dart';

class OrdersTabPage extends StatefulWidget {
  final AppRole role;
  final String chatRoutePrefix;

  const OrdersTabPage({
    super.key,
    required this.role,
    required this.chatRoutePrefix,
  });

  @override
  State<OrdersTabPage> createState() => _OrdersTabPageState();
}

class _OrdersTabPageState extends State<OrdersTabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: OrderStatusTab.values.map((t) => Tab(text: t.label)).toList(),
        ),
        Expanded(
          child: BlocBuilder<HandymanCubit, HandymanState>(
            builder: (context, state) {
              if (state.isLoading && state.bookings.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.error != null && state.bookings.isEmpty) {
                return Center(child: Text(state.error!));
              }
              return TabBarView(
                controller: _tabController,
                children: OrderStatusTab.values
                    .map(
                      (tab) => _BookingList(
                        bookings: filterBookingsByTab(
                          state.bookings,
                          tab,
                          widget.role,
                        ),
                        role: widget.role,
                        chatRoutePrefix: widget.chatRoutePrefix,
                        emptyMessage: 'No ${tab.label.toLowerCase()} orders',
                        hasMoreBookings: state.hasMoreBookings,
                        isLoadingMoreBookings: state.isLoadingMoreBookings,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BookingList extends StatefulWidget {
  final List<BookingEntity> bookings;
  final AppRole role;
  final String chatRoutePrefix;
  final String emptyMessage;
  final bool hasMoreBookings;
  final bool isLoadingMoreBookings;

  const _BookingList({
    required this.bookings,
    required this.role,
    required this.chatRoutePrefix,
    required this.emptyMessage,
    required this.hasMoreBookings,
    required this.isLoadingMoreBookings,
  });

  @override
  State<_BookingList> createState() => _BookingListState();
}

class _BookingListState extends State<_BookingList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<HandymanCubit>().loadMoreBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bookings.isEmpty && !widget.isLoadingMoreBookings) {
      return Center(child: Text(widget.emptyMessage));
    }

    final dateFormat = DateFormat('MMM d, yyyy · h:mm a');
    final itemCount = widget.bookings.length +
        ((widget.hasMoreBookings || widget.isLoadingMoreBookings) ? 1 : 0);

    return RefreshIndicator(
      onRefresh: () => context.read<HandymanCubit>().loadBookings(),
      child: ListView.separated(
        controller: _scrollController,
        padding: GlassStyle.shellTabPadding(context, top: 0),
        itemCount: itemCount,
        separatorBuilder: (_, index) {
          if (index >= widget.bookings.length - 1) {
            return const SizedBox.shrink();
          }
          return const SizedBox(height: 8);
        },
        itemBuilder: (context, index) {
          if (index >= widget.bookings.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final booking = widget.bookings[index];
          return GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          booking.serviceName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      _StatusChip(status: booking.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (widget.role == AppRole.customer && booking.providerName != null)
                    Text('Provider: ${booking.providerName}'),
                  if (widget.role == AppRole.provider && booking.customerName != null)
                    Text('Customer: ${booking.customerName}'),
                  Text(booking.address),
                  Text(dateFormat.format(booking.scheduledAt)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (widget.role == AppRole.provider)
                        ..._providerActions(context, booking),
                      if (widget.role == AppRole.customer)
                        ..._customerActions(context, booking),
                    ],
                  ),
                ],
            ),
          );
        },
      ),
    );
  }

  void _openChat(BuildContext context, String bookingId) async {
    await context.push('${widget.chatRoutePrefix}/$bookingId');
    if (!context.mounted) return;
    final cubit = context.read<HandymanCubit>();
    await cubit.refreshChatPreviewsFromCache();
    unawaited(cubit.loadChatPreviews());
  }

  List<Widget> _providerActions(BuildContext context, BookingEntity booking) {
    return [
      if (booking.status == BookingStatus.assigned) ...[
        ElevatedButton(
          onPressed: () => context.read<HandymanCubit>().updateBookingStatus(booking.id, 'accepted'),
          child: const Text(AppText.accept),
        ),
        OutlinedButton(
          onPressed: () => context.read<HandymanCubit>().updateBookingStatus(booking.id, 'rejected'),
          child: const Text(AppText.reject),
        ),
      ],
      if (booking.status == BookingStatus.accepted)
        ElevatedButton(
          onPressed: () => context.read<HandymanCubit>().updateBookingStatus(booking.id, 'in_progress'),
          child: const Text(AppText.startJob),
        ),
      if (booking.status == BookingStatus.inProgress)
        ElevatedButton(
          onPressed: () => context.read<HandymanCubit>().updateBookingStatus(booking.id, 'completed'),
          child: const Text(AppText.completeJob),
        ),
      if (bookingSupportsChat(booking.status))
        OutlinedButton(
          onPressed: () => _openChat(context, booking.id),
          child: const Text(AppText.chat),
        ),
    ];
  }

  List<Widget> _customerActions(BuildContext context, BookingEntity booking) {
    return [
      if (bookingSupportsChat(booking.status))
        OutlinedButton(
          onPressed: () => _openChat(context, booking.id),
          child: const Text(AppText.chat),
        ),
      if (booking.status == BookingStatus.completed)
        OutlinedButton(
          onPressed: () => context.push('/customer/review/${booking.id}'),
          child: const Text(AppText.writeReview),
        ),
      if (![BookingStatus.completed, BookingStatus.cancelled].contains(booking.status))
        TextButton(
          onPressed: () => context.read<HandymanCubit>().cancelBooking(booking.id),
          child: const Text('Cancel'),
        ),
    ];
  }
}

class _StatusChip extends StatelessWidget {
  final BookingStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        statusLabel(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class ActiveChatsPage extends StatefulWidget {
  final String chatRoutePrefix;

  const ActiveChatsPage({super.key, required this.chatRoutePrefix});

  @override
  State<ActiveChatsPage> createState() => _ActiveChatsPageState();
}

class _ActiveChatsPageState extends State<ActiveChatsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HandymanCubit>().loadChatPreviews();
    });
  }

  String _formatPreviewTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final local = dateTime.toLocal();
    final now = DateTime.now();
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return DateFormat('h:mm a').format(local);
    }
    return DateFormat('MMM d').format(local);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HandymanCubit, HandymanState>(
      builder: (context, state) {
        if (state.isLoadingChatPreviews && state.chatPreviews.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.chatPreviews.isEmpty) {
          return const Center(child: Text('No active chats yet'));
        }
        return RefreshIndicator(
          onRefresh: () => context.read<HandymanCubit>().loadChatPreviews(),
          child: ListView.separated(
            padding: GlassStyle.shellTabPadding(context, top: 0),
            itemCount: state.chatPreviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final chat = state.chatPreviews[index];
              final theme = Theme.of(context);
              final subtitle = chat.lastMessage?.trim().isNotEmpty == true
                  ? chat.lastMessage!.trim()
                  : 'No messages yet';
              return GlassContainer(
                padding: EdgeInsets.zero,
                onTap: () async {
                  await context.push(
                    '${widget.chatRoutePrefix}/${chat.bookingId}',
                  );
                  if (!context.mounted) return;
                  final cubit = context.read<HandymanCubit>();
                  await cubit.refreshChatPreviewsFromCache();
                  unawaited(cubit.loadChatPreviews());
                },
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: chat.hasUnread
                        ? theme.colorScheme.primary.withValues(alpha: 0.18)
                        : GlassStyle.glassFill(context),
                    child: Icon(
                      chat.hasUnread
                          ? Icons.mark_chat_unread_outlined
                          : Icons.chat_bubble_outline,
                      color: chat.hasUnread
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  title: Text(
                    chat.serviceName,
                    style: TextStyle(
                      fontWeight:
                          chat.hasUnread ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: chat.hasUnread
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          chat.hasUnread ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (chat.lastMessageAt != null)
                        Text(
                          _formatPreviewTime(chat.lastMessageAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: chat.hasUnread
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: chat.hasUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      if (chat.hasUnread) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            chat.unreadCount > 99 ? '99+' : '${chat.unreadCount}',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
