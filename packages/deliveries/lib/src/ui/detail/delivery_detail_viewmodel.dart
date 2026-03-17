import "dart:async";
import "package:flutter/foundation.dart";
import "package:core/core.dart";

import "../../data/models/delivery_model.dart";
import "../../data/models/delivery_status.dart";
import "../../data/models/pending_operation_model.dart";
import "../../data/repositories/deliveries_repository.dart";

class DeliveryDetailViewModel extends ChangeNotifier {
  final DeliveriesRepository _repository;
  final String deliveryId;

  late final StreamSubscription<List<DeliveryModel>> _deliveriesSub;
  late final StreamSubscription<List<PendingOperationModel>> _pendingSub;

  DeliveryDetailViewModel({
    required DeliveriesRepository repository,
    required this.deliveryId,
  }) : _repository = repository {
    start = Command0<Unit>(() => _repository.startDelivery(deliveryId));

    confirm = Command1<Unit, String?>(
      (notes) => _repository.confirmDelivery(deliveryId, notes: notes),
    );

    fail = Command1<Unit, ({String reason, String? notes})>(
      (args) => _repository.failDelivery(
        deliveryId,
        reason: args.reason,
        notes: args.notes,
      ),
    );

    // Ouve apenas a entrega específica
    _deliveriesSub = _repository.deliveriesStream.listen((deliveries) {
      _delivery = deliveries.where((d) => d.id == deliveryId).firstOrNull;
      notifyListeners();
    });

    _pendingSub = _repository.pendingOpsStream.listen((ops) {
      _isPending = ops.any(
        (op) => switch (op) {
          StartDeliveryOp(:final deliveryId) => deliveryId == this.deliveryId,
          ConfirmDeliveryOp(:final deliveryId) => deliveryId == this.deliveryId,
          FailDeliveryOp(:final deliveryId) => deliveryId == this.deliveryId,
        },
      );
      notifyListeners();
    });
  }

  DeliveryModel? _delivery;
  bool _isPending = false;

  DeliveryModel? get delivery => _delivery;
  bool get isPending => _isPending;
  bool get canStart =>
      _delivery?.status == DeliveryStatus.pending && !_isPending;
  bool get canConfirm =>
      _delivery?.status == DeliveryStatus.inProgress && !_isPending;
  bool get canFail =>
      _delivery?.status != DeliveryStatus.delivered && !_isPending;

  late final Command0<Unit> start;
  late final Command1<Unit, String?> confirm;
  late final Command1<Unit, ({String reason, String? notes})> fail;

  @override
  void dispose() {
    _deliveriesSub.cancel();
    _pendingSub.cancel();
    start.dispose();
    confirm.dispose();
    fail.dispose();
    super.dispose();
  }
}
