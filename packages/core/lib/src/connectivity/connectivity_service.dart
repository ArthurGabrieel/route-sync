import "package:core/core.dart";

class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService(this._connectivity);

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  AsyncResult<bool> check() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return Success(results.any((r) => r != ConnectivityResult.none));
    } on Exception catch (e, s) {
      return Failure(NetworkException(e.toString(), s));
    }
  }
}
