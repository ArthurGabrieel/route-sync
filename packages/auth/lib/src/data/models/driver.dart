class Driver {
  final String id;
  final String name;
  final String email;
  final String vehicle;

  const Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.vehicle,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    id: json["id"] as String,
    name: json["name"] as String,
    email: json["email"] as String,
    vehicle: json["vehicle"] as String,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "vehicle": vehicle,
  };
}
