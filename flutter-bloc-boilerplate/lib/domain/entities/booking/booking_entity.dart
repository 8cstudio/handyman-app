import 'package:equatable/equatable.dart';

enum BookingStatus {
  pending,
  assigned,
  accepted,
  rejected,
  inProgress,
  completed,
  cancelled;

  static BookingStatus fromString(String value) {
    switch (value) {
      case 'assigned':
        return assigned;
      case 'accepted':
        return accepted;
      case 'rejected':
        return rejected;
      case 'in_progress':
        return inProgress;
      case 'completed':
        return completed;
      case 'cancelled':
        return cancelled;
      default:
        return pending;
    }
  }

  String get apiValue {
    switch (this) {
      case inProgress:
        return 'in_progress';
      default:
        return name;
    }
  }
}

class BookingEntity extends Equatable {
  final String id;
  final String serviceName;
  final double servicePrice;
  final String address;
  final String? notes;
  final DateTime scheduledAt;
  final BookingStatus status;
  final String? providerName;
  final String? customerName;
  final String? chatRoomId;

  const BookingEntity({
    required this.id,
    required this.serviceName,
    required this.servicePrice,
    required this.address,
    this.notes,
    required this.scheduledAt,
    required this.status,
    this.providerName,
    this.customerName,
    this.chatRoomId,
  });

  factory BookingEntity.fromJson(Map<String, dynamic> json) {
    final service = json['services'] as Map<String, dynamic>?;
    final provider = json['providers'] as Map<String, dynamic>?;
    final customer = json['customers'] as Map<String, dynamic>?;
    final chatRoom = json['chat_rooms'] as List?;

    return BookingEntity(
      id: json['id'] as String,
      serviceName: service?['name'] as String? ?? '',
      servicePrice: (service?['price'] as num?)?.toDouble() ?? 0,
      address: json['address'] as String? ?? '',
      notes: json['notes'] as String?,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      status: BookingStatus.fromString(json['status'] as String? ?? 'pending'),
      providerName: (provider?['profiles'] as Map?)?['full_name'] as String?,
      customerName: (customer?['profiles'] as Map?)?['full_name'] as String?,
      chatRoomId: chatRoom is List && chatRoom.isNotEmpty
          ? chatRoom.first['id'] as String?
          : null,
    );
  }

  @override
  List<Object?> get props => [id, status, scheduledAt];
}
