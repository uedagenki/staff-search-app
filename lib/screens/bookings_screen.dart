import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/booking.dart';
import 'booking_detail_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Booking> _allBookings = [
    Booking(
      id: '1',
      staffId: '2',
      staffName: '田中 美咲',
      staffImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      staffJobTitle: '美容師',
      date: DateTime.now().add(const Duration(days: 1)),
      timeSlot: '14:00 - 15:30',
      status: BookingStatus.confirmed,
      notes: 'カットとカラーをお願いします',
      price: 8000,
    ),
    Booking(
      id: '2',
      staffId: '1',
      staffName: '佐藤 健',
      staffImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      staffJobTitle: '保険コンサルタント',
      date: DateTime.now().add(const Duration(days: 3)),
      timeSlot: '10:00 - 11:00',
      status: BookingStatus.confirmed,
      notes: '生命保険の見直し相談',
      price: 0,
    ),
    Booking(
      id: '3',
      staffId: '7',
      staffName: '中村 大輔',
      staffImage: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400',
      staffJobTitle: 'パーソナルトレーナー',
      date: DateTime.now().subtract(const Duration(days: 2)),
      timeSlot: '18:00 - 19:00',
      status: BookingStatus.completed,
      notes: 'ダイエットプログラム',
      price: 5000,
    ),
    Booking(
      id: '4',
      staffId: '4',
      staffName: '鈴木 花子',
      staffImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
      staffJobTitle: 'エステティシャン',
      date: DateTime.now().subtract(const Duration(days: 5)),
      timeSlot: '15:00 - 16:30',
      status: BookingStatus.completed,
      notes: 'フェイシャルエステ',
      price: 12000,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Booking> _getUpcomingBookings() {
    return _allBookings
        .where((b) =>
            b.status == BookingStatus.confirmed &&
            b.date.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Booking> _getPastBookings() {
    return _allBookings
        .where((b) => b.status == BookingStatus.completed)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Booking> _getCancelledBookings() {
    return _allBookings
        .where((b) => b.status == BookingStatus.cancelled)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('予約履歴'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: '予約中'),
            Tab(text: '完了'),
            Tab(text: 'キャンセル'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(_getUpcomingBookings()),
          _buildBookingList(_getPastBookings()),
          _buildBookingList(_getCancelledBookings()),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '予約がありません',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildBookingCard(bookings[index]);
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailScreen(booking: booking),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // スタッフ画像
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: booking.staffImage,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // スタッフ情報
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
                          booking.staffJobTitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // ステータスバッジ
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: booking.getStatusColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      booking.getStatusText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const Divider(height: 24),
              
              // 予約詳細
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${booking.date.year}年${booking.date.month}月${booking.date.day}日',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    booking.timeSlot,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              
              if (booking.price != null && booking.price! > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.payments,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '¥${booking.price!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              
              if (booking.notes != null) ...[
                const SizedBox(height: 8),
                Text(
                  booking.notes!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
