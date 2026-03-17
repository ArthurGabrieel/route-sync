import "package:core/core.dart";

sealed class DeliveryException extends AppException {
  const DeliveryException(super.message, [super.stackTrace]);
}

class DeliveryNotFoundException extends DeliveryException {
  const DeliveryNotFoundException(String id)
    : super("Entrega $id não encontrada");
}

class DeliveryAlreadyCompletedException extends DeliveryException {
  const DeliveryAlreadyCompletedException(String id)
    : super("Entrega $id já foi finalizada");
}

class DeliverySyncException extends DeliveryException {
  const DeliverySyncException(super.message, [super.stackTrace]);
}
