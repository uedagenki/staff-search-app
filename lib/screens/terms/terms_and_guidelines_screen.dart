import 'package:flutter/material.dart';

/// 利用規約・ガイドライン画面
class TermsAndGuidelinesScreen extends StatefulWidget {
  const TermsAndGuidelinesScreen({super.key});

  @override
  State<TermsAndGuidelinesScreen> createState() => _TermsAndGuidelinesScreenState();
}

class _TermsAndGuidelinesScreenState extends State<TermsAndGuidelinesScreen> {
  int _selectedIndex = 0;

  final List<String> _tabTitles = [
    'コミュニティ\nガイドライン',
    'ライブ配信\nガイドライン',
    '著作権\nポリシー',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('利用規約・ガイドライン'),
      ),
      body: Row(
        children: [
          // 左側のタブメニュー
          Container(
            width: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                right: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: ListView.builder(
              itemCount: _tabTitles.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedIndex;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade50 : null,
                      border: Border(
                        left: BorderSide(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Text(
                      _tabTitles[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.grey.shade700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 右側のコンテンツ
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildCommunityGuidelines();
      case 1:
        return _buildLiveStreamingGuidelines();
      case 2:
        return _buildCopyrightPolicy();
      default:
        return const SizedBox();
    }
  }

  // コミュニティガイドライン
  Widget _buildCommunityGuidelines() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('コミュニティガイドライン'),
        const SizedBox(height: 8),
        _buildSectionSubtitle('安全で健全なコミュニティを維持するためのルール'),
        const SizedBox(height: 24),

        _buildGuideline(
          icon: Icons.not_interested,
          title: '禁止行為',
          items: [
            '暴力的・攻撃的なコンテンツの投稿',
            '差別的・侮辱的な言動',
            'ヌードや性的なコンテンツ',
            '違法行為の助長や実行',
            '他人のプライバシー侵害',
            'スパムや詐欺行為',
            '未成年者に対する不適切な行為',
            'なりすましや虚偽の情報',
          ],
        ),

        const SizedBox(height: 24),
        _buildGuideline(
          icon: Icons.verified_user,
          title: '年齢制限',
          items: [
            '13歳未満：アカウント登録不可',
            '13-15歳：基本機能（視聴・いいね・コメント）のみ',
            '16歳以上：DM送信・動画ダウンロード可能',
            '18歳以上：ライブ配信可能（年齢確認必須）',
            '※ 13歳未満と判明した場合、アカウントは永久停止されます',
          ],
        ),

        const SizedBox(height: 24),
        _buildGuideline(
          icon: Icons.security,
          title: '安全機能',
          items: [
            'ブロック機能：不快なユーザーをブロック',
            '通報機能：違反行為を運営に報告',
            'プライバシー設定：誰が自分のコンテンツを見られるか制御',
            '禁止ワードフィルター：不適切な言葉を自動検出',
            'ストーカー行為検知：過度な接触を防止',
          ],
        ),

        const SizedBox(height: 24),
        _buildGuideline(
          icon: Icons.favorite,
          title: '推奨行動',
          items: [
            '他者への敬意を持った交流',
            '建設的で前向きなコメント',
            'オリジナルコンテンツの作成',
            '適切な年齢層向けのコンテンツ',
            'プライバシーへの配慮',
          ],
        ),
      ],
    );
  }

  // ライブ配信ガイドライン
  Widget _buildLiveStreamingGuidelines() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('ライブ配信ガイドライン'),
        const SizedBox(height: 8),
        _buildSectionSubtitle('安全で楽しいライブ配信のためのルール'),
        const SizedBox(height: 24),

        _buildGuideline(
          icon: Icons.live_tv,
          title: 'ライブ配信の基本ルール',
          items: [
            '配信者は18歳以上であること（年齢確認必須）',
            '本人確認が完了していること',
            '店舗所属または100人以上のフォロワーが必要',
            '公序良俗に反する内容の配信禁止',
            '第三者の権利を侵害する配信禁止',
          ],
        ),

        const SizedBox(height: 24),
        _buildGuideline(
          icon: Icons.not_interested,
          title: 'ライブ配信で禁止される行為',
          items: [
            '暴力的・攻撃的な内容',
            'ヌードや性的に露骨な表現',
            '薬物使用や違法行為',
            '危険行為や自傷行為',
            '差別的・侮辱的な発言',
            '未成年者の出演（配信者本人を除く）',
            '飲酒・喫煙の過度な表現',
            '著作権侵害（無断での音楽使用等）',
          ],
        ),

        const SizedBox(height: 24),
        _buildGuideline(
          icon: Icons.supervisor_account,
          title: 'モデレーション',
          items: [
            'コメント欄での不適切な発言の削除',
            '荒らし行為をするユーザーのブロック',
            '禁止ワードフィルターの有効化',
            'スローモード（投稿制限）の活用',
            'フォロワーのみのコメント制限',
          ],
        ),

        const SizedBox(height: 24),
        _buildGuideline(
          icon: Icons.monetization_on,
          title: '収益化について',
          items: [
            '投げ銭機能は18歳以上のみ利用可能',
            '店舗所属スタッフは還元率に応じて収益を受け取れます',
            '収益の受け取りには本人確認が必要',
            '税務申告は配信者の責任で行ってください',
          ],
        ),

        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Text(
                    '違反時のペナルティ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '• 軽度の違反：警告またはライブ配信の一時停止\n'
                '• 重度の違反：アカウント停止または永久BAN\n'
                '• 違法行為：関係機関への通報',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 著作権ポリシー
  Widget _buildCopyrightPolicy() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('著作権ポリシー'),
        const SizedBox(height: 8),
        _buildSectionSubtitle('知的財産権の保護と尊重'),
        const SizedBox(height: 24),

        _buildGuideline(
          icon: Icons.copyright,
          title: '著作権の基本',
          items: [
            '他人の著作物を無断で使用してはいけません',
            '音楽、動画、画像、テキストなど全てが対象',
            '著作権は自動的に発生し、登録は不要',
            '著作権侵害は法的責任を問われる可能性があります',
          ],
        ),

        const SizedBox(height: 24),
        _buildGuideline(
          icon: Icons.music_note,
          title: '音楽の使用について',
          items: [
            'ライブ配信での無断音楽使用は禁止',
            'JASRACなどへの許諾が必要',
            'ロイヤリティフリー音源の使用を推奨',
            'カバー演奏も原則として許諾が必要',
            '自作曲の使用は問題ありません',
          ],
        ),

        const SizedBox(height: 24),
        _buildGuideline(
          icon: Icons.image,
          title: '画像・動画の使用',
          items: [
            '他人が撮影した写真や動画の無断使用禁止',
            'テレビ番組やアニメの映像使用禁止',
            '著作権フリー素材の使用を推奨',
            '引用の場合も出典を明記',
          ],
        ),

        const SizedBox(height: 24),
        _buildGuideline(
          icon: Icons.report,
          title: '著作権侵害の通報',
          items: [
            '自分の著作物が無断使用されている場合',
            '通報フォームから詳細を記載',
            '著作権の証明資料を添付',
            '運営が確認後、適切な措置を実施',
          ],
        ),

        const SizedBox(height: 24),
        _buildGuideline(
          icon: Icons.check_circle,
          title: '安全な使用方法',
          items: [
            'オリジナルコンテンツの作成',
            '著作権フリー素材の活用',
            '正規のライセンスを取得',
            'クリエイティブ・コモンズ素材の利用',
            '引用の際は適切な方法で',
          ],
        ),

        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'フェアユース（公正利用）について',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '批評、コメント、ニュース報道、教育、研究などの目的で、'
                '限定的に著作物を引用することは認められる場合があります。'
                'ただし、日本の著作権法に基づき適切な引用方法を守る必要があります。',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSectionSubtitle(String subtitle) {
    return Text(
      subtitle,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildGuideline({
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
