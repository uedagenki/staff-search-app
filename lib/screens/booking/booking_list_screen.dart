// SCREEN: Booking List Screen | BOOK-01 / BOOK-04
import '../../../utils/screen_logger.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking.dart';
import '../../services/firebase_booking_service.dart';

class BookingListScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const BookingListScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen>
    with ScreenLogMixin, SingleTickerProviderStateMixin {
  @override
  String get screenId => 'Booking List Screen | BOOK-01 / BOOK-04';

  final _bookingService = FirebaseBookingService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('予約管理'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'すべて'),
            Tab(text: '予約中'),
            Tab(text: '確定'),
            Tab(text: '完了'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(null),
          _buildBookingList('pending'),
          _buildBookingList('confirmed'),
          _buildBookingList('completed'),
        ],
      ),
    );
  }

  Widget _buildBookingList(String? status) {
    return StreamBuilder<List<Booking>>(
      stream: _bookingService.watchUserBookings(widget.userId, status: status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'エラーが発生しました\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('再読み込み'),
                ),
              ],
            ),
          );
        }

        final bookings = snapshot.data ?? [];

        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  status == null
                      ? '予約がありません'
                      : _getEmptyMessage(status),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return _buildBookingCard(bookings[index]);
            },
          ),
        );
      },
    );
  }

  String _getEmptyMessage(String status) {
    switch (status) {
      case 'pending':
        return '予約中の予約がありません';
      case 'confirmed':
        return '確定済みの予約がありません';
      case 'completed':
        return '完了した予約がありません';
      default:
        return '予約がありません';
    }
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _showBookingDetail(booking),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: booking.staffAvatar.isNotEmpty
                        ? NetworkImage(booking.staffAvatar)
                        : null,
                    child: booking.staffAvatar.isEmpty
                        ? const Icon(Icons.person, size: 25)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.staffName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.serviceName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(booking.status),
                ],
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.calendar_today,
                DateFormat('yyyy年M月d日 (E)', 'ja').format(booking.dateTime),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.access_time,
                '${DateFormat('HH:mm').format(booking.dateTime)} (${booking.duration}分)',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.attach_money,
                '¥${booking.price.toStringAsFixed(0)}',
              ),
              if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.notes,
                  booking.notes!,
                ),
              ],
              if (booking.canCancel) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelDialog(booking),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('キャンセル'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = '予約中';
        break;
      case 'confirmed':
        color = Colors.green;
        label = '確定';
        break;
      case 'completed':
        color = Colors.blue;
        label = '完了';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'キャンセル';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  void _showBookingDetail(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(
                '予約詳細',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('予約ID', booking.id),
              _buildDetailRow('スタッフ', booking.staffName),
              _buildDetailRow('サービス', booking.serviceName),
              _buildDetailRow('サービス詳細', booking.serviceDescription),
              _buildDetailRow(
                '日時',
                DateFormat('yyyy年M月d日 (E) HH:mm', 'ja')
                    .format(booking.dateTime),
              ),
              _buildDetailRow('所要時間', '${booking.duration}分'),
              _buildDetailRow('料金', '¥${booking.price.toStringAsFixed(0)}'),
              _buildDetailRow('ステータス', _getStatusLabel(booking.status)),
              if (booking.notes != null && booking.notes!.isNotEmpty)
                _buildDetailRow('備考', booking.notes!),
              if (booking.cancellationReason != null)
                _buildDetailRow('キャンセル理由', booking.cancellationReason!),
              _buildDetailRow(
                '予約日時',
                DateFormat('yyyy/MM/dd HH:mm').format(booking.createdAt),
              ),
              if (booking.updatedAt != null)
                _buildDetailRow(
                  '更新日時',
                  DateFormat('yyyy/MM/dd HH:mm').format(booking.updatedAt!),
                ),
              const SizedBox(height: 24),
              if (booking.canCancel)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showCancelDialog(booking);
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('予約をキャンセル'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return '予約中';
      case 'confirmed':
        return '確定';
      case 'completed':
        return '完了';
      case 'cancelled':
        return 'キャンセル';
      default:
        return status;
    }
  }

  void _showCancelDialog(Booking booking) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('予約のキャンセル'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('この予約をキャンセルしますか？'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'キャンセル理由 (任意)',
                border: OutlineInputBorder(),
                hintText: 'キャンセル理由を入力してください',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('戻る'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelBooking(
                booking,
                reasonController.text.isNotEmpty
                    ? reasonController.text
                    : null,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(Booking booking, String? reason) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await _bookingService.cancelBooking(
      booking.id,
      booking.staffId,
      booking.userId,
      reason,
    );

    if (mounted) {
      Navigator.pop(context);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('予約をキャンセルしました'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('キャンセルに失敗しました'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
