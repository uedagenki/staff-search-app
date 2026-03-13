// SCREEN: Staff Bookings Screen | BOOK-01 / BOOK-04
import '../../../utils/screen_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';
import 'package:intl/intl.dart';
import 'staff_calendar_screen.dart';
import 'staff_service_management_screen.dart';

class StaffBookingsScreen extends StatefulWidget {
  const StaffBookingsScreen({super.key});

  @override
  State<StaffBookingsScreen> createState() => _StaffBookingsScreenState();
}

class _StaffBookingsScreenState extends State<StaffBookingsScreen> with ScreenLogMixin, SingleTickerProviderStateMixin {
  @override
  String get screenId => 'Staff Bookings Screen | BOOK-01 / BOOK-04';

  final _bookingService = BookingService();
  late TabController _tabController;

  List<Booking> _allBookings = [];
  List<Booking> _pendingBookings = [];
  List<Booking> _confirmedBookings = [];
  List<Booking> _completedBookings = [];
  bool _isLoading = true;

  String _staffId = 'staff_001'; // 実際にはログイン情報から取得

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    final bookings = await _bookingService.getStaffBookings(_staffId);
    
    setState(() {
      _allBookings = bookings;
      _pendingBookings = bookings.where((b) => b.isPending).toList();
      _confirmedBookings = bookings.where((b) => b.isConfirmed).toList();
      _completedBookings = bookings.where((b) => b.isCompleted).toList();
      _isLoading = false;
    });
  }

  Future<void> _confirmBooking(Booking booking) async {
    final success = await _bookingService.confirmBooking(
      booking.id,
      booking.staffId,
      booking.userId,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('予約を確認しました'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadBookings();
    }
  }

  Future<void> _completeBooking(Booking booking) async {
    final success = await _bookingService.completeBooking(
      booking.id,
      booking.staffId,
      booking.userId,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('予約を完了しました'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadBookings();
    }
  }

  Future<void> _cancelBooking(Booking booking) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _CancellationDialog(),
    );

    if (reason != null && mounted) {
      final success = await _bookingService.cancelBooking(
        booking.id,
        booking.staffId,
        booking.userId,
        reason,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('予約をキャンセルしました'),
            backgroundColor: Colors.orange,
          ),
        );
        await _loadBookings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('予約管理'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StaffCalendarScreen(),
                ),
              );
            },
            tooltip: 'カレンダー',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StaffServiceManagementScreen(),
                ),
              );
            },
            tooltip: 'サービス管理',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: '全て (${_allBookings.length})'),
            Tab(text: '未確認 (${_pendingBookings.length})'),
            Tab(text: '確認済 (${_confirmedBookings.length})'),
            Tab(text: '完了 (${_completedBookings.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(_allBookings),
                _buildBookingList(_pendingBookings),
                _buildBookingList(_confirmedBookings),
                _buildBookingList(_completedBookings),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToServiceManagement(),
        icon: const Icon(Icons.add),
        label: const Text('サービス管理'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '予約がありません',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return _buildBookingCard(bookings[index]);
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (booking.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        statusText = '未確認';
        break;
      case 'confirmed':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        statusText = '確認済';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.done_all;
        statusText = '完了';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'キャンセル';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = '不明';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: booking.isPending ? 4 : 2,
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ステータスと日時
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DateFormat('MM/dd (E) HH:mm', 'ja').format(booking.dateTime),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // サービス名
              Text(
                booking.serviceName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${booking.duration}分 | ¥${booking.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const Divider(height: 24),

              // 顧客情報
              Row(
                children: [
                  const Icon(Icons.person, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          booking.userPhone,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (booking.notes != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.note, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking.notes!,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // アクションボタン
              if (booking.isPending || booking.isConfirmed) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (booking.isPending) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmBooking(booking),
                          icon: const Icon(Icons.check),
                          label: const Text('確認'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (booking.isConfirmed) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _completeBooking(booking),
                          icon: const Icon(Icons.done),
                          label: const Text('完了'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (booking.canCancel)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _cancelBooking(booking),
                          icon: const Icon(Icons.cancel),
                          label: const Text('キャンセル'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => _buildBookingDetailsSheet(booking, scrollController),
      ),
    );
  }

  Widget _buildBookingDetailsSheet(Booking booking, ScrollController scrollController) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            '予約詳細',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          _buildDetailRow('サービス', booking.serviceName),
          _buildDetailRow('説明', booking.serviceDescription),
          _buildDetailRow('日時', DateFormat('yyyy年MM月dd日 (E) HH:mm', 'ja').format(booking.dateTime)),
          _buildDetailRow('所要時間', '${booking.duration}分'),
          _buildDetailRow('料金', '¥${booking.price.toStringAsFixed(0)}'),
          _buildDetailRow('顧客名', booking.userName),
          _buildDetailRow('電話番号', booking.userPhone),
          _buildDetailRow('メール', booking.userEmail),
          if (booking.notes != null)
            _buildDetailRow('備考', booking.notes!),
          _buildDetailRow('予約日時', DateFormat('yyyy/MM/dd HH:mm', 'ja').format(booking.createdAt)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToServiceManagement() {
    // サービス管理画面へ遷移
    Navigator.pushNamed(context, '/staff/services');
  }
}

class _CancellationDialog extends StatefulWidget {
  @override
  State<_CancellationDialog> createState() => _CancellationDialogState();
}

class _CancellationDialogState extends State<_CancellationDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('キャンセル理由'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'キャンセル理由を入力してください',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('戻る'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('キャンセル'),
        ),
      ],
    );
  }
}
