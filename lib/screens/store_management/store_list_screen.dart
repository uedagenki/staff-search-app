import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/company.dart';
import '../../services/company_service.dart';
import '../company/company_staff_management_screen.dart';
import 'store_signup_screen.dart';
import 'store_edit_screen.dart';

/// 複数店舗管理画面
class StoreListScreen extends StatefulWidget {
  const StoreListScreen({super.key});

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  final CompanyService _companyService = CompanyService();
  List<Company> _stores = [];
  bool _isLoading = true;
  String? _currentStoreId;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    setState(() => _isLoading = true);
    try {
      // 全企業を取得してisStore=trueのものだけフィルター
      final allCompanies = await _companyService.getAllCompanies();
      _stores = allCompanies.where((c) => c.isStore).toList();
      
      // 現在選択中の店舗IDを取得
      _currentStoreId = await _companyService.getCurrentCompanyId();
    } catch (e) {
      debugPrint('店舗読み込みエラー: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectStore(Company store) async {
    await _companyService.setCurrentCompanyId(store.id);
    setState(() {
      _currentStoreId = store.id;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${store.name} を選択しました'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _navigateToStoreManagement(Company store) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyStaffManagementScreen(company: store),
      ),
    );
    
    if (result == true) {
      _loadStores();
    }
  }

  Future<void> _navigateToEditStore(Company store) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreEditScreen(company: store),
      ),
    );
    
    if (result == true) {
      _loadStores();
    }
  }

  Future<void> _navigateToCreateStore() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StoreSignupScreen(),
      ),
    );
    
    if (result == true) {
      _loadStores();
    }
  }

  Future<void> _deleteStore(Company store) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('店舗削除'),
        content: Text('${store.name} を削除しますか？\n\nこの操作は取り消せません。'),
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
      try {
        await _companyService.deleteCompany(store.id);
        
        // 削除した店舗が現在選択中の店舗だった場合、選択を解除
        if (_currentStoreId == store.id) {
          _currentStoreId = null;
          // 残りの店舗がある場合は最初の店舗を選択
          if (_stores.length > 1) {
            final remainingStore = _stores.firstWhere((s) => s.id != store.id);
            await _companyService.setCurrentCompanyId(remainingStore.id);
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${store.name} を削除しました'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadStores();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('削除に失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('店舗管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreateStore,
            tooltip: '新規店舗登録',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stores.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadStores,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _stores.length,
                    itemBuilder: (context, index) {
                      final store = _stores[index];
                      final isSelected = store.id == _currentStoreId;
                      return _buildStoreCard(store, isSelected);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateStore,
        icon: const Icon(Icons.add),
        label: const Text('新規店舗登録'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '登録されている店舗がありません',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToCreateStore,
            icon: const Icon(Icons.add),
            label: const Text('最初の店舗を登録'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(Company store, bool isSelected) {
    final dateFormat = DateFormat('yyyy年MM月dd日', 'ja_JP');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 4 : 2,
      color: isSelected ? Colors.blue.shade50 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー部分
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.store,
                size: 32,
                color: Colors.blue,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    store.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '選択中',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.business, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(store.industry),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(child: Text(store.address)),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 詳細情報
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 説明文
                Text(
                  store.description,
                  style: TextStyle(color: Colors.grey.shade700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // ステータス情報
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      Icons.people,
                      '${store.employeeCount}名',
                      Colors.blue,
                    ),
                    _buildInfoChip(
                      Icons.supervisor_account,
                      '${store.staffIds.length}スタッフ',
                      Colors.purple,
                    ),
                    _buildInfoChip(
                      Icons.payments,
                      '還元率 ${(store.tipCommissionRate * 100).toStringAsFixed(1)}%',
                      Colors.green,
                    ),
                    if (store.establishedDate != null)
                      _buildInfoChip(
                        Icons.calendar_today,
                        dateFormat.format(store.establishedDate!),
                        Colors.orange,
                      ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // アクションボタン
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isSelected)
                  TextButton.icon(
                    onPressed: () => _selectStore(store),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('選択'),
                  ),
                TextButton.icon(
                  onPressed: () => _navigateToEditStore(store),
                  icon: const Icon(Icons.edit),
                  label: const Text('編集'),
                ),
                TextButton.icon(
                  onPressed: () => _navigateToStoreManagement(store),
                  icon: const Icon(Icons.settings),
                  label: const Text('管理'),
                ),
                TextButton.icon(
                  onPressed: () => _deleteStore(store),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('削除', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
