import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_celengan/models/saving_goals.dart';

class StorageService {
  static const String _savingsBoxName = 'savings_box';
  static Box<String>? _savingsBox; // Ubah tipe ke String untuk JSON
  static final List<Function(List<SavingsGoal>)> _listeners = [];

  // Inisialisasi penyimpanan
  static Future<void> initialize() async {
    await Hive.initFlutter();
    _savingsBox = await Hive.openBox<String>(_savingsBoxName);
    
    // Debug: Print semua data yang tersimpan
    if (_savingsBox != null) {
      print('Savings in box: ${_savingsBox!.keys.length}');
      for (var key in _savingsBox!.keys) {
        print('- Key: $key');
      }
    }
  }

  // Simpan tabungan baru
  static Future<void> saveSavingsGoal(SavingsGoal goal) async {
    if (_savingsBox == null) await initialize();
    try {
      // Serialize to JSON string for better storage
      final jsonData = jsonEncode(goal.toMap());
      await _savingsBox!.put(goal.id, jsonData);
      print('Saved goal: ${goal.id} (${goal.name}) - Current: ${goal.currentAmount}');
      _notifyListeners();
    } catch (e) {
      print('Error saving goal: $e');
    }
  }
  
  // Perbarui tabungan
  static Future<void> updateSavingsGoal(SavingsGoal goal) async {
    await saveSavingsGoal(goal);
  }

  // Hapus tabungan
  static Future<void> deleteSavingsGoal(String id) async {
    if (_savingsBox == null) await initialize();
    try {
      await _savingsBox!.delete(id);
      print('Deleted goal: $id');
      _notifyListeners();
    } catch (e) {
      print('Error deleting goal: $e');
    }
  }

  // Ambil semua tabungan
  static List<SavingsGoal> getAllSavingsGoals() {
    if (_savingsBox == null || _savingsBox!.isEmpty) return [];
    
    final goals = <SavingsGoal>[];
    
    for (var key in _savingsBox!.keys) {
      try {
        final jsonString = _savingsBox!.get(key);
        if (jsonString != null) {
          final Map<String, dynamic> goalMap = jsonDecode(jsonString);
          final goal = SavingsGoal.fromMap(goalMap);
          goals.add(goal);
          print('Loaded goal: ${goal.id} (${goal.name}) - Current: ${goal.currentAmount}');
        }
      } catch (e) {
        print('Error loading savings goal with key $key: $e');
      }
    }
    
    return goals;
  }

  // Mendapatkan tabungan berdasarkan ID
  static SavingsGoal? getSavingsGoalById(String id) {
    if (_savingsBox == null) return null;
    
    try {
      final jsonString = _savingsBox!.get(id);
      if (jsonString == null) return null;
      
      final Map<String, dynamic> goalMap = jsonDecode(jsonString);
      return SavingsGoal.fromMap(goalMap);
    } catch (e) {
      print('Error loading savings goal with id $id: $e');
      return null;
    }
  }

  // Tambahkan listener untuk perubahan data
  static void addListener(Function(List<SavingsGoal>) listener) {
    _listeners.add(listener);
  }

  // Hapus listener
  static void removeListener(Function(List<SavingsGoal>) listener) {
    _listeners.remove(listener);
  }

  // Notifikasi semua listener
  static void _notifyListeners() {
    final goals = getAllSavingsGoals();
    for (var listener in _listeners) {
      listener(goals);
    }
  }

  // Pisahkan tabungan ongoing dan completed
  static Map<String, List<SavingsGoal>> getSeparatedSavingsGoals() {
    final allGoals = getAllSavingsGoals();
    final ongoingGoals = <SavingsGoal>[];
    final completedGoals = <SavingsGoal>[];
    
    for (var goal in allGoals) {
      if (goal.isCompleted || goal.completedAt != null) {
        completedGoals.add(goal);
      } else {
        ongoingGoals.add(goal);
      }
    }
    
    return {
      'ongoing': ongoingGoals,
      'completed': completedGoals,
    };
  }
  
  // Untuk debugging - hapus semua data
  static Future<void> clearAllData() async {
    if (_savingsBox == null) await initialize();
    await _savingsBox!.clear();
    print('All data cleared');
    _notifyListeners();
  }
}