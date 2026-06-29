import 'package:my_bloc_app/domain/entities/booking/booking_entity.dart';
import 'package:my_bloc_app/domain/entities/booking/bookings_page_result.dart';
import 'package:my_bloc_app/domain/entities/catalog/catalog_entity.dart';
import 'package:my_bloc_app/domain/entities/catalog/services_page_result.dart';
import 'package:my_bloc_app/domain/entities/chat/chat_preview_entity.dart';
import 'package:my_bloc_app/domain/entities/chat/message_entity.dart';
import 'package:my_bloc_app/domain/entities/chat/messages_page_result.dart';

abstract class HandymanApi {
  Future<List<CategoryEntity>> getCategories();

  Future<ServicesPageResult> getServices({
    String? categoryId,
    String? search,
    int page = 0,
    int pageSize = 20,
  });

  Future<ServiceEntity?> getService(String id);

  Future<BookingEntity> createBooking({
    required String serviceId,
    required DateTime scheduledAt,
    required String address,
    String? notes,
  });

  Future<BookingsPageResult> getBookings({
    int page = 0,
    int pageSize = 20,
  });

  Future<void> updateBookingStatus(
    String bookingId,
    String status, {
    String? note,
  });

  Future<void> cancelBooking(String bookingId, {String? reason});

  Future<String?> getChatRoomId(String bookingId);

  Future<List<ChatPreviewEntity>> getChatInbox();

  Future<MessagesPageResult> getMessages(
    String chatRoomId, {
    int limit = 30,
    DateTime? before,
    DateTime? after,
  });

  Future<MessageEntity> sendMessage({
    required String chatRoomId,
    required String content,
    String messageType = 'text',
  });

  Future<void> markMessagesRead(String chatRoomId);

  Future<void> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  });

  Future<void> uploadProviderDocument({
    required String providerId,
    required String documentType,
    required String fileUrl,
  });

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? defaultAddress,
  });

  Future<String?> getProviderId();

  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  });

  Future<void> unregisterDeviceToken(String token);
}
