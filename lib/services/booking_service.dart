import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../utils/storage_helper.dart';
import '../models/booking.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  // 予約を作成
  Future<Booking?> createBooking(Booking booking) async {
    try {
      // タイムスロットの重複チェック
      if (!await _isTimeSlotAvailable(booking.staffId, booking.dateTime, booking.duration)) {
        if (kDebugMode) {
          debugPrint('Time slot is not available');
        }
        return null;
      }

      // スタッフの予約リストに追加
      final staffBookings = await getStaffBookings(booking.staffId);
      staffBookings.add(booking);
      await _saveStaffBookings(booking.staffId, staffBookings);

      // ユーザーの予約リストに追加
      final userBookings = await getUserBookings(booking.userId);
      userBookings.add(booking);
      await _saveUserBookings(booking.userId, userBookings);

      return booking;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to create booking: $e');
      }
      return null;
    }
  }

  // スタッフの予約一覧を取得
  Future<List<Booking>> getStaffBookings(String staffId, {String? status, DateTime? date}) async {
    try {
      final jsonStr = await StorageHelper.getString('bookings_staff_$staffId');
      
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        var bookings = jsonList.map((json) => Booking.fromJson(json)).toList();

        // ステータスでフィルター
        if (status != null) {
          bookings = bookings.where((b) => b.status == status).toList();
        }

        // 日付でフィルター
        if (date != null) {
          bookings = bookings.where((b) {
            return b.dateTime.year == date.year &&
                   b.dateTime.month == date.month &&
                   b.dateTime.day == date.day;
          }).toList();
        }

        // 日時順にソート
        bookings.sort((a, b) => a.dateTime.compareTo(b.dateTime));

        return bookings;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load staff bookings: $e');
      }
    }
    return [];
  }

  // ユーザーの予約一覧を取得
  Future<List<Booking>> getUserBookings(String userId, {String? status}) async {
    try {
      final jsonStr = await StorageHelper.getString('bookings_user_$userId');
      
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        var bookings = jsonList.map((json) => Booking.fromJson(json)).toList();

        // ステータスでフィルター
        if (status != null) {
          bookings = bookings.where((b) => b.status == status).toList();
        }

        // 日時順にソート
        bookings.sort((a, b) => a.dateTime.compareTo(b.dateTime));

        return bookings;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load user bookings: $e');
      }
    }
    return [];
  }

  // 予約を更新
  Future<bool> updateBooking(Booking updatedBooking) async {
    try {
      // スタッフの予約を更新
      final staffBookings = await getStaffBookings(updatedBooking.staffId);
      final staffIndex = staffBookings.indexWhere((b) => b.id == updatedBooking.id);
      if (staffIndex != -1) {
        staffBookings[staffIndex] = updatedBooking;
        await _saveStaffBookings(updatedBooking.staffId, staffBookings);
      }

      // ユーザーの予約を更新
      final userBookings = await getUserBookings(updatedBooking.userId);
      final userIndex = userBookings.indexWhere((b) => b.id == updatedBooking.id);
      if (userIndex != -1) {
        userBookings[userIndex] = updatedBooking;
        await _saveUserBookings(updatedBooking.userId, userBookings);
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to update booking: $e');
      }
      return false;
    }
  }

  // 予約をキャンセル
  Future<bool> cancelBooking(String bookingId, String staffId, String userId, String? reason) async {
    try {
      final staffBookings = await getStaffBookings(staffId);
      final booking = staffBookings.firstWhere((b) => b.id == bookingId);
      
      final cancelledBooking = booking.copyWith(
        status: 'cancelled',
        cancellationReason: reason,
        updatedAt: DateTime.now(),
      );

      return await updateBooking(cancelledBooking);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to cancel booking: $e');
      }
      return false;
    }
  }

  // 予約を確認
  Future<bool> confirmBooking(String bookingId, String staffId, String userId) async {
    try {
      final staffBookings = await getStaffBookings(staffId);
      final booking = staffBookings.firstWhere((b) => b.id == bookingId);
      
      final confirmedBooking = booking.copyWith(
        status: 'confirmed',
        updatedAt: DateTime.now(),
      );

      return await updateBooking(confirmedBooking);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to confirm booking: $e');
      }
      return false;
    }
  }

  // 予約を完了
  Future<bool> completeBooking(String bookingId, String staffId, String userId) async {
    try {
      final staffBookings = await getStaffBookings(staffId);
      final booking = staffBookings.firstWhere((b) => b.id == bookingId);
      
      final completedBooking = booking.copyWith(
        status: 'completed',
        updatedAt: DateTime.now(),
      );

      return await updateBooking(completedBooking);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to complete booking: $e');
      }
      return false;
    }
  }

  // 利用可能なタイムスロットを取得
  Future<List<TimeSlot>> getAvailableTimeSlots(
    String staffId,
    DateTime date,
    int duration,
  ) async {
    try {
      final bookings = await getStaffBookings(staffId, date: date);
      final slots = <TimeSlot>[];

      // 営業時間: 9:00 - 18:00
      final startHour = 9;
      final endHour = 18;

      DateTime currentTime = DateTime(date.year, date.month, date.day, startHour, 0);
      final endTime = DateTime(date.year, date.month, date.day, endHour, 0);

      while (currentTime.isBefore(endTime)) {
        final slotEnd = currentTime.add(Duration(minutes: duration));
        
        if (slotEnd.isAfter(endTime)) break;

        // この時間帯に予約があるかチェック
        final hasConflict = bookings.any((booking) {
          if (booking.isCancelled) return false;
          
          return (currentTime.isBefore(booking.endTime) && 
                  slotEnd.isAfter(booking.dateTime));
        });

        slots.add(TimeSlot(
          startTime: currentTime,
          endTime: slotEnd,
          isAvailable: !hasConflict,
        ));

        // 30分刻みで次のスロットへ
        currentTime = currentTime.add(const Duration(minutes: 30));
      }

      return slots;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get available time slots: $e');
      }
      return [];
    }
  }

  // スタッフのサービス一覧を取得
  Future<List<Service>> getStaffServices(String staffId) async {
    try {
      final jsonStr = await StorageHelper.getString('services_$staffId');
      
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        return jsonList.map((json) => Service.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load staff services: $e');
      }
    }
    return [];
  }

  // サービスを追加
  Future<bool> addService(Service service) async {
    try {
      final services = await getStaffServices(service.staffId);
      services.add(service);
      
      final jsonList = services.map((s) => s.toJson()).toList();
      await StorageHelper.setString('services_${service.staffId}', jsonEncode(jsonList));
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to add service: $e');
      }
      return false;
    }
  }

  // サービスを更新
  Future<bool> updateService(Service updatedService) async {
    try {
      final services = await getStaffServices(updatedService.staffId);
      final index = services.indexWhere((s) => s.id == updatedService.id);
      
      if (index != -1) {
        services[index] = updatedService;
        
        final jsonList = services.map((s) => s.toJson()).toList();
        await StorageHelper.setString('services_${updatedService.staffId}', jsonEncode(jsonList));
        
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to update service: $e');
      }
    }
    return false;
  }

  // サービスを削除
  Future<bool> deleteService(String staffId, String serviceId) async {
    try {
      final services = await getStaffServices(staffId);
      services.removeWhere((s) => s.id == serviceId);
      
      final jsonList = services.map((s) => s.toJson()).toList();
      await StorageHelper.setString('services_$staffId', jsonEncode(jsonList));
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to delete service: $e');
      }
      return false;
    }
  }

  // 統計情報を取得
  Future<Map<String, dynamic>> getBookingStats(String staffId) async {
    try {
      final allBookings = await getStaffBookings(staffId);
      final now = DateTime.now();
      final thisMonthStart = DateTime(now.year, now.month, 1);

      final thisMonthBookings = allBookings.where((b) {
        return b.createdAt.isAfter(thisMonthStart);
      }).toList();

      return {
        'total': allBookings.length,
        'thisMonth': thisMonthBookings.length,
        'pending': allBookings.where((b) => b.isPending).length,
        'confirmed': allBookings.where((b) => b.isConfirmed).length,
        'completed': allBookings.where((b) => b.isCompleted).length,
        'cancelled': allBookings.where((b) => b.isCancelled).length,
        'revenue': allBookings
            .where((b) => b.isCompleted)
            .fold<double>(0, (sum, b) => sum + b.price),
        'thisMonthRevenue': thisMonthBookings
            .where((b) => b.isCompleted)
            .fold<double>(0, (sum, b) => sum + b.price),
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get booking stats: $e');
      }
      return {};
    }
  }

  // プライベートメソッド

  Future<bool> _isTimeSlotAvailable(String staffId, DateTime startTime, int duration) async {
    final bookings = await getStaffBookings(staffId);
    final endTime = startTime.add(Duration(minutes: duration));

    for (final booking in bookings) {
      if (booking.isCancelled) continue;

      if (startTime.isBefore(booking.endTime) && endTime.isAfter(booking.dateTime)) {
        return false;
      }
    }

    return true;
  }

  Future<void> _saveStaffBookings(String staffId, List<Booking> bookings) async {
    final jsonList = bookings.map((b) => b.toJson()).toList();
    await StorageHelper.setString('bookings_staff_$staffId', jsonEncode(jsonList));
  }

  Future<void> _saveUserBookings(String userId, List<Booking> bookings) async {
    final jsonList = bookings.map((b) => b.toJson()).toList();
    await StorageHelper.setString('bookings_user_$userId', jsonEncode(jsonList));
  }

  // サンプルデータ生成
  Future<void> createSampleData(String staffId, String staffName) async {
    // サンプルサービス
    final services = [
      Service(
        id: 'service_${DateTime.now().millisecondsSinceEpoch}_1',
        staffId: staffId,
        name: 'カット',
        description: 'シャンプー・ブロー込み',
        price: 5000,
        duration: 60,
        category: 'ヘアスタイル',
      ),
      Service(
        id: 'service_${DateTime.now().millisecondsSinceEpoch}_2',
        staffId: staffId,
        name: 'カラー',
        description: '全体カラー・トリートメント込み',
        price: 8000,
        duration: 90,
        category: 'ヘアスタイル',
      ),
      Service(
        id: 'service_${DateTime.now().millisecondsSinceEpoch}_3',
        staffId: staffId,
        name: 'パーマ',
        description: 'カット・トリートメント込み',
        price: 10000,
        duration: 120,
        category: 'ヘアスタイル',
      ),
    ];

    for (final service in services) {
      await addService(service);
    }

    // サンプル予約
    final now = DateTime.now();
    final bookings = [
      Booking(
        id: 'booking_${DateTime.now().millisecondsSinceEpoch}_1',
        userId: 'user_001',
        userName: '山田太郎',
        userEmail: 'yamada@example.com',
        userPhone: '090-1234-5678',
        staffId: staffId,
        staffName: staffName,
        staffAvatar: '',
        serviceId: services[0].id,
        serviceName: services[0].name,
        serviceDescription: services[0].description,
        price: services[0].price,
        dateTime: now.add(const Duration(days: 1)).copyWith(hour: 10, minute: 0),
        duration: services[0].duration,
        status: 'confirmed',
        notes: 'よろしくお願いします',
        createdAt: now,
      ),
      Booking(
        id: 'booking_${DateTime.now().millisecondsSinceEpoch}_2',
        userId: 'user_002',
        userName: '佐藤花子',
        userEmail: 'sato@example.com',
        userPhone: '080-9876-5432',
        staffId: staffId,
        staffName: staffName,
        staffAvatar: '',
        serviceId: services[1].id,
        serviceName: services[1].name,
        serviceDescription: services[1].description,
        price: services[1].price,
        dateTime: now.add(const Duration(days: 2)).copyWith(hour: 14, minute: 0),
        duration: services[1].duration,
        status: 'pending',
        createdAt: now,
      ),
    ];

    for (final booking in bookings) {
      await createBooking(booking);
    }
  }
}
