import 'package:intl/intl.dart';

extension TengeFormatX on num {
  /// Formats a number as Tenge, e.g. `1800` -> `1 800 ₸`.
  String get tenge {
    final formatter = NumberFormat.decimalPattern('ru');
    return '${formatter.format(this)} ₸';
  }
}
