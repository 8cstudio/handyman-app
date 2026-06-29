import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_bloc_app/domain/entities/catalog/catalog_entity.dart';
import 'package:my_bloc_app/domain/entities/catalog/services_page_result.dart';
import 'package:my_bloc_app/domain/repository_interfaces/handyman_repository.dart';
import 'package:my_bloc_app/presentation/blocs/handyman/handyman_state.dart';

export 'handyman_state.dart';

class HandymanCubit extends Cubit<HandymanState> {
  static const _servicePageSize = 20;
  static const _bookingPageSize = 20;

  final HandymanRepository _repository;
  int _servicesRequestId = 0;
  int _bookingsRequestId = 0;
  String? _currentCategoryFilter;
  String? _currentSearchFilter;
  Timer? _bookingsSyncDebounce;
  Timer? _catalogSyncDebounce;
  Timer? _chatInboxSyncDebounce;

  HandymanCubit({required HandymanRepository repository})
      : _repository = repository,
        super(const HandymanState());

  Future<void> loadCategories() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final categories = await _repository.getCategories();
      emit(state.copyWith(isLoading: false, categories: categories));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadHomeFeed() async {
    _currentCategoryFilter = null;
    _currentSearchFilter = null;
    await _loadServicesPage(
      reset: true,
      categoryId: null,
      search: null,
      loadCategories: true,
    );
  }

  Future<void> applyServiceFilters({
    String? categoryId,
    String? search,
  }) async {
    await _loadServicesPage(
      reset: true,
      categoryId: categoryId,
      search: search,
      loadCategories: false,
    );
  }

