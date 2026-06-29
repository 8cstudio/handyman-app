import 'package:equatable/equatable.dart';
import 'package:my_bloc_app/domain/entities/booking/booking_entity.dart';

class AppNotification extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final String? bookingId;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.bookingId,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        message: message,
        createdAt: createdAt,
        bookingId: bookingId,
        isRead: isRead ?? this.isRead,
      );

  factory AppNotification.bookingStatusChanged({
    required BookingEntity booking,
    required BookingStatus previousStatus,
    required String statusLabel,
  }) {
    return AppNotification(
      id: '${booking.id}-${booking.status.name}-${DateTime.now().millisecondsSinceEpoch}',
      title: booking.serviceName,
      message: 'Status changed from $statusLabel to ${statusLabelFor(booking.status)}',
      createdAt: DateTime.now(),
      bookingId: booking.id,
    );
  }

  factory AppNotification.newBooking({required BookingEntity booking}) {
    return AppNotification(
      id: 'new-${booking.id}-${DateTime.now().millisecondsSinceEpoch}',
      title: booking.serviceName,
      message: 'New order: ${statusLabelFor(booking.status)}',
      createdAt: DateTime.now(),
      bookingId: booking.id,
    );
  }

  static String statusLabelFor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.assigned:
        return 'Assigned';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  List<Object?> get props => [id, title, message, createdAt, bookingId, isRead];
}
