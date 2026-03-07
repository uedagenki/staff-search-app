import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/service_menu.dart';
import '../../services/local_booking_service.dart';
import '../../services/local_auth_service.dart';

/// スタッフ側：メニュー管理画面（メニュー作成・編集・削除）
class StaffMenuManagementScreen extends StatefulWidget {
  const StaffMenuManagementScreen({super.key});

  @override
  State<StaffMenuManagementScreen> createState() => _StaffMenuManagementScreenState();
}

class _StaffMenuManagementScreenState extends State<StaffMenuManagementScreen> {
  final _bookingService = LocalBookingService();
  final _authService = LocalAuthService();
  
  List<ServiceMenu> _menus = [];
  bool _isLoading = true;
  String? _staffId;

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  Future<void> _loadMenus() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      _staffId = user.id;
      final menus = await _bookingService.getStaffMenus(user.id);

      setState(() {
        _menus = menus;
      });
    } catch (e) {
      debugPrint('メニュー読み込みエラー: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addMenu() async {
    if (_staffId == null) return;

    final result = await Navigator.push<ServiceMenu>(
      context,
      MaterialPageRoute(
        builder: (context) => MenuEditScreen(
          staffId: _staffId!,
        ),
      ),
    );

    if (result != null) {
      await _bookingService.addMenu(result);
      _loadMenus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('メニューを追加しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _editMenu(ServiceMenu menu) async {
    final result = await Navigator.push<ServiceMenu>(
      context,
      MaterialPageRoute(
        builder: (context) => MenuEditScreen(
          staffId: menu.staffId,
          menu: menu,
        ),
      ),
    );

    if (result != null) {
      await _bookingService.updateMenu(result);
      _loadMenus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('メニューを更新しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteMenu(ServiceMenu menu) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('メニュー削除'),
        content: Text('「${menu.name}」を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _bookingService.deleteMenu(menu.id);
      _loadMenus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('メニューを削除しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メニュー管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addMenu,
            tooltip: 'メニュー追加',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _menus.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'メニューがありません',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _addMenu,
                        icon: const Icon(Icons.add),
                        label: const Text('最初のメニューを追加'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMenus,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _menus.length,
                    itemBuilder: (context, index) {
                      final menu = _menus[index];
                      return _buildMenuCard(menu);
                    },
                  ),
                ),
      floatingActionButton: _menus.isNotEmpty
          ? FloatingActionButton(
              onPressed: _addMenu,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildMenuCard(ServiceMenu menu) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.cut,
            color: Colors.blue[700],
            size: 32,
          ),
        ),
        title: Text(
          menu.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              menu.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${menu.duration}分',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.payments, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '¥${menu.price}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            if (!menu.isActive) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '非公開',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('編集'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('削除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _editMenu(menu);
            } else if (value == 'delete') {
              _deleteMenu(menu);
            }
          },
        ),
      ),
    );
  }
}

/// メニュー編集画面
class MenuEditScreen extends StatefulWidget {
  final String staffId;
  final ServiceMenu? menu;

  const MenuEditScreen({
    super.key,
    required this.staffId,
    this.menu,
  });

  @override
  State<MenuEditScreen> createState() => _MenuEditScreenState();
}

class _MenuEditScreenState extends State<MenuEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.menu != null) {
      _nameController.text = widget.menu!.name;
      _descriptionController.text = widget.menu!.description;
      _priceController.text = widget.menu!.price.toString();
      _durationController.text = widget.menu!.duration.toString();
      _isActive = widget.menu!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final menu = ServiceMenu(
        id: widget.menu?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        staffId: widget.staffId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: int.parse(_priceController.text),
        duration: int.parse(_durationController.text),
        category: widget.menu?.category ?? 'その他', // デフォルトカテゴリー
        isActive: _isActive,
        createdAt: widget.menu?.createdAt ?? DateTime.now(),
      );

      Navigator.pop(context, menu);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menu == null ? 'メニュー追加' : 'メニュー編集'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // メニュー名
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'メニュー名',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cut),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'メニュー名を入力してください';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 説明
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '説明',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '説明を入力してください';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 料金
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: '料金（円）',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payments),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '料金を入力してください';
                }
                final price = int.tryParse(value);
                if (price == null || price < 0) {
                  return '正しい料金を入力してください';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 所要時間
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: '所要時間（分）',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '所要時間を入力してください';
                }
                final duration = int.tryParse(value);
                if (duration == null || duration < 1) {
                  return '正しい所要時間を入力してください';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 公開/非公開
            Card(
              child: SwitchListTile(
                title: const Text('メニューを公開する'),
                subtitle: Text(_isActive ? '予約可能' : '非公開'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 32),

            // 保存ボタン
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '保存',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
