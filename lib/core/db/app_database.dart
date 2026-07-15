import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/categories_table.dart';
import 'tables/products_table.dart';
import 'tables/stock_movements_table.dart';
import 'tables/sync_meta_table.dart';
import 'tables/transaction_items_table.dart';
import 'tables/transactions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Products,
    SyncMeta,
    Transactions,
    TransactionItems,
    StockMovements,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(transactions);
        await m.createTable(transactionItems);
        await m.createTable(stockMovements);
      }
      if (from < 3) {
        await m.addColumn(transactions, transactions.lastAttemptAt);
        await m.addColumn(products, products.needsReview);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pos_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
