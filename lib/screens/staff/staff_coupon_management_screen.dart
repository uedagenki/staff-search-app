import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/coupon.dart';
import '../../services/local_booking_service.dart';
import '../../services/local_auth_service.dart';

/// スタッフ側：クーポン管理画面
class StaffCouponManagementScreen extends StatefulWidget {
  const StaffCouponManagementScreen({super.key});

  @override
  State<StaffCouponManagementScreen> createState() =>
      _StaffCouponManagementScreenState();
}

class _StaffCouponManagementScreenState
    extends State<StaffCouponManagementScreen> {
  final _bookingService = LocalBookingService();
  final _authService = LocalAuthService();
  
  List<Coupon> _coupons = [];
  bool _isLoading = true;
  String? _staffId;
  String? _staffName;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      _staffId = user.id;
      _staffName = user.name;
      _coupons = await _bookingService.getStaffCoupons(user.id);
      
      // デモクーポンがない場合は作成
      if (_coupons.isEmpty) {
        await _bookingService.createDemoCoupons(user.id, user.name);
        _coupons = await _bookingService.getStaffCoupons(user.id);
      }

      setState(() {});
    } catch (e) {
      debugPrint('クーポン読み込みエラー: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createCoupon() async {
    if (_staffId == null || _staffName == null) return;

    final result = await Navigator.push<Coupon>(
      context,
      MaterialPageRoute(
        builder: (context) => _CreateCouponScreen(
          staffId: _staffId!,
          staffName: _staffName!,
        ),
      ),
    );

    if (result != null) {
      await _bookingService.createCoupon(result);
      _loadCoupons();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('クーポンを作成しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _toggleCouponActive(Coupon coupon) async {
    final updated = coupon.copyWith(isActive: !coupon.isActive);
    await _bookingService.updateCoupon(updated);
    _loadCoupons();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            coupon.isActive ? 'クーポンを無効にしました' : 'クーポンを有効にしました',
          ),
          backgroundColor: coupon.isActive ? Colors.orange : Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteCoupon(Coupon coupon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('クーポン削除'),
        content: Text('「${coupon.title}」を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _bookingService.deleteCoupon(coupon.id);
      _loadCoupons();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('クーポンを削除しました'),
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
        title: const Text('クーポン管理'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _coupons.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadCoupons,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _coupons.length,
                    itemBuilder: (context, index) {
                      return _buildCouponCard(_coupons[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCoupon,
        icon: const Icon(Icons.add),
        label: const Text('クーポン作成'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'クーポンがありません',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createCoupon,
            icon: const Icon(Icons.add),
            label: const Text('最初のクーポンを作成'),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    final dateFormat = DateFormat('yyyy/MM/dd');
    final isValid = coupon.isValid();
    final isExpired = DateTime.now().isAfter(coupon.validUntil);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isValid
                    ? [Colors.orange.shade400, Colors.red.shade400]
                    : [Colors.grey.shade300, Colors.grey.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    coupon.type.formatDiscount(coupon.discountValue),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isValid ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    coupon.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // ステータスバッジ
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(coupon, isExpired),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(coupon, isExpired),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
                // 説明
                Text(
                  coupon.description,
                  style: const TextStyle(fontSize: 14),
                ),
                
                const Divider(height: 24),

                // 詳細情報
                _buildInfoRow(
                  Icons.calendar_today,
                  '有効期限',
                  '${dateFormat.format(coupon.validFrom)} 〜 ${dateFormat.format(coupon.validUntil)}',
                ),
                
                if (coupon.minPrice != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.money,
                    '最低利用金額',
                    '¥${coupon.minPrice!.toString()}',
                  ),
                ],

                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.confirmation_number,
                  '利用状況',
                  coupon.usageLimit != null
                      ? '${coupon.usedCount} / ${coupon.usageLimit} 回使用'
                      : '${coupon.usedCount} 回使用（無制限）',
                ),

                const SizedBox(height: 16),

                // アクションボタン
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _toggleCouponActive(coupon),
                        icon: Icon(
                          coupon.isActive ? Icons.pause : Icons.play_arrow,
                        ),
                        label: Text(
                          coupon.isActive ? '無効にする' : '有効にする',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: coupon.isActive
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _deleteCoupon(coupon),
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      tooltip: '削除',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(Coupon coupon, bool isExpired) {
    if (!coupon.isActive) return Colors.grey;
    if (isExpired) return Colors.red;
    if (coupon.usageLimit != null && coupon.usedCount >= coupon.usageLimit!) {
      return Colors.orange;
    }
    return Colors.green;
  }

  String _getStatusText(Coupon coupon, bool isExpired) {
    if (!coupon.isActive) return '無効';
    if (isExpired) return '期限切れ';
    if (coupon.usageLimit != null && coupon.usedCount >= coupon.usageLimit!) {
      return '利用上限';
    }
    return '有効';
  }
}

/// クーポン作成画面
class _CreateCouponScreen extends StatefulWidget {
  final String staffId;
  final String staffName;

  const _CreateCouponScreen({
    required this.staffId,
    required this.staffName,
  });

  @override
  State<_CreateCouponScreen> createState() => _CreateCouponScreenState();
}

class _CreateCouponScreenState extends State<_CreateCouponScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _usageLimitController = TextEditingController();
  
  CouponType _type = CouponType.fixedAmount;
  DateTime _validFrom = DateTime.now();
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountValueController.dispose();
    _minPriceController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final coupon = Coupon(
      id: '${widget.staffId}_coupon_${DateTime.now().millisecondsSinceEpoch}',
      staffId: widget.staffId,
      staffName: widget.staffName,
      title: _titleController.text,
      description: _descriptionController.text,
      type: _type,
      discountValue: int.parse(_discountValueController.text),
      minPrice: _minPriceController.text.isNotEmpty
          ? int.parse(_minPriceController.text)
          : null,
      validFrom: _validFrom,
      validUntil: _validUntil,
      usageLimit: _usageLimitController.text.isNotEmpty
          ? int.parse(_usageLimitController.text)
          : null,
      createdAt: DateTime.now(),
    );

    Navigator.pop(context, coupon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('クーポン作成'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // クーポン名
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'クーポン名',
                hintText: '例: 初回限定1000円OFF',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'クーポン名を入力してください';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 説明
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '説明',
                hintText: '例: 初めてのご利用で1000円割引',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '説明を入力してください';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 割引タイプ
            DropdownButtonFormField<CouponType>(
              value: _type,
              decoration: const InputDecoration(
                labelText: '割引タイプ',
                border: OutlineInputBorder(),
              ),
              items: CouponType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _type = value);
                }
              },
            ),

            const SizedBox(height: 16),

            // 割引額/割引率
            TextFormField(
              controller: _discountValueController,
              decoration: InputDecoration(
                labelText: _type == CouponType.fixedAmount
                    ? '割引額（円）'
                    : '割引率（%）',
                hintText: _type == CouponType.fixedAmount ? '1000' : '20',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '割引額/割引率を入力してください';
                }
                final intValue = int.tryParse(value);
                if (intValue == null || intValue <= 0) {
                  return '正の整数を入力してください';
                }
                if (_type == CouponType.percentage && intValue > 100) {
                  return '100以下の数値を入力してください';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 最低利用金額
            TextFormField(
              controller: _minPriceController,
              decoration: const InputDecoration(
                labelText: '最低利用金額（円）',
                hintText: '例: 3000（省略可）',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // 利用上限回数
            TextFormField(
              controller: _usageLimitController,
              decoration: const InputDecoration(
                labelText: '利用上限回数',
                hintText: '例: 100（省略可：無制限）',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            // 有効期限（開始）
            ListTile(
              title: const Text('有効期限（開始）'),
              subtitle: Text(
                DateFormat('yyyy/MM/dd').format(_validFrom),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _validFrom,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _validFrom = date);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),

            const SizedBox(height: 16),

            // 有効期限（終了）
            ListTile(
              title: const Text('有効期限（終了）'),
              subtitle: Text(
                DateFormat('yyyy/MM/dd').format(_validUntil),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _validUntil,
                  firstDate: _validFrom,
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _validUntil = date);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),

            const SizedBox(height: 24),

            // 作成ボタン
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                child: const Text(
                  'クーポンを作成',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
