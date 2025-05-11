import 'package:flutter/material.dart';
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
  
  // Tambahkan properti kategori
  String category;
  int categoryColorValue; // Menyimpan nilai Color sebagai int

  // Tambahkan properti milestone
  List<double> milestones;
  List<bool> achievedMilestones;

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
    this.category = 'Umum', // Default kategori
    this.categoryColorValue = 0xFF42A5F5, // Default warna biru
    List<double>? milestones,
    List<bool>? achievedMilestones,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    transactions = transactions ?? [],
    milestones = milestones ?? [0.25, 0.5, 0.75],
    achievedMilestones = achievedMilestones ?? [false, false, false];

  // Getter untuk mengubah nilai int menjadi Color
  Color get categoryColor => Color(categoryColorValue);

  double get progressPercentage => currentAmount / targetAmount;

  bool get isCompleted => currentAmount >= targetAmount;

  DateTime get estimatedCompletionDate {
    // Kode tetap sama
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
    // Kode tetap sama
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

    // Periksa milestone setelah deposit
    checkMilestones();
  }

  void withdraw(double amount, String note) {
    // Kode tetap sama
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

  // Metode untuk memeriksa milestone
  void checkMilestones() {
    final progress = progressPercentage;
    for (int i = 0; i < milestones.length; i++) {
      if (progress >= milestones[i]) {
        achievedMilestones[i] = true;
      }
    }
  }

  // Update toMap untuk menambahkan kategori dan milestone
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
      'category': category,
      'categoryColorValue': categoryColorValue,
      'milestones': milestones,
      'achievedMilestones': achievedMilestones,
    };
  }

  // Update fromMap untuk memuat kategori dan milestone
  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    // memastikan field yang ada adalah benar dan nilai tidak null
    final id = map['id'] as String? ?? const Uuid().v4();
    final name = map['name'] as String? ?? 'Tabungan';
    final targetAmount = (map['targetAmount'] as num?)?.toDouble() ?? 0.0;
    final currentAmount = (map['currentAmount'] as num?)?.toDouble() ?? 0.0;
    final frequency = map['frequency'] as String? ?? 'Harian';
    final depositAmount = (map['depositAmount'] as num?)?.toDouble() ?? 0.0;
    final currencyCode = map['currencyCode'] as String? ?? 'Rp';
    final category = map['category'] as String? ?? 'Umum';
    final categoryColorValue = map['categoryColorValue'] as int? ?? 0xFF42A5F5;
    
    List<double> milestones = [0.25, 0.5, 0.75];
    List<bool> achievedMilestones = [false, false, false];
    
    if (map['milestones'] != null) {
      try {
        milestones = (map['milestones'] as List).map((e) => (e as num).toDouble()).toList();
      } catch (e) {
        print('Error parsing milestones: $e');
      }
    }
    
    if (map['achievedMilestones'] != null) {
      try {
        achievedMilestones = (map['achievedMilestones'] as List).map((e) => e as bool).toList();
      } catch (e) {
        print('Error parsing achievedMilestones: $e');
      }
    }
    
    // Memastikan createdAt dan completedAt tidak null
    // Jika null, set ke default
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
      category: category,
      categoryColorValue: categoryColorValue,
      milestones: milestones,
      achievedMilestones: achievedMilestones,
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