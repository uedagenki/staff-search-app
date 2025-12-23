import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/job_categories.dart';

class FilterSettingsScreen extends StatefulWidget {
  const FilterSettingsScreen({super.key});

  @override
  State<FilterSettingsScreen> createState() => _FilterSettingsScreenState();
}

class _FilterSettingsScreenState extends State<FilterSettingsScreen> {
  double _maxDistance = 50.0; // km
  double _minRating = 0.0;
  bool _onlineOnly = false;
  String _selectedCategory = 'すべて';
  bool _isLoading = true;

  final List<String> _categories = ['すべて'];

  @override
  void initState() {
    super.initState();
    _categories.addAll(JobCategories.getCategoryNames());
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _maxDistance = prefs.getDouble('filter_max_distance') ?? 50.0;
      _minRating = prefs.getDouble('filter_min_rating') ?? 0.0;
      _onlineOnly = prefs.getBool('filter_online_only') ?? false;
      _selectedCategory = prefs.getString('filter_category') ?? 'すべて';
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('filter_max_distance', _maxDistance);
    await prefs.setDouble('filter_min_rating', _minRating);
    await prefs.setBool('filter_online_only', _onlineOnly);
    await prefs.setString('filter_category', _selectedCategory);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('設定を保存しました'),
          duration: Duration(seconds: 1),
        ),
      );
      Navigator.pop(context, true); // true = 設定が変更された
    }
  }

  Future<void> _resetSettings() async {
    setState(() {
      _maxDistance = 50.0;
      _minRating = 0.0;
      _onlineOnly = false;
      _selectedCategory = 'すべて';
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('filter_max_distance');
    await prefs.remove('filter_min_rating');
    await prefs.remove('filter_online_only');
    await prefs.remove('filter_category');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('設定をリセットしました'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('絞り込み設定'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _resetSettings,
            child: const Text(
              'リセット',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 距離設定
            _buildSectionTitle('距離範囲', Icons.location_on),
            const SizedBox(height: 16),
            _buildDistanceSlider(),
            const SizedBox(height: 32),

            // カテゴリー設定
            _buildSectionTitle('カテゴリー', Icons.category),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            const SizedBox(height: 32),

            // 評価設定
            _buildSectionTitle('最低評価', Icons.star),
            const SizedBox(height: 16),
            _buildRatingSlider(),
            const SizedBox(height: 32),

            // オンラインのみ
            _buildSectionTitle('オンライン状態', Icons.online_prediction),
            const SizedBox(height: 16),
            _buildOnlineSwitch(),
            const SizedBox(height: 48),

            // 適用ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '設定を適用',
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
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceSlider() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '現在地からの距離',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _maxDistance >= 100 ? '制限なし' : '${_maxDistance.toInt()}km以内',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('1km', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _maxDistance,
                  min: 1,
                  max: 100,
                  divisions: 99,
                  label: _maxDistance >= 100 ? '制限なし' : '${_maxDistance.toInt()}km',
                  onChanged: (value) {
                    setState(() {
                      _maxDistance = value;
                    });
                  },
                ),
              ),
              const Text('100km+', style: TextStyle(fontSize: 12)),
            ],
          ),
          if (_maxDistance >= 100)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '距離制限なしで全てのスタッフを表示します',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '表示するカテゴリーを選択',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSlider() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '最低評価',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Text(
                    _minRating == 0 ? '制限なし' : '${_minRating.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (_minRating > 0) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('0', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _minRating,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  label: _minRating == 0 ? '制限なし' : _minRating.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      _minRating = value;
                    });
                  },
                ),
              ),
              const Text('5.0', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineSwitch() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _onlineOnly ? Colors.green[100] : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.online_prediction,
              color: _onlineOnly ? Colors.green : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'オンラインのみ表示',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '出勤中のスタッフのみ表示',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _onlineOnly,
            onChanged: (value) {
              setState(() {
                _onlineOnly = value;
              });
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
