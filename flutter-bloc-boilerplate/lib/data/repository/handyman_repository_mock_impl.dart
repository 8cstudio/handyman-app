import 'package:my_bloc_app/data/data_sources/local/auth_local_data_source.dart';
import 'package:my_bloc_app/data/mock/mock_data_store.dart';
import 'package:my_bloc_app/domain/entities/booking/booking_entity.dart';
import 'package:my_bloc_app/domain/entities/booking/bookings_page_result.dart';
import 'package:my_bloc_app/domain/entities/chat/cached_messages_snapshot.dart';
import 'package:my_bloc_app/domain/entities/chat/chat_preview_entity.dart';
import 'package:my_bloc_app/domain/entities/chat/messages_page_result.dart';
import 'package:my_bloc_app/domain/entities/catalog/catalog_entity.dart';
import 'package:my_bloc_app/domain/entities/catalog/services_page_result.dart';
import 'package:my_bloc_app/domain/entities/chat/message_entity.dart';
import 'package:my_bloc_app/domain/entities/user/user_entity.dart';
import 'package:my_bloc_app/domain/repository_interfaces/handyman_repository.dart';

class HandymanRepositoryMockImpl implements HandymanRepository {
  final AuthLocalDataSource _authLocal;
  final MockDataStore _store = MockDataStore.instance;

  HandymanRepositoryMockImpl(this._authLocal) {
    _store.seed();
  }

  Future<UserEntity?> _currentUser() => _authLocal.getUser();

  @override
  Future<List<CategoryEntity>> getCategories() async {
    await _simulateDelay();
    return _store.categories;
  }

  @override
  Future<ServicesPageResult> getServices({
    String? categoryId,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) async {
    await _simulateDelay();
    return _store.filterServices(
      categoryId: categoryId,
      search: search,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<List<CategoryEntity>> getCachedCategories() async {
    await _simulateDelay();
    return _store.categories;
  }

  @override
  Future<ServicesPageResult?> getCachedServices({
    String? categoryId,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) async {
    await _simulateDelay();
    return _store.filterServices(
      categoryId: categoryId,
      search: search,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<BookingsPageResult?> getCachedBookings({
    int page = 0,
    int pageSize = 20,
  }) async {
    await _simulateDelay();
    final user = await _currentUser();
    if (user == null) return null;
    return _store.paginatedBookingsForUser(user, page: page, pageSize: pageSize);
  }

  @override
  Future<ServiceEntity?> getService(String id) async {
    await _simulateDelay();
    return _store.serviceById(id);
  }

  @override
  Future<BookingEntity> createBooking({
    required String serviceId,
    required DateTime scheduledAt,
    required String address,
    String? notes,
  }) async {
    await _simulateDelay();
    final user = await _currentUser();
    return _store.createBooking(
      customerId: user?.id ?? MockDataStore.mockCustomerUserId,
      customerName: user?.name ?? 'Customer',
      serviceId: serviceId,
      scheduledAt: scheduledAt,
      address: address,
      notes: notes,
    );
  }

  @override
  Future<BookingsPageResult> getBookings({
    int page = 0,
    int pageSize = 20,
  }) async {
    await _simulateDelay();
    final user = await _currentUser();
    if (user == null) {
      return const BookingsPageResult(bookings: [], hasMore: false);
    }
    return _store.paginatedBookingsForUser(user, page: page, pageSize: pageSize);
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status, {String? note}) async {
    await _simulateDelay();
    _store.updateBookingStatus(bookingId, status);
  }

  @override
  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    await _simulateDelay();
    _store.cancelBooking(bookingId);
  }

  @override
  Future<String?> getChatRoomId(String bookingId) async {
    await _simulateDelay();
    return _store.chatRoomIdForBooking(bookingId);
  }

  @override
  Future<List<ChatPreviewEntity>?> getCachedChatInbox() async {
    final user = await _currentUser();
    if (user == null) return null;
    return _store.chatInboxForUser(user);
  }

  @override
  Future<List<ChatPreviewEntity>> getChatInbox() async {
    await _simulateDelay();
    final user = await _currentUser();
    if (user == null) return const [];
    return _store.chatInboxForUser(user);
  }

  @override
  Future<CachedMessagesSnapshot?> getCachedMessages(String chatRoomId) async {
    final result = _store.paginatedMessagesForChatRoom(chatRoomId, limit: 30);
    if (result.messages.isEmpty) return null;
    return CachedMessagesSnapshot(
      messages: result.messages,
      hasMoreOlder: result.hasMore,
    );
  }

  @override
  Future<MessagesPageResult> getMessages(
    String chatRoomId, {
    int limit = 30,
    DateTime? before,
    DateTime? after,
  }) async {
    await _simulateDelay();
    return _store.paginatedMessagesForChatRoom(
      chatRoomId,
      limit: limit,
      before: before,
      after: after,
    );
  }

  @override
  Future<MessageEntity> sendMessage({
    required String chatRoomId,
    required String content,
    String messageType = 'text',
  }) async {
    await _simulateDelay();
    final user = await _currentUser();
    return _store.sendMessage(
      chatRoomId: chatRoomId,
      senderId: user?.id ?? 'mock-user',
      senderName: user?.name ?? 'User',
      content: content,
      messageType: messageType,
    );
  }

  @override
  Future<void> markMessagesRead(String chatRoomId) async {
    final user = await _currentUser();
    if (user == null) return;
    _store.markMessagesRead(chatRoomId, user.id);
  }

  @override
  void subscribeToMessages(String chatRoomId, void Function() onNewMessage) {
    // Mock mode refreshes on send; no live subscription needed.
  }

  @override
  void unsubscribeFromMessages() {}

  @override
  void subscribeToChatInbox(void Function() onChange) {}

  @override
  void unsubscribeFromChatInbox() {}

  @override
  void subscribeToBookings(void Function() onChange) {}

  @override
  void unsubscribeFromBookings() {}

  @override
  void subscribeToCatalog(void Function() onChange) {}

  @override
  void unsubscribeFromCatalog() {}

  @override
  Future<void> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    await _simulateDelay();
    // Mock: review accepted silently.
  }

  @override
  Future<void> uploadProviderDocument({
    required String providerId,
    required String documentType,
    required String fileUrl,
  }) async {
    await _simulateDelay();
  }

  @override
  Future<String> uploadFile(String bucket, String path, List<int> bytes) async {
    await _simulateDelay();
    return 'https://mock.storage/$bucket/$path';
  }

  @override
  Future<void> updateProfile({String? fullName, String? phone, String? defaultAddress}) async {
    await _simulateDelay();
    final user = await _currentUser();
    if (user == null) return;
    _store.updateUserProfile(user.id, fullName: fullName, phone: phone);
  }

  @override
  Future<String?> getProviderId() async {
    final user = await _currentUser();
    if (user == null) return null;
    return _store.providerIdForUser(user.id);
  }

  Future<void> _simulateDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
