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
                '予約について',
                [
                  {'q': 'スタッフの予約方法は？', 'a': 'スタッフのプロフィール画面から「予約する」ボタンをタップし、日時とサービスを選択してください。'},
                  {'q': '予約をキャンセルするには？', 'a': '予約一覧から該当の予約を選択し、「キャンセル」ボタンをタップしてください。キャンセル料金は予約時間の24時間前までは無料です。'},
                  {'q': '予約の変更はできますか？', 'a': 'はい、予約詳細画面から「変更」ボタンで日時の変更が可能です。'},
                ],
              ),
              _buildFAQItem(
                '支払いについて',
                [
                  {'q': '利用可能な支払い方法は？', 'a': 'クレジットカード（Visa、Mastercard、JCB）、デビットカード、電子マネー（PayPay、LINE Pay）に対応しています。'},
                  {'q': '支払い情報の変更方法は？', 'a': 'プロフィール → 設定 → 支払い方法 から変更できます。'},
                  {'q': '領収書は発行されますか？', 'a': '予約完了後、メールで領収書が自動送信されます。アプリ内の予約履歴からもダウンロード可能です。'},
                ],
              ),
              _buildFAQItem(
                'アカウント・設定',
                [
                  {'q': 'パスワードを忘れました', 'a': 'ログイン画面の「パスワードを忘れた方」から再設定できます。登録メールアドレスにリセットリンクが送信されます。'},
                  {'q': 'メールアドレスの変更方法は？', 'a': 'プロフィール → 設定 → アカウント情報 からメールアドレスを変更できます。'},
                  {'q': '退会したい', 'a': 'プロフィール → 設定 → アカウント管理 → 退会手続き から行えます。予約がある場合は完了後に退会可能です。'},
                ],
              ),
              _buildFAQItem(
                'ライブ配信・ギフト',
                [
                  {'q': 'ライブ配信を視聴するには？', 'a': 'ホーム画面の「ライブ」タブから配信中のスタッフを選択して視聴できます。'},
                  {'q': 'ギフトの送り方は？', 'a': 'ライブ配信中に画面下のギフトアイコンをタップし、送りたいギフトを選択してください。'},
                  {'q': 'ギフトの購入方法は？', 'a': 'プロフィール → ウォレット からコインを購入し、ライブ配信でギフトと交換できます。'},
                ],
              ),
              _buildFAQItem(
                'レビュー・評価',
                [
                  {'q': 'レビューの投稿方法は？', 'a': 'サービス完了後、予約履歴から「レビューを書く」ボタンをタップして評価とコメントを投稿できます。'},
                  {'q': 'レビューの編集・削除はできますか？', 'a': 'レビュー投稿後7日以内であれば、マイレビューから編集・削除が可能です。'},
                  {'q': '不適切なレビューを報告するには？', 'a': 'レビューの右上メニューから「報告する」を選択してください。'},
                ],
              ),
              _buildFAQItem(
                'トラブル・その他',
                [
                  {'q': 'スタッフと連絡が取れません', 'a': 'メッセージ機能で連絡できない場合は、運営サポートにお問い合わせください。'},
                  {'q': 'アプリが正常に動作しない', 'a': 'アプリを最新版に更新し、端末を再起動してください。それでも解決しない場合はサポートまでご連絡ください。'},
                  {'q': 'スタッフの情報が間違っています', 'a': '該当スタッフのプロフィール画面から「報告する」ボタンでご報告ください。'},
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
                        'お困りの際は',
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
                          Text('support@staffsearch.com'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('0120-XXX-XXXX'),
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
