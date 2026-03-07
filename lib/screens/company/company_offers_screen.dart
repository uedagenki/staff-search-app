import 'package:flutter/material.dart';
import '../../models/company.dart';
import '../../services/company_service.dart';

/// 企業のオファー一覧画面
class CompanyOffersScreen extends StatefulWidget {
  final Company company;

  const CompanyOffersScreen({
    super.key,
    required this.company,
  });

  @override
  State<CompanyOffersScreen> createState() => _CompanyOffersScreenState();
}

class _CompanyOffersScreenState extends State<CompanyOffersScreen> {
  final _companyService = CompanyService();
  List<HeadhuntingOffer> _offers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() => _isLoading = true);

    try {
      _offers = await _companyService.getCompanyOffers(widget.company.id);
      setState(() {});
    } catch (e) {
      debugPrint('オファー読み込みエラー: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('送信したオファー'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _offers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'オファーがありません',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'スタッフ詳細画面から\nヘッドハンティングオファーを送信できます',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _offers.length,
                  itemBuilder: (context, index) {
                    final offer = _offers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(offer.status.emoji),
                        ),
                        title: Text(offer.staffName),
                        subtitle: Text(
                          '${offer.position}\n${offer.status.displayName}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        isThreeLine: true,
                        onTap: () {
                          // TODO: オファー詳細画面へ遷移
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
