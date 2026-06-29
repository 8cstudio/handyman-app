import 'package:drift/drift.dart';
import 'package:my_bloc_app/data/local/database/app_database.dart';
import 'package:my_bloc_app/domain/entities/booking/booking_entity.dart';
import 'package:my_bloc_app/domain/entities/booking/bookings_page_result.dart';
import 'package:my_bloc_app/domain/entities/catalog/catalog_entity.dart';
import 'package:my_bloc_app/domain/entities/catalog/services_page_result.dart';
import 'package:my_bloc_app/domain/entities/chat/cached_messages_snapshot.dart';
import 'package:my_bloc_app/domain/entities/chat/chat_preview_entity.dart';
import 'package:my_bloc_app/domain/entities/chat/message_entity.dart';

class LocalCacheStore {
  final AppDatabase _db;

  LocalCacheStore(this._db);

  Future<void> clearAll() => _db.clearAll();

  Future<List<CategoryEntity>> getCategories() async {
    final rows = await (_db.select(_db.cachedCategories)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return rows.map(_categoryFromRow).toList();
  }

  Future<void> saveCategories(List<CategoryEntity> categories) async {
    await _db.transaction(() async {
      await _db.delete(_db.cachedCategories).go();
      for (var i = 0; i < categories.length; i++) {
        final category = categories[i];
        await _db.into(_db.cachedCategories).insert(
              CachedCategoriesCompanion.insert(
                id: category.id,
                name: category.name,
                description: Value(category.description),
                imageUrl: Value(category.imageUrl),
                sortOrder: Value(i),
              ),
            );
      }
    });
  }

  Future<ServicesPageResult?> getServices({
    String? categoryId,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) async {
    final query = _db.select(_db.cachedServices);
    if (categoryId != null) {
      query.where((t) => t.categoryId.equals(categoryId));
    }
    if (search != null && search.isNotEmpty) {
      query.where((t) => t.name.like('%$search%'));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.name)]);

    final rows = await query.get();
    if (rows.isEmpty) return null;

    final start = page * pageSize;
    if (start >= rows.length) {
      return const ServicesPageResult(services: [], hasMore: false);
    }

    final end = (start + pageSize).clamp(0, rows.length);
    return ServicesPageResult(
      services: rows.sublist(start, end).map(_serviceFromRow).toList(),
      hasMore: end < rows.length,
    );
  }

