import 'package:intl/intl.dart';

/// 価格フォーマット用のユーティリティクラス
class PriceFormatter {
  /// 価格を「¥1,000」形式でフォーマット
  static String format(int price) {
    final formatter = NumberFormat('#,###');
    return '¥${formatter.format(price)}';
  }
  
  /// 価格を「1,000」形式でフォーマット（¥記号なし）
  static String formatWithoutSymbol(int price) {
    final formatter = NumberFormat('#,###');
    return formatter.format(price);
  }
}
