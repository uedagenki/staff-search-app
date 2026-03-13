// SCREEN: Privacy Policy Screen | AUTH-01
import 'package:flutter/material.dart';

/// プライバシーポリシー表示画面
class PrivacyPolicyScreen extends StatelessWidget {
  final bool showAcceptButton;
  final VoidCallback? onAccept;

  const PrivacyPolicyScreen({
    super.key,
    this.showAcceptButton = false,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    debugPrint('📱 SCREEN: Privacy Policy Screen | AUTH-01'); // debug only

    return Scaffold(
      appBar: AppBar(
        title: const Text('プライバシーポリシー'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '1. はじめに',
              'staffsearch（以下「当アプリ」）は、ユーザーの皆様のプライバシーを尊重し、'
              '個人情報の保護に努めます。本プライバシーポリシーは、当アプリがどのような'
              '個人情報を収集し、どのように利用・管理するかを説明するものです。',
            ),
            _buildSection(
              '2. 収集する情報',
              '当アプリは以下の情報を収集します：\n\n'
              '【アカウント情報】\n'
              '・メールアドレス\n'
              '・氏名\n'
              '・プロフィール画像\n'
              '・自己紹介文\n\n'
              '【利用情報】\n'
              '・予約履歴\n'
              '・メッセージ履歴\n'
              '・レビュー・評価\n'
              '・決済情報（ポイント購入履歴）\n\n'
              '【位置情報】\n'
              '・スタッフ検索時の現在地情報（ユーザーの同意がある場合のみ）\n\n'
              '【デバイス情報】\n'
              '・デバイスID\n'
              '・OSバージョン\n'
              '・アプリバージョン',
            ),
            _buildSection(
              '3. 情報の利用目的',
              '収集した情報は以下の目的で利用します：\n\n'
              '・サービスの提供・運営\n'
              '・ユーザーサポート\n'
              '・予約管理・メッセージ配信\n'
              '・決済処理\n'
              '・サービス品質の向上\n'
              '・統計データの作成\n'
              '・不正利用の防止',
            ),
            _buildSection(
              '4. 情報の第三者提供',
              '当アプリは、以下の場合を除き、ユーザーの個人情報を第三者に提供しません：\n\n'
              '・ユーザーの同意がある場合\n'
              '・法令に基づく場合\n'
              '・人の生命、身体または財産の保護のために必要がある場合\n\n'
              '【第三者サービス】\n'
              '当アプリは以下のサービスを利用しています：\n'
              '・Firebase（Google）: データベース、認証、ストレージ\n'
              '・Stripe: 決済処理\n'
              '・Agora: ライブ配信機能\n'
              '・Google Maps: 地図表示',
            ),
            _buildSection(
              '5. 情報の管理',
              '当アプリは、個人情報への不正アクセス、紛失、破壊、改ざん、漏洩を防ぐため、'
              '適切なセキュリティ対策を講じます。\n\n'
              '・データの暗号化\n'
              '・アクセス制限\n'
              '・定期的なセキュリティ監査',
            ),
            _buildSection(
              '6. ユーザーの権利',
              'ユーザーは以下の権利を有します：\n\n'
              '・個人情報の開示請求\n'
              '・個人情報の訂正・削除請求\n'
              '・個人情報の利用停止請求\n'
              '・アカウントの削除\n\n'
              'これらの請求は、アプリ内の設定画面またはサポート窓口から行うことができます。',
            ),
            _buildSection(
              '7. Cookie・トラッキング技術',
              '当アプリは、サービス向上のため、以下の技術を使用する場合があります：\n\n'
              '・Cookie\n'
              '・ローカルストレージ\n'
              '・アクセス解析ツール（Firebase Analytics）',
            ),
            _buildSection(
              '8. 未成年者の個人情報',
              '当アプリは、18歳未満の方による利用を想定していません。'
              '18歳未満の方が利用する場合は、保護者の同意が必要です。',
            ),
            _buildSection(
              '9. プライバシーポリシーの変更',
              '当アプリは、必要に応じて本プライバシーポリシーを変更することがあります。'
              '変更後のプライバシーポリシーは、アプリ内で通知し、または当アプリのウェブサイトに掲載します。',
            ),
            _buildSection(
              '10. お問い合わせ',
              '本プライバシーポリシーに関するお問い合わせは、以下までご連絡ください：\n\n'
              'メール: support@staffsearch.example.com\n'
              'アプリ内サポート: 設定 > ヘルプ・サポート',
            ),
            _buildSection(
              '制定日',
              '2025年1月1日',
              isLastSection: true,
            ),
            if (showAcceptButton && onAccept != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.privacy_tip,
                      size: 48,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '上記のプライバシーポリシーをお読みいただき、'
                      '同意される場合は下のボタンをタップしてください。',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          '同意して続ける',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, {bool isLastSection = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLastSection ? 0 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
