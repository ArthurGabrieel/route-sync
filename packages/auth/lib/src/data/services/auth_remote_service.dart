import "package:core/core.dart";

import "../exceptions/auth_exception.dart";
import "../models/auth_response.dart";
import "../models/driver.dart";

class AuthRemoteService {
  static const _validEmail = "driver@gmail.com";
  static const _validPassword = "123456";
  static const _delay = Duration(milliseconds: 800);

  AsyncResult<AuthResponse> login(String email, String password) async {
    try {
      await Future.delayed(_delay);

      if (email != _validEmail || password != _validPassword) {
        return const Failure(InvalidCredentialsException());
      }

      return Success(
        AuthResponse(
          token: "mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}",
          driver: const Driver(
            id: "driver-001",
            name: "Carlos Silva",
            email: _validEmail,
            vehicle: "Fiat Fiorino · ABC-1234",
          ),
        ),
      );
    } on Exception catch (e, s) {
      return Failure(NetworkException(e.toString(), s));
    }
  }

  AsyncResult<Unit> logout(String token) async {
    try {
      await Future.delayed(_delay);
      return const Success(unit);
    } on Exception catch (e, s) {
      return Failure(NetworkException(e.toString(), s));
    }
  }
}
