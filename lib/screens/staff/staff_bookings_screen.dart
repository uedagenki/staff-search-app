import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'booking_detail_screen.dart';

class StaffBookingsScreen extends StatefulWidget {
  const StaffBookingsScreen({super.key});

  @override
  State<StaffBookingsScreen> createState() => _StaffBookingsScreenState();
}

class _StaffBookingsScreenState extends State<StaffBookingsScreen> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    // LocalStorageからスタッフの予約データを取得
    final bookingsJson = html.window.localStorage['staff_bookings'];
    
    if (bookingsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(bookingsJson);
        setState(() {
          _bookings = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          _isLoading = false;
        });
      } catch (e) {
        _initializeSampleBookings();
      }
    } else {
      _initializeSampleBookings();
    }
  }

  void _initializeSampleBookings() {
    // サンプル予約データを作成
    _bookings = [
      {
        'id': 'booking_001',
        'customerName': '山田 太郎',
        'customerPhone': '090-1234-5678',
        'customerEmail': 'yamada@example.com',
        'dateTime': '2024年12月25日 14:00',
        'service': 'カット＆カラー',
        'price': 8000,
        'status': '確認待ち',
        'notes': '前回と同じスタイルでお願いします',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 'booking_002',
        'customerName': '佐藤 花子',
        'customerPhone': '080-9876-5432',
        'customerEmail': 'sato@example.com',
        'dateTime': '2024年12月26日 10:00',
        'service': 'ヘアトリートメント',
        'price': 5000,
        'status': '予約確定',
        'notes': '',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'id': 'booking_003',
        'customerName': '田中 一郎',
        'customerPhone': '070-1111-2222',
        'customerEmail': 'tanaka@example.com',
        'dateTime': '2024年12月27日 16:00',
        'service': 'パーマ',
        'price': 12000,
        'status': '確認待ち',
        'notes': '自然なウェーブをお願いします',
        'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      },
    ];

    // LocalStorageに保存
    html.window.localStorage['staff_bookings'] = jsonEncode(_bookings);
    
    setState(() {
      _isLoading = false;
    });
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

  void _navigateToDetail(Map<String, dynamic> booking) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailScreen(booking: booking),
      ),
    );
    // 詳細画面から戻ってきたら予約リストを再読み込み
    _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '予約管理',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadBookings,
                    tooltip: '更新',
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_bookings.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '予約がありません',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _loadBookings();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildBookingCard(_bookings[index]),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final customerName = booking['customerName'] ?? '不明';
    final dateTime = booking['dateTime'] ?? '';
    final status = booking['status'] ?? '確認待ち';
    final service = booking['service'] ?? '';
    final statusColor = _getStatusColor(status);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDetail(booking),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      customerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    dateTime,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.design_services, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    service,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _navigateToDetail(booking),
                      child: const Text('詳細を見る'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (status == '確認待ち')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _navigateToDetail(booking),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('確認する'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
