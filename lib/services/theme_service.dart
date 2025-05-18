import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeService with ChangeNotifier {
  static const String _themeBoxName = 'theme_box';
  static const String _isDarkModeKey = 'is_dark_mode';
  static Box<bool>? _themeBox;
  
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  // Inisialisasi
  Future<void> initialize({required bool testing}) async {
    if (testing) {
      // Gunakan nilai default untuk testing tanpa menyentuh Hive
      _isDarkMode = false;
      return;
    }
    
    // Hanya buka box Hive jika bukan testing
    _themeBox = await Hive.openBox<bool>(_themeBoxName);
    _loadTheme();
  }
  
  // Muat tema dari penyimpanan
  void _loadTheme() {
    _isDarkMode = _themeBox?.get(_isDarkModeKey) ?? false;
    notifyListeners();
  }
  
  // Toggle tema
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _themeBox?.put(_isDarkModeKey, _isDarkMode);
    notifyListeners();
  }
}