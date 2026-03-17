import "dart:async";

import "package:connectivity_plus/connectivity_plus.dart";
import "package:result_dart/result_dart.dart";

class ConnectivityRepository {
  final Connectivity _connectivity;
  final _controller = StreamController<bool>.broadcast();

  bool _isOnline = true;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  Stream<bool> get onlineStream => _controller.stream;

  ConnectivityRepository(this._connectivity) {
    _connectivity.onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _isOnline = results.any((r) => r != ConnectivityResult.none);
      if (wasOnline != _isOnline) _controller.add(_isOnline);
    });
  }

  AsyncResult<bool> check() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isOnline = results.any((r) => r != ConnectivityResult.none);
      _controller.add(_isOnline);
      return Success(_isOnline);
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  void dispose() => _controller.close();
}
