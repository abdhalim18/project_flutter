import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/sync/pull_sync_service.dart';
import 'package:pos_app/core/sync/sync_engine.dart';
import 'package:pos_app/features/pos/application/cart_provider.dart';
import 'package:pos_app/features/pos/application/pos_providers.dart';
import 'package:pos_app/features/pos/presentation/pos_screen.dart';
import 'package:pos_app/features/pos/presentation/qty_stepper.dart';
import 'package:pos_app/features/products/application/product_providers.dart';
import 'package:pos_app/features/products/domain/category.dart';
import 'package:pos_app/features/products/domain/product.dart';

class _NoopPullSync implements PullSyncService {
  @override
  Future<void> pullAll() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoopSyncEngine implements SyncEngine {
  @override
  Future<void> syncPendingTransactions({bool force = false}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _products = [
  Product(id: 'p-espresso', name: 'Espresso', price: 15000, stockQty: 2, isActive: true),
  Product(id: 'p-croissant', name: 'Croissant', price: 18000, stockQty: 0, isActive: true),
  Product(id: 'p-mocha', name: 'Mocha', price: 24000, stockQty: 10, isActive: true),
];

Future<ProviderContainer> _pumpPos(WidgetTester tester) async {
  // Ukuran layar HP (360x800 dp), supaya semua kartu produk terlihat dan ikut dirender.
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      productsStreamProvider.overrideWith((ref) => Stream.value(_products)),
      categoriesStreamProvider.overrideWith((ref) => Stream.value(const <Category>[])),
      pullSyncServiceProvider.overrideWithValue(_NoopPullSync()),
      syncEngineProvider.overrideWithValue(_NoopSyncEngine()),
      autoSyncOnReconnectProvider.overrideWith((ref) {}),
      pendingSyncCountProvider.overrideWith((ref) => Stream.value(0)),
      failedSyncCountProvider.overrideWith((ref) => Stream.value(0)),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: PosScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Tombol (+ atau −) di kartu produk bernama [name].
Finder _button(String name, String tooltip) => find.descendant(
  of: find.ancestor(of: find.text(name), matching: find.byType(Card)),
  matching: find.byTooltip(tooltip),
);

// Tooltip ada di dalam IconButton, jadi IconButton dicari sebagai ancestor-nya.
IconButton _iconButton(WidgetTester tester, String name, String tooltip) =>
    tester.widget<IconButton>(
      find.ancestor(of: _button(name, tooltip), matching: find.byType(IconButton)),
    );

int _qty(ProviderContainer c, String productId) =>
    c.read(cartProvider).where((i) => i.productId == productId).fold(0, (s, i) => s + i.qty);

void main() {
  testWidgets('tombol + menambah, tombol − mengurangi lalu menghapus dari keranjang', (
    tester,
  ) async {
    final container = await _pumpPos(tester);

    // Awalnya hanya tombol +, tanpa tombol −.
    expect(_button('Mocha', 'Kurangi'), findsNothing);

    await tester.tap(_button('Mocha', 'Tambah'));
    await tester.pump();
    await tester.tap(_button('Mocha', 'Tambah'));
    await tester.pump();
    expect(_qty(container, 'p-mocha'), 2);
    expect(find.descendant(of: find.byType(QtyStepper), matching: find.text('2')), findsOneWidget);

    await tester.tap(_button('Mocha', 'Kurangi'));
    await tester.pump();
    expect(_qty(container, 'p-mocha'), 1);

    await tester.tap(_button('Mocha', 'Kurangi'));
    await tester.pump();
    expect(_qty(container, 'p-mocha'), 0);
    expect(container.read(cartProvider), isEmpty);
    expect(_button('Mocha', 'Kurangi'), findsNothing);
  });

  testWidgets('tidak bisa menambah melebihi stok', (tester) async {
    final container = await _pumpPos(tester);

    await tester.tap(_button('Espresso', 'Tambah'));
    await tester.pump();
    await tester.tap(_button('Espresso', 'Tambah'));
    await tester.pump();
    expect(_qty(container, 'p-espresso'), 2);

    // Stok Espresso 2: tombol + nonaktif, dan mengetuk kartunya juga tidak menambah.
    expect(_iconButton(tester, 'Espresso', 'Tambah').onPressed, isNull);
    await tester.tap(find.text('Espresso'));
    await tester.pump();
    expect(_qty(container, 'p-espresso'), 2);

    // Tombol − tetap bisa dipakai.
    await tester.tap(_button('Espresso', 'Kurangi'));
    await tester.pump();
    expect(_qty(container, 'p-espresso'), 1);
    expect(_iconButton(tester, 'Espresso', 'Tambah').onPressed, isNotNull);
  });

  testWidgets('produk dengan stok habis tidak bisa ditambah', (tester) async {
    final container = await _pumpPos(tester);

    expect(_iconButton(tester, 'Croissant', 'Tambah').onPressed, isNull);
    await tester.tap(find.text('Croissant'));
    await tester.pump();
    expect(_qty(container, 'p-croissant'), 0);
  });

  testWidgets('mengetuk kartu tetap menambah satu', (tester) async {
    final container = await _pumpPos(tester);

    await tester.tap(find.text('Mocha'));
    await tester.pump();
    expect(_qty(container, 'p-mocha'), 1);
  });
}
