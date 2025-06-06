import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_celengan/models/saving_goals.dart';

class StorageService {
  static const String _savingsBoxName = 'savings_box';
  static Box<String>? _savingsBox; // Ubah tipe ke String untuk JSON
  static final List<Function(List<SavingsGoal>)> _listeners = [];

  // Tambahkan field untuk mocking
  static bool _isTesting = false;
  static List<SavingsGoal> _mockSavings = [];

  // Inisialisasi penyimpanan
  static Future<void> initialize({required bool testing}) async {
    if (testing) {
      _isTesting = true;
      _mockSavings = []; // Reset mock data untuk testing
      return;
    }
    
    _isTesting = false;
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
    if (_isTesting) {
      // Cek apakah goal dengan ID yang sama sudah ada
      final index = _mockSavings.indexWhere((g) => g.id == goal.id);
      if (index >= 0) {
        _mockSavings[index] = goal; // Update goal yang sudah ada
      } else {
        _mockSavings.add(goal); // Tambahkan goal baru
      }
      _notifyListeners();
      return;
    }
    
    if (_savingsBox == null) await initialize(testing: false);
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
    if (_isTesting) {
      _mockSavings.removeWhere((g) => g.id == id);
      _notifyListeners();
      return;
    }
    
    if (_savingsBox == null) await initialize(testing: false);
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
    if (_isTesting) {
      return List.from(_mockSavings);
    }
    
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
    if (_isTesting) {
      final found = _mockSavings.where((g) => g.id == id);
      return found.isNotEmpty ? found.first : null;
    }
    
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

  // Menambahkan listener untuk perubahan data
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
    if (_savingsBox == null) await initialize(testing: false);
    await _savingsBox!.clear();
    print('All data cleared');
    _notifyListeners();
  }
}