  Future<void> saveServices(List<ServiceEntity> services) async {
    if (services.isEmpty) return;
    await _db.batch((batch) {
      for (final service in services) {
        batch.insert(
          _db.cachedServices,
          CachedServicesCompanion.insert(
            id: service.id,
            name: service.name,
            description: Value(service.description),
            price: service.price,
            durationMinutes: service.durationMinutes,
            imageUrl: Value(service.imageUrl),
            categoryId: service.categoryId,
            categoryName: Value(service.categoryName),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<BookingsPageResult?> getBookings({
    int page = 0,
    int pageSize = 20,
  }) async {
    final rows = await (_db.select(_db.cachedBookings)
          ..orderBy([(t) => OrderingTerm.desc(t.scheduledAt)]))
        .get();
    if (rows.isEmpty) return null;

    final start = page * pageSize;
    if (start >= rows.length) {
      return const BookingsPageResult(bookings: [], hasMore: false);
    }

    final end = (start + pageSize).clamp(0, rows.length);
    return BookingsPageResult(
      bookings: rows.sublist(start, end).map(_bookingFromRow).toList(),
      hasMore: end < rows.length,
    );
  }

  Future<void> saveBookings(List<BookingEntity> bookings) async {
    if (bookings.isEmpty) return;
    await _db.batch((batch) {
      for (final booking in bookings) {
        batch.insert(
          _db.cachedBookings,
          CachedBookingsCompanion.insert(
            id: booking.id,
            serviceName: booking.serviceName,
            servicePrice: booking.servicePrice,
            address: booking.address,
            notes: Value(booking.notes),
            scheduledAt: booking.scheduledAt,
            status: booking.status.apiValue,
            providerName: Value(booking.providerName),
            customerName: Value(booking.customerName),
            chatRoomId: Value(booking.chatRoomId),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<String?> getChatRoomId(String bookingId) async {
    final row = await (_db.select(_db.chatRoomMappings)
          ..where((t) => t.bookingId.equals(bookingId)))
        .getSingleOrNull();
    return row?.chatRoomId;
  }

  Future<void> saveChatRoomId(String bookingId, String chatRoomId) async {
    await _db.into(_db.chatRoomMappings).insertOnConflictUpdate(
          ChatRoomMappingsCompanion.insert(
            bookingId: bookingId,
            chatRoomId: chatRoomId,
          ),
        );
  }

  Future<CachedMessagesSnapshot?> getMessages(String chatRoomId) async {
    final rows = await (_db.select(_db.cachedMessages)
          ..where((t) => t.chatRoomId.equals(chatRoomId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    if (rows.isEmpty) return null;

    final meta = await (_db.select(_db.messageRoomMeta)
          ..where((t) => t.chatRoomId.equals(chatRoomId)))
        .getSingleOrNull();

    return CachedMessagesSnapshot(
      messages: rows.map(_messageFromRow).toList(),
      hasMoreOlder: meta?.hasMoreOlder ?? false,
    );
  }

  Future<void> saveMessages(
    String chatRoomId,
    List<MessageEntity> messages, {
    required bool hasMoreOlder,
  }) async {
    if (messages.isEmpty) return;

    await _db.transaction(() async {
      await (_db.delete(_db.cachedMessages)
            ..where((t) => t.chatRoomId.equals(chatRoomId)))
          .go();

      await _db.batch((batch) {
        for (final message in messages) {
          batch.insert(
            _db.cachedMessages,
            _messageCompanion(chatRoomId, message),
            mode: InsertMode.insertOrReplace,
          );
        }
      });

      await _db.into(_db.messageRoomMeta).insertOnConflictUpdate(
            MessageRoomMetaCompanion(
              chatRoomId: Value(chatRoomId),
              hasMoreOlder: Value(hasMoreOlder),
            ),
          );
    });
  }

  Future<void> appendMessage(String chatRoomId, MessageEntity message) async {
    await _db.into(_db.cachedMessages).insertOnConflictUpdate(
          _messageCompanion(chatRoomId, message),
        );
  }

  Future<List<ChatPreviewEntity>?> getInbox() async {
    final rows = await (_db.select(_db.chatInboxRows)
          ..orderBy([
            (t) => OrderingTerm.desc(t.lastMessageAt),
          ]))
        .get();
    if (rows.isEmpty) return null;
    return rows.map(_inboxFromRow).toList();
  }

  Future<void> saveInbox(List<ChatPreviewEntity> previews) async {
    await _db.transaction(() async {
      await _db.delete(_db.chatInboxRows).go();
      for (final preview in previews) {
        await _db.into(_db.chatInboxRows).insert(
              ChatInboxRowsCompanion.insert(
                bookingId: preview.bookingId,
                chatRoomId: preview.chatRoomId,
                serviceName: preview.serviceName,
                lastMessage: Value(preview.lastMessage),
                lastMessageAt: Value(preview.lastMessageAt),
                unreadCount: Value(preview.unreadCount),
              ),
            );
      }
    });
  }

  Future<void> updateInboxAfterSend({
    required String chatRoomId,
    required MessageEntity message,
  }) async {
    await (_db.update(_db.chatInboxRows)
          ..where((t) => t.chatRoomId.equals(chatRoomId)))
        .write(
      ChatInboxRowsCompanion(
        lastMessage: Value(message.content),
        lastMessageAt: Value(message.createdAt),
        unreadCount: const Value(0),
      ),
    );
  }

  Future<void> clearInboxUnread(String chatRoomId) async {
    await (_db.update(_db.chatInboxRows)
          ..where((t) => t.chatRoomId.equals(chatRoomId)))
        .write(
      const ChatInboxRowsCompanion(unreadCount: Value(0)),
    );
  }

  CategoryEntity _categoryFromRow(CachedCategory row) => CategoryEntity(
        id: row.id,
        name: row.name,
        description: row.description,
        imageUrl: row.imageUrl,
      );

  ServiceEntity _serviceFromRow(CachedService row) => ServiceEntity(
        id: row.id,
        name: row.name,
        description: row.description,
        price: row.price,
        durationMinutes: row.durationMinutes,
        imageUrl: row.imageUrl,
        categoryId: row.categoryId,
        categoryName: row.categoryName,
      );

  BookingEntity _bookingFromRow(CachedBooking row) => BookingEntity(
        id: row.id,
        serviceName: row.serviceName,
        servicePrice: row.servicePrice,
        address: row.address,
        notes: row.notes,
        scheduledAt: row.scheduledAt,
        status: BookingStatus.fromString(row.status),
        providerName: row.providerName,
        customerName: row.customerName,
        chatRoomId: row.chatRoomId,
      );

  MessageEntity _messageFromRow(CachedMessage row) => MessageEntity(
        id: row.id,
        content: row.content,
        senderId: row.senderId,
        senderName: row.senderName,
        messageType: row.messageType,
        createdAt: row.createdAt,
        readAt: row.readAt,
      );

  ChatPreviewEntity _inboxFromRow(ChatInboxRow row) => ChatPreviewEntity(
        bookingId: row.bookingId,
        chatRoomId: row.chatRoomId,
        serviceName: row.serviceName,
        lastMessage: row.lastMessage,
        lastMessageAt: row.lastMessageAt,
        unreadCount: row.unreadCount,
      );

  CachedMessagesCompanion _messageCompanion(
    String chatRoomId,
    MessageEntity message,
  ) =>
      CachedMessagesCompanion.insert(
        id: message.id,
        chatRoomId: chatRoomId,
        content: message.content,
        senderId: message.senderId,
        senderName: message.senderName,
        messageType: Value(message.messageType),
        createdAt: message.createdAt,
        readAt: Value(message.readAt),
      );
}
