import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:convert';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedGender = 'other';
  List<String> _selectedCategories = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _profileImageUrl;

  final List<Map<String, String>> _categories = [
    {'value': 'beauty_health', 'label': '美容・健康'},
    {'value': 'sales_consulting', 'label': '営業・接客'},
    {'value': 'professional', 'label': '専門職'},
    {'value': 'creative', 'label': 'クリエイティブ'},
    {'value': 'it_tech', 'label': 'IT・技術'},
    {'value': 'education', 'label': '教育'},
    {'value': 'medical_care', 'label': '医療・介護'},
    {'value': 'other', 'label': 'その他'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profileData = html.window.localStorage['user_profile'];
      if (profileData != null) {
        final profile = json.decode(profileData);
        setState(() {
          _nameController.text = profile['name'] ?? 'ゲストユーザー';
          _emailController.text = profile['email'] ?? 'guest@example.com';
          _addressController.text = profile['address'] ?? '';
          _ageController.text = profile['age']?.toString() ?? '';
          _selectedGender = profile['gender'] ?? 'other';
          _selectedCategories = List<String>.from(profile['categories'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load profile: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      // Web環境でのファイル選択
      final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          final reader = html.FileReader();
          
          reader.onLoadEnd.listen((event) {
            setState(() {
              _profileImageUrl = reader.result as String?;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('プロフィール画像を選択しました'),
                duration: Duration(seconds: 2),
              ),
            );
          });
          
          reader.readAsDataUrl(file);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to pick image: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画像の選択に失敗しました')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('少なくとも1つのカテゴリーを選択してください')),
      );
      return;
    }

    if (_selectedCategories.length > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('カテゴリーは最大3つまで選択できます')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'age': _ageController.text,
        'gender': _selectedGender,
        'categories': _selectedCategories,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      html.window.localStorage['user_profile'] = json.encode(userData);

      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('プロフィールを保存しました')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save profile: $e');
      }
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存に失敗しました')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール設定'),
        elevation: 0,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // プロフィール画像
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              radius: 20,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                onPressed: _pickProfileImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 名前
                    const Text(
                      '名前',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: '名前を入力',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // メールアドレス
                    const Text(
                      'メールアドレス',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'example@email.com',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 年齢
                    const Text(
                      '年齢',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '例: 25',
                        prefixIcon: const Icon(Icons.cake),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 性別
                    const Text(
                      '性別',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('男性')),
                        DropdownMenuItem(value: 'female', child: Text('女性')),
                        DropdownMenuItem(value: 'other', child: Text('その他')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedGender = value;
                          });
                        }
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 住所
                    const Text(
                      '住所',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: '東京都渋谷区...',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // カテゴリー選択
                    const Text(
                      '興味のあるカテゴリー（最大3つ）',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[50],
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((category) {
                          final isSelected = _selectedCategories.contains(category['value']);
                          return FilterChip(
                            label: Text(category['label']!),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  if (_selectedCategories.length < 3) {
                                    _selectedCategories.add(category['value']!);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('カテゴリーは最大3つまで選択できます'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } else {
                                  _selectedCategories.remove(category['value']);
                                }
                              });
                            },
                            selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                            checkmarkColor: Theme.of(context).colorScheme.primary,
                          );
                        }).toList(),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // アカウント設定
                    const Text(
                      'アカウント設定',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('パスワード変更'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('パスワード変更機能（開発中）')),
                        );
                      },
                    ),
                    
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('通知設定'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('通知設定機能（開発中）')),
                        );
                      },
                    ),
                    
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('プライバシー設定'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('プライバシー設定機能（開発中）')),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
