/// 予約モデル（ホットペッパービューティー風）
class Booking {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final String staffId;
  final String staffName;
  final String staffJobTitle;
  final String? storeName;
  final String? storeAddress;
  final DateTime bookingDate;
  final String bookingTime; // "10:00", "14:30" など
  final List<BookingMenu> menus; // 選択したメニュー
  final String? couponId; // 使用したクーポンID
  final int totalPrice; // 合計金額
  final int discountAmount; // 割引額
  final int finalPrice; // 最終金額（合計 - 割引）
  final BookingStatus status;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? note; // 備考・要望
  
  Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    required this.staffId,
    required this.staffName,
    required this.staffJobTitle,
    this.storeName,
    this.storeAddress,
    required this.bookingDate,
    required this.bookingTime,
    required this.menus,
    this.couponId,
    required this.totalPrice,
    this.discountAmount = 0,
    required this.finalPrice,
    required this.status,
    this.cancellationReason,
    required this.createdAt,
    this.confirmedAt,
    this.completedAt,
    this.cancelledAt,
    this.note,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      userPhone: json['userPhone'] as String?,
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      staffJobTitle: json['staffJobTitle'] as String,
      storeName: json['storeName'] as String?,
      storeAddress: json['storeAddress'] as String?,
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      bookingTime: json['bookingTime'] as String,
      menus: (json['menus'] as List)
          .map((m) => BookingMenu.fromJson(m as Map<String, dynamic>))
          .toList(),
      couponId: json['couponId'] as String?,
      totalPrice: json['totalPrice'] as int,
      discountAmount: json['discountAmount'] as int? ?? 0,
      finalPrice: json['finalPrice'] as int,
      status: BookingStatus.values.firstWhere(
        (s) => s.toString() == 'BookingStatus.${json['status']}',
      ),
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'staffId': staffId,
      'staffName': staffName,
      'staffJobTitle': staffJobTitle,
      'storeName': storeName,
      'storeAddress': storeAddress,
      'bookingDate': bookingDate.toIso8601String(),
      'bookingTime': bookingTime,
      'menus': menus.map((m) => m.toJson()).toList(),
      'couponId': couponId,
      'totalPrice': totalPrice,
      'discountAmount': discountAmount,
      'finalPrice': finalPrice,
      'status': status.toString().split('.').last,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'note': note,
    };
  }

  Booking copyWith({
    BookingStatus? status,
    DateTime? confirmedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return Booking(
      id: id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      staffId: staffId,
      staffName: staffName,
      staffJobTitle: staffJobTitle,
      storeName: storeName,
      storeAddress: storeAddress,
      bookingDate: bookingDate,
      bookingTime: bookingTime,
      menus: menus,
      couponId: couponId,
      totalPrice: totalPrice,
      discountAmount: discountAmount,
      finalPrice: finalPrice,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      note: note,
    );
  }
}

/// 予約メニュー
class BookingMenu {
  final String id;
  final String name;
  final int price;
  final int duration; // 所要時間（分）
  
  BookingMenu({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
  });

  factory BookingMenu.fromJson(Map<String, dynamic> json) {
    return BookingMenu(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      duration: json['duration'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration': duration,
    };
  }
}

/// 予約ステータス
enum BookingStatus {
  pending,    // 予約申込（確認待ち）
  confirmed,  // 予約確定
  completed,  // 完了
  cancelled,  // キャンセル
}

extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return '確認待ち';
      case BookingStatus.confirmed:
        return '予約確定';
      case BookingStatus.completed:
        return '完了';
      case BookingStatus.cancelled:
        return 'キャンセル';
    }
  }

  String get emoji {
    switch (this) {
      case BookingStatus.pending:
        return '⏳';
      case BookingStatus.confirmed:
        return '✅';
      case BookingStatus.completed:
        return '🎉';
      case BookingStatus.cancelled:
        return '❌';
    }
  }
}
