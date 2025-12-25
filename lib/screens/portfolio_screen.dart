import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  List<Map<String, dynamic>> _portfolioItems = [];

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  void _loadPortfolio() {
    try {
      final portfolioJson = html.window.localStorage['staff_portfolio'];
      if (portfolioJson != null && portfolioJson.isNotEmpty) {
        final items = jsonDecode(portfolioJson) as List;
        setState(() {
          _portfolioItems = items.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      }
    } catch (e) {
      debugPrint('ポートフォリオデータの読み込みエラー: $e');
    }
  }

  void _savePortfolio() {
    try {
      html.window.localStorage['staff_portfolio'] = jsonEncode(_portfolioItems);

      // staff_profileにも追加
      final profileJson = html.window.localStorage['staff_profile'];
      if (profileJson != null) {
        final profile = jsonDecode(profileJson) as Map<String, dynamic>;
        profile['portfolio'] = _portfolioItems;
        html.window.localStorage['staff_profile'] = jsonEncode(profile);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ポートフォリオを保存しました'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存エラー: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addPortfolioItem() {
    showDialog(
      context: context,
      builder: (context) => _PortfolioItemDialog(
        onSave: (title, description, imageData) {
          setState(() {
            _portfolioItems.add({
              'title': title,
              'description': description,
              'image': imageData,
              'createdAt': DateTime.now().toIso8601String(),
            });
          });
          _savePortfolio();
        },
      ),
    );
  }

  void _editPortfolioItem(int index) {
    final item = _portfolioItems[index];
    showDialog(
      context: context,
      builder: (context) => _PortfolioItemDialog(
        initialTitle: item['title'],
        initialDescription: item['description'],
        initialImage: item['image'],
        onSave: (title, description, imageData) {
          setState(() {
            _portfolioItems[index] = {
              'title': title,
              'description': description,
              'image': imageData,
              'createdAt': item['createdAt'],
              'updatedAt': DateTime.now().toIso8601String(),
            };
          });
          _savePortfolio();
        },
      ),
    );
  }

  void _deletePortfolioItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('この作品を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _portfolioItems.removeAt(index);
              });
              _savePortfolio();
              Navigator.pop(context);
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ポートフォリオ'),
        actions: [
          IconButton(
            onPressed: _addPortfolioItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _portfolioItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'ポートフォリオはまだありません',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addPortfolioItem,
                    icon: const Icon(Icons.add),
                    label: const Text('作品を追加'),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: _portfolioItems.length,
              itemBuilder: (context, index) {
                final item = _portfolioItems[index];
                return GestureDetector(
                  onTap: () => _editPortfolioItem(index),
                  onLongPress: () => _deletePortfolioItem(index),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: item['image'] != null
                              ? Image.memory(
                                  base64Decode(item['image'].split(',').last),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : Container(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  child: const Icon(Icons.image, size: 60, color: Colors.grey),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] ?? '無題',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item['description'] != null && item['description'].isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item['description'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _PortfolioItemDialog extends StatefulWidget {
  final String? initialTitle;
  final String? initialDescription;
  final String? initialImage;
  final Function(String title, String description, String? imageData) onSave;

  const _PortfolioItemDialog({
    this.initialTitle,
    this.initialDescription,
    this.initialImage,
    required this.onSave,
  });

  @override
  State<_PortfolioItemDialog> createState() => _PortfolioItemDialogState();
}

class _PortfolioItemDialogState extends State<_PortfolioItemDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _imageData;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
    _imageData = widget.initialImage;
  }

  void _pickImage() {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((e) {
          setState(() {
            _imageData = reader.result as String?;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialTitle == null ? '作品を追加' : '作品を編集'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _imageData != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          base64Decode(_imageData!.split(',').last),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          const Text(
                            '写真を選択',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '説明',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(
              _titleController.text,
              _descriptionController.text,
              _imageData,
            );
            Navigator.pop(context);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
