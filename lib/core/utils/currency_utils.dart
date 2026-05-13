import 'package:intl/intl.dart';

class CurrencyUtils {
  static String formatIndianCurrency(dynamic amount) {
    double value = 0;
    if (amount is double) {
      value = amount;
    } else if (amount is int) {
      value = amount.toDouble();
    } else if (amount is String) {
      value = double.tryParse(amount) ?? 0;
    }
    
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );
    return format.format(value);
  }
}
