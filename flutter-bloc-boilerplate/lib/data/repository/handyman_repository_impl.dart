import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_bloc_app/core/supabase/supabase_service.dart';
import 'package:my_bloc_app/data/data_sources/remote/apis/handyman/handyman_api.dart';
import 'package:my_bloc_app/data/local/local_cache_store.dart';
import 'package:my_bloc_app/domain/entities/booking/booking_entity.dart';
import 'package:my_bloc_app/domain/entities/catalog/catalog_entity.dart';
import 'package:my_bloc_app/domain/entities/catalog/services_page_result.dart';
import 'package:my_bloc_app/domain/entities/booking/bookings_page_result.dart';
import 'package:my_bloc_app/domain/entities/chat/cached_messages_snapshot.dart';
import 'package:my_bloc_app/domain/entities/chat/messages_page_result.dart';
import 'package:my_bloc_app/domain/entities/chat/message_entity.dart';
import 'package:my_bloc_app/domain/entities/chat/chat_preview_entity.dart';
import 'package:my_bloc_app/domain/repository_interfaces/handyman_repository.dart';

class HandymanRepositoryImpl implements HandymanRepository {
  final HandymanApi _api;
  final LocalCacheStore _cache;
  RealtimeChannel? _messagesChannel;
  RealtimeChannel? _chatInboxChannel;
  RealtimeChannel? _bookingsChannel;
  RealtimeChannel? _catalogChannel;

