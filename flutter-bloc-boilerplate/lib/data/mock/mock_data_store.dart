import 'package:my_bloc_app/domain/entities/booking/booking_entity.dart';
import 'package:my_bloc_app/domain/entities/booking/bookings_page_result.dart';
import 'package:my_bloc_app/domain/entities/catalog/catalog_entity.dart';
import 'package:my_bloc_app/domain/entities/catalog/services_page_result.dart';
import 'package:my_bloc_app/domain/entities/chat/message_entity.dart';
import 'package:my_bloc_app/domain/entities/chat/chat_preview_entity.dart';
import 'package:my_bloc_app/domain/entities/chat/messages_page_result.dart';
import 'package:my_bloc_app/domain/entities/theme/theme_config_entity.dart';
import 'package:my_bloc_app/domain/entities/user/user_entity.dart';
import 'package:my_bloc_app/domain/entities/user/user_role.dart';

/// In-memory mock backend used when [FlavorConfig.useMockAuth] is true.
class MockDataStore {
  MockDataStore._();
  static final instance = MockDataStore._();

  final Map<String, UserEntity> _usersByEmail = {};
  final List<_MockBooking> _bookings = [];
  final Map<String, List<MessageEntity>> _messagesByChatRoom = {};
  int _bookingCounter = 100;
  int _messageCounter = 1000;

  static const mockProviderId = 'mock-provider-001';
  static const mockProviderUserId = 'mock-provider-user';
  static const mockCustomerUserId = 'mock-customer-user';

