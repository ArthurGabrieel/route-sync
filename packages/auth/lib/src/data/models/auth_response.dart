import "driver.dart";

class AuthResponse {
  final String token;
  final Driver driver;

  const AuthResponse({required this.token, required this.driver});
}