  HandymanRepositoryImpl({
    required HandymanApi api,
    required LocalCacheStore cache,
  })  : _api = api,
        _cache = cache;

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
      final remote = await _api.getCategories();
      await _cache.saveCategories(remote);
      return remote;
    } catch (e) {
      final cached = await _cache.getCategories();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  @override
  Future<List<CategoryEntity>> getCachedCategories() => _cache.getCategories();

  @override
  Future<ServicesPageResult> getServices({
    String? categoryId,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final remote = await _api.getServices(
        categoryId: categoryId,
        search: search,
        page: page,
        pageSize: pageSize,
      );
      await _cache.saveServices(remote.services);
      return remote;
    } catch (e) {
      final cached = await _cache.getServices(
        categoryId: categoryId,
        search: search,
        page: page,
        pageSize: pageSize,
      );
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<ServicesPageResult?> getCachedServices({
    String? categoryId,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) =>
      _cache.getServices(
        categoryId: categoryId,
        search: search,
        page: page,
        pageSize: pageSize,
      );

  @override
  Future<ServiceEntity?> getService(String id) => _api.getService(id);

  @override
  Future<BookingEntity> createBooking({
    required String serviceId,
    required DateTime scheduledAt,
    required String address,
    String? notes,
  }) =>
      _api.createBooking(
        serviceId: serviceId,
        scheduledAt: scheduledAt,
        address: address,
        notes: notes,
      );

  @override
  Future<BookingsPageResult> getBookings({
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final remote = await _api.getBookings(page: page, pageSize: pageSize);
      await _cache.saveBookings(remote.bookings);
      return remote;
    } catch (e) {
      final cached = await _cache.getBookings(page: page, pageSize: pageSize);
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<BookingsPageResult?> getCachedBookings({
    int page = 0,
    int pageSize = 20,
  }) =>
      _cache.getBookings(page: page, pageSize: pageSize);

  @override
  Future<void> updateBookingStatus(String bookingId, String status, {String? note}) =>
      _api.updateBookingStatus(bookingId, status, note: note);

  @override
  Future<void> cancelBooking(String bookingId, {String? reason}) =>
      _api.cancelBooking(bookingId, reason: reason);

  @override
  Future<String?> getChatRoomId(String bookingId) async {
    final cached = await _cache.getChatRoomId(bookingId);
    if (cached != null) return cached;

    final roomId = await _api.getChatRoomId(bookingId);
    if (roomId != null) {
      await _cache.saveChatRoomId(bookingId, roomId);
    }
    return roomId;
  }

  @override
  Future<List<ChatPreviewEntity>?> getCachedChatInbox() => _cache.getInbox();

  @override
  Future<List<ChatPreviewEntity>> getChatInbox() async {
    final previews = await _api.getChatInbox();
    await _cache.saveInbox(previews);
    return previews;
  }

  @override
  Future<CachedMessagesSnapshot?> getCachedMessages(String chatRoomId) =>
      _cache.getMessages(chatRoomId);

  @override
  Future<MessagesPageResult> getMessages(
    String chatRoomId, {
    int limit = 30,
    DateTime? before,
    DateTime? after,
  }) async {
    final result = await _api.getMessages(
      chatRoomId,
      limit: limit,
      before: before,
      after: after,
    );

    if (before == null && after == null) {
      await _cache.saveMessages(
        chatRoomId,
        result.messages,
        hasMoreOlder: result.hasMore,
      );
    } else if (after != null && result.messages.isNotEmpty) {
      final cached = await _cache.getMessages(chatRoomId);
      final merged = _mergeMessagesById(
        cached?.messages ?? [],
        result.messages,
      );
      await _cache.saveMessages(
        chatRoomId,
        merged,
        hasMoreOlder: cached?.hasMoreOlder ?? false,
      );
    } else if (before != null && result.messages.isNotEmpty) {
      final cached = await _cache.getMessages(chatRoomId);
      final merged = _mergeMessagesById(
        result.messages,
        cached?.messages ?? [],
      );
      await _cache.saveMessages(
        chatRoomId,
        merged,
        hasMoreOlder: result.hasMore,
      );
    }

    return result;
  }

  @override
  Future<MessageEntity> sendMessage({
    required String chatRoomId,
    required String content,
    String messageType = 'text',
  }) async {
    final message = await _api.sendMessage(
      chatRoomId: chatRoomId,
      content: content,
      messageType: messageType,
    );
    await _cache.appendMessage(chatRoomId, message);
    await _cache.updateInboxAfterSend(
      chatRoomId: chatRoomId,
      message: message,
    );
    return message;
  }

  @override
  Future<void> markMessagesRead(String chatRoomId) async {
    await _api.markMessagesRead(chatRoomId);
    await _cache.clearInboxUnread(chatRoomId);
  }

  List<MessageEntity> _mergeMessagesById(
    List<MessageEntity> first,
    List<MessageEntity> second,
  ) {
    final byId = {for (final msg in first) msg.id: msg};
    for (final msg in second) {
      byId[msg.id] = msg;
    }
    final merged = byId.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return merged;
  }

  @override
  void subscribeToMessages(String chatRoomId, void Function() onNewMessage) {
    unsubscribeFromMessages();
    _messagesChannel = SupabaseService.client
        .channel('messages_$chatRoomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_room_id',
            value: chatRoomId,
          ),
          callback: (_) => onNewMessage(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_room_id',
            value: chatRoomId,
          ),
          callback: (_) => onNewMessage(),
        )
        .subscribe();
  }

  @override
  void unsubscribeFromMessages() {
    if (_messagesChannel != null) {
      SupabaseService.client.removeChannel(_messagesChannel!);
      _messagesChannel = null;
    }
  }

  @override
  void subscribeToChatInbox(void Function() onChange) {
    unsubscribeFromChatInbox();
    _chatInboxChannel = SupabaseService.client
        .channel('chat_inbox')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (_) => onChange(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          callback: (_) => onChange(),
        )
        .subscribe();
  }

  @override
  void unsubscribeFromChatInbox() {
    if (_chatInboxChannel != null) {
      SupabaseService.client.removeChannel(_chatInboxChannel!);
      _chatInboxChannel = null;
    }
  }

  @override
  void subscribeToBookings(void Function() onChange) {
    unsubscribeFromBookings();
    _bookingsChannel = SupabaseService.client
        .channel('bookings_sync')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          callback: (_) => onChange(),
        )
        .subscribe();
  }

  @override
  void unsubscribeFromBookings() {
    if (_bookingsChannel != null) {
      SupabaseService.client.removeChannel(_bookingsChannel!);
      _bookingsChannel = null;
    }
  }

  @override
  void subscribeToCatalog(void Function() onChange) {
    unsubscribeFromCatalog();
    _catalogChannel = SupabaseService.client
        .channel('catalog_sync')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'categories',
          callback: (_) => onChange(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'services',
          callback: (_) => onChange(),
        )
        .subscribe();
  }

  @override
  void unsubscribeFromCatalog() {
    if (_catalogChannel != null) {
      SupabaseService.client.removeChannel(_catalogChannel!);
      _catalogChannel = null;
    }
  }

  @override
  Future<void> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) =>
      _api.submitReview(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );

  @override
  Future<void> uploadProviderDocument({
    required String providerId,
    required String documentType,
    required String fileUrl,
  }) =>
      _api.uploadProviderDocument(
        providerId: providerId,
        documentType: documentType,
        fileUrl: fileUrl,
      );

  @override
  Future<String> uploadFile(String bucket, String path, List<int> bytes) async {
    await SupabaseService.client.storage.from(bucket).uploadBinary(
          path,
          Uint8List.fromList(bytes),
        );
    return SupabaseService.client.storage.from(bucket).getPublicUrl(path);
  }

  @override
  Future<void> updateProfile({String? fullName, String? phone, String? defaultAddress}) =>
      _api.updateProfile(
        fullName: fullName,
        phone: phone,
        defaultAddress: defaultAddress,
      );

  @override
  Future<String?> getProviderId() => _api.getProviderId();
}
