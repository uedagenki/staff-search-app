import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/company.dart';
import '../../services/company_service.dart';

class StoreSignupScreen extends StatefulWidget {
  const StoreSignupScreen({super.key});

  @override
  State<StoreSignupScreen> createState() => _StoreSignupScreenState();
}

class _StoreSignupScreenState extends State<StoreSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyService = CompanyService();
  
  // フォームコントローラー
  final _storeNameController = TextEditingController();
  final _industryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _employeeCountController = TextEditingController();
  final _benefitsController = TextEditingController();
  final _tipCommissionRateController = TextEditingController(text: '10.0');
  
  bool _isLoading = false;
  DateTime? _establishedDate;
  
  final List<String> _storeTypes = [
    '飲食店',
    'カフェ',
    'バー',
    '居酒屋',
    '美容室',
    'エステサロン',
    'ネイルサロン',
    'マッサージ店',
    'ホテル',
    '小売店',
    'その他',
  ];
  
  @override
  void dispose() {
    _storeNameController.dispose();
    _industryController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _contactEmailController.dispose();
    _contactPersonController.dispose();
    _employeeCountController.dispose();
    _benefitsController.dispose();
    _tipCommissionRateController.dispose();
    super.dispose();
  }
  
  Future<void> _selectEstablishedDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _establishedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ja'),
    );
    
    if (picked != null) {
      setState(() {
        _establishedDate = picked;
      });
    }
  }
  
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_establishedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('開業日を選択してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 福利厚生をリストに変換
      final benefitsList = _benefitsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      
      // スタッフ還元率を計算（0.0〜1.0の範囲に正規化：店舗がスタッフから受け取る割合）
      final tipRate = (double.tryParse(_tipCommissionRateController.text) ?? 10.0) / 100.0;
      
      // 簡易的な位置情報（東京中心から±0.1度の範囲でランダム生成）
      final random = DateTime.now().millisecondsSinceEpoch % 1000 / 1000.0;
      final latitude = 35.6812 + (random - 0.5) * 0.2; // 東京駅周辺
      final longitude = 139.7671 + (random - 0.5) * 0.2;
      
      final store = Company(
        id: 'store_${DateTime.now().millisecondsSinceEpoch}',
        name: _storeNameController.text,
        industry: _industryController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
        website: _websiteController.text.isEmpty ? null : _websiteController.text,
        contactEmail: _contactEmailController.text,
        contactPerson: _contactPersonController.text,
        employeeCount: int.parse(_employeeCountController.text),
        establishedDate: _establishedDate!,
        benefits: benefitsList,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isStore: true, // 店舗として登録
        tipCommissionRate: tipRate,
        latitude: latitude,
        longitude: longitude,
      );
      
      await _companyService.createCompany(store);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('店舗登録が完了しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // 登録成功を通知
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('店舗登録エラー: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登録に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('店舗・会社登録'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ヘッダー
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[700]!, Colors.orange[500]!],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.store, color: Colors.white, size: 40),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '店舗アカウント登録',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'スタッフの働く場所を登録',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // 基本情報
                    const Text(
                      '基本情報',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _storeNameController,
                      decoration: const InputDecoration(
                        labelText: '店舗名 *',
                        prefixIcon: Icon(Icons.store),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '店舗名を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: _industryController.text.isEmpty ? null : _industryController.text,
                      decoration: const InputDecoration(
                        labelText: '業種 *',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: _storeTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _industryController.text = value;
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '業種を選択してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: '店舗説明 *',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '店舗説明を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // 連絡先情報
                    const Text(
                      '連絡先情報',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: '住所 *',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '住所を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: '電話番号',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(
                        labelText: 'ウェブサイト',
                        prefixIcon: Icon(Icons.language),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _contactEmailController,
                      decoration: const InputDecoration(
                        labelText: '担当者メールアドレス *',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'メールアドレスを入力してください';
                        }
                        if (!value.contains('@')) {
                          return '正しいメールアドレスを入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _contactPersonController,
                      decoration: const InputDecoration(
                        labelText: '担当者名 *',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '担当者名を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // 店舗詳細
                    const Text(
                      '店舗詳細',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _employeeCountController,
                      decoration: const InputDecoration(
                        labelText: 'スタッフ数 *',
                        prefixIcon: Icon(Icons.people),
                        border: OutlineInputBorder(),
                        suffixText: '名',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'スタッフ数を入力してください';
                        }
                        if (int.tryParse(value) == null) {
                          return '数値を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    InkWell(
                      onTap: _selectEstablishedDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '開業日 *',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _establishedDate == null
                              ? '選択してください'
                              : '${_establishedDate!.year}年${_establishedDate!.month}月${_establishedDate!.day}日',
                          style: TextStyle(
                            color: _establishedDate == null ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _tipCommissionRateController,
                      decoration: const InputDecoration(
                        labelText: 'スタッフ還元率 *',
                        prefixIcon: Icon(Icons.monetization_on),
                        border: OutlineInputBorder(),
                        suffixText: '%',
                        helperText: 'スタッフから店舗が受け取れる還元率（0〜100%）',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'スタッフ還元率を入力してください';
                        }
                        final rate = double.tryParse(value);
                        if (rate == null || rate < 0 || rate > 100) {
                          return '0〜100の範囲で入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _benefitsController,
                      decoration: const InputDecoration(
                        labelText: '福利厚生（カンマ区切り）',
                        prefixIcon: Icon(Icons.emoji_emotions),
                        border: OutlineInputBorder(),
                        hintText: '例: 社会保険完備, 交通費支給, まかない有',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    
                    // 登録ボタン
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '店舗登録',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 注意事項
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                '店舗登録について',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• 店舗アカウントは、スタッフの勤務先として表示されます\n'
                            '• チップ手数料は店舗の収益に影響します\n'
                            '• スタッフからの予約受付、レビュー管理が可能になります',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
