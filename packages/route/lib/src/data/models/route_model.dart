import "route_point_model.dart";

class RouteModel {
  final String id;
  final DateTime date;
  final String startAddress;
  final double totalDistanceKm;
  final int estimatedMinutes;
  final List<RoutePointModel> points;

  const RouteModel({
    required this.id,
    required this.date,
    required this.startAddress,
    required this.totalDistanceKm,
    required this.estimatedMinutes,
    required this.points,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
    id: json["id"] as String,
    date: DateTime.parse(json["date"] as String),
    startAddress: json["startAddress"] as String,
    totalDistanceKm: (json["totalDistanceKm"] as num).toDouble(),
    estimatedMinutes: json["estimatedMinutes"] as int,
    points: (json["points"] as List)
        .map((p) => RoutePointModel.fromJson(p as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date.toIso8601String(),
    "startAddress": startAddress,
    "totalDistanceKm": totalDistanceKm,
    "estimatedMinutes": estimatedMinutes,
    "points": points.map((p) => p.toJson()).toList(),
  };

  int get totalPoints => points.length;

  RoutePointModel? get nextPoint => points.isNotEmpty ? points.first : null;
}
