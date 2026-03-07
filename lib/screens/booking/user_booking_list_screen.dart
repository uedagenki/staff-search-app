import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/booking.dart';
import '../../services/local_booking_service.dart';
import '../../services/local_auth_service.dart';
import 'booking_detail_screen.dart';

/// ユーザー側：予約一覧画面（カレンダー表示付き）
class UserBookingListScreen extends StatefulWidget {
  const UserBookingListScreen({super.key});

  @override
  State<UserBookingListScreen> createState() => _UserBookingListScreenState();
}

class _UserBookingListScreenState extends State<UserBookingListScreen>
    with SingleTickerProviderStateMixin {
  final _bookingService = LocalBookingService();
  final _authService = LocalAuthService();

  late TabController _tabController;
  List<Booking> _allBookings = [];
  List<Booking> _upcomingBookings = [];
  List<Booking> _pastBookings = [];
  Map<DateTime, List<Booking>> _bookingsByDate = {};
  bool _isLoading = true;
  String? _userId;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDay = _focusedDay;
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      _userId = user.id;
      _allBookings = await _bookingService.getUserBookings(user.id);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      setState(() {
        _upcomingBookings = _allBookings
            .where((b) => b.bookingDate.isAfter(today) || 
                         (b.bookingDate.year == today.year &&
                          b.bookingDate.month == today.month &&
                          b.bookingDate.day == today.day))
            .where((b) => b.status != BookingStatus.cancelled)
            .toList();

        _pastBookings = _allBookings
            .where((b) => b.bookingDate.isBefore(today))
            .toList();

        // カレンダー用に日付ごとにグループ化
        _bookingsByDate = {};
        for (var booking in _allBookings) {
          final date = DateTime(
            booking.bookingDate.year,
            booking.bookingDate.month,
            booking.bookingDate.day,
          );
          _bookingsByDate.putIfAbsent(date, () => []).add(booking);
        }
      });
    } catch (e) {
      debugPrint('予約読み込みエラー: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Booking> _getBookingsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _bookingsByDate[date] ?? [];
  }

  Future<void> _cancelBooking(Booking booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('予約キャンセル'),
        content: const Text('この予約をキャンセルしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('戻る'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _bookingService.cancelBooking(booking.id, 'ユーザーによるキャンセル');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('予約をキャンセルしました'),
            backgroundColor: Colors.red,
          ),
        );
        _loadBookings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('予約一覧'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'カレンダー'),
            Tab(text: '予約中 (${_upcomingBookings.length})'),
            Tab(text: '過去の予約 (${_pastBookings.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCalendarView(),
                _buildBookingList(_upcomingBookings, showCancelButton: true),
                _buildBookingList(_pastBookings),
              ],
            ),
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        TableCalendar(
          locale: 'ja_JP',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          eventLoader: _getBookingsForDay,
          calendarStyle: CalendarStyle(
            markersMaxCount: 3,
            markerDecoration: BoxDecoration(
              color: Colors.blue[700],
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.blue[300],
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blue[700],
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _buildBookingList(
            _selectedDay != null ? _getBookingsForDay(_selectedDay!) : [],
            showCancelButton: true,
            emptyMessage: _selectedDay != null
                ? '${DateFormat('yyyy/MM/dd').format(_selectedDay!)}の予約はありません'
                : '日付を選択してください',
          ),
        ),
      ],
    );
  }

  Widget _buildBookingList(
    List<Booking> bookings, {
    bool showCancelButton = false,
    String? emptyMessage,
  }) {
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
              emptyMessage ?? '予約がありません',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
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
          final booking = bookings[index];
          return _buildBookingCard(booking, showCancelButton: showCancelButton);
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, {bool showCancelButton = false}) {
    final dateFormat = DateFormat('yyyy/MM/dd (E)', 'ja_JP');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailScreen(booking: booking),
            ),
          ).then((_) => _loadBookings());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(booking.status).withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    booking.status.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.status.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(booking.status),
                          ),
                        ),
                        Text(
                          '予約ID: ${booking.id.substring(0, 8)}...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 本文
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // スタッフ情報
                  Row(
                    children: [
                      const Icon(Icons.person, size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
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
                            Text(
                              booking.staffJobTitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // 予約日時
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        '${dateFormat.format(booking.bookingDate)} ${booking.bookingTime}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // メニュー
                  const Text(
                    '選択メニュー',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...booking.menus.map((menu) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '• ${menu.name} (${menu.duration}分)',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              '¥${menu.price}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      )),

                  const Divider(height: 24),

                  // 料金
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '最終金額',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '¥${booking.finalPrice}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  // キャンセルボタン
                  if (showCancelButton &&
                      booking.status == BookingStatus.pending) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _cancelBooking(booking),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('予約をキャンセル'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }
}
