import "dart:async";
import "package:core/core.dart";

import "../models/driver.dart";
import "../services/auth_local_service.dart";
import "../services/auth_remote_service.dart";

class AuthRepository {
  final AuthRemoteService _remote;
  final AuthLocalService _local;

  final _controller = StreamController<Driver?>.broadcast();

  Driver? _currentDriver;

  Stream<Driver?> get driverStream => _controller.stream;
  Driver? get currentDriver => _currentDriver;
  bool get isAuthenticated => _currentDriver != null;

  set currentDriver(Driver? driver) {
    _currentDriver = driver;
    _controller.add(driver);
  }

  AuthRepository(this._remote, this._local);

  AsyncResult<Driver> initialize() async {
    return _local
        .getToken()
        .flatMap((_) => _local.getDriver())
        .onFailure((_) => currentDriver = null)
        .onSuccess((driver) => currentDriver = driver);
  }

  AsyncResult<Driver> login(String email, String password) async {
    return _remote
        .login(email, password)
        .flatMap((resp) => _local.saveToken(resp.token).map((_) => resp))
        .flatMap((resp) => _local.saveDriver(resp.driver))
        .onSuccess((driver) => currentDriver = driver);
  }

  AsyncResult<Unit> logout() async {
    return _local
        .getToken()
        .flatMap(_remote.logout)
        .flatMap((_) => _local.clear())
        .onSuccess((_) => currentDriver = null);
  }

  void dispose() => _controller.close();
}
