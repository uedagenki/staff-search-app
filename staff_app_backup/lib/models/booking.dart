import 'package:flutter/material.dart';

enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

class Booking {
  final String id;
  final String staffId;
  final String staffName;
  final String staffImage;
  final String staffJobTitle;
  final DateTime date;
  final String timeSlot;
  final BookingStatus status;
  final String? notes;
  final double? price;

  Booking({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.staffImage,
    required this.staffJobTitle,
    required this.date,
    required this.timeSlot,
    required this.status,
    this.notes,
    this.price,
  });

  String getStatusText() {
    switch (status) {
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

  Color getStatusColor() {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFFF9800); // Orange
      case BookingStatus.confirmed:
        return const Color(0xFF4CAF50); // Green
      case BookingStatus.completed:
        return const Color(0xFF2196F3); // Blue
      case BookingStatus.cancelled:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}
