import 'package:flutter/material.dart';
import 'package:my_celengan/screens/home_screen.dart';
import 'package:my_celengan/services/storage_service.dart';
import 'package:my_celengan/services/theme_service.dart';
import 'package:provider/provider.dart';

// Tambahkan parameter untuk testing
void main({bool testing = false}) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await StorageService.initialize(testing: testing);
    
    final themeService = ThemeService();
    await themeService.initialize(testing: testing);
    
    runApp(
      ChangeNotifierProvider<ThemeService>.value(
        value: themeService,
        child: const MyCelenganApp(),
      ),
    );
  } catch (e) {
    print('Error initializing app: $e');
    runApp(const MyCelenganApp());
  }
}

class MyCelenganApp extends StatelessWidget {
  const MyCelenganApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeService>().isDarkMode;
    
    return MaterialApp(
      title: 'My Celengan',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
  
  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF42A5F5),
        primary: const Color(0xFF42A5F5), // Bright blue
        secondary: const Color(0xFFFF8A65), // Coral orange
        tertiary: const Color(0xFF4CAF50), // Bright green
        background: Colors.white,
        onBackground: Colors.black87,
        surface: Colors.white,
        onSurface: Colors.black87,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF42A5F5),
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF8A65),
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
    );
  }
  
  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: const Color(0xFF1976D2),
        primary: const Color(0xFF1976D2), // Darker blue
        secondary: const Color(0xFFFF7043), // Darker orange
        tertiary: const Color(0xFF388E3C), // Darker green
        background: const Color(0xFF121212),
        onBackground: Colors.white,
        surface: const Color(0xFF1E1E1E),
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1565C0), //Dark Blue
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF272727),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF7043), // Darker orange
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      useMaterial3: true,
      fontFamily: 'Roboto',
    );
  }
}