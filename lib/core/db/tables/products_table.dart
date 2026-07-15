import 'package:drift/drift.dart';

@DataClassName('ProductRow')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get sku => text().nullable()();
  RealColumn get price => real()();
  IntColumn get stockQty => integer()();
  TextColumn get photoUrl => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  // Set server-side when a stock movement (e.g. concurrent offline sales
  // racing on the last unit) drives stock_qty negative; cleared only when
  // an admin acknowledges it, never auto-cleared by a later positive movement.
  BoolColumn get needsReview => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
