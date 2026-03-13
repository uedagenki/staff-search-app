// SCREEN: Content Moderation Screen | ADMIN (no spec)
import '../../../utils/screen_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../utils/storage_helper.dart';
import 'dart:convert';

class ContentModerationScreen extends StatefulWidget {
  const ContentModerationScreen({super.key});

  @override
  State<ContentModerationScreen> createState() => _ContentModerationScreenState();
}

class _ContentModerationScreenState extends State<ContentModerationScreen> with ScreenLogMixin {
  @override
  String get screenId => 'Content Moderation Screen | ADMIN (no spec)';

  List<ContentItem> _allContent = [];
  List<ContentItem> _filteredContent = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _filterType = 'all'; // all, post, comment, story

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // サンプルコンテンツデータを生成
      _allContent = _generateSampleContent();
      _applyFilters();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load content: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<ContentItem> _generateSampleContent() {
    return [
      ContentItem(
        id: 'post_001',
        type: 'post',
        authorName: '山田太郎',
        authorId: 'user_001',
        content: '本日は美容室でカットとカラーをしてもらいました。担当スタッフさんが丁寧で満足です!',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        reportCount: 0,
        status: 'approved',
      ),
      ContentItem(
        id: 'post_002',
        type: 'post',
        authorName: '佐藤花子',
        authorId: 'user_002',
        content: 'スパムメッセージです。こちらのサイトをご覧ください → http://spam.example.com',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        reportCount: 3,
        status: 'reported',
      ),
      ContentItem(
        id: 'comment_001',
        type: 'comment',
        authorName: '田中一郎',
        authorId: 'user_003',
        content: 'とても参考になる投稿ですね!私も試してみます。',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        reportCount: 0,
        status: 'approved',
      ),
      ContentItem(
        id: 'comment_002',
        type: 'comment',
        authorName: '鈴木美咲',
        authorId: 'user_004',
        content: '不適切な言葉: バカ、クソ、最悪なサービス',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        reportCount: 5,
        status: 'reported',
      ),
      ContentItem(
        id: 'story_001',
        type: 'story',
        authorName: 'スタッフ 高橋',
        authorId: 'staff_001',
        content: '今日の新しいヘアスタイルを紹介します!',
        createdAt: DateTime.now().subtract(const Duration(hours: 16)),
        reportCount: 0,
        status: 'approved',
      ),
      ContentItem(
        id: 'post_003',
        type: 'post',
        authorName: '伊藤健',
        authorId: 'user_005',
        content: '個人情報を公開します: 電話番号 090-1234-5678、住所 東京都渋谷区...',
        createdAt: DateTime.now().subtract(const Duration(hours: 24)),
        reportCount: 8,
        status: 'reported',
      ),
    ];
  }

