import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/company.dart';
import '../services/company_service.dart';
import '../services/headhunting_auth_service.dart';
import 'store_management/store_signup_screen.dart';

/// 統合ヘッドハンティング管理画面
class IntegratedHeadhuntingScreen extends StatefulWidget {
  const IntegratedHeadhuntingScreen({super.key});

  @override
  State<IntegratedHeadhuntingScreen> createState() => _IntegratedHeadhuntingScreenState();
}

class _IntegratedHeadhuntingScreenState extends State<IntegratedHeadhuntingScreen> {
  final CompanyService _companyService = CompanyService();
  final HeadhuntingAuthService _headhuntingAuthService = HeadhuntingAuthService();
  
  Company? _currentCompany;
  bool _isHeadhuntingRegistered = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final company = await _companyService.getCurrentCompany();
      
      if (company != null) {
        final isRegistered = await _headhuntingAuthService.isHeadhuntingCompany(company.id);
        
        setState(() {
          _currentCompany = company;
          _isHeadhuntingRegistered = isRegistered;
          _isLoading = false;
        });
      } else {
        setState(() {
          _currentCompany = null;
          _isHeadhuntingRegistered = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _registerAsHeadhuntingCompany() async {
    if (_currentCompany == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ヘッドハンティング企業登録'),
        content: const Text(
          'ヘッドハンティング企業として登録しますか？\n\n'
          '登録すると、スタッフの詳細情報を閲覧し、直接スカウトできるようになります。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('登録する'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _headhuntingAuthService.registerHeadhuntingCompany(_currentCompany!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ヘッドハンティング企業として登録しました'),
              backgroundColor: Colors.green,
            ),
          );
          
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('登録に失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _unregisterHeadhuntingCompany() async {
    if (_currentCompany == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ヘッドハンティング企業登録解除'),
        content: const Text(
          'ヘッドハンティング企業の登録を解除しますか？\n\n'
          '解除すると、スタッフの詳細情報の閲覧やスカウト機能が使用できなくなります。',
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
            child: const Text('解除する'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _headhuntingAuthService.unregisterHeadhuntingCompany(_currentCompany!.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ヘッドハンティング企業の登録を解除しました'),
              backgroundColor: Colors.orange,
            ),
          );
          
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('解除に失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _openHeadhuntingManagementApp() async {
    const url = 'https://9090-ivmmk44rjvkdnze0ep01h-c81df28e.sandbox.novita.ai';
    
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ヘッドハンティング管理アプリを開けませんでした'),
              backgroundColor: Colors.red,
            ),
          );
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ヘッドハンティング管理'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentCompany == null
              ? _buildNoCompanyView()
              : _buildManagementView(),
    );
  }

  Widget _buildNoCompanyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              '企業情報が登録されていません',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ヘッドハンティング機能を利用するには、\n先に企業情報を登録してください。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                // 店舗登録画面に遷移
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StoreSignupScreen(),
                  ),
                );
                
                // 登録完了後、データを再読み込み
                if (result == true) {
                  _loadData();
                }
              },
              icon: const Icon(Icons.add_business),
              label: const Text('企業を登録する'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 企業情報カード
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.business,
                          size: 30,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentCompany!.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentCompany!.industry,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isHeadhuntingRegistered
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isHeadhuntingRegistered
                              ? Icons.check_circle
                              : Icons.info_outline,
                          color: _isHeadhuntingRegistered
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _isHeadhuntingRegistered
                                ? 'ヘッドハンティング企業として登録済み'
                                : 'ヘッドハンティング企業未登録',
                            style: TextStyle(
                              color: _isHeadhuntingRegistered
                                  ? Colors.green.shade900
                                  : Colors.orange.shade900,
                              fontWeight: FontWeight.bold,
                            ),
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
          
          // 登録状態による表示切り替え
          if (_isHeadhuntingRegistered) ...[
            _buildRegisteredView(),
          ] else ...[
            _buildUnregisteredView(),
          ],
        ],
      ),
    );
  }

  Widget _buildRegisteredView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '利用可能な機能',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // 機能カード
        _buildFeatureCard(
          icon: Icons.search,
          title: 'スタッフ検索',
          description: '優秀なスタッフを検索してスカウト',
          color: Colors.blue,
        ),
        
        _buildFeatureCard(
          icon: Icons.person_search,
          title: 'スタッフ詳細閲覧',
          description: 'スタッフの詳細情報を確認',
          color: Colors.green,
        ),
        
        _buildFeatureCard(
          icon: Icons.mail_outline,
          title: 'オファー送信',
          description: '直接スカウトオファーを送信',
          color: Colors.purple,
        ),
        
        _buildFeatureCard(
          icon: Icons.message_outlined,
          title: 'メッセージ',
          description: 'スタッフと直接メッセージ',
          color: Colors.orange,
        ),
        
        const SizedBox(height: 24),
        
        // ヘッドハンティング管理アプリへのリンク
        Card(
          elevation: 2,
          color: Colors.blue.shade700,
          child: InkWell(
            onTap: _openHeadhuntingManagementApp,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.open_in_new,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ヘッドハンティング管理アプリ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '詳細な管理機能はこちら',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 登録解除ボタン
        Center(
          child: TextButton.icon(
            onPressed: _unregisterHeadhuntingCompany,
            icon: const Icon(Icons.remove_circle_outline),
            label: const Text('ヘッドハンティング企業登録を解除'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnregisteredView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ヘッドハンティング企業に登録',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '登録すると利用できる機能',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildBenefitItem('✓ スタッフの詳細情報を閲覧'),
                _buildBenefitItem('✓ 優秀なスタッフを検索'),
                _buildBenefitItem('✓ 直接スカウトオファーを送信'),
                _buildBenefitItem('✓ スタッフとメッセージでやり取り'),
                _buildBenefitItem('✓ オファー管理機能'),
                
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _registerAsHeadhuntingCompany,
                    icon: const Icon(Icons.how_to_reg),
                    label: const Text('ヘッドハンティング企業として登録する'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
