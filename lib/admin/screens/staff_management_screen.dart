// SCREEN: Staff Management Screen | ADMIN (no spec)
import '../../../utils/screen_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../utils/storage_helper.dart';
import '../../models/staff.dart';
import 'dart:convert';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> with ScreenLogMixin {
  @override
  String get screenId => 'Staff Management Screen | ADMIN (no spec)';

  List<Staff> _staffList = [];
  List<Staff> _filteredStaff = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'all'; // all, pending, approved, rejected

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStaff() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final staffJson = await StorageHelper.getString('staff_list');
      if (staffJson != null) {
        final List<dynamic> staffData = jsonDecode(staffJson);
        _staffList = staffData.map((json) => Staff.fromJson(json)).toList();
        _applyFilters();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load staff: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    List<Staff> filtered = List.from(_staffList);

    // ステータスフィルター
    if (_filterStatus != 'all') {
      filtered = filtered.where((staff) {
        // ステータスはカスタムフィールドとして追加する必要があるため、
        // ここではダミーロジックとして扱います
        return true;
      }).toList();
    }

    // 検索フィルター
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((staff) {
        return staff.name.toLowerCase().contains(query) ||
               staff.jobTitle.toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      _filteredStaff = filtered;
    });
  }

  Future<void> _deleteStaff(Staff staff) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('スタッフ削除'),
        content: Text('${staff.name} さんを削除しますか？\nこの操作は取り消せません。'),
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
      _staffList.removeWhere((s) => s.id == staff.id);
      final staffJson = jsonEncode(_staffList.map((s) => s.toJson()).toList());
      await StorageHelper.setString('staff_list', staffJson);
      
      _applyFilters();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('スタッフを削除しました'),
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

  void _showStaffDetails(Staff staff) {
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
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: staff.profileImages.isNotEmpty
                            ? NetworkImage(staff.profileImages.first)
                            : null,
                        child: staff.profileImages.isEmpty
                            ? Text(
                                staff.name[0].toUpperCase(),
                                style: const TextStyle(fontSize: 32),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              staff.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              staff.jobTitle,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  staff.rating.toStringAsFixed(1),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // 詳細情報
                  _buildDetailRow('スタッフID', staff.id),
                  _buildDetailRow('職種', staff.jobTitle),
                  _buildDetailRow('経験年数', '${staff.experience}年'),
                  _buildDetailRow('所在地', staff.location),
                  if (staff.storeName != null)
                    _buildDetailRow('店舗名', staff.storeName!),
                  if (staff.companyName != null)
                    _buildDetailRow('会社名', staff.companyName!),
                  _buildDetailRow('評価', '${staff.rating} (${staff.reviewCount}件)'),
                  _buildDetailRow('フォロワー数', '${staff.followersCount}'),
                  _buildDetailRow('ギフト総額', '¥${staff.giftAmount.toStringAsFixed(0)}'),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // プロフィール
                  Text(
                    'プロフィール',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(staff.bio),

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
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _deleteStaff(staff);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スタッフ管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '更新',
            onPressed: _loadStaff,
          ),
        ],
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'スタッフ名または職種で検索',
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
          ),

          // 統計サマリー
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            '${_staffList.length}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Text('総スタッフ数'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            '${_filteredStaff.length}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Text('表示中'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // スタッフリスト
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStaff.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'スタッフが見つかりません',
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
                        itemCount: _filteredStaff.length,
                        itemBuilder: (context, index) {
                          final staff = _filteredStaff[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: staff.profileImages.isNotEmpty
                                    ? NetworkImage(staff.profileImages.first)
                                    : null,
                                child: staff.profileImages.isEmpty
                                    ? Text(staff.name[0].toUpperCase())
                                    : null,
                              ),
                              title: Text(staff.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(staff.jobTitle),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, size: 14, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text('${staff.rating} (${staff.reviewCount})'),
                                      const SizedBox(width: 16),
                                      const Icon(Icons.location_on, size: 14),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text(staff.location)),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.info_outline),
                                    tooltip: '詳細',
                                    onPressed: () => _showStaffDetails(staff),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    tooltip: '削除',
                                    color: Colors.red,
                                    onPressed: () => _deleteStaff(staff),
                                  ),
                                ],
                              ),
                              onTap: () => _showStaffDetails(staff),
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
