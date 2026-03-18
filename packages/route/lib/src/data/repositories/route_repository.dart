import "dart:async";
import "package:core/core.dart";

import "../models/route_model.dart";
import "../services/route_local_service.dart";
import "../services/route_remote_service.dart";

class RouteRepository {
  final RouteRemoteService _remote;
  final RouteLocalService _local;
  final ConnectivityRepository _connectivity;

  final _controller = StreamController<RouteModel?>.broadcast();

  RouteModel? _route;

  Stream<RouteModel?> get routeStream => _controller.stream;
  RouteModel? get route => _route;

  Result<RouteModel> _setRoute(RouteModel route) {
    _route = route;
    _controller.add(route);
    return Success(route);
  }

  RouteRepository(this._remote, this._local, this._connectivity);

  AsyncResult<RouteModel> loadRoute() async {
    if (_connectivity.isOnline) {
      return _remote //
          .getRoute()
          .flatMap(_local.saveRoute)
          .onSuccess(_setRoute);
    }

    return _local.getRoute().onSuccess(_setRoute);
  }

  void dispose() => _controller.close();
}
