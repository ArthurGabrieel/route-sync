import "package:drift/drift.dart";
import "package:drift_flutter/drift_flutter.dart";

part "app_database.g.dart";

// ── Tabelas ──────────────────────────────────────────────────────────────────

class Deliveries extends Table {
  TextColumn get id             => text()();
  TextColumn get recipientName  => text()();
  TextColumn get address        => text()();
  TextColumn get scheduledWindow => text()();
  TextColumn get items          => text()(); // JSON array
  TextColumn get status         => text().withDefault(const Constant("pending"))();
  TextColumn get notes          => text().nullable()();
  DateTimeColumn get updatedAt  => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PendingOperations extends Table {
  IntColumn  get id          => integer().autoIncrement()();
  TextColumn get type        => text()();
  TextColumn get payload     => text()(); // JSON
  DateTimeColumn get createdAt => dateTime()();
  IntColumn  get retryCount  => integer().withDefault(const Constant(0))();
  TextColumn get status      => text().withDefault(const Constant("pending"))();
}

// ── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [Deliveries, PendingOperations])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: "routesync"));

  // Construtor para testes — permite passar conexão in-memory
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;

  // ── Deliveries ─────────────────────────────────────────────────────────────

  Stream<List<Delivery>> watchAll() =>
      (select(deliveries)
        ..orderBy([(d) => OrderingTerm.asc(d.updatedAt)]))
          .watch();

  Future<List<Delivery>> getAll() =>
      (select(deliveries)
        ..orderBy([(d) => OrderingTerm.asc(d.updatedAt)]))
          .get();

  Future<void> upsertDelivery(DeliveriesCompanion delivery) =>
      into(deliveries).insertOnConflictUpdate(delivery);

  Future<void> upsertAll(List<DeliveriesCompanion> items) =>
      transaction(() async {
        for (final item in items) {
          await into(deliveries).insertOnConflictUpdate(item);
        }
      });

  Future<void> updateStatus(String id, String status, {String? notes}) =>
      (update(deliveries)..where((d) => d.id.equals(id)))
          .write(DeliveriesCompanion(
            status: Value(status),
            notes: Value(notes),
            updatedAt: Value(DateTime.now()),
          ));

  // ── Pending Operations ─────────────────────────────────────────────────────

  Stream<List<PendingOperation>> watchPending() =>
      (select(pendingOperations)
        ..where((p) => p.status.isIn(["pending", "failed"]))
        ..orderBy([(p) => OrderingTerm.asc(p.createdAt)]))
          .watch();

  Future<List<PendingOperation>> getPending() =>
      (select(pendingOperations)
        ..where((p) => p.status.isIn(["pending", "failed"]))
        ..orderBy([(p) => OrderingTerm.asc(p.createdAt)]))
          .get();

  Future<int> insertPendingOp(PendingOperationsCompanion op) =>
      into(pendingOperations).insert(op);

  Future<void> deletePendingOp(int id) =>
      (delete(pendingOperations)..where((p) => p.id.equals(id))).go();

  Future<void> incrementRetry(int id) =>
      (update(pendingOperations)..where((p) => p.id.equals(id)))
          .write(PendingOperationsCompanion(
            status: const Value("failed"),
            retryCount: Variable(
              pendingOperations.retryCount + const Constant(1),
            ) as Value<int>,
          ));
}