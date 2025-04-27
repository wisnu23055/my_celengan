import 'package:flutter/material.dart';
import 'package:my_celengan/screens/home_screen.dart';
import 'package:my_celengan/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await StorageService.initialize();
    print('Storage initialized successfully');
  } catch (e) {
    print('Error initializing storage: $e');
  }
  
  runApp(const MyCelenganApp());
}

class MyCelenganApp extends StatelessWidget {
  const MyCelenganApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Celengan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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
      ),
      home: const HomeScreen(),
    );
  }
}