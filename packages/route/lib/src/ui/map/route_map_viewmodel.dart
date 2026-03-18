import "dart:async";
import "package:flutter/foundation.dart";
import "package:core/core.dart";
import "package:deliveries/deliveries.dart";

import "../../data/models/route_model.dart";
import "../../data/models/route_point_model.dart";
import "../../data/repositories/route_repository.dart";

class RouteMapViewModel extends ChangeNotifier {
  final RouteRepository _routeRepository;
  final DeliveriesRepository _deliveriesRepository;

  late final StreamSubscription<RouteModel?> _routeSub;
  late final StreamSubscription<List<DeliveryModel>> _deliveriesSub;

  RouteMapViewModel({
    required RouteRepository routeRepository,
    required DeliveriesRepository deliveriesRepository,
  }) : _routeRepository = routeRepository,
       _deliveriesRepository = deliveriesRepository {
    load = Command0<RouteModel>(_routeRepository.loadRoute);

    _routeSub = _routeRepository.routeStream.listen((route) {
      _route = route;
      notifyListeners();
    });

    _deliveriesSub = _deliveriesRepository.deliveriesStream.listen((
      deliveries,
    ) {
      _deliveryStatuses = {for (final d in deliveries) d.id: d.status};
      notifyListeners();
    });
  }

  RouteModel? _route;
  Map<String, DeliveryStatus> _deliveryStatuses = {};

  RouteModel? get route => _route;
  late final Command0<RouteModel> load;

  List<RoutePointModel> get _points => _route?.points ?? [];

  int get totalPoints => _points.length;
  int get completedPoints => _countByStatus(DeliveryStatus.delivered);
  int get failedPoints => _countByStatus(DeliveryStatus.failed);
  int get pendingPoints => totalPoints - completedPoints - failedPoints;

  double get progressPercent =>
      totalPoints == 0 ? 0 : completedPoints / totalPoints;

  DeliveryStatus statusOf(RoutePointModel point) =>
      _deliveryStatuses[point.deliveryId] ?? DeliveryStatus.pending;

  RoutePointModel? get nextPoint => _route?.points.firstWhere(
    (p) =>
        _deliveryStatuses[p.deliveryId] == DeliveryStatus.pending ||
        _deliveryStatuses[p.deliveryId] == null,
  );

  String get estimatedTimeLeft {
    if (_route == null) return "--";
    final remaining = _route!.points
        .where(
          (p) => _deliveryStatuses[p.deliveryId] != DeliveryStatus.delivered,
        )
        .fold(0, (sum, p) => sum + (p.minutesToNext ?? 0));
    final hours = remaining ~/ 60;
    final minutes = remaining % 60;
    if (hours == 0) return "${minutes}min";
    return '${hours}h${minutes.toString().padLeft(2, '0')}min';
  }

  int _countByStatus(DeliveryStatus status) =>
      _points.where((p) => statusOf(p) == status).length;

  @override
  void dispose() {
    _routeSub.cancel();
    _deliveriesSub.cancel();
    load.dispose();
    super.dispose();
  }
}
