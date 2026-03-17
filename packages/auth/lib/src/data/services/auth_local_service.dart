import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";

import "../models/driver.dart";

class AuthLocalService {
  final SharedPreferences _prefs;

  AuthLocalService(this._prefs);

  static const _tokenKey = "auth_token";
  static const _driverKey = "auth_driver";

  Future<String?> getToken() async => _prefs.getString(_tokenKey);

  Future<void> saveToken(String token) async =>
      _prefs.setString(_tokenKey, token);

  Future<Driver?> getDriver() async {
    final json = _prefs.getString(_driverKey);
    if (json == null) return null;
    return Driver.fromJson(jsonDecode(json));
  }

  Future<void> saveDriver(Driver driver) async =>
      _prefs.setString(_driverKey, jsonEncode(driver.toJson()));

  Future<void> clear() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_driverKey);
  }
}
