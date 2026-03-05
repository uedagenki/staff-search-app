class Booking {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String staffId;
  final String staffName;
  final String staffAvatar;
  final String serviceId;
  final String serviceName;
  final String serviceDescription;
  final double price;
  final DateTime dateTime;
  final int duration; // 分単位
  final String status; // 'pending' | 'confirmed' | 'completed' | 'cancelled'
  final String? notes;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.staffId,
    required this.staffName,
    required this.staffAvatar,
    required this.serviceId,
    required this.serviceName,
    required this.serviceDescription,
    required this.price,
    required this.dateTime,
    required this.duration,
    this.status = 'pending',
    this.notes,
    this.cancellationReason,
    required this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      userPhone: json['userPhone'] as String,
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      staffAvatar: json['staffAvatar'] as String,
      serviceId: json['serviceId'] as String,
      serviceName: json['serviceName'] as String,
      serviceDescription: json['serviceDescription'] as String,
      price: (json['price'] as num).toDouble(),
      dateTime: DateTime.parse(json['dateTime'] as String),
      duration: json['duration'] as int,
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
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
      'staffAvatar': staffAvatar,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'serviceDescription': serviceDescription,
      'price': price,
      'dateTime': dateTime.toIso8601String(),
      'duration': duration,
      'status': status,
      'notes': notes,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? staffId,
    String? staffName,
    String? staffAvatar,
    String? serviceId,
    String? serviceName,
    String? serviceDescription,
    double? price,
    DateTime? dateTime,
    int? duration,
    String? status,
    String? notes,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      staffAvatar: staffAvatar ?? this.staffAvatar,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      price: price ?? this.price,
      dateTime: dateTime ?? this.dateTime,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  DateTime get endTime => dateTime.add(Duration(minutes: duration));

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  bool get canCancel {
    return (isPending || isConfirmed) && 
           dateTime.isAfter(DateTime.now().add(const Duration(hours: 24)));
  }
}

class Service {
  final String id;
  final String staffId;
  final String name;
  final String description;
  final double price;
  final int duration; // 分単位
  final String category;
  final bool isActive;
  final List<String> images;

  Service({
    required this.id,
    required this.staffId,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.category,
    this.isActive = true,
    this.images = const [],
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      staffId: json['staffId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      duration: json['duration'] as int,
      category: json['category'] as String,
      isActive: json['isActive'] as bool? ?? true,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'category': category,
      'isActive': isActive,
      'images': images,
    };
  }
}

class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final String? bookingId;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.bookingId,
  });

  int get durationMinutes => endTime.difference(startTime).inMinutes;
}
