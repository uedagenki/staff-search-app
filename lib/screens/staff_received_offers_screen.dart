import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/store_staff_offer.dart';
import '../models/company.dart'; // OfferStatusをインポート
import '../services/store_staff_offer_service.dart';
import '../services/local_auth_service.dart';

/// スタッフが受け取ったオファー管理画面
class StaffReceivedOffersScreen extends StatefulWidget {
  const StaffReceivedOffersScreen({super.key});

  @override
  State<StaffReceivedOffersScreen> createState() =>
      _StaffReceivedOffersScreenState();
}

class _StaffReceivedOffersScreenState extends State<StaffReceivedOffersScreen>
    with SingleTickerProviderStateMixin {
  final _offerService = StoreStaffOfferService();
  final _authService = LocalAuthService();

  late TabController _tabController;
  List<StoreStaffOffer> _allOffers = [];
  bool _isLoading = true;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOffers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOffers() async {
    setState(() => _isLoading = true);
    try {
      // 現在のユーザーのメールアドレスを取得
      final user = await _authService.getCurrentUser();
      _currentUserEmail = user?.email;

      if (_currentUserEmail != null) {
        final offers = await _offerService.getStaffOffersByEmail(_currentUserEmail!);
        offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        setState(() {
          _allOffers = offers;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<StoreStaffOffer> _getOffersByStatus(OfferStatus status) {
    return _allOffers.where((o) => o.status == status).toList();
  }

  Future<void> _handleAccept(StoreStaffOffer offer) async {
    final messageController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('オファーを承諾'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${offer.companyName}からのオファーを承諾しますか？'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'メッセージ（任意）',
                border: OutlineInputBorder(),
                hintText: 'よろしくお願いいたします',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('承諾'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _offerService.acceptOffer(
        offer.id,
        responseMessage: messageController.text.trim().isNotEmpty
            ? messageController.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('オファーを承諾しました'),
            backgroundColor: Colors.green,
          ),
        );
        _loadOffers();
      }
    }
  }

  Future<void> _handleDecline(StoreStaffOffer offer) async {
    final messageController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('オファーを辞退'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${offer.companyName}からのオファーを辞退しますか？'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: '辞退理由（任意）',
                border: OutlineInputBorder(),
                hintText: '申し訳ございませんが...',
              ),
              maxLines: 3,
            ),
          ],
        ),
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
            child: const Text('辞退'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _offerService.declineOffer(
        offer.id,
        responseMessage: messageController.text.trim().isNotEmpty
            ? messageController.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('オファーを辞退しました'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadOffers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingOffers = _getOffersByStatus(OfferStatus.pending);
    final acceptedOffers = _getOffersByStatus(OfferStatus.accepted);
    final declinedOffers = _getOffersByStatus(OfferStatus.declined);

    return Scaffold(
      appBar: AppBar(
        title: const Text('店舗からのオファー'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '新規 (${pendingOffers.length})'),
            Tab(text: '承諾済み (${acceptedOffers.length})'),
            Tab(text: '辞退済み (${declinedOffers.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOffersList(pendingOffers, true),
                _buildOffersList(acceptedOffers, false),
                _buildOffersList(declinedOffers, false),
              ],
            ),
    );
  }

  Widget _buildOffersList(List<StoreStaffOffer> offers, bool showActions) {
    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'オファーがありません',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        return _buildOfferCard(offers[index], showActions);
      },
    );
  }

  Widget _buildOfferCard(StoreStaffOffer offer, bool showActions) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade600],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.store, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.companyName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat('yyyy/MM/dd HH:mm').format(offer.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  offer.status.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ],
            ),
          ),

          // 内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ポジション
                Row(
                  children: [
                    const Icon(Icons.work, color: Colors.purple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        offer.position,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // メッセージ
                const Text(
                  'メッセージ:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  offer.message,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),

                // 投げ銭還元率
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '投げ銭還元率',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'あなた: ${((1 - offer.tipCommissionRate) * 100).toStringAsFixed(1)}% / 店舗: ${(offer.tipCommissionRate * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 特典
                if (offer.benefits.isNotEmpty) ...[
                  const Text(
                    '特典・福利厚生:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: offer.benefits.map((benefit) {
                      return Chip(
                        label: Text(benefit),
                        backgroundColor: Colors.purple.shade50,
                        avatar: const Icon(Icons.check_circle, size: 18),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // ライブ配信特典
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.live_tv, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '✨ TikTok方式特典',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'フォロワー数に関係なくライブ配信が可能！',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // アクションボタン
                if (showActions) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleDecline(offer),
                          icon: const Icon(Icons.close),
                          label: const Text('辞退'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleAccept(offer),
                          icon: const Icon(Icons.check),
                          label: const Text('承諾'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
