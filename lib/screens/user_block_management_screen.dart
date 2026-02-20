import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';

class UserBlockManagementScreen extends StatefulWidget {
  const UserBlockManagementScreen({super.key});

  @override
  State<UserBlockManagementScreen> createState() => _UserBlockManagementScreenState();
}

class _UserBlockManagementScreenState extends State<UserBlockManagementScreen> {
  List<Map<String, dynamic>> _blockedStaff = [];
  List<String> _ngWords = [];
  final TextEditingController _ngWordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBlockedData();
  }

  @override
  void dispose() {
    _ngWordController.dispose();
    super.dispose();
  }

  void _loadBlockedData() {
    // ブロックしたスタッフリストを読み込み
    final blockedJson = html.window.localStorage['blocked_staff'];
    if (blockedJson != null) {
      try {
        final List<dynamic> data = jsonDecode(blockedJson);
        setState(() {
          _blockedStaff = data.cast<Map<String, dynamic>>();
        });
      } catch (e) {
        // エラー時は空リスト
      }
    }

    // NGワードリストを読み込み
    final ngWordsJson = html.window.localStorage['ng_words'];
    if (ngWordsJson != null) {
      try {
        final List<dynamic> data = jsonDecode(ngWordsJson);
        setState(() {
          _ngWords = data.cast<String>();
        });
      } catch (e) {
        // エラー時は空リスト
      }
    }
  }

  void _saveBlockedStaff() {
    html.window.localStorage['blocked_staff'] = jsonEncode(_blockedStaff);
  }

  void _saveNGWords() {
    html.window.localStorage['ng_words'] = jsonEncode(_ngWords);
  }

  void _unblockStaff(int index) {
    setState(() {
      _blockedStaff.removeAt(index);
    });
    _saveBlockedStaff();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ブロックを解除しました')),
    );
  }

  void _addNGWord() {
    final word = _ngWordController.text.trim();
    if (word.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NGワードを入力してください')),
      );
      return;
    }

    if (_ngWords.contains(word)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('既に登録されています')),
      );
      return;
    }

    setState(() {
      _ngWords.add(word);
    });
    _saveNGWords();
    _ngWordController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('NGワードを追加しました')),
    );
  }

  void _removeNGWord(int index) {
    setState(() {
      _ngWords.removeAt(index);
    });
    _saveNGWords();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('NGワードを削除しました')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ブロック管理'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ブロックしたスタッフセクション
            _buildSectionHeader(
              icon: Icons.block,
              title: 'ブロックしたスタッフ',
              subtitle: '${_blockedStaff.length}人',
            ),
            const SizedBox(height: 12),
            if (_blockedStaff.isEmpty)
              _buildEmptyState(
                icon: Icons.block_outlined,
                message: 'ブロックしたスタッフはいません',
              )
            else
              ..._blockedStaff.asMap().entries.map((entry) {
                final index = entry.key;
                final staff = entry.value;
                return _buildBlockedStaffCard(staff, index);
              }),
            
            const SizedBox(height: 32),
            
            // NGワードセクション
            _buildSectionHeader(
              icon: Icons.report,
              title: 'NGワード設定',
              subtitle: '${_ngWords.length}件',
            ),
            const SizedBox(height: 12),
            
            // NGワード追加フォーム
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NGワードを追加',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '登録したワードを含むメッセージや投稿は自動的に非表示になります',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ngWordController,
                            decoration: const InputDecoration(
                              hintText: 'NGワードを入力',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onSubmitted: (_) => _addNGWord(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addNGWord,
                          child: const Text('追加'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // NGワードリスト
            if (_ngWords.isEmpty)
              _buildEmptyState(
                icon: Icons.speaker_notes_off,
                message: 'NGワードは登録されていません',
              )
            else
              ..._ngWords.asMap().entries.map((entry) {
                final index = entry.key;
                final word = entry.value;
                return _buildNGWordCard(word, index);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(icon, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockedStaffCard(Map<String, dynamic> staff, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            staff['image'] ?? 'https://via.placeholder.com/150',
          ),
        ),
        title: Text(staff['name'] ?? '不明'),
        subtitle: Text(
          staff['category'] ?? '',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: OutlinedButton.icon(
          onPressed: () => _unblockStaff(index),
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('解除'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildNGWordCard(String word, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red[50],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.block, color: Colors.red, size: 20),
        ),
        title: Text(
          word,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          'このワードを含むコンテンツは非表示',
          style: TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('NGワードを削除'),
                content: Text('「$word」を削除しますか？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('キャンセル'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _removeNGWord(index);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('削除'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
