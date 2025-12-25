import 'package:flutter/material.dart';
import 'support_chat_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ヘルプ・サポート'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // アプリ使用説明セクション
              Card(
                color: Colors.purple[50],
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.purple[700], size: 28),
                          const SizedBox(width: 12),
                          const Text(
                            'スタッフアプリの使い方',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildUsageStep('1', 'プロフィール登録', '詳細なプロフィール、スキル、経験を登録してユーザーにアピール'),
                      _buildUsageStep('2', 'ライブ配信', '自分の魅力やスキルをライブ配信でリアルタイムに伝える'),
                      _buildUsageStep('3', '予約管理', 'ユーザーからの予約を確認・管理し、スケジュールを調整'),
                      _buildUsageStep('4', 'ギフト受取', 'ライブ配信中にユーザーからギフトを受け取り収益化'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // サポートチャットカード
              Card(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SupportChatScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.blue,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '運営に問い合わせ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'チャットでお気軽にご相談ください',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // よくある質問セクション
              const Text(
                'よくある質問 (Q&A)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildFAQItem(
                'プロフィール・登録',
                [
                  {'q': 'プロフィールの編集方法は？', 'a': 'プロフィールタブ → プロフィール編集 から、写真、自己紹介、スキルなどを編集できます。'},
                  {'q': '写真は何枚まで登録できますか？', 'a': '最大5枚まで登録可能です。プロフィール写真は第一印象を左右するため、高品質な写真を使用することをお勧めします。'},
                  {'q': 'カテゴリの変更はできますか？', 'a': 'はい、プロフィール編集画面からカテゴリ・職種の変更が可能です。'},
                ],
              ),
              _buildFAQItem(
                'プラン・料金',
                [
                  {'q': 'プランの違いは何ですか？', 'a': 'フリープラン（無料）、ベーシック（¥2,980）、プロフェッショナル（¥5,980）、プレミアム（¥9,980）があり、月間予約数、ライブ配信機能、ギフト手数料などが異なります。'},
                  {'q': 'プランの変更方法は？', 'a': 'プロフィール → プラン管理 から、いつでもプランの変更が可能です。'},
                  {'q': 'ギフトの手数料はいくらですか？', 'a': 'プロフェッショナルプランは15%、プレミアムプランは0%です。フリー・ベーシックプランではギフト機能は利用できません。'},
                ],
              ),
              _buildFAQItem(
                '予約管理',
                [
                  {'q': '予約の確認方法は？', 'a': 'ホーム画面の予約一覧、またはカレンダーから予約を確認できます。'},
                  {'q': '予約をキャンセルするには？', 'a': '予約詳細画面から「キャンセル」ボタンをタップしてください。ただし、ユーザー都合以外のキャンセルは評価に影響する可能性があります。'},
                  {'q': '予約時間を変更したい', 'a': 'ユーザーとメッセージ機能で調整し、予約詳細画面から変更できます。'},
                ],
              ),
              _buildFAQItem(
                'ライブ配信・ギフト',
                [
                  {'q': 'ライブ配信の開始方法は？', 'a': 'ホーム画面の「ライブ配信開始」ボタンをタップし、配信タイトルと説明を入力して開始できます。'},
                  {'q': 'ギフトはどうやって受け取りますか？', 'a': 'ライブ配信中にユーザーがギフトを送ると自動的に記録され、チップ管理画面で確認・出金申請ができます。'},
                  {'q': '収益の出金方法は？', 'a': 'プロフィール → チップ管理 → 出金申請 から、登録した銀行口座へ出金申請できます。最低出金額は¥1,000からです。'},
                ],
              ),
              _buildFAQItem(
                'レビュー・評価',
                [
                  {'q': '評価を上げるには？', 'a': '丁寧な対応、時間厳守、高品質なサービス提供を心がけてください。ユーザーからの良いレビューが評価向上につながります。'},
                  {'q': '悪いレビューが投稿されました', 'a': '不当なレビューの場合は、レビューの横のメニューから「報告する」で運営に報告できます。運営が内容を確認し、適切に対応します。'},
                  {'q': 'レビューに返信できますか？', 'a': 'はい、各レビューに対して返信が可能です。丁寧な返信は他のユーザーにも好印象を与えます。'},
                ],
              ),
              _buildFAQItem(
                'トラブル・その他',
                [
                  {'q': 'ユーザーとトラブルになりました', 'a': 'まず冷静にユーザーと話し合い、解決を試みてください。解決しない場合は運営サポートにご連絡ください。'},
                  {'q': '不適切なメッセージを受け取りました', 'a': 'メッセージ画面からユーザーをブロックし、運営に報告してください。'},
                  {'q': 'アカウントを一時停止したい', 'a': 'プロフィール → 設定 → アカウント管理 から一時停止が可能です。予約がある場合は完了後に停止されます。'},
                ],
              ),
              const SizedBox(height: 24),
              // サポート情報
              Card(
                color: Colors.blue[50],
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'スタッフサポート窓口',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('営業時間: 9:00 - 18:00（平日）'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.email, size: 16, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('staff-support@staffsearch.com'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('0120-XXX-YYYY（スタッフ専用）'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsageStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.purple[700],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String category, List<Map<String, String>> faqs) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          category,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const Icon(Icons.help_outline, color: Colors.blue),
        children: faqs.map((faq) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Q',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        faq['q']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'A',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        faq['a']!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                if (faqs.indexOf(faq) < faqs.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
