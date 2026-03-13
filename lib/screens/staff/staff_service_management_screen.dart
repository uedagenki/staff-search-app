// SCREEN: Staff Service Management Screen | STAFF-01
import '../../../utils/screen_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';

class StaffServiceManagementScreen extends StatefulWidget {
  const StaffServiceManagementScreen({super.key});

  @override
  State<StaffServiceManagementScreen> createState() => _StaffServiceManagementScreenState();
}

class _StaffServiceManagementScreenState extends State<StaffServiceManagementScreen> with ScreenLogMixin {
  @override
  String get screenId => 'Staff Service Management Screen | STAFF-01';

  final _bookingService = BookingService();
  List<Service> _services = [];
  bool _isLoading = true;

  String _staffId = 'staff_001'; // 実際にはログイン情報から取得

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
    });

    final services = await _bookingService.getStaffServices(_staffId);
    
    setState(() {
      _services = services;
      _isLoading = false;
    });
  }

  Future<void> _addService() async {
    final result = await Navigator.push<Service>(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceEditScreen(staffId: _staffId),
      ),
    );

    if (result != null) {
      await _bookingService.addService(result);
      await _loadServices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('サービスを追加しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _editService(Service service) async {
    final result = await Navigator.push<Service>(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceEditScreen(
          staffId: _staffId,
          service: service,
        ),
      ),
    );

    if (result != null) {
      await _bookingService.updateService(result);
      await _loadServices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('サービスを更新しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteService(Service service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('${service.name}を削除しますか?\nこの操作は取り消せません。'),
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

    if (confirmed == true) {
      await _bookingService.deleteService(_staffId, service.id);
      await _loadServices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('サービスを削除しました'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('サービス管理'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
              ? _buildEmptyState()
              : _buildServiceList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addService,
        icon: const Icon(Icons.add),
        label: const Text('サービス追加'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'サービスが登録されていません',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '下のボタンから最初のサービスを追加しましょう',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _editService(service),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: service.isActive
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              service.isActive ? '公開中' : '非公開',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: service.isActive
                                    ? Colors.green.shade700
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _deleteService(service),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.access_time,
                        '${service.duration}分',
                        Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.attach_money,
                        '¥${service.price.toStringAsFixed(0)}',
                        Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.category,
                        service.category,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceEditScreen extends StatefulWidget {
  final String staffId;
  final Service? service;

  const ServiceEditScreen({
    super.key,
    required this.staffId,
    this.service,
  });

  @override
  State<ServiceEditScreen> createState() => _ServiceEditScreenState();
}

class _ServiceEditScreenState extends State<ServiceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  String _selectedCategory = 'ヘアスタイル';
  bool _isActive = true;

  final List<String> _categories = [
    'ヘアスタイル',
    'カラーリング',
    'パーマ',
    'トリートメント',
    'ヘッドスパ',
    'メイク',
    'ネイル',
    'エステ',
    'マッサージ',
    'その他',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _descriptionController.text = widget.service!.description;
      _priceController.text = widget.service!.price.toStringAsFixed(0);
      _durationController.text = widget.service!.duration.toString();
      _selectedCategory = widget.service!.category;
      _isActive = widget.service!.isActive;
    } else {
      _durationController.text = '60';
      _priceController.text = '5000';
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

  void _saveService() {
    if (_formKey.currentState!.validate()) {
      final service = Service(
        id: widget.service?.id ?? 
            'service_${DateTime.now().millisecondsSinceEpoch}',
        staffId: widget.staffId,
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        duration: int.parse(_durationController.text),
        category: _selectedCategory,
        isActive: _isActive,
      );

      Navigator.pop(context, service);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service == null ? 'サービス追加' : 'サービス編集'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveService,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // サービス名
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'サービス名',
                hintText: '例: カット',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'サービス名を入力してください';
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
                hintText: '例: シャンプー・ブロー込み',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '説明を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // カテゴリー
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'カテゴリー',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
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
            const SizedBox(height: 16),

            // 料金と所要時間
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: '料金',
                      hintText: '5000',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                      suffixText: '円',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '料金を入力';
                      }
                      if (double.tryParse(value) == null) {
                        return '無効な値';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: '所要時間',
                      hintText: '60',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                      suffixText: '分',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '時間を入力';
                      }
                      if (int.tryParse(value) == null) {
                        return '無効な値';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 公開状態
            Card(
              child: SwitchListTile(
                title: const Text('公開状態'),
                subtitle: Text(_isActive ? 'このサービスは公開されています' : 'このサービスは非公開です'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                secondary: Icon(
                  _isActive ? Icons.visibility : Icons.visibility_off,
                  color: _isActive ? Colors.green : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 保存ボタン
            ElevatedButton.icon(
              onPressed: _saveService,
              icon: const Icon(Icons.save),
              label: Text(widget.service == null ? 'サービスを追加' : 'サービスを更新'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
