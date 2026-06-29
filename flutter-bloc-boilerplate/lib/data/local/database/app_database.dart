import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:my_bloc_app/data/local/database/tables.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  CachedCategories,
  CachedServices,
  CachedBookings,
  CachedMessages,
  MessageRoomMeta,
  ChatRoomMappings,
  ChatInboxRows,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'handyman_cache.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  Future<void> clearAll() async {
    await transaction(() async {
      await delete(cachedCategories).go();
      await delete(cachedServices).go();
      await delete(cachedBookings).go();
      await delete(cachedMessages).go();
      await delete(messageRoomMeta).go();
      await delete(chatRoomMappings).go();
      await delete(chatInboxRows).go();
    });
  }
}
