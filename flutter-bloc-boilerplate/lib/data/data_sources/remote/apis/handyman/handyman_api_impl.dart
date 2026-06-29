import 'package:dio/dio.dart';
import 'package:my_bloc_app/core/dio/dio_client.dart';
import 'package:my_bloc_app/core/dio/exception/api_exception.dart';
import 'package:my_bloc_app/data/data_sources/remote/apis/handyman/handyman_api.dart';
import 'package:my_bloc_app/data/data_sources/remote/constants/network_constants.dart';
import 'package:my_bloc_app/domain/entities/booking/booking_entity.dart';
import 'package:my_bloc_app/domain/entities/booking/bookings_page_result.dart';
import 'package:my_bloc_app/domain/entities/catalog/catalog_entity.dart';
import 'package:my_bloc_app/domain/entities/catalog/services_page_result.dart';
import 'package:my_bloc_app/domain/entities/chat/chat_preview_entity.dart';
import 'package:my_bloc_app/domain/entities/chat/message_entity.dart';
import 'package:my_bloc_app/domain/entities/chat/messages_page_result.dart';

class HandymanApiImpl implements HandymanApi {
  final DioClient _dioClient;

  HandymanApiImpl(this._dioClient);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
      final response = await _dioClient.get(
        NetworkConstants.catalogCategories,
        options: Options(headers: _headers),
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['categories'] as List? ?? [];
      return list
          .map((e) => CategoryEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<ServicesPageResult> getServices({
    String? categoryId,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dioClient.get(
        NetworkConstants.companyServices,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (categoryId != null) 'category_id': categoryId,
          if (search != null && search.isNotEmpty) 'search': search,
        },
        options: Options(headers: _headers),
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['services'] as List? ?? [];
      return ServicesPageResult(
        services: list
            .map((e) => ServiceEntity.fromJson(e as Map<String, dynamic>))
            .toList(),
        hasMore: data['has_more'] as bool? ?? false,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<ServiceEntity?> getService(String id) async {
    try {
      final response = await _dioClient.get(
        NetworkConstants.companyServices,
        queryParameters: {'id': id},
        options: Options(headers: _headers),
      );
      final data = response.data as Map<String, dynamic>;
      final service = data['service'];
      if (service == null) return null;
      return ServiceEntity.fromJson(service as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<BookingEntity> createBooking({
    required String serviceId,
    required DateTime scheduledAt,
    required String address,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.post(
        NetworkConstants.bookingsCreate,
        data: {
          'service_id': serviceId,
          'scheduled_at': scheduledAt.toUtc().toIso8601String(),
          'address': address,
          if (notes != null) 'notes': notes,
        },
        options: Options(headers: _headers),
      );
      final data = response.data as Map<String, dynamic>;
      return BookingEntity.fromJson(data['booking'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<BookingsPageResult> getBookings({
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dioClient.get(
        NetworkConstants.bookingsList,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
        options: Options(headers: _headers),
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['bookings'] as List? ?? [];
      return BookingsPageResult(
        bookings: list
            .map((e) => BookingEntity.fromJson(e as Map<String, dynamic>))
            .toList(),
        hasMore: data['has_more'] as bool? ?? false,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> updateBookingStatus(
    String bookingId,
    String status, {
    String? note,
  }) async {
    try {
      await _dioClient.post(
        NetworkConstants.bookingsUpdateStatus,
        data: {
          'booking_id': bookingId,
          'status': status,
          if (note != null) 'note': note,
        },
        options: Options(headers: _headers),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    try {
      await _dioClient.post(
        NetworkConstants.bookingsCancel,
        data: {
          'booking_id': bookingId,
          if (reason != null) 'reason': reason,
        },
        options: Options(headers: _headers),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<String?> getChatRoomId(String bookingId) async {
    try {
      final response = await _dioClient.get(
        NetworkConstants.chatRoomByBooking,
        queryParameters: {'booking_id': bookingId},
        options: Options(headers: _headers),
      );
      final data = response.data as Map<String, dynamic>;
      return data['chat_room_id'] as String?;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<ChatPreviewEntity>> getChatInbox() async {
    try {
      final response = await _dioClient.get(
        NetworkConstants.chatInbox,
        options: Options(headers: _headers),
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['chats'] as List? ?? [];
      return list
          .map((e) => ChatPreviewEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<MessagesPageResult> getMessages(
    String chatRoomId, {
    int limit = 30,
    DateTime? before,
    DateTime? after,
  }) async {
    try {
      final response = await _dioClient.get(
        NetworkConstants.chatMessagesList,
        queryParameters: {
          'chat_room_id': chatRoomId,
          'limit': limit,
          if (before != null) 'before': before.toUtc().toIso8601String(),
          if (after != null) 'after': after.toUtc().toIso8601String(),
        },
        options: Options(headers: _headers),
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['messages'] as List? ?? [];
      return MessagesPageResult(
        messages: list
            .map((e) => MessageEntity.fromJson(e as Map<String, dynamic>))
            .toList(),
        hasMore: data['has_more'] as bool? ?? false,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<MessageEntity> sendMessage({
    required String chatRoomId,
    required String content,
    String messageType = 'text',
  }) async {
    try {
      final response = await _dioClient.post(
        NetworkConstants.chatSendMessage,
        data: {
          'chat_room_id': chatRoomId,
          'content': content,
          'message_type': messageType,
        },
        options: Options(headers: _headers),
      );
      final data = response.data as Map<String, dynamic>;
      return MessageEntity.fromJson(data['message'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> markMessagesRead(String chatRoomId) async {
    try {
      await _dioClient.post(
        NetworkConstants.chatMarkRead,
        data: {'chat_room_id': chatRoomId},
        options: Options(headers: _headers),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _dioClient.post(
        NetworkConstants.reviewsSubmit,
        data: {
          'booking_id': bookingId,
          'rating': rating,
          if (comment != null) 'comment': comment,
        },
        options: Options(headers: _headers),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> uploadProviderDocument({
    required String providerId,
    required String documentType,
    required String fileUrl,
  }) async {
    try {
      await _dioClient.post(
        NetworkConstants.companyProvidersManage,
        data: {
          'provider_id': providerId,
          'document_type': documentType,
          'file_url': fileUrl,
        },
        options: Options(headers: _headers),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? defaultAddress,
  }) async {
    try {
      await _dioClient.put(
        NetworkConstants.profileUpdate,
        data: {
          if (fullName != null) 'full_name': fullName,
          if (phone != null) 'phone': phone,
          if (defaultAddress != null) 'default_address': defaultAddress,
        },
        options: Options(headers: _headers),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<String?> getProviderId() async {
    try {
      final response = await _dioClient.get(
        NetworkConstants.profileProvider,
        options: Options(headers: _headers),
      );
      final data = response.data as Map<String, dynamic>;
      return data['provider_id'] as String?;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    try {
      await _dioClient.post(
        NetworkConstants.pushRegisterToken,
        data: {
          'token': token,
          'platform': platform,
        },
        options: Options(headers: _headers),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> unregisterDeviceToken(String token) async {
    try {
      await _dioClient.delete(
        NetworkConstants.pushUnregisterToken,
        data: {'token': token},
        options: Options(headers: _headers),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
