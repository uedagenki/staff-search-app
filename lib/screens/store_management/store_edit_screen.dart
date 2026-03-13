import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/company.dart';
import '../../services/company_service.dart';

/// 店舗プロフィール編集画面
class StoreEditScreen extends StatefulWidget {
  final Company company;

  const StoreEditScreen({
    super.key,
    required this.company,
  });

  @override
  State<StoreEditScreen> createState() => _StoreEditScreenState();
}

class _StoreEditScreenState extends State<StoreEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final CompanyService _companyService = CompanyService();

  // テキストコントローラー
  late TextEditingController _storeNameController;
  late TextEditingController _industryController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _contactEmailController;
  late TextEditingController _contactPersonController;
  late TextEditingController _employeeCountController;
  late TextEditingController _benefitsController;
  late TextEditingController _tipCommissionRateController;

  bool _isLoading = false;
  DateTime? _establishedDate;

  // 店舗タイプリスト
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
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _storeNameController = TextEditingController(text: widget.company.name);
    _industryController = TextEditingController(text: widget.company.industry);
    _descriptionController = TextEditingController(text: widget.company.description);
    _addressController = TextEditingController(text: widget.company.address);
    _phoneController = TextEditingController(text: widget.company.phoneNumber ?? '');
    _websiteController = TextEditingController(text: widget.company.website ?? '');
    _contactEmailController = TextEditingController(text: widget.company.contactEmail);
    _contactPersonController = TextEditingController(text: widget.company.contactPerson);
    _employeeCountController = TextEditingController(text: widget.company.employeeCount.toString());
    _benefitsController = TextEditingController(text: widget.company.benefits.join(', '));
    _tipCommissionRateController = TextEditingController(
      text: (widget.company.tipCommissionRate * 100).toStringAsFixed(1),
    );
    _establishedDate = widget.company.establishedDate;
  }

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
      locale: const Locale('ja', 'JP'),
    );

    if (picked != null) {
      setState(() {
        _establishedDate = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_establishedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('開業日を選択してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 特典リストをパース
      final benefitsList = _benefitsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // 還元率をパース（0-100% → 0.0-1.0）
      final tipRate = double.tryParse(_tipCommissionRateController.text) ?? 10.0;
      final normalizedRate = (tipRate / 100).clamp(0.0, 1.0);

      // 更新された企業情報を作成
      final updatedCompany = widget.company.copyWith(
        name: _storeNameController.text.trim(),
        industry: _industryController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        contactEmail: _contactEmailController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        employeeCount: int.tryParse(_employeeCountController.text) ?? 0,
        establishedDate: _establishedDate,
        benefits: benefitsList,
        tipCommissionRate: normalizedRate,
      );

      await _companyService.updateCompany(updatedCompany);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('店舗情報を更新しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('店舗情報編集'),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _handleSave,
              child: const Text(
                '保存',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 基本情報セクション
                  _buildSectionHeader('基本情報'),
                  const SizedBox(height: 12),

                  // 店舗名
                  TextFormField(
                    controller: _storeNameController,
                    decoration: const InputDecoration(
                      labelText: '店舗名 *',
                      prefixIcon: Icon(Icons.store),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '店舗名を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 業種
                  DropdownButtonFormField<String>(
                    value: _storeTypes.contains(_industryController.text)
                        ? _industryController.text
                        : null,
                    decoration: const InputDecoration(
                      labelText: '業種 *',
                      prefixIcon: Icon(Icons.business),
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

                  // 店舗説明
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '店舗説明 *',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                      hintText: '店舗の特徴やアピールポイントを入力',
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '店舗説明を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 連絡先情報セクション
                  _buildSectionHeader('連絡先情報'),
                  const SizedBox(height: 12),

                  // 住所
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: '住所 *',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '住所を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 電話番号
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: '電話番号',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                      hintText: '例: 03-1234-5678',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // ウェブサイト
                  TextFormField(
                    controller: _websiteController,
                    decoration: const InputDecoration(
                      labelText: 'ウェブサイト',
                      prefixIcon: Icon(Icons.language),
                      border: OutlineInputBorder(),
                      hintText: 'https://example.com',
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),

                  // 連絡先メールアドレス
                  TextFormField(
                    controller: _contactEmailController,
                    decoration: const InputDecoration(
                      labelText: '連絡先メールアドレス *',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'メールアドレスを入力してください';
                      }
                      if (!value.contains('@')) {
                        return '有効なメールアドレスを入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 連絡担当者
                  TextFormField(
                    controller: _contactPersonController,
                    decoration: const InputDecoration(
                      labelText: '連絡担当者 *',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '連絡担当者を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 詳細情報セクション
                  _buildSectionHeader('詳細情報'),
                  const SizedBox(height: 12),

                  // 従業員数
                  TextFormField(
                    controller: _employeeCountController,
                    decoration: const InputDecoration(
                      labelText: '従業員数 *',
                      prefixIcon: Icon(Icons.people),
                      border: OutlineInputBorder(),
                      suffixText: '人',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '従業員数を入力してください';
                      }
                      if (int.tryParse(value) == null) {
                        return '数値を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 開業日
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
                            : DateFormat('yyyy年MM月dd日', 'ja_JP').format(_establishedDate!),
                        style: TextStyle(
                          color: _establishedDate == null ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 特典・福利厚生
                  TextFormField(
                    controller: _benefitsController,
                    decoration: const InputDecoration(
                      labelText: '特典・福利厚生',
                      prefixIcon: Icon(Icons.card_giftcard),
                      border: OutlineInputBorder(),
                      hintText: '例: 交通費支給, まかない付き, 社割あり（カンマ区切り）',
                      helperText: '複数の特典はカンマ（,）で区切ってください',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // スタッフ還元率
                  TextFormField(
                    controller: _tipCommissionRateController,
                    decoration: const InputDecoration(
                      labelText: 'スタッフ還元率 *',
                      prefixIcon: Icon(Icons.monetization_on),
                      border: OutlineInputBorder(),
                      suffixText: '%',
                      helperText: '店舗がスタッフから受け取る還元率（0〜100%）',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '還元率を入力してください';
                      }
                      final rate = double.tryParse(value);
                      if (rate == null || rate < 0 || rate > 100) {
                        return '0〜100の範囲で入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // 保存ボタン
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      child: const Text(
                        '保存',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }
}
