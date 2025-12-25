class TipHistory {
  final String id;
  final String staffId;
  final String staffName;
  final String staffImage;
  final double amount;
  final DateTime timestamp;
  final String? message;

  TipHistory({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.staffImage,
    required this.amount,
    required this.timestamp,
    this.message,
  });
}
