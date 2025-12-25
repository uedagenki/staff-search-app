import 'package:flutter/material.dart';

class PlanManagementScreen extends StatefulWidget {
  const PlanManagementScreen({super.key});

  @override
  State<PlanManagementScreen> createState() => _PlanManagementScreenState();
}

class _PlanManagementScreenState extends State<PlanManagementScreen> {
  String _currentPlan = 'フリー'; // 現在のプラン

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プラン管理'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 現在のプランカード
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '現在のプラン',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: _getPlanGradient(_currentPlan),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_currentPlanプラン',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'プランを選択',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // フリープラン
              _buildPlanCard(
                'フリー',
                '¥0',
                '/月',
                Colors.grey,
                [
                  '基本プロフィール',
                  '月5件まで予約受付',
                  'メッセージ機能',
                  '基本サポート',
                ],
                _currentPlan == 'フリー',
              ),
              // ベーシックプラン
              _buildPlanCard(
                'ベーシック',
                '¥2,980',
                '/月',
                Colors.amber,
                [
                  'フリープランの全機能',
                  '月20件まで予約受付',
                  'ポートフォリオ掲載',
                  'レビュー機能',
                  '優先サポート',
                ],
                _currentPlan == 'ベーシック',
              ),
              // プロフェッショナルプラン
              _buildPlanCard(
                'プロフェッショナル',
                '¥5,980',
                '/月',
                Colors.purple,
                [
                  'ベーシックプランの全機能',
                  '無制限予約受付',
                  'ライブ配信機能',
                  'ギフト受取機能',
                  'プロフィール上位表示',
                  '分析ツール',
                  '専任サポート',
                ],
                _currentPlan == 'プロフェッショナル',
              ),
              // プレミアムプラン
              _buildPlanCard(
                'プレミアム',
                '¥9,980',
                '/月',
                Colors.pink,
                [
                  'プロフェッショナルプランの全機能',
                  '最優先表示',
                  '専用バッジ表示',
                  'カスタムプロフィールURL',
                  '広告優先掲載',
                  'マーケティング支援',
                  'コンシェルジュサポート',
                ],
                _currentPlan == 'プレミアム',
              ),
              const SizedBox(height: 24),
              // 注意事項
              Card(
                color: Colors.orange[50],
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'プラン変更について',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• プラン変更は即座に反映されます\n'
                        '• アップグレードは日割り計算\n'
                        '• ダウングレードは次回更新時に適用\n'
                        '• いつでも変更・キャンセル可能',
                        style: TextStyle(fontSize: 12, height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    String planName,
    String price,
    String period,
    Color color,
    List<String> features,
    bool isCurrent,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$planNameプラン',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '現在のプラン',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  period,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: color, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCurrent
                    ? null
                    : () {
                        _showPlanChangeDialog(planName);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrent ? Colors.grey : color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isCurrent ? '利用中' : 'このプランにする',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getPlanGradient(String plan) {
    switch (plan) {
      case 'ベーシック':
        return const LinearGradient(colors: [Colors.amber, Colors.orange]);
      case 'プロフェッショナル':
        return const LinearGradient(colors: [Colors.purple, Colors.deepPurple]);
      case 'プレミアム':
        return const LinearGradient(colors: [Colors.pink, Colors.red]);
      default:
        return const LinearGradient(colors: [Colors.grey, Colors.blueGrey]);
    }
  }

  void _showPlanChangeDialog(String newPlan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$newPlanプランに変更'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('現在のプラン: $_currentPlanプラン'),
            const SizedBox(height: 8),
            Text('変更後: $newPlanプラン'),
            const SizedBox(height: 16),
            const Text(
              'プランを変更しますか？\n変更は即座に反映されます。',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentPlan = newPlan;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$newPlanプランに変更しました'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0a0a0a),
            ),
            child: const Text('変更する'),
          ),
        ],
      ),
    );
  }
}
