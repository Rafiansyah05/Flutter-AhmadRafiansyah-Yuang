import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _numberFormatter = NumberFormat('#,###', 'id_ID');

  /// Tampilkan nominal lengkap: Rp 12.000
  static String format(double amount) {
    return _formatter.format(amount);
  }

  /// Tampilkan nominal kompak: Rp 1,2jt / Rp 500rb
  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return format(amount);
  }

  /// Format angka dengan titik pemisah ribuan (untuk input field)
  /// 12000 → 12.000
  static String formatInput(String value) {
    final cleaned = value.replaceAll('.', '').replaceAll(',', '');
    if (cleaned.isEmpty) return '';
    final number = int.tryParse(cleaned);
    if (number == null) return value;
    return _numberFormatter.format(number);
  }

  /// Ambil nilai double dari string input yang sudah diformat
  /// "12.000" → 12000.0
  static double parseInput(String value) {
    final cleaned = value.replaceAll('.', '').replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0;
  }

  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  static String dateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  static String day(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }
}
