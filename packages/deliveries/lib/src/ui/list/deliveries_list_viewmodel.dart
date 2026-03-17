import "dart:async";
import "package:flutter/foundation.dart";
import "package:core/core.dart";

import "../../data/models/delivery_model.dart";
import "../../data/models/delivery_status.dart";
import "../../data/models/pending_operation_model.dart";
import "../../data/repositories/deliveries_repository.dart";

class DeliveriesListViewModel extends ChangeNotifier {
  final DeliveriesRepository _repository;

  late final StreamSubscription<List<DeliveryModel>> _deliveriesSub;
  late final StreamSubscription<List<PendingOperationModel>> _pendingSub;

  DeliveriesListViewModel(this._repository) {
    load = Command0<List<DeliveryModel>>(_repository.loadDeliveries);
    sync = Command0<Unit>(_repository.processPendingQueue);

    _deliveriesSub = _repository.deliveriesStream.listen((deliveries) {
      _deliveries = deliveries;
      notifyListeners();
    });

    _pendingSub = _repository.pendingOpsStream.listen((ops) {
      _pendingOps = ops;
      notifyListeners();
    });
  }

  List<DeliveryModel> _deliveries = [];
  List<PendingOperationModel> _pendingOps = [];
  DeliveryStatus? _activeFilter;

  List<DeliveryModel> get deliveries => _activeFilter == null
      ? _deliveries
      : _deliveries.where((d) => d.status == _activeFilter).toList();

  List<PendingOperationModel> get pendingOps => _pendingOps;
  bool get hasPending => _pendingOps.isNotEmpty;
  int get pendingCount => _pendingOps.length;
  DeliveryStatus? get activeFilter => _activeFilter;

  late final Command0<List<DeliveryModel>> load;
  late final Command0<Unit> sync;

  void setFilter(DeliveryStatus? status) {
    _activeFilter = status;
    notifyListeners();
  }

  bool isPending(String id) => _pendingOps.any(
    (op) => switch (op) {
      StartDeliveryOp(:final deliveryId) => deliveryId == id,
      ConfirmDeliveryOp(:final deliveryId) => deliveryId == id,
      FailDeliveryOp(:final deliveryId) => deliveryId == id,
    },
  );

  @override
  void dispose() {
    _deliveriesSub.cancel();
    _pendingSub.cancel();
    load.dispose();
    sync.dispose();
    super.dispose();
  }
}
