import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_celengan/main.dart';
import 'package:my_celengan/services/theme_service.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Dark mode toggle test', (WidgetTester tester) async {
    // Setup ThemeService
    final themeService = ThemeService();
    await themeService.initialize(testing: true);

    // Pump aplikasi
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: themeService,
        child: const MyCelenganApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verifikasi mode terang aktif secara default
    expect(themeService.isDarkMode, false);

    // Tap tombol mode gelap
    final darkModeButton = find.byIcon(Icons.dark_mode);
    expect(darkModeButton, findsOneWidget);
    await tester.tap(darkModeButton);
    await tester.pumpAndSettle();

    // Verifikasi mode gelap aktif
    expect(themeService.isDarkMode, true);

    // Tap tombol mode terang
    final lightModeButton = find.byIcon(Icons.light_mode);
    expect(lightModeButton, findsOneWidget);
    await tester.tap(lightModeButton);
    await tester.pumpAndSettle();

    // Verifikasi mode terang aktif kembali
    expect(themeService.isDarkMode, false);
  });
}