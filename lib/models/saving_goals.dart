import 'package:uuid/uuid.dart';

class SavingsGoal {
  final String id;  // ID unik untuk identifikasi
  String name;
  double targetAmount;
  double currentAmount;
  String frequency;
  double depositAmount;
  String currencyCode;
  DateTime createdAt;
  DateTime? completedAt;
  List<Transaction> transactions;

  SavingsGoal({
    String? id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.frequency,
    required this.depositAmount,
    this.currencyCode = 'Rp',
    DateTime? createdAt,
    this.completedAt,
    List<Transaction>? transactions,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    transactions = transactions ?? [];

  double get progressPercentage => currentAmount / targetAmount;

  bool get isCompleted => currentAmount >= targetAmount;

  DateTime get estimatedCompletionDate {
    if (depositAmount <= 0) return DateTime.now().add(const Duration(days: 365));
    
    final remainingAmount = targetAmount - currentAmount;
    final depositsNeeded = remainingAmount / depositAmount;
    
    int daysToAdd;
    if (frequency == 'Harian') {
      daysToAdd = depositsNeeded.ceil();
    } else if (frequency == 'Mingguan') {
      daysToAdd = (depositsNeeded * 7).ceil();
    } else {
      daysToAdd = (depositsNeeded * 30).ceil();
    }
    
    return DateTime.now().add(Duration(days: daysToAdd));
  }

  void addDeposit(double amount, String note) {
    currentAmount += amount;
    transactions.add(
      Transaction(
        amount: amount,
        date: DateTime.now(),
        note: note,
        isDeposit: true,
      ),
    );
    
    if (currentAmount > targetAmount) {
      currentAmount = targetAmount;
    }
  }

  void withdraw(double amount, String note) {
    if (amount <= currentAmount) {
      currentAmount -= amount;
      transactions.add(
        Transaction(
          amount: amount,
          date: DateTime.now(),
          note: note,
          isDeposit: false,
        ),
      );
    }
  }

  // Konversi ke Map untuk penyimpanan
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'frequency': frequency,
      'depositAmount': depositAmount,
      'currencyCode': currencyCode,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'transactions': transactions.map((t) => t.toMap()).toList(),
    };
  }

  // Buat objek dari Map
  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    // Pastikan field yang ada adalah benar dan nilai tidak null
    final id = map['id'] as String? ?? const Uuid().v4();
    final name = map['name'] as String? ?? 'Tabungan';
    final targetAmount = (map['targetAmount'] as num?)?.toDouble() ?? 0.0;
    final currentAmount = (map['currentAmount'] as num?)?.toDouble() ?? 0.0;
    final frequency = map['frequency'] as String? ?? 'Harian';
    final depositAmount = (map['depositAmount'] as num?)?.toDouble() ?? 0.0;
    final currencyCode = map['currencyCode'] as String? ?? 'Rp';
    
    DateTime? createdAt;
    if (map['createdAt'] != null) {
      try {
        createdAt = DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int);
      } catch (e) {
        createdAt = DateTime.now();
      }
    } else {
      createdAt = DateTime.now();
    }
    
    DateTime? completedAt;
    if (map['completedAt'] != null) {
      try {
        completedAt = DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int);
      } catch (e) {
        completedAt = null;
      }
    }
    
    List<Transaction> transactions = [];
    if (map['transactions'] != null) {
      try {
        transactions = (map['transactions'] as List)
            .map((item) => Transaction.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('Error loading transactions: $e');
      }
    }
    
    return SavingsGoal(
      id: id,
      name: name,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      frequency: frequency,
      depositAmount: depositAmount,
      currencyCode: currencyCode,
      createdAt: createdAt,
      completedAt: completedAt,
      transactions: transactions,
    );
  }
}

class Transaction {
  final double amount;
  final DateTime date;
  final String note;
  final bool isDeposit;

  Transaction({
    required this.amount,
    required this.date,
    required this.note,
    required this.isDeposit,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'note': note,
      'isDeposit': isDeposit,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['date'] as int)
          : DateTime.now(),
      note: map['note'] as String? ?? '',
      isDeposit: map['isDeposit'] as bool? ?? true,
    );
  }
}