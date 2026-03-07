import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking.dart';
import '../models/coupon.dart';
import '../models/service_menu.dart';

/// ローカルストレージベースの予約管理サービス
class LocalBookingService {
  static const String _bookingsKey = 'bookings';
  static const String _couponsKey = 'coupons';
  static const String _menusKey = 'service_menus';

  // ========== 予約管理 ==========

  /// 予約を作成
  Future<Booking> createBooking(Booking booking) async {
    final prefs = await SharedPreferences.getInstance();
    final bookingsJson = prefs.getString(_bookingsKey);
    List<dynamic> bookings = bookingsJson != null ? jsonDecode(bookingsJson) : [];
    
    bookings.add(booking.toJson());
    await prefs.setString(_bookingsKey, jsonEncode(bookings));
    
    // クーポンを使用した場合、使用回数を増やす
    if (booking.couponId != null) {
      await _incrementCouponUsage(booking.couponId!);
    }
    
    return booking;
  }

  /// 全予約を取得
  Future<List<Booking>> getAllBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingsJson = prefs.getString(_bookingsKey);
    
    if (bookingsJson == null) return [];
    
    final List<dynamic> bookingsList = jsonDecode(bookingsJson);
    return bookingsList.map((json) => Booking.fromJson(json)).toList();
  }

  /// ユーザーの予約を取得
  Future<List<Booking>> getUserBookings(String userId) async {
    final allBookings = await getAllBookings();
    return allBookings.where((b) => b.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// スタッフの予約を取得
  Future<List<Booking>> getStaffBookings(String staffId) async {
    final allBookings = await getAllBookings();
    return allBookings.where((b) => b.staffId == staffId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// 予約IDで予約を取得
  Future<Booking?> getBookingById(String bookingId) async {
    final allBookings = await getAllBookings();
    try {
      return allBookings.firstWhere((b) => b.id == bookingId);
    } catch (e) {
      return null;
    }
  }

  /// 予約を更新
  Future<void> updateBooking(Booking updatedBooking) async {
    final prefs = await SharedPreferences.getInstance();
    final allBookings = await getAllBookings();
    
    final index = allBookings.indexWhere((b) => b.id == updatedBooking.id);
    if (index != -1) {
      allBookings[index] = updatedBooking;
      final bookingsJson = jsonEncode(allBookings.map((b) => b.toJson()).toList());
      await prefs.setString(_bookingsKey, bookingsJson);
    }
  }

  /// 予約を確定
  Future<void> confirmBooking(String bookingId) async {
    final booking = await getBookingById(bookingId);
    if (booking != null) {
      final confirmed = booking.copyWith(
        status: BookingStatus.confirmed,
        confirmedAt: DateTime.now(),
      );
      await updateBooking(confirmed);
    }
  }

  /// 予約を完了
  Future<void> completeBooking(String bookingId) async {
    final booking = await getBookingById(bookingId);
    if (booking != null) {
      final completed = booking.copyWith(
        status: BookingStatus.completed,
        completedAt: DateTime.now(),
      );
      await updateBooking(completed);
    }
  }

  /// 予約をキャンセル
  Future<void> cancelBooking(String bookingId, String reason) async {
    final booking = await getBookingById(bookingId);
    if (booking != null) {
      final cancelled = booking.copyWith(
        status: BookingStatus.cancelled,
        cancelledAt: DateTime.now(),
        cancellationReason: reason,
      );
      await updateBooking(cancelled);
    }
  }

  // ========== クーポン管理 ==========

  /// クーポンを作成
  Future<Coupon> createCoupon(Coupon coupon) async {
    final prefs = await SharedPreferences.getInstance();
    final couponsJson = prefs.getString(_couponsKey);
    List<dynamic> coupons = couponsJson != null ? jsonDecode(couponsJson) : [];
    
    coupons.add(coupon.toJson());
    await prefs.setString(_couponsKey, jsonEncode(coupons));
    
    return coupon;
  }

  /// 全クーポンを取得
  Future<List<Coupon>> getAllCoupons() async {
    final prefs = await SharedPreferences.getInstance();
    final couponsJson = prefs.getString(_couponsKey);
    
    if (couponsJson == null) return [];
    
    final List<dynamic> couponsList = jsonDecode(couponsJson);
    return couponsList.map((json) => Coupon.fromJson(json)).toList();
  }

  /// スタッフのクーポンを取得
  Future<List<Coupon>> getStaffCoupons(String staffId) async {
    final allCoupons = await getAllCoupons();
    return allCoupons.where((c) => c.staffId == staffId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// 有効なクーポンを取得
  Future<List<Coupon>> getValidCoupons(String staffId) async {
    final staffCoupons = await getStaffCoupons(staffId);
    return staffCoupons.where((c) => c.isValid()).toList();
  }

  /// クーポンを更新
  Future<void> updateCoupon(Coupon updatedCoupon) async {
    final prefs = await SharedPreferences.getInstance();
    final allCoupons = await getAllCoupons();
    
    final index = allCoupons.indexWhere((c) => c.id == updatedCoupon.id);
    if (index != -1) {
      allCoupons[index] = updatedCoupon;
      final couponsJson = jsonEncode(allCoupons.map((c) => c.toJson()).toList());
      await prefs.setString(_couponsKey, couponsJson);
    }
  }

  /// クーポンの使用回数を増やす
  Future<void> _incrementCouponUsage(String couponId) async {
    final allCoupons = await getAllCoupons();
    final index = allCoupons.indexWhere((c) => c.id == couponId);
    
    if (index != -1) {
      final coupon = allCoupons[index];
      final updated = coupon.copyWith(usedCount: coupon.usedCount + 1);
      await updateCoupon(updated);
    }
  }

  /// クーポンを削除
  Future<void> deleteCoupon(String couponId) async {
    final prefs = await SharedPreferences.getInstance();
    final allCoupons = await getAllCoupons();
    
    allCoupons.removeWhere((c) => c.id == couponId);
    final couponsJson = jsonEncode(allCoupons.map((c) => c.toJson()).toList());
    await prefs.setString(_couponsKey, couponsJson);
  }

  // ========== メニュー管理 ==========

  /// メニューを作成
  Future<ServiceMenu> createMenu(ServiceMenu menu) async {
    final prefs = await SharedPreferences.getInstance();
    final menusJson = prefs.getString(_menusKey);
    List<dynamic> menus = menusJson != null ? jsonDecode(menusJson) : [];
    
    menus.add(menu.toJson());
    await prefs.setString(_menusKey, jsonEncode(menus));
    
    return menu;
  }

  /// 全メニューを取得
  Future<List<ServiceMenu>> getAllMenus() async {
    final prefs = await SharedPreferences.getInstance();
    final menusJson = prefs.getString(_menusKey);
    
    if (menusJson == null) return [];
    
    final List<dynamic> menusList = jsonDecode(menusJson);
    return menusList.map((json) => ServiceMenu.fromJson(json)).toList();
  }

  /// スタッフのメニューを取得
  Future<List<ServiceMenu>> getStaffMenus(String staffId) async {
    final allMenus = await getAllMenus();
    return allMenus.where((m) => m.staffId == staffId && m.isActive).toList();
  }

  /// メニューを追加
  Future<void> addMenu(ServiceMenu newMenu) async {
    final prefs = await SharedPreferences.getInstance();
    final allMenus = await getAllMenus();
    
    allMenus.add(newMenu);
    final menusJson = jsonEncode(allMenus.map((m) => m.toJson()).toList());
    await prefs.setString(_menusKey, menusJson);
  }

  /// メニューを更新
  Future<void> updateMenu(ServiceMenu updatedMenu) async {
    final prefs = await SharedPreferences.getInstance();
    final allMenus = await getAllMenus();
    
    final index = allMenus.indexWhere((m) => m.id == updatedMenu.id);
    if (index != -1) {
      allMenus[index] = updatedMenu;
      final menusJson = jsonEncode(allMenus.map((m) => m.toJson()).toList());
      await prefs.setString(_menusKey, menusJson);
    }
  }

  /// メニューを削除
  Future<void> deleteMenu(String menuId) async {
    final prefs = await SharedPreferences.getInstance();
    final allMenus = await getAllMenus();
    
    allMenus.removeWhere((m) => m.id == menuId);
    final menusJson = jsonEncode(allMenus.map((m) => m.toJson()).toList());
    await prefs.setString(_menusKey, menusJson);
  }

  // ========== デモデータ作成 ==========

  /// デモメニューを作成
  Future<void> createDemoMenus(String staffId, String staffName) async {
    // 既存のメニューをチェック（全メニューから）
    final allMenus = await getAllMenus();
    final existingMenus = allMenus.where((m) => m.staffId == staffId).toList();
    if (existingMenus.isNotEmpty) return;

    final demoMenus = [
      ServiceMenu(
        id: '${staffId}_menu_001',
        staffId: staffId,
        name: 'カット',
        description: '丁寧なカウンセリングで理想のスタイルを実現',
        price: 4000,
        duration: 60,
        category: 'ヘアケア',
        createdAt: DateTime.now(),
      ),
      ServiceMenu(
        id: '${staffId}_menu_002',
        staffId: staffId,
        name: 'カラー',
        description: 'トレンドカラーからナチュラルカラーまで',
        price: 6000,
        duration: 90,
        category: 'ヘアケア',
        createdAt: DateTime.now(),
      ),
      ServiceMenu(
        id: '${staffId}_menu_003',
        staffId: staffId,
        name: 'カット+カラー',
        description: 'お得なセットメニュー',
        price: 9000,
        duration: 120,
        category: 'セットメニュー',
        createdAt: DateTime.now(),
      ),
      ServiceMenu(
        id: '${staffId}_menu_004',
        staffId: staffId,
        name: 'トリートメント',
        description: '髪質改善トリートメント',
        price: 3000,
        duration: 30,
        category: 'ヘアケア',
        createdAt: DateTime.now(),
      ),
      ServiceMenu(
        id: '${staffId}_menu_005',
        staffId: staffId,
        name: 'ヘッドスパ',
        description: '極上の癒しのヘッドスパ',
        price: 5000,
        duration: 45,
        category: 'スパ',
        createdAt: DateTime.now(),
      ),
    ];

    for (final menu in demoMenus) {
      await addMenu(menu);
    }
  }

  /// デモクーポンを作成
  Future<void> createDemoCoupons(String staffId, String staffName) async {
    // 既存のクーポンをチェック（全クーポンから）
    final allCoupons = await getAllCoupons();
    final existingCoupons = allCoupons.where((c) => c.staffId == staffId).toList();
    if (existingCoupons.isNotEmpty) return;

    final now = DateTime.now();
    final demoCoupons = [
      Coupon(
        id: '${staffId}_coupon_001',
        staffId: staffId,
        staffName: staffName,
        title: '初回限定1000円OFF',
        description: '初めてのご利用で1000円割引！全メニュー対象',
        type: CouponType.fixedAmount,
        discountValue: 1000,
        minPrice: 3000,
        validFrom: now,
        validUntil: now.add(const Duration(days: 90)),
        usageLimit: 100,
        createdAt: now,
      ),
      Coupon(
        id: '${staffId}_coupon_002',
        staffId: staffId,
        staffName: staffName,
        title: 'カット20%OFF',
        description: 'カットメニューが20%割引',
        type: CouponType.percentage,
        discountValue: 20,
        validFrom: now,
        validUntil: now.add(const Duration(days: 30)),
        createdAt: now,
      ),
      Coupon(
        id: '${staffId}_coupon_003',
        staffId: staffId,
        staffName: staffName,
        title: '平日限定500円OFF',
        description: '平日ご来店で500円割引',
        type: CouponType.fixedAmount,
        discountValue: 500,
        minPrice: 2000,
        validFrom: now,
        validUntil: now.add(const Duration(days: 60)),
        createdAt: now,
      ),
    ];

    for (final coupon in demoCoupons) {
      await createCoupon(coupon);
    }
  }

  /// デモ予約データを作成
  Future<void> createDemoBookings(String staffId, String staffName) async {
    final now = DateTime.now();
    
    // サンプル予約データ
    final demoBookings = [
      // 今日の予約（確認待ち）
      Booking(
        id: 'booking_demo_001',
        userId: 'demo_user_001',
        userName: '山田 太郎',
        userEmail: 'yamada@example.com',
        userPhone: '090-1234-5678',
        staffId: staffId,
        staffName: staffName,
        staffJobTitle: 'スタイリスト',
        storeName: 'サロン〇〇',
        storeAddress: '東京都渋谷区〇〇',
        bookingDate: now,
        bookingTime: '14:00',
        menus: [
          BookingMenu(
            id: '${staffId}_menu_001',
            name: 'カット',
            price: 4000,
            duration: 60,
          ),
        ],
        couponId: null,
        totalPrice: 4000,
        discountAmount: 0,
        finalPrice: 4000,
        status: BookingStatus.pending,
        createdAt: now.subtract(const Duration(hours: 2)),
        note: '初めての利用です。よろしくお願いします。',
      ),

      // 明日の予約（確定済み）
      Booking(
        id: 'booking_demo_002',
        userId: 'demo_user_002',
        userName: '佐藤 花子',
        userEmail: 'sato@example.com',
        userPhone: '080-9876-5432',
        staffId: staffId,
        staffName: staffName,
        staffJobTitle: 'スタイリスト',
        storeName: 'サロン〇〇',
        storeAddress: '東京都渋谷区〇〇',
        bookingDate: now.add(const Duration(days: 1)),
        bookingTime: '10:00',
        menus: [
          BookingMenu(
            id: '${staffId}_menu_003',
            name: 'カット+カラー',
            price: 9000,
            duration: 120,
          ),
        ],
        couponId: null,
        totalPrice: 9000,
        discountAmount: 0,
        finalPrice: 9000,
        status: BookingStatus.confirmed,
        createdAt: now.subtract(const Duration(days: 1)),
        note: 'いつも通りでお願いします。',
      ),

      // 3日後の予約（確定済み）
      Booking(
        id: 'booking_demo_003',
        userId: 'demo_user_003',
        userName: '鈴木 一郎',
        userEmail: 'suzuki@example.com',
        userPhone: '070-1111-2222',
        staffId: staffId,
        staffName: staffName,
        staffJobTitle: 'スタイリスト',
        storeName: 'サロン〇〇',
        storeAddress: '東京都渋谷区〇〇',
        bookingDate: now.add(const Duration(days: 3)),
        bookingTime: '15:30',
        menus: [
          BookingMenu(
            id: '${staffId}_menu_002',
            name: 'カラー',
            price: 6000,
            duration: 90,
          ),
        ],
        couponId: null,
        totalPrice: 6000,
        discountAmount: 0,
        finalPrice: 6000,
        status: BookingStatus.confirmed,
        createdAt: now.subtract(const Duration(hours: 12)),
        note: 'アッシュ系の色でお願いします。',
      ),

      // 1週間後の予約（確認待ち）
      Booking(
        id: 'booking_demo_004',
        userId: 'demo_user_004',
        userName: '田中 美咲',
        userEmail: 'tanaka@example.com',
        userPhone: '090-3333-4444',
        staffId: staffId,
        staffName: staffName,
        staffJobTitle: 'スタイリスト',
        storeName: 'サロン〇〇',
        storeAddress: '東京都渋谷区〇〇',
        bookingDate: now.add(const Duration(days: 7)),
        bookingTime: '11:00',
        menus: [
          BookingMenu(
            id: '${staffId}_menu_001',
            name: 'カット',
            price: 4000,
            duration: 60,
          ),
          BookingMenu(
            id: '${staffId}_menu_004',
            name: 'トリートメント',
            price: 3000,
            duration: 30,
          ),
        ],
        couponId: null,
        totalPrice: 7000,
        discountAmount: 0,
        finalPrice: 7000,
        status: BookingStatus.pending,
        createdAt: now.subtract(const Duration(minutes: 30)),
        note: '髪の傷みが気になります。',
      ),

      // 過去の予約（完了）
      Booking(
        id: 'booking_demo_005',
        userId: 'demo_user_005',
        userName: '高橋 健太',
        userEmail: 'takahashi@example.com',
        userPhone: null,
        staffId: staffId,
        staffName: staffName,
        staffJobTitle: 'スタイリスト',
        storeName: 'サロン〇〇',
        storeAddress: '東京都渋谷区〇〇',
        bookingDate: now.subtract(const Duration(days: 2)),
        bookingTime: '16:00',
        menus: [
          BookingMenu(
            id: '${staffId}_menu_001',
            name: 'カット',
            price: 4000,
            duration: 60,
          ),
        ],
        couponId: null,
        totalPrice: 4000,
        discountAmount: 0,
        finalPrice: 4000,
        status: BookingStatus.completed,
        createdAt: now.subtract(const Duration(days: 5)),
        note: null,
      ),

      // 過去の予約（キャンセル）
      Booking(
        id: 'booking_demo_006',
        userId: 'demo_user_006',
        userName: '伊藤 真理',
        userEmail: 'ito@example.com',
        userPhone: '080-5555-6666',
        staffId: staffId,
        staffName: staffName,
        staffJobTitle: 'スタイリスト',
        storeName: 'サロン〇〇',
        storeAddress: '東京都渋谷区〇〇',
        bookingDate: now.add(const Duration(days: 2)),
        bookingTime: '13:00',
        menus: [
          BookingMenu(
            id: '${staffId}_menu_003',
            name: 'カット+カラー',
            price: 9000,
            duration: 120,
          ),
        ],
        couponId: null,
        totalPrice: 9000,
        discountAmount: 0,
        finalPrice: 9000,
        status: BookingStatus.cancelled,
        createdAt: now.subtract(const Duration(days: 3)),
        note: '体調不良のためキャンセルします。申し訳ございません。',
        cancellationReason: '体調不良のため',
      ),
    ];

    // 既存の予約を取得
    final existingBookings = await getAllBookings();
    
    // デモ予約が既に存在しない場合のみ追加
    for (final booking in demoBookings) {
      if (!existingBookings.any((b) => b.id == booking.id)) {
        await createBooking(booking);
      }
    }
  }
}

