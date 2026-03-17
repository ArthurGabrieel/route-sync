import "package:core/core.dart";

sealed class AuthException extends AppException {
  const AuthException(super.message, [super.stackTrace]);
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException() : super("Credenciais inválidas");
}

class SessionExpiredException extends AuthException {
  const SessionExpiredException()
    : super("Sessão expirada, faça login novamente");
}

class NoSessionException extends AuthException {
  const NoSessionException() : super("Nenhuma sessão ativa");
}
