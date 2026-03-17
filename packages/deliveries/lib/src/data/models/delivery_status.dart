enum DeliveryStatus {
  pending,
  inProgress,
  delivered,
  failed;

  String get label => switch (this) {
    DeliveryStatus.pending => "Pendente",
    DeliveryStatus.inProgress => "Em andamento",
    DeliveryStatus.delivered => "Entregue",
    DeliveryStatus.failed => "Falhou",
  };

  // Persiste como string no Drift
  String get value => switch (this) {
    DeliveryStatus.pending => "pending",
    DeliveryStatus.inProgress => "in_progress",
    DeliveryStatus.delivered => "delivered",
    DeliveryStatus.failed => "failed",
  };

  static DeliveryStatus fromValue(String value) => switch (value) {
    "pending" => DeliveryStatus.pending,
    "in_progress" => DeliveryStatus.inProgress,
    "delivered" => DeliveryStatus.delivered,
    "failed" => DeliveryStatus.failed,
    _ => throw ArgumentError("Unknown status: $value"),
  };
}
