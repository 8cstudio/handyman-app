import 'package:drift/drift.dart';

class CachedCategories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedServices extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get price => real()();
  IntColumn get durationMinutes => integer()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get categoryId => text()();
  TextColumn get categoryName => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedBookings extends Table {
  TextColumn get id => text()();
  TextColumn get serviceName => text()();
  RealColumn get servicePrice => real()();
  TextColumn get address => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get status => text()();
  TextColumn get providerName => text().nullable()();
  TextColumn get customerName => text().nullable()();
  TextColumn get chatRoomId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CachedMessages extends Table {
  TextColumn get id => text()();
  TextColumn get chatRoomId => text()();
  TextColumn get content => text()();
  TextColumn get senderId => text()();
  TextColumn get senderName => text()();
  TextColumn get messageType => text().withDefault(const Constant('text'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get readAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MessageRoomMeta extends Table {
  TextColumn get chatRoomId => text()();
  BoolColumn get hasMoreOlder => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {chatRoomId};
}

class ChatRoomMappings extends Table {
  TextColumn get bookingId => text()();
  TextColumn get chatRoomId => text()();

  @override
  Set<Column<Object>> get primaryKey => {bookingId};
}

class ChatInboxRows extends Table {
  TextColumn get bookingId => text()();
  TextColumn get chatRoomId => text()();
  TextColumn get serviceName => text()();
  TextColumn get lastMessage => text().nullable()();
  DateTimeColumn get lastMessageAt => dateTime().nullable()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {bookingId};
}
