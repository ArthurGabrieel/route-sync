import "dart:convert";
import "package:auth/auth.dart";
import "package:core/core.dart";

class AuthLocalService {
  final SharedPreferences _prefs;

  AuthLocalService(this._prefs);

  static const _tokenKey = "auth_token";
  static const _driverKey = "auth_driver";

  AsyncResult<String> getToken() async {
    try {
      final token = _prefs.getString(_tokenKey);
      if (token == null) return const Failure(NoSessionException());
      return Success(token);
    } on Exception catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }

  AsyncResult<String> saveToken(String token) async {
    try {
      await _prefs.setString(_tokenKey, token);
      return Success(token);
    } on Exception catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }

  AsyncResult<Driver> getDriver() async {
    try {
      final json = _prefs.getString(_driverKey);
      if (json == null) return const Failure(NoSessionException());
      return Success(Driver.fromJson(jsonDecode(json)));
    } on Exception catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }

  AsyncResult<Driver> saveDriver(Driver driver) async {
    try {
      await _prefs.setString(_driverKey, jsonEncode(driver.toJson()));
      return Success(driver);
    } on Exception catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }

  AsyncResult<Unit> clear() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_driverKey);
    return const Success(unit);
  }
}
