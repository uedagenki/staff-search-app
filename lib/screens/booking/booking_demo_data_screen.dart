// SCREEN: Booking Demo Data Screen | BOOK-01
import '../../../utils/screen_logger.dart';
import 'package:flutter/material.dart';
import '../../services/firebase_booking_service.dart';

/// 予約機能のデモデータ生成画面
/// 開発・テスト用にサンプルの予約データを生成します
class BookingDemoDataScreen extends StatefulWidget {
  const BookingDemoDataScreen({super.key});

  @override
  State<BookingDemoDataScreen> createState() => _BookingDemoDataScreenState();
}

class _BookingDemoDataScreenState extends State<BookingDemoDataScreen> with ScreenLogMixin {
  @override
  String get screenId => 'Booking Demo Data Screen | BOOK-01';

  final _bookingService = FirebaseBookingService();
  final _staffIdController = TextEditingController(text: 'staff_001');
  final _staffNameController = TextEditingController(text: 'テストスタッフ');
  
  bool _isGenerating = false;
  String? _resultMessage;

  @override
  void dispose() {
    _staffIdController.dispose();
    _staffNameController.dispose();
    super.dispose();
  }

  Future<void> _generateSampleData() async {
    if (_staffIdController.text.isEmpty || _staffNameController.text.isEmpty) {
      setState(() {
        _resultMessage = 'スタッフIDと名前を入力してください';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _resultMessage = null;
    });

    try {
      await _bookingService.createSampleData(
        _staffIdController.text,
        _staffNameController.text,
      );

      setState(() {
        _isGenerating = false;
        _resultMessage = '✅ サンプルデータの生成に成功しました！\n'
            '- 5件のサービスメニューを作成\n'
            '- 3件のサンプル予約を作成';
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _resultMessage = '❌ エラーが発生しました: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('予約デモデータ生成'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '予約機能のテスト用サンプルデータを生成します',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '※ このデータはFirestore Databaseに保存されます',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _staffIdController,
              decoration: const InputDecoration(
                labelText: 'スタッフID',
                hintText: 'staff_001',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _staffNameController,
              decoration: const InputDecoration(
                labelText: 'スタッフ名',
                hintText: 'テストスタッフ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        '生成されるデータ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDataItem('サービスメニュー', '5件'),
                  _buildDataItem('・カット', '¥5,000 (60分)'),
                  _buildDataItem('・カラー', '¥8,000 (90分)'),
                  _buildDataItem('・パーマ', '¥10,000 (120分)'),
                  _buildDataItem('・ヘッドスパ', '¥3,000 (30分)'),
                  _buildDataItem('・トリートメント', '¥6,000 (45分)'),
                  const Divider(height: 24),
                  _buildDataItem('サンプル予約', '3件'),
                  _buildDataItem('・予約中 (pending)', '1件'),
                  _buildDataItem('・確定済み (confirmed)', '2件'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateSampleData,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add_circle_outline),
                label: Text(_isGenerating ? '生成中...' : 'サンプルデータを生成'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (_resultMessage != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _resultMessage!.startsWith('✅')
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _resultMessage!.startsWith('✅')
                        ? Colors.green.shade300
                        : Colors.red.shade300,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _resultMessage!.startsWith('✅')
                          ? Icons.check_circle
                          : Icons.error,
                      color: _resultMessage!.startsWith('✅')
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _resultMessage!,
                        style: TextStyle(
                          fontSize: 14,
                          color: _resultMessage!.startsWith('✅')
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
