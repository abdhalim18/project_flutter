import 'package:drift/drift.dart';

/// Tracks when each remote table was last pulled into the local mirror.
class SyncMeta extends Table {
  TextColumn get entityKey => text()();
  DateTimeColumn get lastPulledAt => dateTime()();

  @override
  Set<Column> get primaryKey => {entityKey};
}
