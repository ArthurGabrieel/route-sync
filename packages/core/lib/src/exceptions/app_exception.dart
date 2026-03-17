abstract class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);

  @override
  String toString() {
    if (stackTrace != null) {
      return "$runtimeType: $message\n$stackTrace";
    }
    return "$runtimeType: $message";
  }
}

class LocalStorageException extends AppException {
  LocalStorageException(super.message, [super.stackTrace]);
}

class NetworkException extends AppException {
  NetworkException(super.message, [super.stackTrace]);
}