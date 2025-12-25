import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';
import '../../widgets/store_search_dialog.dart';

class StaffProfileEditScreen extends StatefulWidget {
  const StaffProfileEditScreen({super.key});

  @override
  State<StaffProfileEditScreen> createState() => _StaffProfileEditScreenState();
}

class _StaffProfileEditScreenState extends State<StaffProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _storeAddressController = TextEditingController(); // 店舗住所
  
  String _selectedGender = 'male';
  String _selectedJobTitle = 'beautician';
  int _experienceYears = 1;
  int _age = 20;
  double? _storeLatitude; // 店舗緯度
  double? _storeLongitude; // 店舗経度
  
  List<Map<String, dynamic>> _profileImages = [];
  bool _isSaving = false;
  final int _maxImages = 5;

  final List<String> _jobTitles = [
    '美容師',
    'コンサルタント',
    'トレーナー',
    '弁護士・士業',
    'デザイナー',
    'エンジニア',
    '講師・教師',
    '医療従事者',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // 店舗検索ダイアログを表示
  void _showStoreSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => StoreSearchDialog(
        onSelect: (storeData) {
          setState(() {
            _storeNameController.text = storeData['storeName'] ?? '';
            _storeAddressController.text = storeData['storeAddress'] ?? '';
            _storeLatitude = storeData['storeLatitude'];
            _storeLongitude = storeData['storeLongitude'];
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _storeNameController.dispose();
    _companyNameController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _storeAddressController.dispose();
    super.dispose();
  }

  void _loadProfileData() {
    try {
      final profileJson = html.window.localStorage['staff_profile'];
      debugPrint('===== プロフィールデータロード開始 =====');
      debugPrint('LocalStorage staff_profile: $profileJson');
      
      if (profileJson != null) {
        final profile = json.decode(profileJson) as Map<String, dynamic>;
        debugPrint('デコードされたプロフィール: ${profile.keys}');
        debugPrint('Email: ${profile['email']}');
        
        setState(() {
          _nameController.text = profile['name'] ?? '';
          _storeNameController.text = profile['storeName'] ?? '';
          _companyNameController.text = profile['companyName'] ?? '';
          _bioController.text = profile['bio'] ?? '';
          _addressController.text = profile['address'] ?? profile['location'] ?? '';
          _emailController.text = profile['email'] ?? '';
          _storeAddressController.text = profile['storeAddress'] ?? '';
          _storeLatitude = profile['storeLatitude']?.toDouble();
          _storeLongitude = profile['storeLongitude']?.toDouble();
          
          // 経験年数を抽出
          final expStr = profile['experience']?.toString() ?? '1';
          _experienceYears = int.tryParse(expStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
          
          _age = profile['age'] ?? 20;
          _selectedGender = profile['gender'] ?? 'male';
          
          // 職種
          final jobTitle = profile['jobTitle'] ?? '';
          _selectedJobTitle = _getJobTitleCode(jobTitle);
          
          // プロフィール画像
          if (profile['profileImages'] != null) {
            final images = profile['profileImages'] as List;
            _profileImages = images.map((img) {
              if (img is Map) {
                return Map<String, dynamic>.from(img);
              } else if (img is String) {
                return {'data': img, 'name': 'profile.png'};
              }
              return {'data': '', 'name': ''};
            }).toList();
          }
        });
        
        debugPrint('ロード完了 - Name: ${_nameController.text}, Email: ${_emailController.text}');
        debugPrint('画像数: ${_profileImages.length}');
      } else {
        debugPrint('⚠️ staff_profile がLocalStorageに存在しません');
      }
    } catch (e) {
      debugPrint('❌ プロフィールデータロードエラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('プロフィールデータの読み込みに失敗しました: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _getJobTitleCode(String jobTitle) {
    if (jobTitle.contains('美容師')) return 'beautician';
    if (jobTitle.contains('コンサルタント')) return 'consultant';
    if (jobTitle.contains('トレーナー')) return 'trainer';
    if (jobTitle.contains('弁護士') || jobTitle.contains('士業')) return 'lawyer';
    if (jobTitle.contains('デザイナー')) return 'designer';
    if (jobTitle.contains('エンジニア')) return 'engineer';
    if (jobTitle.contains('講師') || jobTitle.contains('教師')) return 'teacher';
    if (jobTitle.contains('医療')) return 'medical';
    return 'beautician';
  }

  String _getJobTitleName(String code) {
    switch (code) {
      case 'beautician': return '美容師';
      case 'consultant': return 'コンサルタント';
      case 'trainer': return 'トレーナー';
      case 'lawyer': return '弁護士・士業';
      case 'designer': return 'デザイナー';
      case 'engineer': return 'エンジニア';
      case 'teacher': return '講師・教師';
      case 'medical': return '医療従事者';
      default: return '美容師';
    }
  }

  void _pickImages() {
    debugPrint('===== 画像選択開始 =====');
    debugPrint('現在の画像数: ${_profileImages.length}/$_maxImages');
    
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.multiple = true;
    
    input.onChange.listen((e) {
      final files = input.files;
      debugPrint('選択されたファイル数: ${files?.length ?? 0}');
      
      if (files != null && files.isNotEmpty) {
        int addedCount = 0;
        
        for (var file in files) {
          if (_profileImages.length >= _maxImages) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('写真は最大$_maxImages枚までです'),
                backgroundColor: Colors.orange,
              ),
            );
            break;
          }
          
          debugPrint('ファイル読み込み中: ${file.name}');
          final reader = html.FileReader();
          reader.onLoadEnd.listen((e) {
            setState(() {
              _profileImages.add({
                'name': file.name,
                'data': reader.result as String,
              });
              addedCount++;
            });
            
            debugPrint('✅ 画像追加完了: ${file.name}');
            debugPrint('現在の画像数: ${_profileImages.length}');
            
            if (addedCount == files.length || _profileImages.length >= _maxImages) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('写真を${addedCount}枚追加しました (合計: ${_profileImages.length}枚)'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          });
          
          reader.onError.listen((error) {
            debugPrint('❌ 画像読み込みエラー: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('画像の読み込みに失敗しました: ${file.name}'),
                backgroundColor: Colors.red,
              ),
            );
          });
          
          reader.readAsDataUrl(file);
        }
      } else {
        debugPrint('⚠️ ファイルが選択されませんでした');
      }
    });
    
    input.click();
    debugPrint('ファイル選択ダイアログを開きました');
  }

  void _removeImage(int index) {
    setState(() {
      _profileImages.removeAt(index);
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      html.window.navigator.geolocation?.getCurrentPosition().then((position) {
        final lat = position.coords?.latitude;
        final lon = position.coords?.longitude;
        
        if (lat != null && lon != null) {
          // OpenStreetMapのNominatim APIで住所を取得
          html.HttpRequest.request(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=16&accept-language=ja',
            requestHeaders: {'User-Agent': 'StaffSearchApp/1.0'},
          ).then((response) {
            final data = json.decode(response.responseText!);
            final address = data['address'];
            
            String formattedAddress = '';
            if (address['state'] != null) formattedAddress += address['state'];
            if (address['city'] != null) formattedAddress += address['city'];
            if (address['town'] != null) formattedAddress += address['town'];
            if (address['village'] != null) formattedAddress += address['village'];
            
            setState(() {
              _addressController.text = formattedAddress;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('現在地を取得しました')),
            );
          });
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('位置情報の取得に失敗しました')),
      );
    }
  }

  Future<void> _saveProfile() async {
    debugPrint('===== プロフィール保存開始 =====');
    
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名前を入力してください')),
      );
      return;
    }
    
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('メールアドレスが設定されていません。\n再度ログインしてください。'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });
    
    debugPrint('保存データ準備中...');
    debugPrint('Name: ${_nameController.text}');
    debugPrint('Email: ${_emailController.text}');
    debugPrint('Images: ${_profileImages.length}');

    try {
      final profileData = {
        'name': _nameController.text,
        'storeName': _storeNameController.text,
        'storeAddress': _storeAddressController.text,
        'storeLatitude': _storeLatitude,
        'storeLongitude': _storeLongitude,
        'companyName': _companyNameController.text,
        'age': _age,
        'address': _addressController.text,
        'location': _addressController.text,
        'gender': _selectedGender,
        'jobTitle': _getJobTitleName(_selectedJobTitle),
        'experience': '${_experienceYears}年',
        'bio': _bioController.text,
        'email': _emailController.text,
        'profileImages': _profileImages,
        'updatedAt': DateTime.now().toIso8601String(),
        'registeredAt': _getRegisteredAt(),
      };

      final profileJson = json.encode(profileData);
      html.window.localStorage['staff_profile'] = profileJson;
      debugPrint('✅ staff_profile 保存完了');
      debugPrint('保存データサイズ: ${profileJson.length} bytes');

      // ユーザーアプリ用のスタッフリストにも反映
      try {
        String? staffListStr = html.window.localStorage['all_staff_list'];
        List<dynamic> staffList = [];
        
        if (staffListStr != null && staffListStr.isNotEmpty) {
          staffList = json.decode(staffListStr);
        }
        
        final email = _emailController.text;
        final existingIndex = staffList.indexWhere((s) => s['email'] == email);
        
        final staffListItem = {
          'id': existingIndex >= 0 ? staffList[existingIndex]['id'] : 'staff_${DateTime.now().millisecondsSinceEpoch}',
          'name': _nameController.text,
          'storeName': _storeNameController.text,
          'storeAddress': _storeAddressController.text,
          'storeLatitude': _storeLatitude,
          'storeLongitude': _storeLongitude,
          'companyName': _companyNameController.text,
          'jobTitle': _getJobTitleName(_selectedJobTitle),
          'category': _getJobTitleName(_selectedJobTitle),
          'rating': 5.0,
          'reviews': 0,
          'hourlyRate': 5000,
          'experience': '${_experienceYears}年',
          'bio': _bioController.text,
          'location': _addressController.text,
          'distance': '0.0km',
          'imageUrl': _profileImages.isNotEmpty ? _profileImages[0]['data'] : 'https://via.placeholder.com/150',
          'isOnline': false,
          'tags': [_getJobTitleName(_selectedJobTitle)],
          'email': email,
          'registeredAt': profileData['registeredAt'],
        };
        
        if (existingIndex >= 0) {
          staffList[existingIndex] = staffListItem;
        } else {
          staffList.insert(0, staffListItem);
        }
        
        final staffListJson = json.encode(staffList);
        html.window.localStorage['all_staff_list'] = staffListJson;
        debugPrint('✅ all_staff_list 更新完了 (${staffList.length}件)');
      } catch (e) {
        debugPrint('❌ スタッフリスト更新エラー: $e');
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('プロフィールを保存しました\n画像: ${_profileImages.length}枚'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        debugPrint('✅ プロフィール保存完了');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('プロフィールの保存に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getRegisteredAt() {
    try {
      final profileJson = html.window.localStorage['staff_profile'];
      if (profileJson != null) {
        final profile = json.decode(profileJson);
        return profile['registeredAt'] ?? DateTime.now().toIso8601String();
      }
    } catch (e) {
      // ignore
    }
    return DateTime.now().toIso8601String();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール編集'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
              tooltip: '保存',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // プロフィール写真（最大5枚）
            const Text(
              'プロフィール写真（最大5枚）',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ..._profileImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final image = entry.value;
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(image['data']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () => _removeImage(index),
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
                  );
                }),
                if (_profileImages.length < _maxImages)
                  InkWell(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, color: Colors.grey[600], size: 32),
                          const SizedBox(height: 4),
                          Text(
                            '写真追加',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 24),

            // 基本情報
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '名前 *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            
            const SizedBox(height: 16),

            // 店舗名（検索機能付き）
            TextField(
              controller: _storeNameController,
              decoration: InputDecoration(
                labelText: '店舗名',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.store),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _showStoreSearchDialog,
                  tooltip: '地図から検索',
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // 店舗住所
            if (_storeAddressController.text.isNotEmpty) ...[
              TextField(
                controller: _storeAddressController,
                decoration: const InputDecoration(
                  labelText: '店舗住所',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
            ],

            TextField(
              controller: _companyNameController,
              decoration: const InputDecoration(
                labelText: '会社名',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            
            const SizedBox(height: 16),

            // 年齢
            Row(
              children: [
                const Icon(Icons.cake, color: Colors.grey),
                const SizedBox(width: 12),
                const Text('年齢:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                Expanded(
                  child: Slider(
                    value: _age.toDouble(),
                    min: 18,
                    max: 70,
                    divisions: 52,
                    label: '$_age歳',
                    onChanged: (value) {
                      setState(() {
                        _age = value.toInt();
                      });
                    },
                  ),
                ),
                Text('$_age歳', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            
            const SizedBox(height: 16),

            // 性別
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: '性別',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wc),
              ),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('男性')),
                DropdownMenuItem(value: 'female', child: Text('女性')),
                DropdownMenuItem(value: 'other', child: Text('その他')),
                DropdownMenuItem(value: 'no-answer', child: Text('回答しない')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGender = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),

            // 住所
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: '住所',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: _getCurrentLocation,
                  tooltip: '現在地取得',
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // 職種
            DropdownButtonFormField<String>(
              value: _selectedJobTitle,
              decoration: const InputDecoration(
                labelText: '職種',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
              items: const [
                DropdownMenuItem(value: 'beautician', child: Text('美容師')),
                DropdownMenuItem(value: 'consultant', child: Text('コンサルタント')),
                DropdownMenuItem(value: 'trainer', child: Text('トレーナー')),
                DropdownMenuItem(value: 'lawyer', child: Text('弁護士・士業')),
                DropdownMenuItem(value: 'designer', child: Text('デザイナー')),
                DropdownMenuItem(value: 'engineer', child: Text('エンジニア')),
                DropdownMenuItem(value: 'teacher', child: Text('講師・教師')),
                DropdownMenuItem(value: 'medical', child: Text('医療従事者')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedJobTitle = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),

            // 経験年数
            Row(
              children: [
                const Icon(Icons.military_tech, color: Colors.grey),
                const SizedBox(width: 12),
                const Text('経験年数:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                Expanded(
                  child: Slider(
                    value: _experienceYears.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    label: '$_experienceYears年',
                    onChanged: (value) {
                      setState(() {
                        _experienceYears = value.toInt();
                      });
                    },
                  ),
                ),
                Text('$_experienceYears年', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            
            const SizedBox(height: 16),

            // 自己紹介
            TextField(
              controller: _bioController,
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: '自己紹介',
                border: OutlineInputBorder(),
                hintText: 'あなたの経験やスキル、アピールポイントを記入してください',
              ),
            ),
            
            const SizedBox(height: 16),

            // メールアドレス
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              enabled: false, // メールアドレスは変更不可
            ),
            
            const SizedBox(height: 24),

            // 保存ボタン
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('保存', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
