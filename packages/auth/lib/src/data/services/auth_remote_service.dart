import "../exceptions/auth_exception.dart";
import "../models/auth_response.dart";
import "../models/driver.dart";

class AuthRemoteService {
  static const _validEmail = "driver@gmail.com";
  static const _validPassword = "123456";
  static const _delay = Duration(milliseconds: 800);

  Future<AuthResponse> login(String email, String password) async {
    await Future.delayed(_delay);

    if (email != _validEmail || password != _validPassword) {
      throw const InvalidCredentialsException();
    }

    return AuthResponse(
      token: "mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}",
      driver: const Driver(
        id: "driver-001",
        name: "Carlos Silva",
        email: _validEmail,
        vehicle: "Fiat Fiorino · ABC-1234",
      ),
    );
  }

  Future<void> logout(String token) async {
    await Future.delayed(_delay);
    // Mock — apenas simula a chamada
  }
}
