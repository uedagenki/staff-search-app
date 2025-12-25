import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';

// 店舗・会社検索ダイアログ
class StoreSearchDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSelect;
  
  const StoreSearchDialog({super.key, required this.onSelect});

  @override
  State<StoreSearchDialog> createState() => _StoreSearchDialogState();
}

class _StoreSearchDialogState extends State<StoreSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _showManualInput = false;
  
  // 手動入力用コントローラー
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // 模擬検索機能（実際のGoogle Places APIの代わり）
  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // 模擬的な検索結果を生成（実際の実装ではGoogle Places APIを使用）
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _searchResults = _generateMockResults(query);
      _isSearching = false;
    });
  }

  List<Map<String, dynamic>> _generateMockResults(String query) {
    // 日本の主要都市
    final cities = ['東京', '大阪', '名古屋', '福岡', '札幌', '横浜', '神戸', '京都'];
    
    // 業種タイプ
    final businessTypes = [
      {'type': '美容室', 'icon': '💇'},
      {'type': 'ネイルサロン', 'icon': '💅'},
      {'type': 'エステサロン', 'icon': '✨'},
      {'type': '飲食店', 'icon': '🍴'},
      {'type': 'カフェ', 'icon': '☕'},
      {'type': 'オフィス', 'icon': '🏢'},
    ];

    // クエリに基づいて結果を生成
    List<Map<String, dynamic>> results = [];
    
    for (var city in cities) {
      for (var business in businessTypes) {
        if (query.length >= 2) {
          // クエリが店舗タイプまたは都市名に部分一致する場合
          if (business['type'].toString().contains(query) || 
              city.contains(query) ||
              query.contains(business['type'].toString()) ||
              query.contains(city)) {
            results.add({
              'name': '${business['icon']} ${business['type']} $city店',
              'address': '$city都${city}区1-2-3',
              'type': business['type'],
              'latitude': 35.6812 + (results.length * 0.01),
              'longitude': 139.7671 + (results.length * 0.01),
            });
          }
        }
      }
    }

    // 結果が多い場合は制限
    if (results.length > 10) {
      results = results.sublist(0, 10);
    }

    // 結果がない場合は一般的な結果を返す
    if (results.isEmpty && query.isNotEmpty) {
      results.add({
        'name': '$query (検索結果)',
        'address': '住所情報なし',
        'type': '一般',
        'latitude': 35.6812,
        'longitude': 139.7671,
      });
    }

    return results;
  }

  void _selectPlace(Map<String, dynamic> place) {
    widget.onSelect({
      'storeName': place['name'],
      'storeAddress': place['address'],
      'storeLatitude': place['latitude'],
      'storeLongitude': place['longitude'],
    });
    Navigator.pop(context);
  }

  void _saveManualInput() {
    if (_nameController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('店舗名と住所を入力してください')),
      );
      return;
    }

    widget.onSelect({
      'storeName': _nameController.text,
      'storeAddress': _addressController.text,
      'storeLatitude': 35.6812, // デフォルト座標（東京）
      'storeLongitude': 139.7671,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '店舗・会社を検索',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // タブ切り替え
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('地図から検索'),
                  icon: Icon(Icons.search),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('手動入力'),
                  icon: Icon(Icons.edit),
                ),
              ],
              selected: {_showManualInput},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _showManualInput = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),

            if (!_showManualInput) ...[
              // 検索モード
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '店舗名、会社名、住所で検索...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  _searchPlaces(value);
                },
              ),
              const SizedBox(height: 16),

              // 検索結果
              Expanded(
                child: _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : _searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.store,
                                  size: 64,
                                  color: Colors.grey.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchController.text.isEmpty
                                      ? '店舗名や住所を入力して検索'
                                      : '検索結果がありません',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final place = _searchResults[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.store),
                                  ),
                                  title: Text(
                                    place['name'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              place['address'] ?? '',
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () => _selectPlace(place),
                                ),
                              );
                            },
                          ),
              ),
            ] else ...[
              // 手動入力モード
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '店舗・会社情報を入力してください',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: '店舗名・会社名',
                          hintText: '例: ABC美容室 渋谷店',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.business),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: '住所',
                          hintText: '例: 東京都渋谷区1-2-3',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, size: 20, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'ヒント',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              '• 店舗名には支店名も含めてください\n'
                              '• 住所は都道府県から入力してください\n'
                              '• 正確な情報を入力すると信頼性が高まります',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _saveManualInput,
                          icon: const Icon(Icons.check),
                          label: const Text('この情報で登録'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
