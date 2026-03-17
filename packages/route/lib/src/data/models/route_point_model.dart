class RoutePointModel {
  final int order;
  final String deliveryId;
  final String recipientName;
  final String address;
  final String scheduledWindow;
  final double? distanceToNextKm;
  final int? minutesToNext;

  const RoutePointModel({
    required this.order,
    required this.deliveryId,
    required this.recipientName,
    required this.address,
    required this.scheduledWindow,
    this.distanceToNextKm,
    this.minutesToNext,
  });

  factory RoutePointModel.fromJson(Map<String, dynamic> json) => RoutePointModel(
    order: json["order"] as int,
    deliveryId: json["deliveryId"] as String,
    recipientName: json["recipientName"] as String,
    address: json["address"] as String,
    scheduledWindow: json["scheduledWindow"] as String,
    distanceToNextKm: (json["distanceToNextKm"] as num?)?.toDouble(),
    minutesToNext: json["minutesToNext"] as int?,
  );

  Map<String, dynamic> toJson() => {
    "order": order,
    "deliveryId": deliveryId,
    "recipientName": recipientName,
    "address": address,
    "scheduledWindow": scheduledWindow,
    "distanceToNextKm": distanceToNextKm,
    "minutesToNext": minutesToNext,
  };
}