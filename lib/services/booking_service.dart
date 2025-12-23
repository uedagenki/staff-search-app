import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/booking.dart';

class BookingService {
  static const String _bookingsKey = 'user_bookings';

  // 予約を追加
  Future<void> addBooking(Booking booking) async {
    final prefs = await SharedPreferences.getInstance();
    final bookings = await getBookings();
    
    // 予約データをマップに変換
    final bookingMap = {
      'id': booking.id,
      'staffId': booking.staffId,
      'staffName': booking.staffName,
      'staffImage': booking.staffImage,
      'staffJobTitle': booking.staffJobTitle,
      'date': booking.date.toIso8601String(),
      'timeSlot': booking.timeSlot,
      'status': booking.status.toString(),
      'notes': booking.notes,
      'price': booking.price,
    };
    
    bookings.add(bookingMap);
    await prefs.setString(_bookingsKey, jsonEncode(bookings));
  }

  // すべての予約を取得
  Future<List<Map<String, dynamic>>> getBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingsJson = prefs.getString(_bookingsKey);
    
    if (bookingsJson == null) {
      return [];
    }
    
    final List<dynamic> decoded = jsonDecode(bookingsJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  // 予約を削除
  Future<void> deleteBooking(String bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookings = await getBookings();
    
    bookings.removeWhere((booking) => booking['id'] == bookingId);
    await prefs.setString(_bookingsKey, jsonEncode(bookings));
  }

  // 予約を更新
  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final bookings = await getBookings();
    
    for (var booking in bookings) {
      if (booking['id'] == bookingId) {
        booking['status'] = newStatus.toString();
        break;
      }
    }
    
    await prefs.setString(_bookingsKey, jsonEncode(bookings));
  }

  // Booking オブジェクトの一覧を取得
  Future<List<Booking>> getBookingsList() async {
    final bookingsData = await getBookings();
    
    return bookingsData.map((data) {
      return Booking(
        id: data['id'],
        staffId: data['staffId'],
        staffName: data['staffName'],
        staffImage: data['staffImage'],
        staffJobTitle: data['staffJobTitle'],
        date: DateTime.parse(data['date']),
        timeSlot: data['timeSlot'],
        status: _parseStatus(data['status']),
        notes: data['notes'],
        price: data['price']?.toDouble(),
      );
    }).toList();
  }

  BookingStatus _parseStatus(String statusString) {
    switch (statusString) {
      case 'BookingStatus.pending':
        return BookingStatus.pending;
      case 'BookingStatus.confirmed':
        return BookingStatus.confirmed;
      case 'BookingStatus.completed':
        return BookingStatus.completed;
      case 'BookingStatus.cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}
