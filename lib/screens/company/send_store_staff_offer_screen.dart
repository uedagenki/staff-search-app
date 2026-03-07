import 'package:flutter/material.dart';
import '../../models/company.dart';
import '../../models/staff.dart';
import '../../models/store_staff_offer.dart';
import '../../services/store_staff_offer_service.dart';

/// 店舗スタッフオファー送信画面
class SendStoreStaffOfferScreen extends StatefulWidget {
  final Company company;
  final Staff staff;

  const SendStoreStaffOfferScreen({
    super.key,
    required this.company,
    required this.staff,
  });

  @override
  State<SendStoreStaffOfferScreen> createState() =>
      _SendStoreStaffOfferScreenState();
}

class _SendStoreStaffOfferScreenState extends State<SendStoreStaffOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _offerService = StoreStaffOfferService();

  final _positionController = TextEditingController();
  final _messageController = TextEditingController();
  final _benefitController = TextEditingController();

  double _tipCommissionRate = 0.05; // デフォルト5%
  final List<String> _benefits = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tipCommissionRate = widget.company.tipCommissionRate;
    _positionController.text = widget.staff.jobTitle;
  }

  @override
  void dispose() {
    _positionController.dispose();
    _messageController.dispose();
    _benefitController.dispose();
    super.dispose();
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

  Future<void> _sendOffer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_benefits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('特典を1つ以上追加してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final offer = StoreStaffOffer(
        id: 'offer_${now.millisecondsSinceEpoch}',
        companyId: widget.company.id,
        companyName: widget.company.name,
        staffId: widget.staff.id,
        staffName: widget.staff.name,
        staffEmail: 'staff_${widget.staff.id}@example.com', // デモ用
        position: _positionController.text.trim(),
        message: _messageController.text.trim(),
        tipCommissionRate: _tipCommissionRate,
        benefits: _benefits,
        status: OfferStatus.pending,
        createdAt: now,
      );

      await _offerService.createOffer(offer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.staff.name}さんにオファーを送信しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('オファー送信に失敗しました: $e'),
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
        title: const Text('スタッフ登録オファー'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStaffInfoCard(),
                    const SizedBox(height: 24),
                    _buildOfferForm(),
                    const SizedBox(height: 24),
                    _buildSendButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStaffInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: NetworkImage(widget.staff.profileImage),
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
                    '${widget.staff.jobTitle} - ${widget.staff.category}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.staff.followersCount}人',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        widget.staff.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ポジション
        TextFormField(
          controller: _positionController,
          decoration: const InputDecoration(
            labelText: 'ポジション・職種',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.work),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'ポジションを入力してください';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // オファーメッセージ
        TextFormField(
          controller: _messageController,
          decoration: const InputDecoration(
            labelText: 'オファーメッセージ',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.message),
            hintText: '当店で一緒に働きませんか？',
          ),
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'メッセージを入力してください';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // 投げ銭還元率
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '投げ銭還元率',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '店舗: ${(_tipCommissionRate * 100).toStringAsFixed(1)}% / スタッフ: ${((1 - _tipCommissionRate) * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 14),
                ),
                Slider(
                  value: _tipCommissionRate,
                  min: 0.0,
                  max: 0.10,
                  divisions: 20,
                  label: '${(_tipCommissionRate * 100).toStringAsFixed(1)}%',
                  onChanged: (value) {
                    setState(() {
                      _tipCommissionRate = value;
                    });
                  },
                ),
                const Text(
                  '※ 0%〜10%の範囲で設定可能',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 特典
        const Text(
          '特典・福利厚生',
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
                controller: _benefitController,
                decoration: const InputDecoration(
                  hintText: '例: 社員割引、交通費支給',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addBenefit(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addBenefit,
              child: const Text('追加'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_benefits.isEmpty)
          const Text(
            '特典を追加してください',
            style: TextStyle(color: Colors.grey),
          )
        else
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
      ],
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _sendOffer,
        icon: const Icon(Icons.send),
        label: const Text(
          'オファーを送信',
          style: TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
