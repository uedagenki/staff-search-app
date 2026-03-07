import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/company.dart';
import '../../models/staff.dart';
import '../../services/company_service.dart';

/// ヘッドハンティングオファー送信画面
class SendHeadhuntingOfferScreen extends StatefulWidget {
  final Company company;
  final Staff staff;

  const SendHeadhuntingOfferScreen({
    super.key,
    required this.company,
    required this.staff,
  });

  @override
  State<SendHeadhuntingOfferScreen> createState() => _SendHeadhuntingOfferScreenState();
}

class _SendHeadhuntingOfferScreenState extends State<SendHeadhuntingOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyService = CompanyService();

  final _positionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  final _workLocationController = TextEditingController();

  final List<String> _requirements = [];
  final _requirementController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _workLocationController.text = widget.company.address;
  }

  @override
  void dispose() {
    _positionController.dispose();
    _descriptionController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _workLocationController.dispose();
    _requirementController.dispose();
    super.dispose();
  }

  void _addRequirement() {
    final requirement = _requirementController.text.trim();
    if (requirement.isNotEmpty && !_requirements.contains(requirement)) {
      setState(() {
        _requirements.add(requirement);
        _requirementController.clear();
      });
    }
  }

  void _removeRequirement(String requirement) {
    setState(() {
      _requirements.remove(requirement);
    });
  }

  Future<void> _sendOffer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final offer = HeadhuntingOffer(
        id: 'offer_${DateTime.now().millisecondsSinceEpoch}',
        companyId: widget.company.id,
        companyName: widget.company.name,
        staffId: widget.staff.id,
        staffName: widget.staff.name,
        position: _positionController.text.trim(),
        description: _descriptionController.text.trim(),
        salaryMin: int.parse(_salaryMinController.text),
        salaryMax: int.parse(_salaryMaxController.text),
        workLocation: _workLocationController.text.trim(),
        requirements: _requirements,
        benefits: widget.company.benefits,
        status: OfferStatus.pending,
        createdAt: DateTime.now(),
      );

      await _companyService.createOffer(offer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('オファーを送信しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('送信に失敗しました: $e'),
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
        title: const Text('ヘッドハンティングオファー'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // スタッフ情報
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.person, size: 48),
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 募集職種
                  TextFormField(
                    controller: _positionController,
                    decoration: const InputDecoration(
                      labelText: '募集職種',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work),
                      hintText: '例: シニアスタイリスト',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '募集職種を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 詳細
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '職務内容',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '職務内容を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 年収
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _salaryMinController,
                          decoration: const InputDecoration(
                            labelText: '最低年収（万円）',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '入力してください';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _salaryMaxController,
                          decoration: const InputDecoration(
                            labelText: '最高年収（万円）',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '入力してください';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 勤務地
                  TextFormField(
                    controller: _workLocationController,
                    decoration: const InputDecoration(
                      labelText: '勤務地',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '勤務地を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 応募要件
                  const Text(
                    '応募要件',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _requirementController,
                          decoration: const InputDecoration(
                            labelText: '要件を追加',
                            border: OutlineInputBorder(),
                            hintText: '例: 実務経験3年以上',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addRequirement,
                        icon: const Icon(Icons.add_circle),
                        iconSize: 32,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_requirements.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _requirements.map((req) {
                        return Chip(
                          label: Text(req),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removeRequirement(req),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 16),

                  // 福利厚生プレビュー
                  const Text(
                    '福利厚生',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.company.benefits.map((benefit) {
                      return Chip(
                        label: Text(benefit),
                        backgroundColor: Colors.green[50],
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // 送信ボタン
                  ElevatedButton(
                    onPressed: _sendOffer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'オファーを送信',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}
