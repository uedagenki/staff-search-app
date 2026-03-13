import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/staff.dart';
import '../models/company.dart';
import '../services/company_service.dart';
import 'staff_detail_screen.dart';

/// OpenStreetMapを使用した地図検索画面
class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  final MapController _mapController = MapController();
  final CompanyService _companyService = CompanyService();
  LatLng _currentLocation = const LatLng(35.6812, 139.7671); // 東京駅（デフォルト）
  bool _isLoadingLocation = false;
  List<Staff> _nearbyStaff = [];
  List<Company> _nearbyCompanies = [];
  bool _showStaffMarkers = true; // スタッフピンを表示
  bool _showCompanyMarkers = true; // 店舗ピンを表示
  
  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _loadNearbyStaff();
    _loadNearbyCompanies();
  }

  /// 現在地を取得
  Future<void> _loadCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    
    try {
      // 位置情報の権限確認
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        // 権限がない場合はデフォルト位置を使用
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('位置情報の権限が必要です'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // 現在位置を取得
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      
      // 地図を現在地に移動
      _mapController.move(_currentLocation, 15.0);
      
    } catch (e) {
      debugPrint('位置情報取得エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('現在地を取得できませんでした'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  /// 近くのスタッフを読み込み（デモデータ）
  void _loadNearbyStaff() {
    // デモ用のスタッフデータ
    setState(() {
      _nearbyStaff = [
        Staff(
          id: 'staff_001',
          name: '田中 花子',
          jobTitle: 'ヘアスタイリスト',
          category: 'ヘアサロン',
          profileImage: 'https://via.placeholder.com/150',
          bio: '10年以上の経験を持つベテランスタイリストです。お客様一人ひとりに合わせたヘアスタイルをご提案します。',
          skills: ['カット', 'カラー', 'パーマ'],
          experience: 10,
          qrCode: 'staff_001_qr',
          location: '東京都千代田区丸の内1-1-1',
          storeName: 'Salon Tokyo',
          latitude: 35.6812,
          longitude: 139.7671,
          rating: 4.8,
          reviewCount: 124,
          isOnline: true,
          isLive: false,
        ),
        Staff(
          id: 'staff_002',
          name: '佐藤 太郎',
          jobTitle: 'ネイリスト',
          category: 'ネイルサロン',
          profileImage: 'https://via.placeholder.com/150',
          bio: '繊細なアートが得意なネイリストです。',
          skills: ['ジェルネイル', 'ネイルアート', 'ケア'],
          experience: 5,
          qrCode: 'staff_002_qr',
          location: '東京都渋谷区渋谷1-2-3',
          storeName: 'Nail Art Studio',
          latitude: 35.6580,
          longitude: 139.7016,
          rating: 4.6,
          reviewCount: 89,
          isOnline: true,
          isLive: false,
        ),
        Staff(
          id: 'staff_003',
          name: '鈴木 美咲',
          jobTitle: 'エステティシャン',
          category: 'エステ',
          profileImage: 'https://via.placeholder.com/150',
          bio: '美肌づくりのスペシャリストです。',
          skills: ['フェイシャル', 'ボディケア', '痩身'],
          experience: 8,
          qrCode: 'staff_003_qr',
          location: '東京都新宿区新宿2-3-4',
          storeName: 'Beauty Salon Shinjuku',
          latitude: 35.6895,
          longitude: 139.7006,
          rating: 4.9,
          reviewCount: 156,
          isOnline: true,
          isLive: false,
        ),
        Staff(
          id: 'staff_004',
          name: '高橋 健一',
          jobTitle: 'マッサージセラピスト',
          category: 'マッサージ',
          profileImage: 'https://via.placeholder.com/150',
          bio: '疲れを癒すマッサージのプロです。',
          skills: ['リラクゼーション', 'アロマ', '指圧'],
          experience: 12,
          qrCode: 'staff_004_qr',
          location: '東京都中央区銀座3-4-5',
          storeName: 'Relax Spa Ginza',
          latitude: 35.6721,
          longitude: 139.7653,
          rating: 4.7,
          reviewCount: 98,
          isOnline: true,
          isLive: false,
        ),
        Staff(
          id: 'staff_005',
          name: '伊藤 麻衣',
          jobTitle: 'メイクアップアーティスト',
          category: 'メイク',
          profileImage: 'https://via.placeholder.com/150',
          bio: '特別な日を彩るメイクアップ。',
          skills: ['ブライダルメイク', 'パーティメイク', 'ナチュラルメイク'],
          experience: 7,
          qrCode: 'staff_005_qr',
          location: '東京都港区六本木5-6-7',
          storeName: 'Makeup Studio Roppongi',
          latitude: 35.6627,
          longitude: 139.7294,
          rating: 4.8,
          reviewCount: 112,
          isOnline: false,
          isLive: false,
        ),
      ];
    });
  }

  /// 近くの店舗・企業を読み込み
  Future<void> _loadNearbyCompanies() async {
    try {
      final companies = await _companyService.getAllCompanies();
      setState(() {
        _nearbyCompanies = companies.where((company) => 
          company.latitude != null && company.longitude != null
        ).toList();
      });
    } catch (e) {
      debugPrint('店舗読み込みエラー: $e');
    }
  }

  /// スタッフマーカーをタップ
  void _onStaffMarkerTap(Staff staff) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    staff.name[0],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        staff.jobTitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${staff.rating} (${staff.reviewCount}件)',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.store, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    staff.storeName ?? '店舗名なし',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    staff.location,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StaffDetailScreen(staff: staff),
                    ),
                  );
                },
                child: const Text('詳細を見る'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 店舗マーカーをタップ
  void _onCompanyMarkerTap(Company company) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: company.isStore ? Colors.purple : Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    company.isStore ? Icons.store : Icons.business,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        company.industry,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    company.address,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: 店舗詳細画面の実装
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${company.name}の詳細画面は準備中です')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('詳細を見る'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地図検索'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _isLoadingLocation ? null : _loadCurrentLocation,
            tooltip: '現在地を表示',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 地図
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 13.0,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              // OpenStreetMapタイルレイヤー
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.stafffinder.finder',
                maxZoom: 19,
              ),
              
              // マーカーレイヤー
              MarkerLayer(
                markers: [
                  // 現在地マーカー
                  Marker(
                    point: _currentLocation,
                    width: 60,
                    height: 60,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('現在地'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_pin,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // スタッフマーカー
                  if (_showStaffMarkers)
                    ..._nearbyStaff.map((staff) {
                      return Marker(
                        point: LatLng(staff.latitude!, staff.longitude!),
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () => _onStaffMarkerTap(staff),
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: staff.isOnline 
                                      ? Colors.green 
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  
                  // 店舗・企業マーカー
                  if (_showCompanyMarkers)
                    ..._nearbyCompanies.map((company) {
                      return Marker(
                        point: LatLng(company.latitude!, company.longitude!),
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () => _onCompanyMarkerTap(company),
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: company.isStore 
                                      ? Colors.purple 
                                      : Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  company.isStore ? Icons.store : Icons.business,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ],
          ),
          
          // ローディングインジケーター
          if (_isLoadingLocation)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('現在地を取得中...'),
                    ],
                  ),
                ),
              ),
            ),
          
          // スタッフ数表示
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '近くのスタッフ: ${_nearbyStaff.length}人',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
