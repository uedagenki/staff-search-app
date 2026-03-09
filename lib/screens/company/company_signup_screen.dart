import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/company.dart';
import '../../services/company_service.dart';

class CompanySignupScreen extends StatefulWidget {
  const CompanySignupScreen({super.key});

  @override
  State<CompanySignupScreen> createState() => _CompanySignupScreenState();
}

class _CompanySignupScreenState extends State<CompanySignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyService = CompanyService();
  
  // フォームコントローラー
  final _companyNameController = TextEditingController();
  final _industryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _employeeCountController = TextEditingController();
  final _benefitsController = TextEditingController();
  
  bool _isLoading = false;
  DateTime? _establishedDate;
  
  final List<String> _industries = [
    'IT・通信',
    'サービス業',
    '飲食業',
    '小売業',
    '製造業',
    '医療・福祉',
    '教育',
    '不動産',
    '金融',
    'その他',
  ];
  
  @override
  void dispose() {
    _companyNameController.dispose();
    _industryController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _contactEmailController.dispose();
    _contactPersonController.dispose();
    _employeeCountController.dispose();
    _benefitsController.dispose();
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
          content: Text('設立年月日を選択してください'),
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
      
      final company = Company(
        id: 'company_${DateTime.now().millisecondsSinceEpoch}',
        name: _companyNameController.text,
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
        isStore: false, // 企業として登録
      );
      
      await _companyService.createCompany(company);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('企業登録が完了しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('企業登録エラー: $e');
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
        title: const Text('企業登録（ヘッドハンティング）'),
        backgroundColor: Colors.purple[700],
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
                          colors: [Colors.purple[700]!, Colors.purple[500]!],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.business_center, color: Colors.white, size: 40),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '企業アカウント登録',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'スタッフをヘッドハンティング',
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
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: '会社名 *',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '会社名を入力してください';
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
                      items: _industries.map((industry) {
                        return DropdownMenuItem(
                          value: industry,
                          child: Text(industry),
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
                        labelText: '企業説明 *',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '企業説明を入力してください';
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
                    
                    // 企業詳細
                    const Text(
                      '企業詳細',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _employeeCountController,
                      decoration: const InputDecoration(
                        labelText: '従業員数 *',
                        prefixIcon: Icon(Icons.people),
                        border: OutlineInputBorder(),
                        suffixText: '名',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '従業員数を入力してください';
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
                          labelText: '設立年月日 *',
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
                      controller: _benefitsController,
                      decoration: const InputDecoration(
                        labelText: '福利厚生（カンマ区切り）',
                        prefixIcon: Icon(Icons.emoji_emotions),
                        border: OutlineInputBorder(),
                        hintText: '例: 社会保険完備, 交通費支給, 年次有給休暇',
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
                          backgroundColor: Colors.purple[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '企業登録',
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
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                '企業登録について',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• 企業アカウントは、スタッフへのヘッドハンティングオファーが可能です\n'
                            '• 登録情報は審査の上、承認されます\n'
                            '• 登録後、スタッフ検索とオファー機能をご利用いただけます',
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
