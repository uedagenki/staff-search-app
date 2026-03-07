import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/company.dart';
import '../../models/store_staff_offer.dart';
import '../../services/store_staff_offer_service.dart';
import '../../services/company_service.dart';

/// 店舗スタッフオファー一覧画面（企業側）
class StoreStaffOffersListScreen extends StatefulWidget {
  final Company company;

  const StoreStaffOffersListScreen({
    super.key,
    required this.company,
  });

  @override
  State<StoreStaffOffersListScreen> createState() =>
      _StoreStaffOffersListScreenState();
}

class _StoreStaffOffersListScreenState extends State<StoreStaffOffersListScreen>
    with SingleTickerProviderStateMixin {
  final _offerService = StoreStaffOfferService();
  final _companyService = CompanyService();

  late TabController _tabController;
  List<StoreStaffOffer> _allOffers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      final offers = await _offerService.getCompanyOffers(widget.company.id);
      offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        _allOffers = offers;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<StoreStaffOffer> _getOffersByStatus(OfferStatus status) {
    return _allOffers.where((o) => o.status == status).toList();
  }

  Future<void> _handleAcceptedOffer(StoreStaffOffer offer) async {
    // 承諾されたオファーのスタッフを店舗に追加
    await _companyService.addStaffToCompany(widget.company.id, offer.staffId);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${offer.staffName}さんを店舗スタッフに追加しました'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingOffers = _getOffersByStatus(OfferStatus.pending);
    final acceptedOffers = _getOffersByStatus(OfferStatus.accepted);
    final declinedOffers = _getOffersByStatus(OfferStatus.declined);
    final cancelledOffers = _getOffersByStatus(OfferStatus.cancelled);

    return Scaffold(
      appBar: AppBar(
        title: const Text('スタッフオファー管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '確認待ち (${pendingOffers.length})'),
            Tab(text: '承諾 (${acceptedOffers.length})'),
            Tab(text: '辞退 (${declinedOffers.length})'),
            Tab(text: 'キャンセル (${cancelledOffers.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOffersList(pendingOffers, OfferStatus.pending),
                _buildOffersList(acceptedOffers, OfferStatus.accepted),
                _buildOffersList(declinedOffers, OfferStatus.declined),
                _buildOffersList(cancelledOffers, OfferStatus.cancelled),
              ],
            ),
    );
  }

  Widget _buildOffersList(List<StoreStaffOffer> offers, OfferStatus status) {
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
        return _buildOfferCard(offers[index]);
      },
    );
  }

  Widget _buildOfferCard(StoreStaffOffer offer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(offer.status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  offer.status.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.status.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(offer.status),
                        ),
                      ),
                      Text(
                        DateFormat('yyyy/MM/dd HH:mm').format(offer.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
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
                // スタッフ情報
                Row(
                  children: [
                    const Icon(Icons.person, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.staffName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            offer.position,
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
                const Divider(height: 24),

                // メッセージ
                Text(
                  offer.message,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),

                // 投げ銭還元率
                Row(
                  children: [
                    const Icon(Icons.payments, size: 18, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      '投げ銭還元率: 店舗 ${(offer.tipCommissionRate * 100).toStringAsFixed(1)}% / スタッフ ${((1 - offer.tipCommissionRate) * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 特典
                if (offer.benefits.isNotEmpty) ...[
                  const Text(
                    '特典:',
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
                        backgroundColor: Colors.blue.shade50,
                      );
                    }).toList(),
                  ),
                ],

                // レスポンス
                if (offer.respondedAt != null) ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        '返信日時: ${DateFormat('yyyy/MM/dd HH:mm').format(offer.respondedAt!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (offer.responseMessage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'スタッフからのメッセージ:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            offer.responseMessage!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],

                // 承諾済みの場合、スタッフ追加ボタン
                if (offer.status == OfferStatus.accepted) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleAcceptedOffer(offer),
                      icon: const Icon(Icons.person_add),
                      label: const Text('店舗スタッフに追加'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OfferStatus status) {
    switch (status) {
      case OfferStatus.pending:
        return Colors.orange;
      case OfferStatus.accepted:
        return Colors.green;
      case OfferStatus.declined:
        return Colors.red;
      case OfferStatus.cancelled:
        return Colors.grey;
    }
  }
}
