import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';

class CouponManagementScreen extends StatefulWidget {
  const CouponManagementScreen({super.key});

  @override
  State<CouponManagementScreen> createState() => _CouponManagementScreenState();
}

class _CouponManagementScreenState extends State<CouponManagementScreen> {
  List<Map<String, dynamic>> _coupons = [];

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  void _loadCoupons() {
    try {
      final couponsJson = html.window.localStorage['staff_coupons'];
      if (couponsJson != null && couponsJson.isNotEmpty) {
        final coupons = jsonDecode(couponsJson) as List;
        setState(() {
          _coupons = coupons.map((c) => Map<String, dynamic>.from(c)).toList();
          // 有効期限順にソート
          _coupons.sort((a, b) {
            final aDate = DateTime.parse(a['expiryDate'] ?? '2099-12-31');
            final bDate = DateTime.parse(b['expiryDate'] ?? '2099-12-31');
            return aDate.compareTo(bDate);
          });
        });
      }
    } catch (e) {
      debugPrint('クーポンデータの読み込みエラー: $e');
    }
  }

  void _saveCoupons() {
    try {
      html.window.localStorage['staff_coupons'] = jsonEncode(_coupons);

      // staff_profileにも追加
      final profileJson = html.window.localStorage['staff_profile'];
      if (profileJson != null) {
        final profile = jsonDecode(profileJson) as Map<String, dynamic>;
        profile['coupons'] = _coupons;
        html.window.localStorage['staff_profile'] = jsonEncode(profile);

        // all_staff_listも更新
        _updateAllStaffList(profile);
      }
    } catch (e) {
      debugPrint('クーポン保存エラー: $e');
    }
  }

  void _updateAllStaffList(Map<String, dynamic> profile) {
    try {
      final allStaffJson = html.window.localStorage['all_staff_list'];
      List<dynamic> allStaff = [];
      if (allStaffJson != null && allStaffJson.isNotEmpty) {
        allStaff = jsonDecode(allStaffJson) as List;
      }

      final email = profile['email'];
      final existingIndex = allStaff.indexWhere((s) => s['email'] == email);
      
      if (existingIndex != -1) {
        allStaff[existingIndex]['coupons'] = profile['coupons'];
        html.window.localStorage['all_staff_list'] = jsonEncode(allStaff);
      }
    } catch (e) {
      debugPrint('all_staff_list更新エラー: $e');
    }
  }

