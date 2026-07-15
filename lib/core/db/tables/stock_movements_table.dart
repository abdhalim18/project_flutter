import 'package:drift/drift.dart';

@DataClassName('StockMovementRow')
class StockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  IntColumn get changeQty => integer()();
  TextColumn get reason => text()();
  TextColumn get referenceId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
