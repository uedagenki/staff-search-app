import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class FirebaseBookingService {
  static final FirebaseBookingService _instance = FirebaseBookingService._internal();
  factory FirebaseBookingService() => _instance;
  FirebaseBookingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // コレクション参照
  CollectionReference get _bookingsCollection => _firestore.collection('bookings');
  CollectionReference get _servicesCollection => _firestore.collection('services');

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

      // Firestoreに予約を追加
      final bookingData = booking.toJson();
      await _bookingsCollection.doc(booking.id).set(bookingData);

      if (kDebugMode) {
        debugPrint('✅ Booking created successfully: ${booking.id}');
      }

      return booking;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to create booking: $e');
      }
      return null;
    }
  }

  // スタッフの予約一覧を取得
  Future<List<Booking>> getStaffBookings(String staffId, {String? status, DateTime? date}) async {
    try {
      Query query = _bookingsCollection.where('staffId', isEqualTo: staffId);

      // ステータスでフィルター
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final querySnapshot = await query.get();
      var bookings = querySnapshot.docs
          .map((doc) => Booking.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // 日付でフィルター（メモリ内でフィルタリング）
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
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load staff bookings: $e');
      }
      return [];
    }
  }

  // ユーザーの予約一覧を取得
  Future<List<Booking>> getUserBookings(String userId, {String? status}) async {
    try {
      Query query = _bookingsCollection.where('userId', isEqualTo: userId);

      // ステータスでフィルター
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final querySnapshot = await query.get();
      var bookings = querySnapshot.docs
          .map((doc) => Booking.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // 日時順にソート
      bookings.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      return bookings;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load user bookings: $e');
      }
      return [];
    }
  }

  // 予約を更新
  Future<bool> updateBooking(Booking updatedBooking) async {
    try {
      final bookingData = updatedBooking.toJson();
      await _bookingsCollection.doc(updatedBooking.id).update(bookingData);

      if (kDebugMode) {
        debugPrint('✅ Booking updated successfully: ${updatedBooking.id}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to update booking: $e');
      }
      return false;
    }
  }

  // 予約をキャンセル
  Future<bool> cancelBooking(String bookingId, String staffId, String userId, String? reason) async {
    try {
      final doc = await _bookingsCollection.doc(bookingId).get();
      if (!doc.exists) {
        if (kDebugMode) {
          debugPrint('❌ Booking not found: $bookingId');
        }
        return false;
      }

      final booking = Booking.fromJson(doc.data() as Map<String, dynamic>);
      final cancelledBooking = booking.copyWith(
        status: 'cancelled',
        cancellationReason: reason,
        updatedAt: DateTime.now(),
      );

      return await updateBooking(cancelledBooking);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to cancel booking: $e');
      }
      return false;
    }
  }

  // 予約を確認
  Future<bool> confirmBooking(String bookingId, String staffId, String userId) async {
    try {
      final doc = await _bookingsCollection.doc(bookingId).get();
      if (!doc.exists) {
        if (kDebugMode) {
          debugPrint('❌ Booking not found: $bookingId');
        }
        return false;
      }

      final booking = Booking.fromJson(doc.data() as Map<String, dynamic>);
      final confirmedBooking = booking.copyWith(
        status: 'confirmed',
        updatedAt: DateTime.now(),
      );

      return await updateBooking(confirmedBooking);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to confirm booking: $e');
      }
      return false;
    }
  }

  // 予約を完了
  Future<bool> completeBooking(String bookingId, String staffId, String userId) async {
    try {
      final doc = await _bookingsCollection.doc(bookingId).get();
      if (!doc.exists) {
        if (kDebugMode) {
          debugPrint('❌ Booking not found: $bookingId');
        }
        return false;
      }

      final booking = Booking.fromJson(doc.data() as Map<String, dynamic>);
      final completedBooking = booking.copyWith(
        status: 'completed',
        updatedAt: DateTime.now(),
      );

      return await updateBooking(completedBooking);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to complete booking: $e');
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
      const startHour = 9;
      const endHour = 18;

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
        debugPrint('❌ Failed to get available time slots: $e');
      }
      return [];
    }
  }

  // スタッフのサービス一覧を取得
  Future<List<Service>> getStaffServices(String staffId) async {
    try {
      final querySnapshot = await _servicesCollection
          .where('staffId', isEqualTo: staffId)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Service.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load staff services: $e');
      }
      return [];
    }
  }

  // サービスを追加
  Future<bool> addService(Service service) async {
    try {
      final serviceData = service.toJson();
      await _servicesCollection.doc(service.id).set(serviceData);

      if (kDebugMode) {
        debugPrint('✅ Service added successfully: ${service.id}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to add service: $e');
      }
      return false;
    }
  }

  // サービスを更新
  Future<bool> updateService(Service updatedService) async {
    try {
      final serviceData = updatedService.toJson();
      await _servicesCollection.doc(updatedService.id).update(serviceData);

      if (kDebugMode) {
        debugPrint('✅ Service updated successfully: ${updatedService.id}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to update service: $e');
      }
      return false;
    }
  }

  // サービスを削除（論理削除）
  Future<bool> deleteService(String staffId, String serviceId) async {
    try {
      await _servicesCollection.doc(serviceId).update({'isActive': false});

      if (kDebugMode) {
        debugPrint('✅ Service deleted successfully: $serviceId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to delete service: $e');
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
            .fold<double>(0, (total, b) => total + b.price),
        'thisMonthRevenue': thisMonthBookings
            .where((b) => b.isCompleted)
            .fold<double>(0, (total, b) => total + b.price),
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get booking stats: $e');
      }
      return {};
    }
  }

  // リアルタイム予約リスナー（Stream）
  Stream<List<Booking>> watchStaffBookings(String staffId, {String? status}) {
    Query query = _bookingsCollection.where('staffId', isEqualTo: staffId);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) {
      final bookings = snapshot.docs
          .map((doc) => Booking.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      bookings.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return bookings;
    });
  }

  // リアルタイムユーザー予約リスナー（Stream）
  Stream<List<Booking>> watchUserBookings(String userId, {String? status}) {
    Query query = _bookingsCollection.where('userId', isEqualTo: userId);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) {
      final bookings = snapshot.docs
          .map((doc) => Booking.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      bookings.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return bookings;
    });
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

  // サンプルデータ生成（開発・テスト用）
  Future<void> createSampleData(String staffId, String staffName) async {
    try {
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
        Service(
          id: 'service_${DateTime.now().millisecondsSinceEpoch}_4',
          staffId: staffId,
          name: 'ヘッドスパ',
          description: 'リラックス効果抜群',
          price: 3000,
          duration: 30,
          category: 'リラクゼーション',
        ),
        Service(
          id: 'service_${DateTime.now().millisecondsSinceEpoch}_5',
          staffId: staffId,
          name: 'トリートメント',
          description: '髪質改善トリートメント',
          price: 6000,
          duration: 45,
          category: 'ヘアケア',
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
          dateTime: now.add(const Duration(days: 1)).copyWith(hour: 10, minute: 0, second: 0, millisecond: 0, microsecond: 0),
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
          dateTime: now.add(const Duration(days: 2)).copyWith(hour: 14, minute: 0, second: 0, millisecond: 0, microsecond: 0),
          duration: services[1].duration,
          status: 'pending',
          notes: 'カラーの色味は相談で決めたいです',
          createdAt: now,
        ),
        Booking(
          id: 'booking_${DateTime.now().millisecondsSinceEpoch}_3',
          userId: 'user_003',
          userName: '鈴木一郎',
          userEmail: 'suzuki@example.com',
          userPhone: '070-1111-2222',
          staffId: staffId,
          staffName: staffName,
          staffAvatar: '',
          serviceId: services[2].id,
          serviceName: services[2].name,
          serviceDescription: services[2].description,
          price: services[2].price,
          dateTime: now.add(const Duration(days: 3)).copyWith(hour: 11, minute: 30, second: 0, millisecond: 0, microsecond: 0),
          duration: services[2].duration,
          status: 'pending',
          createdAt: now,
        ),
      ];

      for (final booking in bookings) {
        await createBooking(booking);
      }

      if (kDebugMode) {
        debugPrint('✅ Sample data created successfully!');
        debugPrint('   - ${services.length} services added');
        debugPrint('   - ${bookings.length} bookings created');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to create sample data: $e');
      }
    }
  }
}
