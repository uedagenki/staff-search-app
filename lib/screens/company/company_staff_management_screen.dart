import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/company.dart';
import '../../models/staff.dart';
import '../../services/company_service.dart';
import '../../services/local_auth_service.dart';
import '../../services/store_staff_offer_service.dart';
import '../../data/mock_data.dart';
import 'send_store_staff_offer_screen.dart';
import 'store_staff_offers_list_screen.dart';

/// 店舗（会社）スタッフ管理画面
class CompanyStaffManagementScreen extends StatefulWidget {
  final Company company;

  const CompanyStaffManagementScreen({
    super.key,
    required this.company,
  });

  @override
  State<CompanyStaffManagementScreen> createState() =>
      _CompanyStaffManagementScreenState();
}

class _CompanyStaffManagementScreenState
    extends State<CompanyStaffManagementScreen> {
  final CompanyService _companyService = CompanyService();
  final LocalAuthService _authService = LocalAuthService();
  final StoreStaffOfferService _offerService = StoreStaffOfferService();

  List<Staff> _companyStaff = [];
  List<Staff> _availableStaff = [];
  bool _isLoading = true;
  double _tipCommissionRate = 0.0;
  int _pendingOffersCount = 0;

  @override
  void initState() {
    super.initState();
    _tipCommissionRate = widget.company.tipCommissionRate;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 店舗所属スタッフを取得
      final allStaff = await _loadAllStaff();
      final companyStaffIds = widget.company.staffIds;

      _companyStaff = allStaff
          .where((staff) => companyStaffIds.contains(staff.id))
          .toList();

      // 未所属スタッフを取得（追加候補）
      _availableStaff = allStaff
          .where((staff) => !companyStaffIds.contains(staff.id))
          .toList();
      
      // 保留中のオファー数を取得
      final offers = await _offerService.getCompanyOffers(widget.company.id);
      _pendingOffersCount = offers.where((o) => o.status.toString().contains('pending')).length;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load staff: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<List<Staff>> _loadAllStaff() async {
    // MockDataからスタッフデータを取得
    return MockData.getStaffList();
  }

  Future<void> _addStaff(Staff staff) async {
    await _companyService.addStaffToCompany(widget.company.id, staff.id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${staff.name} を追加しました'),
          backgroundColor: Colors.green,
        ),
      );
      _loadData();
    }
  }

  Future<void> _removeStaff(Staff staff) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('スタッフを削除'),
        content: Text('${staff.name} を店舗から削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _companyService.removeStaffFromCompany(widget.company.id, staff.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${staff.name} を削除しました'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadData();
      }
    }
  }

  Future<void> _updateCommissionRate() async {
    await _companyService.setTipCommissionRate(
      widget.company.id,
      _tipCommissionRate,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('投げ銭還元率を更新しました'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showAddStaffDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('スタッフにオファーを送信'),
        content: SizedBox(
          width: double.maxFinite,
          child: _availableStaff.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('オファー可能なスタッフがいません'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableStaff.length,
                  itemBuilder: (context, index) {
                    final staff = _availableStaff[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(staff.profileImage),
                      ),
                      title: Text(staff.name),
                      subtitle: Text('${staff.jobTitle} - ${staff.category}'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SendStoreStaffOfferScreen(
                              company: widget.company,
                              staff: staff,
                            ),
                          ),
                        );
                        if (result == true) {
                          _loadData();
                        }
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.company.name} - スタッフ管理'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.mail),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoreStaffOffersListScreen(
                        company: widget.company,
                      ),
                    ),
                  );
                  _loadData();
                },
              ),
              if (_pendingOffersCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_pendingOffersCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCommissionRateCard(),
                  _buildLiveBroadcastInfoCard(),
                  _buildStaffListSection(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStaffDialog,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildCommissionRateCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payments, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '投げ銭還元率設定',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '現在の還元率: ${(_tipCommissionRate * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'スタッフが受け取った投げ銭から、店舗が受け取る還元率を設定します。\n（0%〜10%まで設定可能）',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Slider(
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
                ),
                SizedBox(
                  width: 80,
                  child: ElevatedButton(
                    onPressed: _updateCommissionRate,
                    child: const Text('保存'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveBroadcastInfoCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.live_tv, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'ライブ配信特典',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.purple,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '✨ TikTok方式：店舗所属スタッフの特典',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '• フォロワー数に関係なくライブ配信が可能\n'
              '• 通常はフォロワー100人以上必要\n'
              '• 店舗所属により即座にライブ配信機能が解放されます',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffListSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '所属スタッフ（${_companyStaff.length}名）',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (_companyStaff.isNotEmpty)
                TextButton.icon(
                  onPressed: _showAddStaffDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('追加'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_companyStaff.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'スタッフがいません',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showAddStaffDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('スタッフを追加'),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _companyStaff.length,
              itemBuilder: (context, index) {
                final staff = _companyStaff[index];
                return _buildStaffCard(staff);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(Staff staff) {
    final canLiveBroadcast = staff.followersCount >= 100 || 
                              widget.company.staffIds.contains(staff.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(staff.profileImage),
            ),
            if (staff.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Text(staff.name),
            const SizedBox(width: 8),
            if (canLiveBroadcast)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ライブ可能',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${staff.jobTitle} - ${staff.category}'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${staff.followersCount}人',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.card_giftcard, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '¥${staff.giftAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
          onPressed: () => _removeStaff(staff),
        ),
      ),
    );
  }
}
