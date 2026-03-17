import "dart:async";
import "package:core/core.dart";

import "../exceptions/auth_exception.dart";
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

  AuthRepository(this._remote, this._local);

  AsyncResult<Driver> initialize() async {
    try {
      final token = await _local.getToken();
      if (token == null) {
        _controller.add(null);
        return const Failure(NoSessionException());
      }

      final driver = await _local.getDriver();
      if (driver == null) {
        _controller.add(null);
        return const Failure(NoSessionException());
      }

      _currentDriver = driver;
      _controller.add(_currentDriver);
      return Success(driver);
    } on Exception catch (e) {
      _controller.add(null);
      return Failure(e);
    }
  }

  AsyncResult<Driver> login(String email, String password) async {
    try {
      final response = await _remote.login(email, password);
      await _local.saveToken(response.token);
      await _local.saveDriver(response.driver);
      _currentDriver = response.driver;
      _controller.add(_currentDriver);
      return Success(response.driver);
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  AsyncResult<Unit> logout() async {
    try {
      final token = await _local.getToken();
      if (token != null) await _remote.logout(token);
      await _local.clear();
      _currentDriver = null;
      _controller.add(null);
      return const Success(unit);
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  void dispose() => _controller.close();
}
