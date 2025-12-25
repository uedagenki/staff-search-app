import 'package:flutter/material.dart';

enum OfferStatus {
  pending,    // 検討中
  accepted,   // 承認
  declined,   // 辞退
}

class HeadhuntOffer {
  final String id;
  final String staffId;
  final String staffName;
  final String staffImage;
  final String companyName;
  final String position;
  final String jobDescription;
  final String salaryRange;
  final String location;
  final OfferStatus status;
  final DateTime createdAt;
  final String? message;

  HeadhuntOffer({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.staffImage,
    required this.companyName,
    required this.position,
    required this.jobDescription,
    required this.salaryRange,
    required this.location,
    required this.status,
    required this.createdAt,
    this.message,
  });

  String getStatusText() {
    switch (status) {
      case OfferStatus.pending:
        return '検討中';
      case OfferStatus.accepted:
        return '承認済み';
      case OfferStatus.declined:
        return '辞退';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case OfferStatus.pending:
        return const Color(0xFFFF9800); // Orange
      case OfferStatus.accepted:
        return const Color(0xFF4CAF50); // Green
      case OfferStatus.declined:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}
