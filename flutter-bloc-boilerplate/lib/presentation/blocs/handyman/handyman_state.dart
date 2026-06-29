import 'package:equatable/equatable.dart';
import 'package:my_bloc_app/domain/entities/booking/booking_entity.dart';
import 'package:my_bloc_app/domain/entities/catalog/catalog_entity.dart';
import 'package:my_bloc_app/domain/entities/chat/chat_preview_entity.dart';

class HandymanState extends Equatable {
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreServices;
  final int servicesPage;
  final String? selectedCategoryId;
  final String? serviceSearchQuery;
  final bool isLoadingMoreBookings;
  final bool hasMoreBookings;
  final int bookingsPage;
  final List<CategoryEntity> categories;
  final List<ServiceEntity> services;
  final List<BookingEntity> bookings;
  final List<ChatPreviewEntity> chatPreviews;
  final bool isLoadingChatPreviews;
  final String? error;
  final String? successMessage;

  const HandymanState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMoreServices = true,
    this.servicesPage = 0,
    this.selectedCategoryId,
    this.serviceSearchQuery,
    this.isLoadingMoreBookings = false,
    this.hasMoreBookings = true,
    this.bookingsPage = 0,
    this.categories = const [],
    this.services = const [],
    this.bookings = const [],
    this.chatPreviews = const [],
    this.isLoadingChatPreviews = false,
    this.error,
    this.successMessage,
  });

  HandymanState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMoreServices,
    int? servicesPage,
    String? selectedCategoryId,
    String? serviceSearchQuery,
    bool clearSelectedCategoryId = false,
    bool clearServiceSearchQuery = false,
    bool? isLoadingMoreBookings,
    bool? hasMoreBookings,
    int? bookingsPage,
    List<CategoryEntity>? categories,
    List<ServiceEntity>? services,
    List<BookingEntity>? bookings,
    List<ChatPreviewEntity>? chatPreviews,
    bool? isLoadingChatPreviews,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return HandymanState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreServices: hasMoreServices ?? this.hasMoreServices,
      servicesPage: servicesPage ?? this.servicesPage,
      selectedCategoryId: clearSelectedCategoryId
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      serviceSearchQuery: clearServiceSearchQuery
          ? null
          : (serviceSearchQuery ?? this.serviceSearchQuery),
      isLoadingMoreBookings: isLoadingMoreBookings ?? this.isLoadingMoreBookings,
      hasMoreBookings: hasMoreBookings ?? this.hasMoreBookings,
      bookingsPage: bookingsPage ?? this.bookingsPage,
      categories: categories ?? this.categories,
      services: services ?? this.services,
      bookings: bookings ?? this.bookings,
      chatPreviews: chatPreviews ?? this.chatPreviews,
      isLoadingChatPreviews:
          isLoadingChatPreviews ?? this.isLoadingChatPreviews,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isLoadingMore,
        hasMoreServices,
        servicesPage,
        selectedCategoryId,
        serviceSearchQuery,
        isLoadingMoreBookings,
        hasMoreBookings,
        bookingsPage,
        categories,
        services,
        bookings,
        chatPreviews,
        isLoadingChatPreviews,
        error,
        successMessage,
      ];

  int get totalUnreadChatCount =>
      chatPreviews.fold(0, (sum, chat) => sum + chat.unreadCount);

  bool get hasUnreadChats => totalUnreadChatCount > 0;
}
