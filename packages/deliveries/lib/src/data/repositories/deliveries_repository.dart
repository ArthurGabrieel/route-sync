import "dart:async";
import "package:core/core.dart";

import "../exceptions/delivery_exception.dart";
import "../models/delivery_model.dart";
import "../models/delivery_status.dart";
import "../models/pending_operation_model.dart";
import "../services/deliveries_local_service.dart";
import "../services/deliveries_remote_service.dart";

class DeliveriesRepository {
  final DeliveriesRemoteService _remote;
  final DeliveriesLocalService _local;
  final ConnectivityRepository _connectivity;

  final _controller = StreamController<List<DeliveryModel>>.broadcast();

  List<DeliveryModel> _deliveries = [];

  Stream<List<DeliveryModel>> get deliveriesStream => _controller.stream;
  Stream<List<PendingOperationModel>> get pendingOpsStream =>
      _local.watchPending();

  List<DeliveryModel> get deliveries => _deliveries;

  bool get hasPending => false; // atualizado pelo pendingOpsStream

  DeliveriesRepository(this._remote, this._local, this._connectivity) {
    // Alimenta o stream inicial com o banco local via Drift
    _local.watchAll().listen((deliveries) {
      _deliveries = deliveries;
      _controller.add(_deliveries);
    });

    // Sync automático ao voltar online
    _connectivity.onlineStream
        .where((isOnline) => isOnline)
        .listen((_) => _processPendingQueue());
  }

  // ── Leitura ─────────────────────────────────────────────────────────────────

  AsyncResult<List<DeliveryModel>> loadDeliveries() async {
    if (_connectivity.isOnline) {
      return _remote
          .getDeliveries()
          .flatMap(_mergeWithPending)
          .onSuccess((deliveries) => _deliveries = deliveries);
    }
    return _local.getAll().onSuccess((deliveries) => _deliveries = deliveries);
  }

  // ── Ações ───────────────────────────────────────────────────────────────────

  AsyncResult<Unit> startDelivery(String deliveryId) async {
    final op = StartDeliveryOp(
      deliveryId: deliveryId,
      startedAt: DateTime.now(),
    );
    return _applyOptimistic(
      deliveryId: deliveryId,
      newStatus: DeliveryStatus.inProgress,
      op: op,
    );
  }

  AsyncResult<Unit> confirmDelivery(String deliveryId, {String? notes}) async {
    final op = ConfirmDeliveryOp(
      deliveryId: deliveryId,
      confirmedAt: DateTime.now(),
      notes: notes,
    );
    return _applyOptimistic(
      deliveryId: deliveryId,
      newStatus: DeliveryStatus.delivered,
      op: op,
      notes: notes,
    );
  }

  AsyncResult<Unit> failDelivery(
    String deliveryId, {
    required String reason,
    String? notes,
  }) async {
    final op = FailDeliveryOp(
      deliveryId: deliveryId,
      reason: reason,
      failedAt: DateTime.now(),
      notes: notes,
    );
    return _applyOptimistic(
      deliveryId: deliveryId,
      newStatus: DeliveryStatus.failed,
      op: op,
      notes: notes,
    );
  }

  // ── Update otimista ──────────────────────────────────────────────────────────

  AsyncResult<Unit> _applyOptimistic({
    required String deliveryId,
    required DeliveryStatus newStatus,
    required PendingOperationModel op,
    String? notes,
  }) async {
    return _local
        .updateStatus(deliveryId, newStatus, notes: notes) //
        .flatMap((_) {
          return _connectivity.isOnline
              ? _remote.executeOperation(op)
              : _local.enqueue(op).map((_) => unit);
        });
  }

  // ── Fila de operações pendentes ──────────────────────────────────────────────

  AsyncResult<Unit> _processPendingQueue() {
    return _local
        .getPending()
        .flatMap(_executeAllOps)
        .flatMap((_) => _remote.getDeliveries())
        .flatMap(_mergeWithPending)
        .map((_) => unit);
  }

  AsyncResult<Unit> _executeAllOps(List<PendingOperationModel> ops) async {
    for (final op in ops) {
      final result = await _executeOp(op);
      if (result.isError()) return result;
    }
    return const Success(unit);
  }

  AsyncResult<Unit> _executeOp(PendingOperationModel op) {
    return _remote
        .executeOperation(op)
        .flatMap((_) => _local.markDone(op))
        .onFailure((_) => _local.markFailed(op))
        .map((_) => unit)
        .mapError(
          (e) => DeliverySyncException("Sync falhou: operação ${op.type}"),
        );
  }

  // ── Merge local + remoto ─────────────────────────────────────────────────────

  AsyncResult<List<DeliveryModel>> _mergeWithPending(
    List<DeliveryModel> remote,
  ) {
    return _local.getPending().flatMap((pending) {
      final merged = pending.fold(List<DeliveryModel>.from(remote), _applyOp);
      return _local.upsertAll(merged).map((_) => merged);
    });
  }

  List<DeliveryModel> _applyOp(
    List<DeliveryModel> deliveries,
    PendingOperationModel op,
  ) {
    return switch (op) {
      StartDeliveryOp(:final deliveryId) => _patchDelivery(
        deliveries,
        deliveryId,
        status: DeliveryStatus.inProgress,
      ),

      ConfirmDeliveryOp(:final deliveryId, :final notes) => _patchDelivery(
        deliveries,
        deliveryId,
        status: DeliveryStatus.delivered,
        notes: notes,
      ),

      FailDeliveryOp(:final deliveryId, :final notes) => _patchDelivery(
        deliveries,
        deliveryId,
        status: DeliveryStatus.failed,
        notes: notes,
      ),
    };
  }

  List<DeliveryModel> _patchDelivery(
    List<DeliveryModel> deliveries,
    String targetId, {
    required DeliveryStatus status,
    String? notes,
  }) {
    return deliveries.map((d) {
      return d.id == targetId ? d.copyWith(status: status, notes: notes) : d;
    }).toList();
  }

  void dispose() => _controller.close();
}
