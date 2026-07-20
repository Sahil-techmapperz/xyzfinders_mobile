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
  static String formatPriceDisplay(dynamic amount) {
    if (amount == null) return '';
    
    if (amount is num) {
      return formatIndianCurrency(amount);
    }
    
    if (amount is String) {
      final str = amount.trim();
      if (str.isEmpty) return '';
      
      // If it parses fully as a number, use normal formatting
      final numValue = double.tryParse(str);
      if (numValue != null) {
        return formatIndianCurrency(numValue);
      }
      
      // If it contains text, just ensure it has ₹ prefix if appropriate
      // Some text might be "Contact for price", we don't necessarily want "₹ Contact for price"
      // But if it starts with a number like "5000 / month", "₹ 5000 / month" is better.
      final startsWithDigit = RegExp(r'^\d').hasMatch(str);
      if (startsWithDigit && !str.startsWith('₹')) {
        return '₹ $str';
      }
      return str;
    }
    
    return amount.toString();
  }
}
