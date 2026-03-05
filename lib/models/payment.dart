class UserPoints {
  final String userId;
  int points;
  int totalPurchased;
  int totalSpent;
  List<PointTransaction> transactions;

  UserPoints({
    required this.userId,
    this.points = 0,
    this.totalPurchased = 0,
    this.totalSpent = 0,
    List<PointTransaction>? transactions,
  }) : transactions = transactions ?? [];

  factory UserPoints.fromJson(Map<String, dynamic> json) {
    return UserPoints(
      userId: json['userId'] as String,
      points: json['points'] as int? ?? 0,
      totalPurchased: json['totalPurchased'] as int? ?? 0,
      totalSpent: json['totalSpent'] as int? ?? 0,
      transactions: (json['transactions'] as List?)
              ?.map((t) => PointTransaction.fromJson(t))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'points': points,
      'totalPurchased': totalPurchased,
      'totalSpent': totalSpent,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }

  void addPoints(int amount, String description, TransactionType type) {
    points += amount;
    if (type == TransactionType.purchase) {
      totalPurchased += amount;
    }
    transactions.add(PointTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      type: type,
      description: description,
      timestamp: DateTime.now(),
    ));
  }

  void spendPoints(int amount, String description) {
    if (points >= amount) {
      points -= amount;
      totalSpent += amount;
      transactions.add(PointTransaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        amount: -amount,
        type: TransactionType.gift,
        description: description,
        timestamp: DateTime.now(),
      ));
    }
  }
}

class PointTransaction {
  final String id;
  final int amount;
  final TransactionType type;
  final String description;
  final DateTime timestamp;

  PointTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.timestamp,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] as String,
      amount: json['amount'] as int,
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
        orElse: () => TransactionType.other,
      ),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.toString().split('.').last,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum TransactionType {
  purchase, // ポイント購入
  gift, // ギフト送信
  received, // ギフト受信
  withdrawal, // 出金
  refund, // 返金
  other, // その他
}

class StaffEarnings {
  final String staffId;
  int totalEarnings;
  int pendingEarnings;
  int withdrawnEarnings;
  List<EarningTransaction> transactions;
  List<WithdrawalRequest> withdrawalRequests;

  StaffEarnings({
    required this.staffId,
    this.totalEarnings = 0,
    this.pendingEarnings = 0,
    this.withdrawnEarnings = 0,
    List<EarningTransaction>? transactions,
    List<WithdrawalRequest>? withdrawalRequests,
  })  : transactions = transactions ?? [],
        withdrawalRequests = withdrawalRequests ?? [];

  factory StaffEarnings.fromJson(Map<String, dynamic> json) {
    return StaffEarnings(
      staffId: json['staffId'] as String,
      totalEarnings: json['totalEarnings'] as int? ?? 0,
      pendingEarnings: json['pendingEarnings'] as int? ?? 0,
      withdrawnEarnings: json['withdrawnEarnings'] as int? ?? 0,
      transactions: (json['transactions'] as List?)
              ?.map((t) => EarningTransaction.fromJson(t))
              .toList() ??
          [],
      withdrawalRequests: (json['withdrawalRequests'] as List?)
              ?.map((w) => WithdrawalRequest.fromJson(w))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'totalEarnings': totalEarnings,
      'pendingEarnings': pendingEarnings,
      'withdrawnEarnings': withdrawnEarnings,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'withdrawalRequests': withdrawalRequests.map((w) => w.toJson()).toList(),
    };
  }

  void addEarning(int amount, String fromUserId, String fromUserName, String description) {
    totalEarnings += amount;
    pendingEarnings += amount;
    transactions.add(EarningTransaction(
      id: 'earn_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      description: description,
      timestamp: DateTime.now(),
    ));
  }

  void requestWithdrawal(int amount, String bankAccount) {
    if (pendingEarnings >= amount) {
      pendingEarnings -= amount;
      withdrawalRequests.add(WithdrawalRequest(
        id: 'wd_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        bankAccount: bankAccount,
        status: WithdrawalStatus.pending,
        requestedAt: DateTime.now(),
      ));
    }
  }
}

class EarningTransaction {
  final String id;
  final int amount;
  final String fromUserId;
  final String fromUserName;
  final String description;
  final DateTime timestamp;

  EarningTransaction({
    required this.id,
    required this.amount,
    required this.fromUserId,
    required this.fromUserName,
    required this.description,
    required this.timestamp,
  });

  factory EarningTransaction.fromJson(Map<String, dynamic> json) {
    return EarningTransaction(
      id: json['id'] as String,
      amount: json['amount'] as int,
      fromUserId: json['fromUserId'] as String,
      fromUserName: json['fromUserName'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class WithdrawalRequest {
  final String id;
  final int amount;
  final String bankAccount;
  WithdrawalStatus status;
  final DateTime requestedAt;
  DateTime? processedAt;
  String? note;

  WithdrawalRequest({
    required this.id,
    required this.amount,
    required this.bankAccount,
    required this.status,
    required this.requestedAt,
    this.processedAt,
    this.note,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['id'] as String,
      amount: json['amount'] as int,
      bankAccount: json['bankAccount'] as String,
      status: WithdrawalStatus.values.firstWhere(
        (e) => e.toString() == 'WithdrawalStatus.${json['status']}',
        orElse: () => WithdrawalStatus.pending,
      ),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'bankAccount': bankAccount,
      'status': status.toString().split('.').last,
      'requestedAt': requestedAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'note': note,
    };
  }
}

enum WithdrawalStatus {
  pending, // 申請中
  approved, // 承認済み
  processing, // 処理中
  completed, // 完了
  rejected, // 却下
}
