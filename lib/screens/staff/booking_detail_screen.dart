// SCREEN: Booking Detail Screen | BOOK-04
import '../../../utils/screen_logger.dart';
import '../../utils/storage_helper.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class BookingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingDetailScreen({
    super.key,
    required this.booking,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> with ScreenLogMixin {
  @override
  String get screenId => 'Booking Detail Screen | BOOK-04';

  late String _status;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _status = widget.booking['status'] ?? '確認待ち';
  }

  Future<void> _updateBookingStatus(String newStatus) async {
    setState(() {
      _isProcessing = true;
    });

    // LocalStorageから予約データを取得
    final bookingsJson = await StorageHelper.getString('staff_bookings');
    List<dynamic> bookings = [];
    
    if (bookingsJson != null) {
      bookings = jsonDecode(bookingsJson);
    }

    // 該当の予約を更新
    final index = bookings.indexWhere(
      (b) => b['id'] == widget.booking['id']
    );
    
    if (index != -1) {
      bookings[index]['status'] = newStatus;
      bookings[index]['updatedAt'] = DateTime.now().toIso8601String();
      
      // LocalStorageに保存
      await StorageHelper.setString('staff_bookings', jsonEncode(bookings));
      
      setState(() {
        _status = newStatus;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('予約を${newStatus}にしました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '予約確定':
        return Colors.green;
      case '確認待ち':
        return Colors.orange;
      case 'キャンセル':
        return Colors.red;
      case '完了':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerName = widget.booking['customerName'] ?? '不明';
    final dateTime = widget.booking['dateTime'] ?? '';
    final service = widget.booking['service'] ?? '';
    final price = widget.booking['price'] ?? 0;
    final notes = widget.booking['notes'] ?? '';
    final customerPhone = widget.booking['customerPhone'] ?? '';
    final customerEmail = widget.booking['customerEmail'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('予約詳細'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ステータスバッジ
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_status).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _status,
                    style: TextStyle(
                      color: _getStatusColor(_status),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // お客様情報
              _buildSectionTitle('お客様情報'),
              const SizedBox(height: 16),
              _buildInfoCard([
                _buildInfoRow(Icons.person, '名前', customerName),
                if (customerPhone.isNotEmpty)
                  _buildInfoRow(Icons.phone, '電話番号', customerPhone),
                if (customerEmail.isNotEmpty)
                  _buildInfoRow(Icons.email, 'メール', customerEmail),
              ]),
              const SizedBox(height: 24),

              // 予約情報
              _buildSectionTitle('予約情報'),
              const SizedBox(height: 16),
              _buildInfoCard([
                _buildInfoRow(Icons.calendar_today, '日時', dateTime),
                _buildInfoRow(Icons.design_services, 'サービス', service),
                _buildInfoRow(Icons.attach_money, '料金', '¥${price.toString()}'),
              ]),
              const SizedBox(height: 24),

              // 備考
              if (notes.isNotEmpty) ...[
                _buildSectionTitle('備考・要望'),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    notes,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // アクションボタン
              if (_status == '確認待ち') ...[
                _buildSectionTitle('予約対応'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () => _updateBookingStatus('予約確定'),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('予約確定'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () => _showCancelDialog(),
                        icon: const Icon(Icons.cancel),
                        label: const Text('キャンセル'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (_status == '予約確定') ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => _updateBookingStatus('完了'),
                    icon: const Icon(Icons.check),
                    label: const Text('サービス完了'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // 連絡ボタン
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('メッセージ機能（開発中）')),
                    );
                  },
                  icon: const Icon(Icons.message),
                  label: const Text('お客様にメッセージ'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('予約キャンセル確認'),
          ],
        ),
        content: const Text(
          'この予約をキャンセルしますか？\n\nお客様に通知が送信されます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('戻る'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateBookingStatus('キャンセル');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('キャンセルする'),
          ),
        ],
      ),
    );
  }
}
