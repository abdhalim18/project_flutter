import 'package:drift/drift.dart';

@DataClassName('TransactionItemRow')
class TransactionItems extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text()();
  TextColumn get productId => text().nullable()();
  TextColumn get productNameSnapshot => text()();
  RealColumn get unitPrice => real()();
  IntColumn get qty => integer()();
  RealColumn get subtotal => real()();

  @override
  Set<Column> get primaryKey => {id};
}
