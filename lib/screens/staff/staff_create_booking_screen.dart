import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/booking.dart';
import '../../models/service_menu.dart';
import '../../models/coupon.dart';
import '../../services/local_booking_service.dart';
import '../../services/local_auth_service.dart';

/// スタッフ側：予約作成画面（お客様情報入力）
class StaffCreateBookingScreen extends StatefulWidget {
  const StaffCreateBookingScreen({super.key});

  @override
  State<StaffCreateBookingScreen> createState() => _StaffCreateBookingScreenState();
}

class _StaffCreateBookingScreenState extends State<StaffCreateBookingScreen> {
  final _bookingService = LocalBookingService();
  final _authService = LocalAuthService();
  final _formKey = GlobalKey<FormState>();
  
  // お客様情報
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();

  List<ServiceMenu> _menus = [];
  List<Coupon> _availableCoupons = [];
  List<ServiceMenu> _selectedMenus = [];
  Coupon? _selectedCoupon;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  bool _isLoading = true;
  String? _staffId;
  String? _staffName;

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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // スタッフ情報取得
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      _staffId = user.id;
      _staffName = user.name;

      // メニューとクーポンを読み込み
      _menus = await _bookingService.getStaffMenus(user.id);
      _availableCoupons = await _bookingService.getValidCoupons(user.id);

      // デモメニューがない場合は作成
      if (_menus.isEmpty) {
        await _bookingService.createDemoMenus(user.id, user.name);
        _menus = await _bookingService.getStaffMenus(user.id);
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

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

    if (_staffId == null || _staffName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('スタッフ情報の取得に失敗しました'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 予約作成（スタッフが代理で作成するので、userIdは仮のものを使用）
    final booking = Booking(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'walk_in_${DateTime.now().millisecondsSinceEpoch}', // 来店客用ID
      userName: _nameController.text.trim(),
      userEmail: _emailController.text.trim(),
      userPhone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      staffId: _staffId!,
      staffName: _staffName!,
      staffJobTitle: 'スタッフ',
      storeName: null,
      storeAddress: null,
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
      status: BookingStatus.confirmed, // スタッフが作成するので即確定
      createdAt: DateTime.now(),
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );

    try {
      await _bookingService.createBooking(booking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('予約を作成しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('予約の作成に失敗しました: $e'),
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
        title: const Text('予約作成'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // お客様情報
                        _buildCustomerInfo(),
                        const SizedBox(height: 24),

                        // メニュー選択
                        _buildMenuSelection(),
                        const SizedBox(height: 24),

                        // 日時選択
                        _buildDateTimeSelection(),
                        const SizedBox(height: 24),

                        // クーポン選択
                        _buildCouponSelection(),
                        const SizedBox(height: 24),

                        // 備考
                        _buildNoteSection(),
                        const SizedBox(height: 24),

                        // 料金表示
                        _buildPriceSummary(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),

                // 予約確定ボタン
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _selectedMenus.isEmpty || _selectedTime == null
                              ? null
                              : _handleSubmit,
                          child: Text(
                            '予約を確定する（¥${_formatPrice(_calculateFinalPrice())}）',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildCustomerInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'お客様情報',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // お名前
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'お名前',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'お名前を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // メールアドレス
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'メールアドレスを入力してください';
                }
                if (!value.contains('@')) {
                  return '正しいメールアドレスを入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 電話番号（任意）
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '電話番号（任意）',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'メニュー選択',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            if (_menus.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('メニューがありません'),
                ),
              )
            else
              ..._menus.map((menu) {
                final isSelected = _selectedMenus.contains(menu);
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
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
                    '¥${_formatPrice(menu.price)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelection() {
    final dateFormat = DateFormat('yyyy年MM月dd日 (E)', 'ja_JP');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  '日時選択',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // 日付選択
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('予約日'),
              subtitle: Text(dateFormat.format(_selectedDate)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                  locale: const Locale('ja', 'JP'),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),

            const Divider(),

            // 時間選択
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '予約時間',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTimes.map((time) {
                final isSelected = _selectedTime == time;
                return FilterChip(
                  label: Text(time),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTime = selected ? time : null;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_offer, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'クーポン',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            if (_availableCoupons.isEmpty)
              const Text('利用可能なクーポンがありません')
            else
              DropdownButtonFormField<Coupon>(
                value: _selectedCoupon,
                decoration: const InputDecoration(
                  labelText: 'クーポンを選択',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<Coupon>(
                    value: null,
                    child: Text('クーポンを使用しない'),
                  ),
                  ..._availableCoupons.map((coupon) {
                    return DropdownMenuItem<Coupon>(
                      value: coupon,
                      child: Text(
                        '${coupon.title} - ${coupon.type == CouponType.percentage ? '${coupon.discountValue}%OFF' : '¥${coupon.discountValue}OFF'}',
                      ),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCoupon = value;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notes, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  '備考',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: '備考やご要望があれば入力してください',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    final totalPrice = _calculateTotalPrice();
    final discount = _calculateDiscount();
    final finalPrice = _calculateFinalPrice();

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  '料金',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('合計金額'),
                Text(
                  '¥${_formatPrice(totalPrice)}',
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
                    '-¥${_formatPrice(discount)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
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
                  '最終金額',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '¥${_formatPrice(finalPrice)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
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
