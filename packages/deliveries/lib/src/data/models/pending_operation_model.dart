import "dart:convert";

sealed class PendingOperationModel {
  final int? dbId;
  const PendingOperationModel({this.dbId});

  String get type;
  String toJson();
  PendingOperationModel withDbId(int id);

  static PendingOperationModel fromRecord({
    required int id,
    required String type,
    required String payload,
  }) {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    return switch (type) {
      "start_delivery" => StartDeliveryOp.fromJson(data, dbId: id),
      "confirm_delivery" => ConfirmDeliveryOp.fromJson(data, dbId: id),
      "fail_delivery" => FailDeliveryOp.fromJson(data, dbId: id),
      _ => throw ArgumentError("Unknown operation type: $type"),
    };
  }
}

class StartDeliveryOp extends PendingOperationModel {
  final String deliveryId;
  final DateTime startedAt;

  const StartDeliveryOp({
    required this.deliveryId,
    required this.startedAt,
    super.dbId,
  });

  @override
  String get type => "start_delivery";

  @override
  String toJson() => jsonEncode({
    "deliveryId": deliveryId,
    "startedAt": startedAt.toIso8601String(),
  });

  @override
  StartDeliveryOp withDbId(int id) =>
      StartDeliveryOp(deliveryId: deliveryId, startedAt: startedAt, dbId: id);

  factory StartDeliveryOp.fromJson(Map<String, dynamic> json, {int? dbId}) =>
      StartDeliveryOp(
        deliveryId: json["deliveryId"] as String,
        startedAt: DateTime.parse(json["startedAt"] as String),
        dbId: dbId,
      );
}

class ConfirmDeliveryOp extends PendingOperationModel {
  final String deliveryId;
  final DateTime confirmedAt;
  final String? notes;

  const ConfirmDeliveryOp({
    required this.deliveryId,
    required this.confirmedAt,
    this.notes,
    super.dbId,
  });

  @override
  String get type => "confirm_delivery";

  @override
  String toJson() => jsonEncode({
    "deliveryId": deliveryId,
    "confirmedAt": confirmedAt.toIso8601String(),
    "notes": notes,
  });

  @override
  ConfirmDeliveryOp withDbId(int id) => ConfirmDeliveryOp(
    deliveryId: deliveryId,
    confirmedAt: confirmedAt,
    notes: notes,
    dbId: id,
  );

  factory ConfirmDeliveryOp.fromJson(Map<String, dynamic> json, {int? dbId}) =>
      ConfirmDeliveryOp(
        deliveryId: json["deliveryId"] as String,
        confirmedAt: DateTime.parse(json["confirmedAt"] as String),
        notes: json["notes"] as String?,
        dbId: dbId,
      );
}

class FailDeliveryOp extends PendingOperationModel {
  final String deliveryId;
  final String reason;
  final String? notes;
  final DateTime failedAt;

  const FailDeliveryOp({
    required this.deliveryId,
    required this.reason,
    required this.failedAt,
    this.notes,
    super.dbId,
  });

  @override
  String get type => "fail_delivery";

  @override
  String toJson() => jsonEncode({
    "deliveryId": deliveryId,
    "reason": reason,
    "notes": notes,
    "failedAt": failedAt.toIso8601String(),
  });

  @override
  FailDeliveryOp withDbId(int id) => FailDeliveryOp(
    deliveryId: deliveryId,
    reason: reason,
    notes: notes,
    failedAt: failedAt,
    dbId: id,
  );

  factory FailDeliveryOp.fromJson(Map<String, dynamic> json, {int? dbId}) =>
      FailDeliveryOp(
        deliveryId: json["deliveryId"] as String,
        reason: json["reason"] as String,
        notes: json["notes"] as String?,
        failedAt: DateTime.parse(json["failedAt"] as String),
        dbId: dbId,
      );
}
