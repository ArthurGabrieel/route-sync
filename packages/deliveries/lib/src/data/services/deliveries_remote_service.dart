import "dart:math";
import "package:core/core.dart";
import "package:deliveries/src/data/models/pending_operation_model.dart";
import "../exceptions/delivery_exception.dart";
import "../models/delivery_model.dart";
import "../models/delivery_status.dart";

class DeliveriesRemoteService {
  static const _delay = Duration(milliseconds: 800);

  // 20% de chance de falha — simula instabilidade de rede
  Future<void> _simulateNetwork() async {
    await Future.delayed(_delay);
    if (Random().nextDouble() < 0.2) {
      throw NetworkException("Conexão instável simulada");
    }
  }

  AsyncResult<List<DeliveryModel>> getDeliveries() async {
    try {
      await _simulateNetwork();
      return Success(_mockDeliveries);
    } on Exception catch (e, s) {
      return Failure(NetworkException(e.toString(), s));
    }
  }

  AsyncResult<Unit> executeOperation(PendingOperationModel op) async {
    try {
      await _simulateNetwork();
      return const Success(unit);
    } on Exception catch (e, s) {
      return Failure(DeliverySyncException(e.toString(), s));
    }
  }

  static final _mockDeliveries = [
    DeliveryModel(
      id: "del-001",
      recipientName: "Ana Souza",
      address: "Rua das Flores, 123 — Asa Norte",
      scheduledWindow: "08:00 – 10:00",
      items: ["Caixa 1/3", "Envelope A"],
      status: DeliveryStatus.pending,
      updatedAt: DateTime.now(),
    ),
    DeliveryModel(
      id: "del-002",
      recipientName: "Bruno Lima",
      address: "SQN 210 Bloco C Ap. 304 — Asa Norte",
      scheduledWindow: "08:00 – 10:00",
      items: ["Caixa 2/3"],
      status: DeliveryStatus.pending,
      updatedAt: DateTime.now(),
    ),
    DeliveryModel(
      id: "del-003",
      recipientName: "Carla Mendes",
      address: "CLN 408 Bloco A Loja 12 — Asa Norte",
      scheduledWindow: "10:00 – 12:00",
      items: ["Envelope B", "Envelope C"],
      status: DeliveryStatus.pending,
      updatedAt: DateTime.now(),
    ),
    DeliveryModel(
      id: "del-004",
      recipientName: "Diego Ferreira",
      address: "SHIN QI 9 Conjunto 4 Casa 8 — Lago Norte",
      scheduledWindow: "10:00 – 12:00",
      items: ["Caixa grande"],
      status: DeliveryStatus.pending,
      updatedAt: DateTime.now(),
    ),
    DeliveryModel(
      id: "del-005",
      recipientName: "Elisa Torres",
      address: "SQS 308 Bloco H Ap. 512 — Asa Sul",
      scheduledWindow: "12:00 – 14:00",
      items: ["Caixa 3/3"],
      status: DeliveryStatus.pending,
      updatedAt: DateTime.now(),
    ),
    DeliveryModel(
      id: "del-006",
      recipientName: "Fábio Rocha",
      address: "Setor Comercial Sul Bloco B Sala 210",
      scheduledWindow: "12:00 – 14:00",
      items: ["Documento", "Envelope D"],
      status: DeliveryStatus.pending,
      updatedAt: DateTime.now(),
    ),
    DeliveryModel(
      id: "del-007",
      recipientName: "Gabriela Nunes",
      address: "QI 19 Conjunto 5 Casa 2 — Guará",
      scheduledWindow: "14:00 – 16:00",
      items: ["Caixa média", "Envelope E"],
      status: DeliveryStatus.pending,
      updatedAt: DateTime.now(),
    ),
    DeliveryModel(
      id: "del-008",
      recipientName: "Henrique Alves",
      address: "Rua 8 Sul Conjunto 4 Casa 16 — Águas Claras",
      scheduledWindow: "14:00 – 16:00",
      items: ["Caixa pequena"],
      status: DeliveryStatus.pending,
      updatedAt: DateTime.now(),
    ),
    DeliveryModel(
      id: "del-009",
      recipientName: "Isabela Castro",
      address: "QNA 37 Conjunto B Casa 12 — Taguatinga",
      scheduledWindow: "16:00 – 18:00",
      items: ["Envelope F", "Envelope G"],
      status: DeliveryStatus.pending,
      updatedAt: DateTime.now(),
    ),
    DeliveryModel(
      id: "del-010",
      recipientName: "João Martins",
      address: "Setor de Habitações Individuais Sul — Parkway",
      scheduledWindow: "16:00 – 18:00",
      items: ["Caixa 1/2", "Caixa 2/2"],
      status: DeliveryStatus.pending,
      updatedAt: DateTime.now(),
    ),
  ];
}