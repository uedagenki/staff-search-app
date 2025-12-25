import 'package:flutter/material.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('レビュー管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 評価サマリー
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      '総合評価',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          '5.0',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '/ 5.0',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 24),
                        Icon(Icons.star, color: Colors.orange, size: 24),
                        Icon(Icons.star, color: Colors.orange, size: 24),
                        Icon(Icons.star, color: Colors.orange, size: 24),
                        Icon(Icons.star, color: Colors.orange, size: 24),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '456件のレビュー',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 評価分布
                    _buildRatingBar(5, 412, 456),
                    _buildRatingBar(4, 32, 456),
                    _buildRatingBar(3, 8, 456),
                    _buildRatingBar(2, 3, 456),
                    _buildRatingBar(1, 1, 456),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // レビュー一覧
            const Text(
              '最近のレビュー',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildReviewCard(
              '田中 美咲',
              5,
              '2024/12/20',
              'とても丁寧な対応で満足しています！カットの技術も素晴らしく、また利用したいと思います。ありがとうございました！',
              null,
            ),
            _buildReviewCard(
              '山田 花子',
              5,
              '2024/12/18',
              '希望通りの仕上がりで大満足です。カウンセリングも丁寧で安心してお任せできました。',
              'ありがとうございます！またのご来店お待ちしております。',
            ),
            _buildReviewCard(
              '佐藤 健',
              5,
              '2024/12/15',
              'ライブ配信で見た通りの技術力でした。予約してよかったです！',
              null,
            ),
            _buildReviewCard(
              '鈴木 一郎',
              4,
              '2024/12/10',
              '全体的には満足していますが、もう少し早めに終われればなお良かったです。',
              'ご意見ありがとうございます。時間配分を改善いたします。',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    double percentage = (count / total) * 100;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Row(
              children: [
                Text('$stars', style: const TextStyle(fontSize: 13)),
                const Icon(Icons.star, size: 14, color: Colors.orange),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: count / total,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    String userName,
    int rating,
    String date,
    String comment,
    String? reply,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: Text(userName[0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) => Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              size: 14,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              comment,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            if (reply != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.reply, size: 14, color: Colors.blue[700]),
                        const SizedBox(width: 4),
                        Text(
                          'あなたの返信',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      reply,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (reply == null)
                  TextButton.icon(
                    onPressed: () {
                      // 返信ダイアログ表示
                    },
                    icon: const Icon(Icons.reply, size: 16),
                    label: const Text('返信する', style: TextStyle(fontSize: 13)),
                  )
                else
                  TextButton.icon(
                    onPressed: () {
                      // 返信編集ダイアログ表示
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('返信を編集', style: TextStyle(fontSize: 13)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
