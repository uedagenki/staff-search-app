import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../utils/storage_helper.dart';
import 'dart:convert';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  // ユーザーレポートをCSVエクスポート
  Future<String?> exportUsersToCSV() async {
    try {
      final usersJson = await StorageHelper.getString('registered_users');
      if (usersJson == null) return null;

      final List<dynamic> users = jsonDecode(usersJson);
      
      List<List<dynamic>> rows = [
        ['ユーザーID', '名前', 'メール', '電話番号', '登録日', 'ポイント', 'メール認証'],
      ];

      for (var user in users) {
        rows.add([
          user['id'] ?? '',
          user['name'] ?? '',
          user['email'] ?? '',
          user['phoneNumber'] ?? '',
          user['createdAt'] ?? '',
          user['points'] ?? 0,
          user['isEmailVerified'] == true ? '済' : '未',
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);
      
      if (kIsWeb) {
        // Web版: ダウンロードリンクを返す
        return csv;
      } else {
        // モバイル版: ファイルに保存
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/users_${DateTime.now().millisecondsSinceEpoch}.csv');
        await file.writeAsString(csv);
        return file.path;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to export users to CSV: $e');
      }
      return null;
    }
  }

  // スタッフレポートをCSVエクスポート
  Future<String?> exportStaffToCSV() async {
    try {
      final staffJson = await StorageHelper.getString('staff_list');
      if (staffJson == null) return null;

      final List<dynamic> staffList = jsonDecode(staffJson);
      
      List<List<dynamic>> rows = [
        ['スタッフID', '名前', '職種', 'カテゴリー', '評価', 'レビュー数', '経験年数', '所在地', 'フォロワー数', 'ギフト総額'],
      ];

      for (var staff in staffList) {
        rows.add([
          staff['id'] ?? '',
          staff['name'] ?? '',
          staff['jobTitle'] ?? '',
          staff['category'] ?? '',
          staff['rating'] ?? 0,
          staff['reviewCount'] ?? 0,
          staff['experience'] ?? 0,
          staff['location'] ?? '',
          staff['followersCount'] ?? 0,
          staff['giftAmount'] ?? 0,
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);
      
      if (kIsWeb) {
        return csv;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/staff_${DateTime.now().millisecondsSinceEpoch}.csv');
        await file.writeAsString(csv);
        return file.path;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to export staff to CSV: $e');
      }
      return null;
    }
  }

  // 予約レポートをCSVエクスポート
  Future<String?> exportBookingsToCSV() async {
    try {
      final bookingsJson = await StorageHelper.getString('staff_bookings');
      if (bookingsJson == null) return null;

      final List<dynamic> bookings = jsonDecode(bookingsJson);
      
      List<List<dynamic>> rows = [
        ['予約ID', '顧客名', '電話番号', 'メール', '予約日時', 'サービス', '価格', 'ステータス', '作成日時'],
      ];

      for (var booking in bookings) {
        rows.add([
          booking['id'] ?? '',
          booking['customer_name'] ?? '',
          booking['phone'] ?? '',
          booking['email'] ?? '',
          booking['date_time'] ?? '',
          booking['service'] ?? '',
          booking['price'] ?? 0,
          booking['status'] ?? '',
          booking['createdAt'] ?? '',
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);
      
      if (kIsWeb) {
        return csv;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/bookings_${DateTime.now().millisecondsSinceEpoch}.csv');
        await file.writeAsString(csv);
        return file.path;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to export bookings to CSV: $e');
      }
      return null;
    }
  }

  // 統計レポートをPDFエクスポート
  Future<void> exportStatsToPDF({
    required Map<String, dynamic> stats,
    required String title,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // タイトル
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '生成日時: ${DateTime.now().toString().split('.')[0]}',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),

                // 統計情報
                pw.Text(
                  '概要統計',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),

                // ユーザー統計
                _buildStatRow('総ユーザー数', '${stats['users']?['total'] ?? 0} 人'),
                _buildStatRow('アクティブユーザー', '${stats['users']?['active'] ?? 0} 人'),
                _buildStatRow('今月の新規ユーザー', '${stats['users']?['new_this_month'] ?? 0} 人'),
                
                pw.SizedBox(height: 16),

                // スタッフ統計
                _buildStatRow('総スタッフ数', '${stats['staff']?['total'] ?? 0} 人'),
                _buildStatRow('アクティブスタッフ', '${stats['staff']?['active'] ?? 0} 人'),
                
                pw.SizedBox(height: 16),

                // 売上統計
                _buildStatRow('総売上', '¥${_formatNumber(stats['revenue']?['total'] ?? 0)}'),
                _buildStatRow('今月の売上', '¥${_formatNumber(stats['revenue']?['this_month'] ?? 0)}'),
                _buildStatRow('平均単価', '¥${_formatNumber(stats['revenue']?['average_booking'] ?? 0)}'),
                
                pw.SizedBox(height: 16),

                // 予約統計
                _buildStatRow('総予約数', '${stats['bookings']?['total'] ?? 0} 件'),
                _buildStatRow('今月の予約', '${stats['bookings']?['this_month'] ?? 0} 件'),
                _buildStatRow('完了', '${stats['bookings']?['completed'] ?? 0} 件'),
                _buildStatRow('キャンセル', '${stats['bookings']?['cancelled'] ?? 0} 件'),
              ],
            );
          },
        ),
      );

      // PDF表示・印刷
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to export stats to PDF: $e');
      }
    }
  }

  pw.Widget _buildStatRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 14),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // エクスポートメニューを表示
  static void showExportMenu({
    required BuildContext context,
    required Function() onExportUsers,
    required Function() onExportStaff,
    required Function() onExportBookings,
    required Function() onExportPDF,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('ユーザーデータをCSVエクスポート'),
              onTap: () {
                Navigator.pop(context);
                onExportUsers();
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('スタッフデータをCSVエクスポート'),
              onTap: () {
                Navigator.pop(context);
                onExportStaff();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('予約データをCSVエクスポート'),
              onTap: () {
                Navigator.pop(context);
                onExportBookings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('統計レポートをPDFエクスポート'),
              onTap: () {
                Navigator.pop(context);
                onExportPDF();
              },
            ),
          ],
        ),
      ),
    );
  }
}
