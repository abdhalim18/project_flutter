import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/format/rupiah_input.dart';

const _f = RupiahInputFormatter();

/// Mensimulasikan satu ketikan: teks baru [text] dengan kursor di [cursor].
TextEditingValue _edit(TextEditingValue old, String text, int cursor) => _f.formatEditUpdate(
  old,
  TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: cursor),
  ),
);

TextEditingValue _at(String text, int cursor) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: cursor),
);

void main() {
  test('format dan parse', () {
    expect(formatRupiah(0), '0');
    expect(formatRupiah(950), '950');
    expect(formatRupiah(15000), '15.000');
    expect(formatRupiah(1250000), '1.250.000');
    expect(formatRupiah(15000.0), '15.000');
    expect(parseRupiah('1.250.000'), 1250000);
    expect(parseRupiah(''), 0);
    expect(parseRupiah('Rp 50.000'), 50000);
  });

  test('mengetik angka satu per satu memberi titik ribuan', () {
    var value = const TextEditingValue();
    for (final ch in '150000'.split('')) {
      final text = value.text + ch;
      value = _edit(value, text, text.length);
    }
    expect(value.text, '150.000');
    expect(value.selection.baseOffset, value.text.length);
  });

  test('menempel angka panjang (dengan atau tanpa titik)', () {
    expect(_edit(const TextEditingValue(), '2500000', 7).text, '2.500.000');
    expect(_edit(const TextEditingValue(), 'Rp 75.000', 9).text, '75.000');
  });

  test('backspace tepat setelah titik menghapus angka sebelum titik', () {
    // "12.000" dengan kursor setelah titik (offset 3); backspace menghapus titiknya → "12000".
    // Yang seharusnya terhapus adalah angka "2", jadi hasilnya "1.000" dengan kursor tetap
    // di depan "000".
    final result = _edit(_at('12.000', 3), '12000', 2);
    expect(result.text, '1.000');
    expect(result.selection.baseOffset, 2);
  });

  test('backspace di akhir menghapus angka terakhir', () {
    final result = _edit(_at('15.000', 6), '15.00', 5);
    expect(result.text, '1.500');
    expect(result.selection.baseOffset, 5);
  });

  test('menyisipkan angka di tengah menjaga posisi kursor', () {
    // "15.000", kursor setelah "1" (offset 1), ketik "2" → "125.000", kursor setelah "2".
    final result = _edit(_at('15.000', 1), '125.000', 2);
    expect(result.text, '125.000');
    expect(result.selection.baseOffset, 2);
  });

  test('nol di depan dibuang, menghapus semua jadi kosong', () {
    expect(_edit(_at('0', 1), '05', 2).text, '5');
    expect(_edit(_at('5', 1), '', 0).text, '');
  });

  test('menolak lebih dari 12 digit', () {
    final old = _at('999.999.999.999', 15);
    expect(_edit(old, '999.999.999.9999', 16), old);
  });

  testWidgets('dipakai di TextField', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextField(controller: controller, inputFormatters: const [RupiahInputFormatter()]),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), '100000');
    expect(controller.text, '100.000');
    expect(parseRupiah(controller.text), 100000);
  });
}
