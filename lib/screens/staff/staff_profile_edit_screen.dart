import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StaffProfileEditScreen extends StatefulWidget {
  const StaffProfileEditScreen({super.key});

  @override
  State<StaffProfileEditScreen> createState() => _StaffProfileEditScreenState();
}

class _StaffProfileEditScreenState extends State<StaffProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController(text: '田中 美咲');
  final TextEditingController _jobTitleController = TextEditingController(text: '美容師');
  final TextEditingController _bioController = TextEditingController(
    text: '10年以上の経験を持つベテラン美容師です。お客様一人ひとりに合わせたスタイリングをご提案いたします。',
  );
  final TextEditingController _experienceController = TextEditingController(text: '10');
  final TextEditingController _locationController = TextEditingController(text: '東京都渋谷区');
  final TextEditingController _storeNameController = TextEditingController(text: 'Salon de Beaute 新宿');
  final TextEditingController _companyNameController = TextEditingController(text: 'ビューティーサロングループ');
  
  // 店舗/会社の位置情報（緯度・経度の文字列）
  String? _storeLatitude;
  String? _storeLongitude;

  List<String> _profileImages = [
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
  ];
  bool _isSaving = false;
  final int _maxImages = 5;

  // サンプル画像リスト
  final List<String> _sampleImages = [
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
    'https://i.pravatar.cc/400?img=45',
    'https://i.pravatar.cc/400?img=23',
    'https://i.pravatar.cc/400?img=47',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _jobTitleController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _locationController.dispose();
    _storeNameController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'プロフィール画像を選択',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _sampleImages.length + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // カメラボタン
                        return _buildImageOption(
                          icon: Icons.camera_alt,
                          label: 'カメラ',
                          color: Colors.blue,
                          onTap: () {
                            Navigator.pop(context);
                            _showCameraFeatureDialog();
                          },
                        );
                      } else if (index == 1) {
                        // ギャラリーボタン
                        return _buildImageOption(
                          icon: Icons.photo_library,
                          label: 'ギャラリー',
                          color: Colors.green,
                          onTap: () {
                            Navigator.pop(context);
                            _showGalleryFeatureDialog();
                          },
                        );
                      } else {
                        // サンプル画像
                        final imageUrl = _sampleImages[index - 2];
                        final isSelected = _profileImages.contains(imageUrl);
                        return GestureDetector(
                          onTap: () {
                            if (isSelected) {
                              // 選択解除（最低1枚は必要）
                              if (_profileImages.length > 1) {
                                setState(() {
                                  _profileImages.remove(imageUrl);
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('最低1枚の画像が必要です'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            } else {
                              // 選択追加（最大5枚まで）
                              if (_profileImages.length < _maxImages) {
                                setState(() {
                                  _profileImages.add(imageUrl);
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('画像は最大$_maxImages枚までです'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey[300]!,
                                    width: isSelected ? 3 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${_profileImages.indexOf(imageUrl) + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCameraFeatureDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.camera_alt, color: Colors.blue),
            SizedBox(width: 8),
            Text('カメラで撮影'),
          ],
        ),
        content: const Text('カメラ機能は開発中です。\n\n実際のアプリでは、デバイスのカメラを起動して写真を撮影できます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showGalleryFeatureDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.photo_library, color: Colors.green),
            SizedBox(width: 8),
            Text('ギャラリーから選択'),
          ],
        ),
        content: const Text('ギャラリー機能は開発中です。\n\n実際のアプリでは、デバイスのギャラリーから写真を選択できます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    // 保存処理のシミュレーション
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _storeLatitude != null && _storeLongitude != null
                ? 'プロフィールと店舗位置を保存しました'
                : 'プロフィールを保存しました',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
  
  Future<void> _pickStoreLocation() async {
    // 簡易的な位置入力ダイアログ
    final latController = TextEditingController(text: _storeLatitude ?? '35.6895');
    final lngController = TextEditingController(text: _storeLongitude ?? '139.6917');
    
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.map, color: Colors.blue),
            SizedBox(width: 8),
            Text('店舗位置を設定'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '店舗の緯度・経度を入力してください',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: latController,
              decoration: const InputDecoration(
                labelText: '緯度',
                hintText: '例: 35.6895',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.public),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lngController,
              decoration: const InputDecoration(
                labelText: '経度',
                hintText: '例: 139.6917',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.public),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 位置の調べ方:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1. Google Mapsで店舗を検索\n2. 右クリックして座標をコピー\n3. ここに貼り付け',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, {
                'latitude': latController.text,
                'longitude': lngController.text,
              });
            },
            child: const Text('設定'),
          ),
        ],
      ),
    );
    
    if (result != null && mounted) {
      setState(() {
        _storeLatitude = result['latitude'];
        _storeLongitude = result['longitude'];
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('店舗位置を設定しました'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
    
    latController.dispose();
    lngController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール編集'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // プロフィール画像
              const Text(
                'プロフィール画像（最大5枚）',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _profileImages.length + (_profileImages.length < _maxImages ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _profileImages.length) {
                      // 既存の画像
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: _profileImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // 順番表示
                            Positioned(
                              top: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // 削除ボタン（最低1枚は残す）
                            if (_profileImages.length > 1)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _profileImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    } else {
                      // 追加ボタン
                      return GestureDetector(
                        onTap: _showImagePickerDialog,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[400]!,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 32,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '追加',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),

              // 基本情報
              const Text(
                '基本情報',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '名前',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _jobTitleController,
                decoration: const InputDecoration(
                  labelText: '職種',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '経験年数',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.stars),
                  suffixText: '年',
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: '勤務地',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _storeNameController,
                decoration: InputDecoration(
                  labelText: '店舗名',
                  hintText: '所属店舗名を入力',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.store),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _storeLatitude != null && _storeLongitude != null 
                          ? Icons.map 
                          : Icons.add_location,
                      color: _storeLatitude != null && _storeLongitude != null 
                          ? Colors.green 
                          : Colors.grey,
                    ),
                    onPressed: _pickStoreLocation,
                    tooltip: '位置を設定',
                  ),
                ),
              ),
              if (_storeLatitude != null && _storeLongitude != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    '📍 位置設定済み (緯度: $_storeLatitude, 経度: $_storeLongitude)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              TextField(
                controller: _companyNameController,
                decoration: const InputDecoration(
                  labelText: '会社名',
                  hintText: '所属会社名を入力',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 24),

              // 自己紹介
              const Text(
                '自己紹介',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _bioController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '自己紹介文',
                  hintText: 'あなたの経験やスキル、得意なことなどを記入してください',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // 保存ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '保存',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // キャンセルボタン
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'キャンセル',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
