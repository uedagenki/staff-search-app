import 'package:flutter/material.dart';
import '../services/local_booking_service.dart';
import '../services/local_auth_service.dart';

/// デバッグ: 予約システムデータ初期化画面
class BookingSystemDebugScreen extends StatefulWidget {
  const BookingSystemDebugScreen({super.key});

  @override
  State<BookingSystemDebugScreen> createState() => _BookingSystemDebugScreenState();
}

class _BookingSystemDebugScreenState extends State<BookingSystemDebugScreen> {
  final _bookingService = LocalBookingService();
  final _authService = LocalAuthService();
  
  String _status = '初期化前';
  bool _isLoading = false;

  Future<void> _initializeAllData() async {
    setState(() {
      _isLoading = true;
      _status = '初期化中...';
    });

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        setState(() {
          _status = 'エラー: ユーザーが見つかりません';
          _isLoading = false;
        });
        return;
      }

      // メニューデータ作成
      setState(() => _status = 'メニューデータ作成中...');
      await _bookingService.createDemoMenus(user.id, user.name);
      
      // メニュー確認
      final menus = await _bookingService.getAllMenus();
      setState(() => _status = 'メニュー作成完了: ${menus.length}件');
      
      await Future.delayed(const Duration(seconds: 1));

      // クーポンデータ作成
      setState(() => _status = 'クーポンデータ作成中...');
      await _bookingService.createDemoCoupons(user.id, user.name);
      
      // クーポン確認
      final coupons = await _bookingService.getAllCoupons();
      setState(() => _status = 'クーポン作成完了: ${coupons.length}件');
      
      await Future.delayed(const Duration(seconds: 1));

      // 予約データ作成
      setState(() => _status = '予約データ作成中...');
      await _bookingService.createDemoBookings(user.id, user.name);
      
      // 予約確認
      final bookings = await _bookingService.getAllBookings();
      setState(() => _status = '予約作成完了: ${bookings.length}件');
      
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _status = '✅ 初期化完了!\n\nメニュー: ${menus.length}件\nクーポン: ${coupons.length}件\n予約: ${bookings.length}件';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('データ初期化が完了しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = '❌ エラー: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkCurrentData() async {
    setState(() {
      _isLoading = true;
      _status = 'データ確認中...';
    });

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        setState(() {
          _status = 'エラー: ユーザーが見つかりません';
          _isLoading = false;
        });
        return;
      }

      final allMenus = await _bookingService.getAllMenus();
      final staffMenus = await _bookingService.getStaffMenus(user.id);
      final allCoupons = await _bookingService.getAllCoupons();
      final validCoupons = await _bookingService.getValidCoupons(user.id);
      final allBookings = await _bookingService.getAllBookings();
      final staffBookings = await _bookingService.getStaffBookings(user.id);

      setState(() {
        _status = '''
📊 現在のデータ状況

ユーザー: ${user.name} (${user.email})
Role: ${user.role}

メニュー:
- 全メニュー: ${allMenus.length}件
- スタッフメニュー: ${staffMenus.length}件

クーポン:
- 全クーポン: ${allCoupons.length}件
- 有効クーポン: ${validCoupons.length}件

予約:
- 全予約: ${allBookings.length}件
- スタッフ予約: ${staffBookings.length}件
''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ エラー: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('予約システムデバッグ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '状態',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              ElevatedButton.icon(
                onPressed: _checkCurrentData,
                icon: const Icon(Icons.info),
                label: const Text('現在のデータを確認'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _initializeAllData,
                icon: const Icon(Icons.refresh),
                label: const Text('データを初期化'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],

            const SizedBox(height: 24),

            const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 使い方',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. 「現在のデータを確認」でデータ状況を確認\n2. 「データを初期化」でデモデータを作成\n3. 予約画面に戻って動作確認',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