  void _applyFilters() {
    List<ContentItem> filtered = List.from(_allContent);

    // タイプフィルター
    if (_filterType != 'all') {
      filtered = filtered.where((item) => item.type == _filterType).toList();
    }

    // 検索フィルター
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.authorName.toLowerCase().contains(query) ||
               item.content.toLowerCase().contains(query);
      }).toList();
    }

    // 報告数でソート
    filtered.sort((a, b) => b.reportCount.compareTo(a.reportCount));

    setState(() {
      _filteredContent = filtered;
    });
  }

  Future<void> _approveContent(ContentItem item) async {
    try {
      setState(() {
        item.status = 'approved';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('コンテンツを承認しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('承認に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteContent(ContentItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('コンテンツ削除'),
        content: Text('このコンテンツを削除しますか?\n投稿者: ${item.authorName}\n\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() {
        _allContent.removeWhere((c) => c.id == item.id);
        _applyFilters();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('コンテンツを削除しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('削除に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showContentDetails(ContentItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ヘッダー
                  Row(
                    children: [
                      Icon(
                        _getContentIcon(item.type),
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getContentTypeLabel(item.type),
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              '投稿者: ${item.authorName}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(item.status),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // 詳細情報
                  _buildDetailRow('コンテンツID', item.id),
                  _buildDetailRow('投稿者ID', item.authorId),
                  _buildDetailRow('投稿日時', _formatDateTime(item.createdAt)),
                  _buildDetailRow('報告数', '${item.reportCount}件'),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // コンテンツ本文
                  Text(
                    'コンテンツ内容',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(item.content),
                  ),

                  const SizedBox(height: 24),

                  // アクションボタン
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('閉じる'),
                      ),
                      const SizedBox(width: 8),
                      if (item.status == 'reported')
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _approveContent(item);
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('承認'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _deleteContent(item);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('削除'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getContentIcon(String type) {
    switch (type) {
      case 'post':
        return Icons.article;
      case 'comment':
        return Icons.comment;
      case 'story':
        return Icons.auto_stories;
      default:
        return Icons.description;
    }
  }

  String _getContentTypeLabel(String type) {
    switch (type) {
      case 'post':
        return '投稿';
      case 'comment':
        return 'コメント';
      case 'story':
        return 'ストーリー';
      default:
        return '不明';
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'approved':
        color = Colors.green;
        label = '承認済み';
        break;
      case 'reported':
        color = Colors.red;
        label = '報告あり';
        break;
      case 'pending':
        color = Colors.orange;
        label = '保留中';
        break;
      default:
        color = Colors.grey;
        label = '不明';
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.2),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final reportedCount = _allContent.where((item) => item.reportCount > 0).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('コンテンツ管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '更新',
            onPressed: _loadContent,
          ),
        ],
      ),
      body: Column(
        children: [
          // 検索バーとフィルター
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '投稿者名またはコンテンツで検索',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => _applyFilters(),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('すべて'),
                        selected: _filterType == 'all',
                        onSelected: (selected) {
                          setState(() {
                            _filterType = 'all';
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('投稿'),
                        selected: _filterType == 'post',
                        onSelected: (selected) {
                          setState(() {
                            _filterType = 'post';
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('コメント'),
                        selected: _filterType == 'comment',
                        onSelected: (selected) {
                          setState(() {
                            _filterType = 'comment';
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('ストーリー'),
                        selected: _filterType == 'story',
                        onSelected: (selected) {
                          setState(() {
                            _filterType = 'story';
                            _applyFilters();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 統計サマリー
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            '${_allContent.length}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Text('総コンテンツ数'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            '$reportedCount',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Text('要対応'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // コンテンツリスト
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredContent.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'コンテンツが見つかりません',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredContent.length,
                        itemBuilder: (context, index) {
                          final item = _filteredContent[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: item.reportCount > 0 ? Colors.red[50] : null,
                            child: ListTile(
                              leading: Icon(
                                _getContentIcon(item.type),
                                color: item.reportCount > 0 ? Colors.red : Theme.of(context).primaryColor,
                              ),
                              title: Text(
                                item.authorName,
                                style: TextStyle(
                                  fontWeight: item.reportCount > 0 ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.content.length > 50
                                        ? '${item.content.substring(0, 50)}...'
                                        : item.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        _getContentTypeLabel(item.type),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (item.reportCount > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '報告 ${item.reportCount}件',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (item.status == 'reported')
                                    IconButton(
                                      icon: const Icon(Icons.check_circle),
                                      tooltip: '承認',
                                      color: Colors.green,
                                      onPressed: () => _approveContent(item),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    tooltip: '削除',
                                    color: Colors.red,
                                    onPressed: () => _deleteContent(item),
                                  ),
                                ],
                              ),
                              onTap: () => _showContentDetails(item),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class ContentItem {
  final String id;
  final String type; // post, comment, story
  final String authorName;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final int reportCount;
  String status; // approved, reported, pending

  ContentItem({
    required this.id,
    required this.type,
    required this.authorName,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.reportCount,
    required this.status,
  });
}
