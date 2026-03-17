import "dart:async";

import "package:connectivity_plus/connectivity_plus.dart";
import "package:result_dart/result_dart.dart";

import "connectivity_service.dart";

class ConnectivityRepository {
  final ConnectivityService _service;
  final _controller = StreamController<bool>.broadcast();

  bool _isOnline = true;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  Stream<bool> get onlineStream => _controller.stream;

  set _online(bool value) {
    _isOnline = value;
    _controller.add(value);
  }

  ConnectivityRepository(this._service) {
    _service.onConnectivityChanged.listen((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline != _isOnline) _online = isOnline;
    });
  }

  AsyncResult<bool> check() async {
    return _service.check().onSuccess((isOnline) => _online = isOnline);
  }

  void dispose() => _controller.close();
}
