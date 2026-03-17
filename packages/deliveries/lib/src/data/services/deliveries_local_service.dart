import "dart:convert";
import "package:core/core.dart";
import "../models/delivery_model.dart";
import "../models/delivery_status.dart";
import "../models/pending_operation_model.dart";

class DeliveriesLocalService {
  final AppDatabase _db;

  DeliveriesLocalService(this._db);

  // ── Deliveries ─────────────────────────────────────────────────────────────

  Stream<List<DeliveryModel>> watchAll() {
    return _db.watchAll().map((rows) => rows.map(_rowToModel).toList());
  }

  AsyncResult<List<DeliveryModel>> getAll() async {
    try {
      final rows = await _db.getAll();
      return Success(rows.map(_rowToModel).toList());
    } on Exception catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }

  AsyncResult<Unit> upsertAll(List<DeliveryModel> deliveries) async {
    try {
      await _db.upsertAll(deliveries.map(_modelToCompanion).toList());
      return const Success(unit);
    } on Exception catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }

  AsyncResult<Unit> updateStatus(
    String id,
    DeliveryStatus status, {
    String? notes,
  }) async {
    try {
      await _db.updateStatus(id, status.value, notes: notes);
      return const Success(unit);
    } on Exception catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }

  // ── Pending Operations ─────────────────────────────────────────────────────

  Stream<List<PendingOperationModel>> watchPending() {
    return _db.watchPending().map(
      (rows) => rows
          .map(
            (row) => PendingOperationModel.fromRecord(
              id: row.id,
              type: row.type,
              payload: row.payload,
            ),
          )
          .toList(),
    );
  }

  AsyncResult<List<PendingOperationModel>> getPending() async {
    try {
      final rows = await _db.getPending();
      return Success(
        rows
            .map(
              (row) => PendingOperationModel.fromRecord(
                id: row.id,
                type: row.type,
                payload: row.payload,
              ),
            )
            .toList(),
      );
    } on Exception catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }

  AsyncResult<PendingOperationModel> enqueue(PendingOperationModel op) async {
    try {
      final id = await _db.insertPendingOp(
        PendingOperationsCompanion.insert(
          type: op.type,
          payload: op.toJson(),
          createdAt: DateTime.now(),
        ),
      );
      return Success(op.withDbId(id));
    } on Exception catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }

  AsyncResult<PendingOperationModel> markDone(PendingOperationModel op) async {
    try {
      await _db.deletePendingOp(op.dbId!);
      return Success(op);
    } on Exception catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }

  AsyncResult<PendingOperationModel> markFailed(PendingOperationModel op) async {
    try {
      await _db.incrementRetry(op.dbId!);
      return Success(op);
    } on Exception catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }

  // ── Mappers ────────────────────────────────────────────────────────────────

  DeliveryModel _rowToModel(Delivery row) => DeliveryModel(
    id: row.id,
    recipientName: row.recipientName,
    address: row.address,
    scheduledWindow: row.scheduledWindow,
    items: (jsonDecode(row.items) as List).cast<String>(),
    status: DeliveryStatus.fromValue(row.status),
    notes: row.notes,
    updatedAt: row.updatedAt,
  );

  DeliveriesCompanion _modelToCompanion(DeliveryModel model) =>
      DeliveriesCompanion.insert(
        id: model.id,
        recipientName: model.recipientName,
        address: model.address,
        scheduledWindow: model.scheduledWindow,
        items: jsonEncode(model.items),
        status: Value(model.status.value),
        notes: Value(model.notes),
        updatedAt: model.updatedAt,
      );
}
