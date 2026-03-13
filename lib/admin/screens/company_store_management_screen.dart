import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/company.dart';
import '../../services/company_service.dart';

class CompanyStoreManagementScreen extends StatefulWidget {
  const CompanyStoreManagementScreen({super.key});

  @override
  State<CompanyStoreManagementScreen> createState() => _CompanyStoreManagementScreenState();
}

class _CompanyStoreManagementScreenState extends State<CompanyStoreManagementScreen> with SingleTickerProviderStateMixin {
  final CompanyService _companyService = CompanyService();
  late TabController _tabController;
  
  List<Company> _companies = [];
  List<Company> _stores = [];
  List<Company> _filteredCompanies = [];
  List<Company> _filteredStores = [];
  bool _isLoading = true;
  
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final allCompanies = await _companyService.getAllCompanies();
      
      _companies = allCompanies.where((c) => !c.isStore).toList();
      _stores = allCompanies.where((c) => c.isStore).toList();
      
      _filteredCompanies = List.from(_companies);
      _filteredStores = List.from(_stores);
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('データ読み込みエラー: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _searchCompanies(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCompanies = List.from(_companies);
      } else {
        _filteredCompanies = _companies
            .where((company) =>
                company.name.toLowerCase().contains(query.toLowerCase()) ||
                company.industry.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }
  
  void _searchStores(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStores = List.from(_stores);
      } else {
        _filteredStores = _stores
            .where((store) =>
                store.name.toLowerCase().contains(query.toLowerCase()) ||
                store.industry.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }
  
  Future<void> _toggleVerification(Company company) async {
    try {
      final updatedCompany = Company(
        id: company.id,
        name: company.name,
        industry: company.industry,
        description: company.description,
        address: company.address,
        phoneNumber: company.phoneNumber,
        website: company.website,
        logoUrl: company.logoUrl,
        contactEmail: company.contactEmail,
        contactPerson: company.contactPerson,
        employeeCount: company.employeeCount,
        establishedDate: company.establishedDate,
        benefits: company.benefits,
        isVerified: !company.isVerified,
        createdAt: company.createdAt,
        updatedAt: DateTime.now(),
        staffIds: company.staffIds,
        tipCommissionRate: company.tipCommissionRate,
        isStore: company.isStore,
      );
      
      await _companyService.updateCompany(updatedCompany);
      _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(updatedCompany.isVerified ? '承認しました' : '承認を取り消しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _deleteCompany(Company company) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('「${company.name}」を削除しますか？'),
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
        await _companyService.deleteCompany(company.id);
        _loadData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('削除しました'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('エラー: $e'),
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
        title: const Text('企業・店舗管理'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: '企業 (${_companies.length})',
              icon: const Icon(Icons.business_center),
            ),
            Tab(
              text: '店舗 (${_stores.length})',
              icon: const Icon(Icons.store),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCompanyList(),
                _buildStoreList(),
              ],
            ),
    );
  }
  
  Widget _buildCompanyList() {
    return Column(
      children: [
        // 検索バー
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '企業名・業種で検索',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: _searchCompanies,
          ),
        ),
        
        // 統計情報
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildStatChip(
                '承認済み',
                _companies.where((c) => c.isVerified).length,
                Colors.green,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                '未承認',
                _companies.where((c) => !c.isVerified).length,
                Colors.orange,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // 企業一覧
        Expanded(
          child: _filteredCompanies.isEmpty
              ? const Center(child: Text('企業がありません'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredCompanies.length,
                    itemBuilder: (context, index) {
                      final company = _filteredCompanies[index];
                      return _buildCompanyCard(company);
                    },
                  ),
                ),
        ),
      ],
    );
  }
  
  Widget _buildStoreList() {
    return Column(
      children: [
        // 検索バー
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: '店舗名・業種で検索',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: _searchStores,
          ),
        ),
        
        // 統計情報
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildStatChip(
                '承認済み',
                _stores.where((s) => s.isVerified).length,
                Colors.green,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                '未承認',
                _stores.where((s) => !s.isVerified).length,
                Colors.orange,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                '平均手数料',
                (_stores.isEmpty ? 0 : _stores.map((s) => s.tipCommissionRate * 100).reduce((a, b) => a + b) / _stores.length).toInt(),
                Colors.blue,
                suffix: '%',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // 店舗一覧
        Expanded(
          child: _filteredStores.isEmpty
              ? const Center(child: Text('店舗がありません'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredStores.length,
                    itemBuilder: (context, index) {
                      final store = _filteredStores[index];
                      return _buildStoreCard(store);
                    },
                  ),
                ),
        ),
      ],
    );
  }
  
  Widget _buildStatChip(String label, int value, Color color, {String suffix = ''}) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        child: Text(
          value.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      label: Text('$label$suffix'),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }
  
  Widget _buildCompanyCard(Company company) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: company.isVerified ? Colors.green : Colors.orange,
          child: Icon(
            company.isVerified ? Icons.verified : Icons.pending,
            color: Colors.white,
          ),
        ),
        title: Text(
          company.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${company.industry} • 従業員数: ${company.employeeCount}名'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('設立', '${company.establishedDate.year}年${company.establishedDate.month}月${company.establishedDate.day}日'),
                _buildDetailRow('住所', company.address),
                _buildDetailRow('担当者', '${company.contactPerson} (${company.contactEmail})'),
                if (company.phoneNumber != null)
                  _buildDetailRow('電話', company.phoneNumber!),
                if (company.website != null)
                  _buildDetailRow('ウェブサイト', company.website!),
                const SizedBox(height: 8),
                _buildDetailRow('説明', company.description),
                const SizedBox(height: 8),
                if (company.benefits.isNotEmpty)
                  _buildDetailRow('福利厚生', company.benefits.join(', ')),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleVerification(company),
                        icon: Icon(company.isVerified ? Icons.cancel : Icons.check_circle),
                        label: Text(company.isVerified ? '承認取消' : '承認する'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: company.isVerified ? Colors.orange : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _deleteCompany(company),
                        icon: const Icon(Icons.delete),
                        label: const Text('削除'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStoreCard(Company store) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: store.isVerified ? Colors.green : Colors.orange,
          child: Icon(
            store.isVerified ? Icons.verified : Icons.pending,
            color: Colors.white,
          ),
        ),
        title: Text(
          store.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${store.industry} • スタッフ数: ${store.employeeCount}名 • 手数料: ${(store.tipCommissionRate * 100).toStringAsFixed(1)}%'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('開業日', '${store.establishedDate.year}年${store.establishedDate.month}月${store.establishedDate.day}日'),
                _buildDetailRow('住所', store.address),
                _buildDetailRow('担当者', '${store.contactPerson} (${store.contactEmail})'),
                if (store.phoneNumber != null)
                  _buildDetailRow('電話', store.phoneNumber!),
                if (store.website != null)
                  _buildDetailRow('ウェブサイト', store.website!),
                const SizedBox(height: 8),
                _buildDetailRow('説明', store.description),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.monetization_on, color: Colors.amber[700]),
                      const SizedBox(width: 8),
                      Text(
                        'チップ手数料率: ${(store.tipCommissionRate * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[900],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (store.benefits.isNotEmpty)
                  _buildDetailRow('福利厚生', store.benefits.join(', ')),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleVerification(store),
                        icon: Icon(store.isVerified ? Icons.cancel : Icons.check_circle),
                        label: Text(store.isVerified ? '承認取消' : '承認する'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: store.isVerified ? Colors.orange : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _deleteCompany(store),
                        icon: const Icon(Icons.delete),
                        label: const Text('削除'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
