import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/company.dart';
import '../../services/company_service.dart';

/// 企業登録・編集画面
class CompanyRegistrationScreen extends StatefulWidget {
  final Company? company; // 編集の場合は既存の企業データ

  const CompanyRegistrationScreen({
    super.key,
    this.company,
  });

  @override
  State<CompanyRegistrationScreen> createState() => _CompanyRegistrationScreenState();
}

class _CompanyRegistrationScreenState extends State<CompanyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyService = CompanyService();

  // フォームコントローラー
  final _nameController = TextEditingController();
  final _industryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _employeeCountController = TextEditingController();

  DateTime _establishedDate = DateTime(2000, 1, 1);
  final List<String> _benefits = [];
  final _benefitController = TextEditingController();

  bool _isLoading = false;
  bool _isStore = false; // 店舗かどうかのフラグ

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      _loadCompanyData();
    }
  }

  void _loadCompanyData() {
    final company = widget.company!;
    _nameController.text = company.name;
    _industryController.text = company.industry;
    _descriptionController.text = company.description;
    _addressController.text = company.address;
    _phoneController.text = company.phoneNumber ?? '';
    _websiteController.text = company.website ?? '';
    _contactEmailController.text = company.contactEmail;
    _contactPersonController.text = company.contactPerson;
    _employeeCountController.text = company.employeeCount.toString();
    _establishedDate = company.establishedDate;
    _benefits.addAll(company.benefits);
    _isStore = company.isStore;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _contactEmailController.dispose();
    _contactPersonController.dispose();
    _employeeCountController.dispose();
    _benefitController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_benefits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('福利厚生を1つ以上追加してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final company = Company(
        id: widget.company?.id ?? 'company_${now.millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        industry: _industryController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        phoneNumber: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        website: _websiteController.text.trim().isNotEmpty
            ? _websiteController.text.trim()
            : null,
        contactEmail: _contactEmailController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        employeeCount: int.parse(_employeeCountController.text),
        establishedDate: _establishedDate,
        benefits: _benefits,
        isVerified: widget.company?.isVerified ?? false,
        createdAt: widget.company?.createdAt ?? now,
        updatedAt: now,
        isStore: _isStore,
        staffIds: widget.company?.staffIds,
        tipCommissionRate: widget.company?.tipCommissionRate ?? 0.0,
      );

      if (widget.company == null) {
        await _companyService.createCompany(company);
        await _companyService.setCurrentCompanyId(company.id);
      } else {
        await _companyService.updateCompany(company);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.company == null ? '企業を登録しました' : '企業情報を更新しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, company);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addBenefit() {
    final benefit = _benefitController.text.trim();
    if (benefit.isNotEmpty && !_benefits.contains(benefit)) {
      setState(() {
        _benefits.add(benefit);
        _benefitController.clear();
      });
    }
  }

  void _removeBenefit(String benefit) {
    setState(() {
      _benefits.remove(benefit);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.company == null ? '企業登録' : '企業情報編集'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 基本情報
                  const Text(
                    '基本情報',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 企業名
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '企業名',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '企業名を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 業種
                  TextFormField(
                    controller: _industryController,
                    decoration: const InputDecoration(
                      labelText: '業種',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                      hintText: '例: IT・ソフトウェア、美容・サービス',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '業種を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 企業説明
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '企業説明',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '企業説明を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 住所
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: '住所',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '住所を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 従業員数
                  TextFormField(
                    controller: _employeeCountController,
                    decoration: const InputDecoration(
                      labelText: '従業員数',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                      suffix: Text('名'),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '従業員数を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 店舗フラグ
                  SwitchListTile(
                    title: const Text('店舗として登録'),
                    subtitle: const Text(
                      '店舗として登録すると、スタッフ管理機能が有効になります。\n'
                      '所属スタッフはフォロワー数に関係なくライブ配信が可能になります。',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _isStore,
                    onChanged: (value) {
                      setState(() {
                        _isStore = value;
                      });
                    },
                    secondary: const Icon(Icons.store, color: Colors.purple),
                  ),
                  const SizedBox(height: 16),

                  // 設立日
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('設立日'),
                    subtitle: Text(DateFormat('yyyy年MM月dd日').format(_establishedDate)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _establishedDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        locale: const Locale('ja', 'JP'),
                      );
                      if (picked != null) {
                        setState(() {
                          _establishedDate = picked;
                        });
                      }
                    },
                  ),

                  const Divider(height: 32),

                  // 連絡先情報
                  const Text(
                    '連絡先情報',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 電話番号
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: '電話番号（任意）',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // ウェブサイト
                  TextFormField(
                    controller: _websiteController,
                    decoration: const InputDecoration(
                      labelText: 'ウェブサイト（任意）',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.language),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),

                  // 連絡先メール
                  TextFormField(
                    controller: _contactEmailController,
                    decoration: const InputDecoration(
                      labelText: '連絡先メール',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '連絡先メールを入力してください';
                      }
                      if (!value.contains('@')) {
                        return '正しいメールアドレスを入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 担当者名
                  TextFormField(
                    controller: _contactPersonController,
                    decoration: const InputDecoration(
                      labelText: '担当者名',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '担当者名を入力してください';
                      }
                      return null;
                    },
                  ),

                  const Divider(height: 32),

                  // 福利厚生
                  const Text(
                    '福利厚生',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _benefitController,
                          decoration: const InputDecoration(
                            labelText: '福利厚生を追加',
                            border: OutlineInputBorder(),
                            hintText: '例: リモートワーク可',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addBenefit,
                        icon: const Icon(Icons.add_circle),
                        iconSize: 32,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_benefits.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _benefits.map((benefit) {
                        return Chip(
                          label: Text(benefit),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removeBenefit(benefit),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 32),

                  // 登録ボタン
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.company == null ? '企業を登録' : '更新する',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}