  Future<void> loadMoreServices() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMoreServices) return;
    await _loadServicesPage(reset: false);
  }

  Future<void> loadServices({String? categoryId, String? search}) async {
    await applyServiceFilters(categoryId: categoryId, search: search);
  }

  Future<void> _loadServicesPage({
    required bool reset,
    String? categoryId,
    String? search,
    bool loadCategories = false,
  }) async {
    final requestId = ++_servicesRequestId;

    if (reset) {
      _currentCategoryFilter = categoryId;
      _currentSearchFilter = search;

      List<CategoryEntity>? cachedCategories;
      ServicesPageResult? cachedServices;

      if (loadCategories) {
        cachedCategories = await _repository.getCachedCategories();
      }
      cachedServices = await _repository.getCachedServices(
        categoryId: categoryId,
        search: search,
        page: 0,
        pageSize: _servicePageSize,
      );

      final hasCachedServices =
          cachedServices != null && cachedServices.services.isNotEmpty;

      emit(state.copyWith(
        isLoading: !hasCachedServices,
        isLoadingMore: false,
        hasMoreServices: cachedServices?.hasMore ?? true,
        servicesPage: 0,
        services: cachedServices?.services ?? const [],
        categories: cachedCategories ?? state.categories,
        selectedCategoryId: categoryId,
        serviceSearchQuery: search,
        clearSelectedCategoryId: categoryId == null,
        clearServiceSearchQuery: search == null || search.isEmpty,
        clearError: true,
      ));
    } else {
      emit(state.copyWith(isLoadingMore: true, clearError: true));
    }

    try {
      final categories = loadCategories && reset
          ? await _repository.getCategories()
          : null;
      final page = reset ? 0 : state.servicesPage + 1;

      final result = await _repository.getServices(
        categoryId: _currentCategoryFilter,
        search: _currentSearchFilter,
        page: page,
        pageSize: _servicePageSize,
      );

      if (requestId != _servicesRequestId || isClosed) return;

      final mergedServices =
          reset ? result.services : [...state.services, ...result.services];

      emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        categories: categories ?? state.categories,
        services: mergedServices,
        servicesPage: page,
        hasMoreServices: result.hasMore,
      ));
    } catch (e) {
      if (requestId != _servicesRequestId || isClosed) return;
      emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: state.services.isEmpty ? e.toString() : null,
      ));
    }
  }

  Future<void> loadBookings({bool reset = true}) async {
    await _loadBookingsPage(reset: reset);
  }

  Future<void> loadMoreBookings() async {
    if (state.isLoading || state.isLoadingMoreBookings || !state.hasMoreBookings) {
      return;
    }
    await _loadBookingsPage(reset: false);
  }

  Future<void> _loadBookingsPage({required bool reset}) async {
    final requestId = ++_bookingsRequestId;

    if (reset) {
      final cached = await _repository.getCachedBookings(
        page: 0,
        pageSize: _bookingPageSize,
      );
      final hasCached =
          cached != null && cached.bookings.isNotEmpty;

      emit(state.copyWith(
        isLoading: !hasCached,
        isLoadingMoreBookings: false,
        hasMoreBookings: cached?.hasMore ?? true,
        bookingsPage: 0,
        bookings: cached?.bookings ?? const [],
        clearError: true,
      ));
    } else {
      emit(state.copyWith(isLoadingMoreBookings: true, clearError: true));
    }

    try {
      final page = reset ? 0 : state.bookingsPage + 1;
      final result = await _repository.getBookings(
        page: page,
        pageSize: _bookingPageSize,
      );

      if (requestId != _bookingsRequestId || isClosed) return;

      final mergedBookings =
          reset ? result.bookings : [...state.bookings, ...result.bookings];

      emit(state.copyWith(
        isLoading: false,
        isLoadingMoreBookings: false,
        bookings: mergedBookings,
        bookingsPage: page,
        hasMoreBookings: result.hasMore,
      ));
    } catch (e) {
      if (requestId != _bookingsRequestId || isClosed) return;
      emit(state.copyWith(
        isLoading: false,
        isLoadingMoreBookings: false,
        error: state.bookings.isEmpty ? e.toString() : null,
      ));
    }
  }

  Future<void> loadChatPreviews() async {
    final cached = await _repository.getCachedChatInbox();
    if (cached != null && cached.isNotEmpty && !isClosed) {
      emit(state.copyWith(
        chatPreviews: cached,
        isLoadingChatPreviews: true,
        clearError: true,
      ));
    } else {
      emit(state.copyWith(isLoadingChatPreviews: true, clearError: true));
    }

    try {
      final previews = await _repository.getChatInbox();
      if (isClosed) return;
      emit(state.copyWith(
        isLoadingChatPreviews: false,
        chatPreviews: previews,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        isLoadingChatPreviews: false,
        error: state.chatPreviews.isEmpty ? e.toString() : null,
      ));
    }
  }

  Future<void> refreshChatPreviewsFromCache() async {
    final cached = await _repository.getCachedChatInbox();
    if (cached == null || isClosed) return;
    emit(state.copyWith(
      chatPreviews: cached,
      isLoadingChatPreviews: false,
    ));
  }

  Future<void> createBooking({
    required String serviceId,
    required DateTime scheduledAt,
    required String address,
    String? notes,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      await _repository.createBooking(
        serviceId: serviceId,
        scheduledAt: scheduledAt,
        address: address,
        notes: notes,
      );
      await loadBookings();
      emit(state.copyWith(successMessage: 'Booking created'));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));
    try {
      await _repository.updateBookingStatus(bookingId, status);
      await loadBookings();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));
    try {
      await _repository.cancelBooking(bookingId);
      await loadBookings();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));
    try {
      await _repository.submitReview(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );
      emit(state.copyWith(successMessage: 'Review submitted'));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void clearSuccessMessage() {
    emit(state.copyWith(clearSuccess: true));
  }

  void startRealtimeSync() {
    if (!isClosed) loadChatPreviews();

    _repository.subscribeToBookings(() {
      if (isClosed) return;
      _bookingsSyncDebounce?.cancel();
      _bookingsSyncDebounce = Timer(const Duration(milliseconds: 500), () {
        if (!isClosed) {
          loadBookings();
          loadChatPreviews();
        }
      });
    });
    _repository.subscribeToChatInbox(() {
      if (isClosed) return;
      _chatInboxSyncDebounce?.cancel();
      _chatInboxSyncDebounce = Timer(const Duration(milliseconds: 150), () async {
        if (isClosed) return;
        await refreshChatPreviewsFromCache();
        if (!isClosed) await loadChatPreviews();
      });
    });
    _repository.subscribeToCatalog(() {
      if (isClosed) return;
      _catalogSyncDebounce?.cancel();
      _catalogSyncDebounce = Timer(const Duration(milliseconds: 500), () {
        if (!isClosed) {
          _loadServicesPage(
            reset: true,
            categoryId: _currentCategoryFilter,
            search: _currentSearchFilter,
            loadCategories: true,
          );
        }
      });
    });
  }

  @override
  Future<void> close() {
    _bookingsSyncDebounce?.cancel();
    _catalogSyncDebounce?.cancel();
    _chatInboxSyncDebounce?.cancel();
    _repository.unsubscribeFromBookings();
    _repository.unsubscribeFromChatInbox();
    _repository.unsubscribeFromCatalog();
    return super.close();
  }
}
