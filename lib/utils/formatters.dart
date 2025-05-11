import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Menggunakan locale id_ID untuk format Indonesia (menggunakan titik sebagai pemisah ribuan)
  static final NumberFormat _formatter = NumberFormat('#,###', 'id_ID');
  
  static String format(num amount) {
    return _formatter.format(amount);
  }
}