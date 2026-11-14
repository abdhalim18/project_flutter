import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final _grouping = NumberFormat.decimalPattern('id_ID');

/// Format angka rupiah tanpa simbol, dengan titik pemisah ribuan: 150000 → "150.000".
String formatRupiah(num value) => _grouping.format(value.round());

/// Kebalikan [formatRupiah]: mengambil digitnya saja ("150.000" → 150000). Kosong → 0.
int parseRupiah(String text) {
  final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.isEmpty ? 0 : int.parse(digits);
}

/// Memberi titik pemisah ribuan saat mengetik nominal uang (rupiah, tanpa desimal).
///
/// Kursor dipertahankan relatif terhadap digit di sebelah kanannya, jadi menyisipkan atau
/// menghapus angka di tengah tetap terasa wajar.
class RupiahInputFormatter extends TextInputFormatter {
  const RupiahInputFormatter({this.maxDigits = 12});

  final int maxDigits;

  static String _digitsOf(String text) => text.replaceAll(RegExp(r'[^0-9]'), '');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    var cursor = newValue.selection.baseOffset.clamp(0, text.length);

    // Backspace tepat setelah titik hanya menghapus titiknya (digit tidak berubah), lalu
    // titiknya muncul lagi. Hapus digit sebelum titik itu supaya Backspace terasa normal.
    if (text.length < oldValue.text.length && _digitsOf(text) == _digitsOf(oldValue.text)) {
      var i = cursor - 1;
      while (i >= 0 && !RegExp(r'[0-9]').hasMatch(text[i])) {
        i--;
      }
      if (i >= 0) {
        text = text.substring(0, i) + text.substring(i + 1);
        cursor = i;
      }
    }

    var digits = _digitsOf(text);
    if (digits.isEmpty) return const TextEditingValue();
    if (digits.length > maxDigits) return oldValue;

    // Jumlah digit di kanan kursor, dihitung sebelum nol di depan dibuang.
    final digitsAfterCursor = _digitsOf(text.substring(cursor)).length;

    digits = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final formatted = formatRupiah(int.parse(digits));

    var offset = formatted.length;
    var seen = 0;
    while (offset > 0 && seen < digitsAfterCursor) {
      offset--;
      if (formatted[offset] != '.') seen++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
