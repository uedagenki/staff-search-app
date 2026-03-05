import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import '../models/staff.dart';
import '../data/mock_data.dart';
import 'store_detail_screen.dart';

class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  final List<Staff> _staffList = MockData.getStaffList();
  
  // 店舗/会社の情報をマップで管理（店舗ID -> 所属スタッフリスト）
  final Map<String, List<Staff>> _storeStaffMap = {};
  
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // 店舗ごとにスタッフをグループ化
    _groupStaffByStore();
    
    // Web用のマップを登録
    if (kIsWeb) {
      _registerWebView();
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  void _groupStaffByStore() {
    for (var staff in _staffList) {
      if (staff.storeName != null && staff.latitude != null && staff.longitude != null) {
        final storeKey = '${staff.storeName}_${staff.latitude}_${staff.longitude}';
        
        if (!_storeStaffMap.containsKey(storeKey)) {
          _storeStaffMap[storeKey] = [];
        }
        
        _storeStaffMap[storeKey]!.add(staff);
      }
    }
  }
  
  void _registerWebView() {
    // Web用のiframe要素を登録
    ui_web.platformViewRegistry.registerViewFactory(
      'map-view',
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = 'map.html'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地図検索'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showMapInfo(context);
            },
            tooltip: 'ヘルプ',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : kIsWeb
              ? HtmlElementView(viewType: 'map-view')
              : _buildMobileMapPlaceholder(),
    );
  }
  
  Widget _buildMobileMapPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              '地図機能',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Web版でご利用いただけます',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            _buildStoreList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStoreList() {
    return Expanded(
      child: ListView(
        children: _storeStaffMap.entries.map((entry) {
          final staffList = entry.value;
          final storeName = staffList.first.storeName!;
          final companyName = staffList.first.companyName;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.store, color: Colors.orange),
              title: Text(storeName),
              subtitle: Text(
                companyName != null 
                    ? '$companyName (${staffList.length}人)'
                    : '${staffList.length}人のスタッフ',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoreDetailScreen(
                      storeName: storeName,
                      companyName: companyName,
                      staffList: staffList,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
  
  void _showMapInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('地図の使い方'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem(
              Icons.location_on,
              'オレンジ色のマーカー',
              '店舗/会社の位置',
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              Icons.location_on,
              '青色のマーカー',
              '個人スタッフの位置',
              Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'マーカーをクリックすると、所属スタッフの情報が表示されます。',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(IconData icon, String title, String description, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
