import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking.dart';
import '../../services/local_booking_service.dart';
import '../../services/local_auth_service.dart';
import 'staff_create_booking_screen.dart';

/// スタッフ側：予約管理画面
class StaffBookingManagementScreen extends StatefulWidget {
  const StaffBookingManagementScreen({super.key});

  @override
  State<StaffBookingManagementScreen> createState() =>
      _StaffBookingManagementScreenState();
}

class _StaffBookingManagementScreenState
    extends State<StaffBookingManagementScreen> with SingleTickerProviderStateMixin {
  final _bookingService = LocalBookingService();
  final _authService = LocalAuthService();
  
  late TabController _tabController;
  List<Booking> _allBookings = [];
  List<Booking> _pendingBookings = [];
  List<Booking> _confirmedBookings = [];
  List<Booking> _completedBookings = [];
  List<Booking> _cancelledBookings = [];
  bool _isLoading = true;
  String? _staffId;

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
    setState(() => _isLoading = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      _staffId = user.id;
      _allBookings = await _bookingService.getStaffBookings(user.id);

      setState(() {
        _pendingBookings = _allBookings
            .where((b) => b.status == BookingStatus.pending)
            .toList();
        _confirmedBookings = _allBookings
            .where((b) => b.status == BookingStatus.confirmed)
            .toList();
        _completedBookings = _allBookings
            .where((b) => b.status == BookingStatus.completed)
            .toList();
        _cancelledBookings = _allBookings
            .where((b) => b.status == BookingStatus.cancelled)
            .toList();
      });
    } catch (e) {
      debugPrint('予約読み込みエラー: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmBooking(Booking booking) async {
    await _bookingService.confirmBooking(booking.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('予約を確定しました'),
          backgroundColor: Colors.green,
        ),
      );
      _loadBookings();
    }
  }

  Future<void> _completeBooking(Booking booking) async {
    await _bookingService.completeBooking(booking.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('予約を完了しました'),
          backgroundColor: Colors.blue,
        ),
      );
      _loadBookings();
    }
  }

  Future<void> _cancelBooking(Booking booking) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _CancelReasonDialog(),
    );

    if (reason != null && reason.isNotEmpty) {
      await _bookingService.cancelBooking(booking.id, reason);
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

  Future<void> _createBooking() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StaffCreateBookingScreen(),
      ),
    ).then((_) => _loadBookings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('予約管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createBooking,
            tooltip: '予約作成',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('確認待ち'),
                  if (_pendingBookings.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_pendingBookings.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(text: '確定 (${_confirmedBookings.length})'),
            Tab(text: '完了 (${_completedBookings.length})'),
            Tab(text: 'キャンセル (${_cancelledBookings.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(_pendingBookings, showActions: true),
                _buildBookingList(_confirmedBookings, showCompleteAction: true),
                _buildBookingList(_completedBookings),
                _buildBookingList(_cancelledBookings),
              ],
            ),
    );
  }

  Widget _buildBookingList(
    List<Booking> bookings, {
    bool showActions = false,
    bool showCompleteAction = false,
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

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(
            booking,
            showActions: showActions,
            showCompleteAction: showCompleteAction,
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(
    Booking booking, {
    bool showActions = false,
    bool showCompleteAction = false,
  }) {
    final dateFormat = DateFormat('yyyy/MM/dd (E)', 'ja_JP');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                // 予約者情報
                Row(
                  children: [
                    const Icon(Icons.person, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            booking.userEmail,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (booking.userPhone != null)
                            Text(
                              booking.userPhone!,
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
                      '合計金額',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '¥${booking.totalPrice}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                if (booking.discountAmount > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'クーポン割引',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red[700],
                        ),
                      ),
                      Text(
                        '-¥${booking.discountAmount}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
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

                // 備考
                if (booking.note != null && booking.note!.isNotEmpty) ...[
                  const Divider(height: 24),
                  const Text(
                    '備考',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    booking.note!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],

                // キャンセル理由
                if (booking.status == BookingStatus.cancelled &&
                    booking.cancellationReason != null) ...[
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'キャンセル理由',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                booking.cancellationReason!,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // アクションボタン
                if (showActions || showCompleteAction) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (showActions) ...[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _confirmBooking(booking),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('予約確定'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _cancelBooking(booking),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('キャンセル'),
                          ),
                        ),
                      ],
                      if (showCompleteAction) ...[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _completeBooking(booking),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('完了にする'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _cancelBooking(booking),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('キャンセル'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
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

/// キャンセル理由入力ダイアログ
class _CancelReasonDialog extends StatefulWidget {
  @override
  State<_CancelReasonDialog> createState() => _CancelReasonDialogState();
}

class _CancelReasonDialogState extends State<_CancelReasonDialog> {
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
