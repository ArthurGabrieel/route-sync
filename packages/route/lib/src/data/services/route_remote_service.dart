import "package:core/core.dart";

import "../models/route_model.dart";
import "../models/route_point_model.dart";

class RouteRemoteService {
  static const _delay = Duration(milliseconds: 800);

  AsyncResult<RouteModel> getRoute() async {
    try {
      await Future.delayed(_delay);
      return Success(_mockRoute);
    } on Exception catch (e, s) {
      return Failure(NetworkException(e.toString(), s));
    }
  }

  static final _mockRoute = RouteModel(
    id: "route-001",
    date: DateTime.now(),
    startAddress: "CD Brasília — SIA Trecho 3 Lote 625",
    totalDistanceKm: 87.4,
    estimatedMinutes: 360,
    points: [
      const RoutePointModel(
        order: 1,
        deliveryId: "del-001",
        recipientName: "Ana Souza",
        address: "Rua das Flores, 123 — Asa Norte",
        scheduledWindow: "08:00 – 10:00",
        distanceToNextKm: 3.2,
        minutesToNext: 12,
      ),
      const RoutePointModel(
        order: 2,
        deliveryId: "del-002",
        recipientName: "Bruno Lima",
        address: "SQN 210 Bloco C Ap. 304 — Asa Norte",
        scheduledWindow: "08:00 – 10:00",
        distanceToNextKm: 2.8,
        minutesToNext: 10,
      ),
      const RoutePointModel(
        order: 3,
        deliveryId: "del-003",
        recipientName: "Carla Mendes",
        address: "CLN 408 Bloco A Loja 12 — Asa Norte",
        scheduledWindow: "10:00 – 12:00",
        distanceToNextKm: 8.5,
        minutesToNext: 25,
      ),
      const RoutePointModel(
        order: 4,
        deliveryId: "del-004",
        recipientName: "Diego Ferreira",
        address: "SHIN QI 9 Conjunto 4 Casa 8 — Lago Norte",
        scheduledWindow: "10:00 – 12:00",
        distanceToNextKm: 12.3,
        minutesToNext: 35,
      ),
      const RoutePointModel(
        order: 5,
        deliveryId: "del-005",
        recipientName: "Elisa Torres",
        address: "SQS 308 Bloco H Ap. 512 — Asa Sul",
        scheduledWindow: "12:00 – 14:00",
        distanceToNextKm: 5.1,
        minutesToNext: 18,
      ),
      const RoutePointModel(
        order: 6,
        deliveryId: "del-006",
        recipientName: "Fábio Rocha",
        address: "Setor Comercial Sul Bloco B Sala 210",
        scheduledWindow: "12:00 – 14:00",
        distanceToNextKm: 9.7,
        minutesToNext: 28,
      ),
      const RoutePointModel(
        order: 7,
        deliveryId: "del-007",
        recipientName: "Gabriela Nunes",
        address: "QI 19 Conjunto 5 Casa 2 — Guará",
        scheduledWindow: "14:00 – 16:00",
        distanceToNextKm: 11.2,
        minutesToNext: 32,
      ),
      const RoutePointModel(
        order: 8,
        deliveryId: "del-008",
        recipientName: "Henrique Alves",
        address: "Rua 8 Sul Conjunto 4 Casa 16 — Águas Claras",
        scheduledWindow: "14:00 – 16:00",
        distanceToNextKm: 14.8,
        minutesToNext: 42,
      ),
      const RoutePointModel(
        order: 9,
        deliveryId: "del-009",
        recipientName: "Isabela Castro",
        address: "QNA 37 Conjunto B Casa 12 — Taguatinga",
        scheduledWindow: "16:00 – 18:00",
        distanceToNextKm: 18.1,
        minutesToNext: 48,
      ),
      const RoutePointModel(
        order: 10,
        deliveryId: "del-010",
        recipientName: "João Martins",
        address: "Setor de Habitações Individuais Sul — Parkway",
        scheduledWindow: "16:00 – 18:00",
        distanceToNextKm: null,
        minutesToNext: null,
      ),
    ],
  );
}
