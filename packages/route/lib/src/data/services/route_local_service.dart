import "dart:convert";
import "package:core/core.dart";

import "../models/route_model.dart";

class RouteLocalService {
  final SharedPreferences _prefs;

  RouteLocalService(this._prefs);

  static const _routeKey = "cached_route";

  AsyncResult<RouteModel> getRoute() async {
    try {
      final json = _prefs.getString(_routeKey);
      if (json == null) {
        return Failure(LocalStorageException("Sem rota em cache"));
      }
      return Success(RouteModel.fromJson(jsonDecode(json)));
    } on Exception catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }

  AsyncResult<RouteModel> saveRoute(RouteModel route) async {
    try {
      await _prefs.setString(_routeKey, jsonEncode(route.toJson()));
      return Success(route);
    } on Exception catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }

  AsyncResult<Unit> clear() async {
    await _prefs.remove(_routeKey);
    return const Success(unit);
  }
}
