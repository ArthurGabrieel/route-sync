import "delivery_status.dart";

class DeliveryModel {
  final String id;
  final String recipientName;
  final String address;
  final String scheduledWindow;
  final List<String> items;
  final DeliveryStatus status;
  final String? notes;
  final DateTime updatedAt;

  const DeliveryModel({
    required this.id,
    required this.recipientName,
    required this.address,
    required this.scheduledWindow,
    required this.items,
    required this.status,
    required this.updatedAt,
    this.notes,
  });

  DeliveryModel copyWith({
    DeliveryStatus? status,
    String? notes,
    DateTime? updatedAt,
  }) => DeliveryModel(
    id: id,
    recipientName: recipientName,
    address: address,
    scheduledWindow: scheduledWindow,
    items: items,
    status: status ?? this.status,
    notes: notes ?? this.notes,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