  void seed() {
    if (_usersByEmail.isNotEmpty) return;

    _usersByEmail['customer@demo.com'] = const UserEntity(
      id: mockCustomerUserId,
      name: 'Demo Customer',
      email: 'customer@demo.com',
      role: UserRole.customer,
      phone: '+10000000001',
      accessToken: 'mock_token_customer',
    );

    _usersByEmail['provider@demo.com'] = const UserEntity(
      id: mockProviderUserId,
      name: 'Demo Provider',
      email: 'provider@demo.com',
      role: UserRole.provider,
      phone: '+10000000002',
      providerStatus: 'approved',
      accessToken: 'mock_token_provider',
    );

    _usersByEmail['provider-pending@demo.com'] = const UserEntity(
      id: 'mock-provider-pending',
      name: 'Pending Provider',
      email: 'provider-pending@demo.com',
      role: UserRole.provider,
      providerStatus: 'pending',
      accessToken: 'mock_token_provider_pending',
    );

    _bookings.addAll([
      _MockBooking(
        id: 'booking-001',
        serviceId: 'svc-001',
        serviceName: 'Pipe Repair',
        servicePrice: 75,
        customerId: mockCustomerUserId,
        customerName: 'Demo Customer',
        providerId: mockProviderId,
        providerName: 'Demo Provider',
        address: '123 Mock Street',
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        status: BookingStatus.accepted,
      ),
      _MockBooking(
        id: 'booking-002',
        serviceId: 'svc-003',
        serviceName: 'Outlet Installation',
        servicePrice: 85,
        customerId: mockCustomerUserId,
        customerName: 'Demo Customer',
        providerId: mockProviderId,
        providerName: 'Demo Provider',
        address: '456 Demo Ave',
        scheduledAt: DateTime.now().subtract(const Duration(days: 2)),
        status: BookingStatus.completed,
      ),
    ]);

    _ensureChatRoom('booking-001');
    _messagesByChatRoom['chat-booking-001'] = [
      MessageEntity(
        id: 'msg-1',
        content: 'Hi, I will arrive on time.',
        senderId: mockProviderUserId,
        senderName: 'Demo Provider',
        messageType: 'text',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      MessageEntity(
        id: 'msg-2',
        content: 'Thanks! See you then.',
        senderId: mockCustomerUserId,
        senderName: 'Demo Customer',
        messageType: 'text',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  UserEntity? userByEmail(String email) => _usersByEmail[email.toLowerCase().trim()];

  void registerUser(UserEntity user) {
    _usersByEmail[user.email.toLowerCase()] = user;
  }

  UserEntity? userById(String id) {
    for (final user in _usersByEmail.values) {
      if (user.id == id) return user;
    }
    return null;
  }

  List<CategoryEntity> get categories => const [
        CategoryEntity(id: 'cat-001', name: 'Plumbing', description: 'Plumbing services'),
        CategoryEntity(id: 'cat-002', name: 'Electrical', description: 'Electrical services'),
        CategoryEntity(id: 'cat-003', name: 'Carpentry', description: 'Carpentry services'),
      ];

  List<ServiceEntity> get services => const [
        ServiceEntity(
          id: 'svc-001',
          name: 'Pipe Repair',
          description: 'Fix leaking or broken pipes',
          price: 75,
          durationMinutes: 60,
          categoryId: 'cat-001',
          categoryName: 'Plumbing',
        ),
        ServiceEntity(
          id: 'svc-002',
          name: 'Drain Cleaning',
          description: 'Clear clogged drains',
          price: 50,
          durationMinutes: 45,
          categoryId: 'cat-001',
          categoryName: 'Plumbing',
        ),
        ServiceEntity(
          id: 'svc-003',
          name: 'Outlet Installation',
          description: 'Install new electrical outlets',
          price: 85,
          durationMinutes: 90,
          categoryId: 'cat-002',
          categoryName: 'Electrical',
        ),
        ServiceEntity(
          id: 'svc-004',
          name: 'Door Repair',
          description: 'Fix or adjust doors',
          price: 65,
          durationMinutes: 60,
          categoryId: 'cat-003',
          categoryName: 'Carpentry',
        ),
      ];

  ServicesPageResult filterServices({
    String? categoryId,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) {
    var result = services;
    if (categoryId != null) {
      result = result.where((s) => s.categoryId == categoryId).toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      result = result.where((s) => s.name.toLowerCase().contains(q)).toList();
    }

    final from = page * pageSize;
    final end = from + pageSize + 1;
    if (from >= result.length) {
      return const ServicesPageResult(services: [], hasMore: false);
    }

    final slice = result.sublist(from, end.clamp(0, result.length));
    final hasMore = slice.length > pageSize;
    final pageItems = hasMore ? slice.sublist(0, pageSize) : slice;
    return ServicesPageResult(services: pageItems, hasMore: hasMore);
  }

  ServiceEntity? serviceById(String id) {
    try {
      return services.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  ThemeConfigEntity get themeConfig => ThemeConfigEntity.defaults();

  List<BookingEntity> bookingsForUser(UserEntity user) {
    if (user.isCustomer) {
      return _bookings
          .where((b) => b.customerId == user.id)
          .map((b) => b.toEntity())
          .toList();
    }
    if (user.isProvider) {
      return _bookings
          .where((b) => b.providerId == mockProviderId && user.isProviderApproved)
          .map((b) => b.toEntity())
          .toList();
    }
    return [];
  }

  BookingsPageResult paginatedBookingsForUser(
    UserEntity user, {
    int page = 0,
    int pageSize = 20,
  }) {
    final all = bookingsForUser(user)
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    final from = page * pageSize;
    final end = from + pageSize + 1;
    if (from >= all.length) {
      return const BookingsPageResult(bookings: [], hasMore: false);
    }
    final slice = all.sublist(from, end.clamp(0, all.length));
    final hasMore = slice.length > pageSize;
    final pageItems = hasMore ? slice.sublist(0, pageSize) : slice;
    return BookingsPageResult(bookings: pageItems, hasMore: hasMore);
  }

  BookingEntity createBooking({
    required String customerId,
    required String customerName,
    required String serviceId,
    required DateTime scheduledAt,
    required String address,
    String? notes,
  }) {
    final service = serviceById(serviceId)!;
    final booking = _MockBooking(
      id: 'booking-${++_bookingCounter}',
      serviceId: serviceId,
      serviceName: service.name,
      servicePrice: service.price,
      customerId: customerId,
      customerName: customerName,
      address: address,
      notes: notes,
      scheduledAt: scheduledAt,
      status: BookingStatus.pending,
    );
    _bookings.insert(0, booking);

    // Auto-assign in mock mode so provider demo account can accept jobs.
    booking.providerId = mockProviderId;
    booking.providerName = 'Demo Provider';
    booking.status = BookingStatus.assigned;

    return booking.toEntity();
  }

  BookingEntity? updateBookingStatus(String bookingId, String status) {
    final booking = _findBooking(bookingId);
    if (booking == null) return null;

    booking.status = BookingStatus.fromString(status);

    if (booking.status == BookingStatus.assigned && booking.providerId == null) {
      booking.providerId = mockProviderId;
      booking.providerName = 'Demo Provider';
    }

    if (booking.status == BookingStatus.accepted ||
        booking.status == BookingStatus.inProgress ||
        booking.status == BookingStatus.completed) {
      _ensureChatRoom(bookingId);
    }

    return booking.toEntity();
  }

  void cancelBooking(String bookingId) {
    updateBookingStatus(bookingId, 'cancelled');
  }

  String? chatRoomIdForBooking(String bookingId) {
    final booking = _findBooking(bookingId);
    if (booking == null) return null;
    if (!bookingSupportsChatStatus(booking.status)) return null;
    return 'chat-$bookingId';
  }

  bool bookingSupportsChatStatus(BookingStatus status) {
    return status == BookingStatus.accepted ||
        status == BookingStatus.inProgress ||
        status == BookingStatus.completed;
  }

  MessagesPageResult paginatedMessagesForChatRoom(
    String chatRoomId, {
    int limit = 30,
    DateTime? before,
    DateTime? after,
  }) {
    final all = List<MessageEntity>.from(_messagesByChatRoom[chatRoomId] ?? [])
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (after != null) {
      final newer = all.where((m) => m.createdAt.isAfter(after)).toList();
      final hasMore = newer.length > limit;
      final page = newer.take(limit).toList();
      return MessagesPageResult(messages: page, hasMore: hasMore);
    }

    List<MessageEntity> slice;
    if (before != null) {
      slice = all.where((m) => m.createdAt.isBefore(before)).toList();
    } else {
      slice = all;
    }

    final hasMore = slice.length > limit;
    final start = slice.length > limit ? slice.length - limit : 0;
    final page = slice.sublist(start);
    return MessagesPageResult(messages: page, hasMore: hasMore);
  }

  MessageEntity sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String content,
    String messageType = 'text',
  }) {
    final message = MessageEntity(
      id: 'msg-${++_messageCounter}',
      content: content,
      senderId: senderId,
      senderName: senderName,
      messageType: messageType,
      createdAt: DateTime.now(),
    );
    _messagesByChatRoom.putIfAbsent(chatRoomId, () => []).add(message);
    return message;
  }

  void markMessagesRead(String chatRoomId, String readerId) {
    final messages = _messagesByChatRoom[chatRoomId];
    if (messages == null) return;
    for (var i = 0; i < messages.length; i++) {
      final msg = messages[i];
      if (msg.senderId != readerId && msg.readAt == null) {
        messages[i] = MessageEntity(
          id: msg.id,
          content: msg.content,
          senderId: msg.senderId,
          senderName: msg.senderName,
          messageType: msg.messageType,
          createdAt: msg.createdAt,
          readAt: DateTime.now(),
        );
      }
    }
  }

  List<ChatPreviewEntity> chatInboxForUser(UserEntity user) {
    final previews = <ChatPreviewEntity>[];

    for (final booking in bookingsForUser(user)) {
      if (!_supportsChat(booking.status)) continue;
      final roomId = chatRoomIdForBooking(booking.id);
      if (roomId == null) continue;

      final messages = List<MessageEntity>.from(_messagesByChatRoom[roomId] ?? []);
      MessageEntity? last;
      if (messages.isNotEmpty) {
        messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        last = messages.first;
      }

      final unreadCount = messages
          .where((m) => m.senderId != user.id && !m.isRead)
          .length;

      previews.add(ChatPreviewEntity(
        bookingId: booking.id,
        chatRoomId: roomId,
        serviceName: booking.serviceName,
        lastMessage: last?.content,
        lastMessageAt: last?.createdAt,
        unreadCount: unreadCount,
      ));
    }

    previews.sort((a, b) {
      final aTime = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    return previews;
  }

  bool _supportsChat(BookingStatus status) {
    return status == BookingStatus.accepted ||
        status == BookingStatus.inProgress ||
        status == BookingStatus.completed;
  }

  String? providerIdForUser(String userId) {
    if (userId == mockProviderUserId || userId.startsWith('mock-provider')) {
      return mockProviderId;
    }
    return 'mock-provider-${userId.hashCode.abs()}';
  }

  void updateUserProfile(String userId, {String? fullName, String? phone}) {
    for (final entry in _usersByEmail.entries) {
      if (entry.value.id == userId) {
        _usersByEmail[entry.key] = entry.value.copyWith(
          name: fullName ?? entry.value.name,
          phone: phone ?? entry.value.phone,
        );
        return;
      }
    }
  }

  _MockBooking? _findBooking(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  void _ensureChatRoom(String bookingId) {
    _messagesByChatRoom.putIfAbsent('chat-$bookingId', () => []);
  }
}

class _MockBooking {
  _MockBooking({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.customerId,
    required this.customerName,
    required this.address,
    required this.scheduledAt,
    required this.status,
    this.providerId,
    this.providerName,
    this.notes,
  });

  final String id;
  final String serviceId;
  final String serviceName;
  final double servicePrice;
  final String customerId;
  final String customerName;
  String? providerId;
  String? providerName;
  final String address;
  String? notes;
  final DateTime scheduledAt;
  BookingStatus status;

  BookingEntity toEntity() => BookingEntity(
        id: id,
        serviceName: serviceName,
        servicePrice: servicePrice,
        address: address,
        notes: notes,
        scheduledAt: scheduledAt,
        status: status,
        providerName: providerName,
        customerName: customerName,
        chatRoomId: status == BookingStatus.pending ? null : 'chat-$id',
      );
}
