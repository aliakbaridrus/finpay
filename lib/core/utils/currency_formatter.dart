/// Helper format mata uang Rupiah tanpa dependensi tambahan.
abstract final class CurrencyFormatter {
  /// Contoh: 14850000 -> "Rp 14.850.000"
  static String rupiah(num value, {bool withSign = false}) {
    final isNegative = value < 0;
    final digits = value.abs().round().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      final positionFromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) buffer.write('.');
    }

    final sign = isNegative ? '-' : (withSign ? '+' : '');
    return '${sign}Rp $buffer';
  }

  /// Representasi tersembunyi untuk mode privasi saldo.
  static const String hidden = 'Rp ••••••••';
}
