import 'package:drift/drift.dart';

/// `syncState` doubles as the local sync queue signal: the sync engine
/// simply queries `where syncState = 'pending'` instead of maintaining a
/// separate generic outbox table — there is only one entity type (sales
/// transactions) that syncs outward in this phase, so a per-row status
/// column is simpler than a JSON-payload outbox while giving the same
/// idempotency/retry guarantees (the transaction's own UUID primary key is
/// the idempotency key for Supabase upserts).
@DataClassName('TransactionRow')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get cashierId => text()();
  RealColumn get totalAmount => real()();
  RealColumn get discountAmount => real().withDefault(const Constant(0))();
  TextColumn get paymentMethod => text()();
  RealColumn get paymentReceived => real().withDefault(const Constant(0))();
  RealColumn get changeAmount => real().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  DateTimeColumn get clientCreatedAt => dateTime()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
  IntColumn get syncAttemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastSyncError => text().nullable()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
