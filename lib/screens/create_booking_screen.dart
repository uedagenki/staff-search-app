import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../models/coupon.dart';
import '../models/service_menu.dart';
import '../models/staff.dart';
import '../services/local_booking_service.dart';
import '../services/local_auth_service.dart';

/// ユーザー側：予約作成画面
class CreateBookingScreen extends StatefulWidget {
  final Staff staff;

  const CreateBookingScreen({
    super.key,
    required this.staff,
  });

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _bookingService = LocalBookingService();
  final _authService = LocalAuthService();
  final _noteController = TextEditingController();

  List<ServiceMenu> _menus = [];
  List<Coupon> _availableCoupons = [];
  List<ServiceMenu> _selectedMenus = [];
  Coupon? _selectedCoupon;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  bool _isLoading = true;

  final List<String> _availableTimes = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
    '18:00', '18:30', '19:00', '19:30', '20:00',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // メニューとクーポンを読み込み
      _menus = await _bookingService.getStaffMenus(widget.staff.id);
      _availableCoupons = await _bookingService.getValidCoupons(widget.staff.id);

      // デモデータがない場合は作成
      if (_menus.isEmpty) {
        await _bookingService.createDemoMenus(widget.staff.id, widget.staff.name);
        _menus = await _bookingService.getStaffMenus(widget.staff.id);
      }

      setState(() {});
    } catch (e) {
      debugPrint('データ読み込みエラー: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int _calculateTotalPrice() {
    return _selectedMenus.fold(0, (sum, menu) => sum + menu.price);
  }

  int _calculateDiscount() {
    if (_selectedCoupon == null) return 0;
    return _selectedCoupon!.calculateDiscount(_calculateTotalPrice());
  }

  int _calculateFinalPrice() {
    return _calculateTotalPrice() - _calculateDiscount();
  }

  String _formatPrice(int price) {
    final formatter = NumberFormat('#,###');
    return formatter.format(price);
  }

  Future<void> _handleSubmit() async {
    // バリデーション
    if (_selectedMenus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('メニューを選択してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('予約時間を選択してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ユーザー情報取得
    final user = await _authService.getCurrentUser();
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ログインしてください'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 予約作成
    final booking = Booking(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      userName: user.name,
      userEmail: user.email,
      userPhone: user.phoneNumber,
      staffId: widget.staff.id,
      staffName: widget.staff.name,
      staffJobTitle: widget.staff.jobTitle,
      storeName: widget.staff.storeName,
      storeAddress: widget.staff.location,
      bookingDate: _selectedDate,
      bookingTime: _selectedTime!,
      menus: _selectedMenus
          .map((m) => BookingMenu(
                id: m.id,
                name: m.name,
                price: m.price,
                duration: m.duration,
              ))
          .toList(),
      couponId: _selectedCoupon?.id,
      totalPrice: _calculateTotalPrice(),
      discountAmount: _calculateDiscount(),
      finalPrice: _calculateFinalPrice(),
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );

    try {
      await _bookingService.createBooking(booking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('予約を申し込みました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('予約に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('予約する'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // スタッフ情報
                      _buildStaffInfo(),

                      const SizedBox(height: 24),

                      // メニュー選択
                      _buildMenuSelection(),

                      const SizedBox(height: 24),

                      // 日時選択
                      _buildDateTimeSelection(),

                      const SizedBox(height: 24),

                      // クーポン選択
                      if (_availableCoupons.isNotEmpty)
                        _buildCouponSelection(),

                      const SizedBox(height: 24),

                      // 備考
                      _buildNoteInput(),

                      const SizedBox(height: 24),

                      // 料金サマリー
                      _buildPriceSummary(),
                    ],
                  ),
                ),

                // 予約ボタン
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _selectedMenus.isEmpty || _selectedTime == null
                            ? null
                            : _handleSubmit,
                        child: Text(
                          '予約を確定する（¥${_calculateFinalPrice()}}）',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStaffInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                widget.staff.name[0],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.staff.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.staff.jobTitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (widget.staff.storeName != null)
                    Text(
                      widget.staff.storeName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'メニュー選択',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._menus.map((menu) {
          final isSelected = _selectedMenus.contains(menu);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isSelected ? Colors.blue.shade50 : null,
            child: CheckboxListTile(
              value: isSelected,
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    _selectedMenus.add(menu);
                  } else {
                    _selectedMenus.remove(menu);
                  }
                });
              },
              title: Text(menu.name),
              subtitle: Text(
                '${menu.description}\n所要時間: ${menu.duration}分',
              ),
              secondary: Text(
                '¥${menu.price}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDateTimeSelection() {
    final dateFormat = DateFormat('yyyy年MM月dd日 (E)', 'ja_JP');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '日時選択',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // 日付選択
        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.blue),
            title: const Text('予約日'),
            subtitle: Text(dateFormat.format(_selectedDate)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
          ),
        ),

        const SizedBox(height: 12),

        // 時間選択
        const Text(
          '予約時間',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTimes.map((time) {
            final isSelected = _selectedTime == time;
            return ChoiceChip(
              label: Text(time),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedTime = selected ? time : null);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCouponSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'クーポン選択',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...(_availableCoupons.isEmpty
            ? [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '利用可能なクーポンがありません',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              ]
            : [
                ..._availableCoupons.map((coupon) {
                  final isSelected = _selectedCoupon?.id == coupon.id;
                  final canUse = coupon.minPrice == null ||
                      _calculateTotalPrice() >= coupon.minPrice!;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isSelected ? Colors.orange.shade50 : null,
                    child: ListTile(
                      enabled: canUse,
                      leading: Icon(
                        Icons.local_offer,
                        color: canUse ? Colors.orange : Colors.grey,
                      ),
                      title: Text(
                        coupon.title,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        '${coupon.type.formatDiscount(coupon.discountValue)}\n${coupon.description}',
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.orange)
                          : null,
                      onTap: canUse
                          ? () {
                              setState(() {
                                _selectedCoupon =
                                    isSelected ? null : coupon;
                              });
                            }
                          : null,
                    ),
                  );
                }),
              ]),
      ],
    );
  }

  Widget _buildNoteInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '備考・要望',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          decoration: const InputDecoration(
            hintText: '例: アレルギーがあります、駐車場を利用したいです',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    final totalPrice = _calculateTotalPrice();
    final discount = _calculateDiscount();
    final finalPrice = _calculateFinalPrice();

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '料金',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('合計金額'),
                Text(
                  '¥${totalPrice}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            if (discount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'クーポン割引',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  Text(
                    '-¥${discount}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'お支払い金額',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '¥${finalPrice}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
