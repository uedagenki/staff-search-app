import 'package:flutter/material.dart';
import '../../models/company.dart';
import '../../services/company_service.dart';
import 'company_registration_screen.dart';
import 'company_offers_screen.dart';
import 'company_staff_management_screen.dart';

/// 企業管理画面
class CompanyManagementScreen extends StatefulWidget {
  const CompanyManagementScreen({super.key});

  @override
  State<CompanyManagementScreen> createState() => _CompanyManagementScreenState();
}

class _CompanyManagementScreenState extends State<CompanyManagementScreen> {
  final _companyService = CompanyService();
  Company? _currentCompany;
  List<HeadhuntingOffer> _offers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // デモ企業を作成
      await _companyService.createDemoCompanies();

      // 現在の企業を取得
      _currentCompany = await _companyService.getCurrentCompany();

      // オファーを取得
      if (_currentCompany != null) {
        _offers = await _companyService.getCompanyOffers(_currentCompany!.id);
      }

      setState(() {});
    } catch (e) {
      debugPrint('データ読み込みエラー: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _registerCompany() async {
    final result = await Navigator.push<Company>(
      context,
      MaterialPageRoute(
        builder: (context) => const CompanyRegistrationScreen(),
      ),
    );

    if (result != null) {
      _loadData();
    }
  }

  Future<void> _editCompany() async {
    if (_currentCompany == null) return;

    final result = await Navigator.push<Company>(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyRegistrationScreen(
          company: _currentCompany,
        ),
      ),
    );

    if (result != null) {
      _loadData();
    }
  }

  Future<void> _viewOffers() async {
    if (_currentCompany == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyOffersScreen(
          company: _currentCompany!,
        ),
      ),
    );

    _loadData();
  }

  Future<void> _manageStaff() async {
    if (_currentCompany == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyStaffManagementScreen(
          company: _currentCompany!,
        ),
      ),
    );

    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('企業管理'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_currentCompany == null) ...[
                  // 企業未登録の場合
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.business,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '企業が登録されていません',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ヘッドハンティング機能を利用するには\n企業情報を登録してください',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _registerCompany,
                            icon: const Icon(Icons.add),
                            label: const Text('企業を登録'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // 企業情報カード
                  _buildCompanyCard(),
                  const SizedBox(height: 16),

                  // アクションボタン
                  _buildActionButtons(),
                  const SizedBox(height: 16),

                  // 統計情報
                  _buildStatistics(),
                ],

                const SizedBox(height: 24),

                // 説明
                Card(
                  color: Colors.blue[50],
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 ヘッドハンティング機能について',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '企業を登録すると、優秀なスタッフにヘッドハンティングのオファーを送信できます。\n\n'
                          '• スタッフの詳細画面から直接オファー\n'
                          '• 年収、勤務地、福利厚生を提示\n'
                          '• オファー状況を一括管理',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: _currentCompany == null
          ? FloatingActionButton.extended(
              onPressed: _registerCompany,
              icon: const Icon(Icons.add),
              label: const Text('企業登録'),
            )
          : null,
    );
  }

  Widget _buildCompanyCard() {
    final company = _currentCompany!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.business,
                  size: 48,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        company.industry,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (company.isVerified)
                        Row(
                          children: [
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '認証済み企業',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              company.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    company.address,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people, size: 16),
                const SizedBox(width: 4),
                Text(
                  '従業員数: ${company.employeeCount}名',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _editCompany,
                icon: const Icon(Icons.edit),
                label: const Text('企業情報編集'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _viewOffers,
                icon: const Icon(Icons.send),
                label: const Text('オファー一覧'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        if (_currentCompany?.isStore == true) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _manageStaff,
              icon: const Icon(Icons.people),
              label: const Text('スタッフ管理（店舗専用）'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatistics() {
    final pendingCount = _offers.where((o) => o.status == OfferStatus.pending).length;
    final acceptedCount = _offers.where((o) => o.status == OfferStatus.accepted).length;
    final declinedCount = _offers.where((o) => o.status == OfferStatus.declined).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard('送信中', pendingCount.toString(), Colors.orange),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('承諾', acceptedCount.toString(), Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('辞退', declinedCount.toString(), Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
