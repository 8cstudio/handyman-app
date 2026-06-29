import 'package:my_bloc_app/domain/entities/booking/booking_entity.dart';

class BookingsPageResult {
  final List<BookingEntity> bookings;
  final bool hasMore;

  const BookingsPageResult({
    required this.bookings,
    required this.hasMore,
  });
}