  void _addCoupon() {
    showDialog(
      context: context,
      builder: (context) => _CouponDialog(
        onSave: (coupon) {
          setState(() {
            _coupons.add(coupon);
          });
          _saveCoupons();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('クーポンを作成しました'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _editCoupon(int index) {
    showDialog(
      context: context,
      builder: (context) => _CouponDialog(
        initialCoupon: _coupons[index],
        onSave: (coupon) {
          setState(() {
            _coupons[index] = coupon;
          });
          _saveCoupons();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('クーポンを更新しました'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _deleteCoupon(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('クーポンを削除'),
        content: const Text('このクーポンを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _coupons.removeAt(index);
              });
              _saveCoupons();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('クーポンを削除しました'),
                ),
              );
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleCouponStatus(int index) {
    setState(() {
      _coupons[index]['isActive'] = !(_coupons[index]['isActive'] ?? true);
    });
    _saveCoupons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('クーポン管理'),
        actions: [
          IconButton(
            onPressed: _addCoupon,
            icon: const Icon(Icons.add),
            tooltip: '新規クーポン作成',
          ),
        ],
      ),
      body: _coupons.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'クーポンはまだありません',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addCoupon,
                    icon: const Icon(Icons.add),
                    label: const Text('クーポンを作成'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _coupons.length,
              itemBuilder: (context, index) {
                final coupon = _coupons[index];
                final isExpired = _isExpired(coupon['expiryDate']);
                final isActive = coupon['isActive'] ?? true;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isActive && !isExpired
                                  ? [Colors.orange, Colors.deepOrange]
                                  : [Colors.grey.shade400, Colors.grey.shade600],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              _getDiscountText(coupon),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        title: Text(
                          coupon['title'] ?? '無題のクーポン',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isExpired || !isActive ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            if (coupon['description'] != null && coupon['description'].isNotEmpty)
                              Text(
                                coupon['description'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  isExpired ? Icons.event_busy : Icons.event,
                                  size: 14,
                                  color: isExpired ? Colors.red : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '〜${_formatDate(coupon['expiryDate'])}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isExpired ? Colors.red : Colors.grey,
                                  ),
                                ),
                                if (isExpired) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '期限切れ',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                if (!isActive) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '停止中',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (coupon['minPurchase'] != null && coupon['minPurchase'] > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                '最低利用金額: ¥${coupon['minPurchase']}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _editCoupon(index);
                                break;
                              case 'toggle':
                                _toggleCouponStatus(index);
                                break;
                              case 'delete':
                                _deleteCoupon(index);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('編集'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'toggle',
                              child: Row(
                                children: [
                                  Icon(
                                    isActive ? Icons.pause : Icons.play_arrow,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(isActive ? '停止' : '再開'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('削除', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: _coupons.isNotEmpty
          ? FloatingActionButton(
              onPressed: _addCoupon,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  String _getDiscountText(Map<String, dynamic> coupon) {
    final type = coupon['discountType'] ?? 'percentage';
    final value = coupon['discountValue'] ?? 0;
    
    if (type == 'percentage') {
      return '$value%\nOFF';
    } else {
      return '¥$value\nOFF';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '未設定';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}/${date.month}/${date.day}';
    } catch (e) {
      return dateStr;
    }
  }

  bool _isExpired(String? dateStr) {
    if (dateStr == null) return false;
    try {
      final expiryDate = DateTime.parse(dateStr);
      return expiryDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }
}

// クーポン作成・編集ダイアログ
class _CouponDialog extends StatefulWidget {
  final Map<String, dynamic>? initialCoupon;
  final Function(Map<String, dynamic>) onSave;

  const _CouponDialog({
    this.initialCoupon,
    required this.onSave,
  });

  @override
  State<_CouponDialog> createState() => _CouponDialogState();
}

class _CouponDialogState extends State<_CouponDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _discountValueController;
  late TextEditingController _minPurchaseController;
  late TextEditingController _maxDiscountController;
  String _discountType = 'percentage'; // 'percentage' or 'fixed'
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    final coupon = widget.initialCoupon;
    _titleController = TextEditingController(text: coupon?['title'] ?? '');
    _descriptionController = TextEditingController(text: coupon?['description'] ?? '');
    _discountValueController = TextEditingController(
      text: (coupon?['discountValue'] ?? '').toString(),
    );
    _minPurchaseController = TextEditingController(
      text: (coupon?['minPurchase'] ?? '').toString(),
    );
    _maxDiscountController = TextEditingController(
      text: (coupon?['maxDiscount'] ?? '').toString(),
    );
    _discountType = coupon?['discountType'] ?? 'percentage';
    if (coupon?['expiryDate'] != null) {
      _expiryDate = DateTime.parse(coupon!['expiryDate']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialCoupon == null ? 'クーポンを作成' : 'クーポンを編集'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'クーポン名',
                border: OutlineInputBorder(),
                hintText: '例: 新規会員限定10%OFF',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '説明',
                border: OutlineInputBorder(),
                hintText: '例: 初回利用時に使えるお得なクーポン',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            const Text(
              '割引タイプ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'percentage',
                  label: Text('割引率(%)'),
                  icon: Icon(Icons.percent),
                ),
                ButtonSegment(
                  value: 'fixed',
                  label: Text('固定額(円)'),
                  icon: Icon(Icons.attach_money),
                ),
              ],
              selected: {_discountType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _discountType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _discountValueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _discountType == 'percentage' ? '割引率' : '割引額',
                border: const OutlineInputBorder(),
                suffixText: _discountType == 'percentage' ? '%' : '円',
                hintText: _discountType == 'percentage' ? '例: 10' : '例: 500',
              ),
            ),
            const SizedBox(height: 12),
            if (_discountType == 'percentage') ...[
              TextField(
                controller: _maxDiscountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '最大割引額（オプション）',
                  border: OutlineInputBorder(),
                  suffixText: '円',
                  hintText: '例: 1000',
                  helperText: '割引率の上限額を設定',
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _minPurchaseController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '最低利用金額（オプション）',
                border: OutlineInputBorder(),
                suffixText: '円',
                hintText: '例: 3000',
                helperText: 'クーポン利用の条件',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '有効期限',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _expiryDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (pickedDate != null) {
                  setState(() {
                    _expiryDate = pickedDate;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(
                      '${_expiryDate.year}/${_expiryDate.month}/${_expiryDate.day}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            final discountValue = int.tryParse(_discountValueController.text) ?? 0;
            if (_titleController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('クーポン名を入力してください')),
              );
              return;
            }
            if (discountValue <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('割引額を入力してください')),
              );
              return;
            }
            if (_discountType == 'percentage' && discountValue > 100) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('割引率は100%以下で設定してください')),
              );
              return;
            }

            final coupon = {
              'id': widget.initialCoupon?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
              'title': _titleController.text,
              'description': _descriptionController.text,
              'discountType': _discountType,
              'discountValue': discountValue,
              'minPurchase': int.tryParse(_minPurchaseController.text) ?? 0,
              'maxDiscount': _discountType == 'percentage' 
                  ? (int.tryParse(_maxDiscountController.text) ?? 0)
                  : 0,
              'expiryDate': _expiryDate.toIso8601String(),
              'isActive': widget.initialCoupon?['isActive'] ?? true,
              'createdAt': widget.initialCoupon?['createdAt'] ?? DateTime.now().toIso8601String(),
            };
            widget.onSave(coupon);
            Navigator.pop(context);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountValueController.dispose();
    _minPurchaseController.dispose();
    _maxDiscountController.dispose();
    super.dispose();
  }
}
