import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_celengan/main.dart';
import 'package:my_celengan/services/theme_service.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Text visibility in light and dark mode', (WidgetTester tester) async {
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

    // Verifikasi teks terlihat di mode terang
    expect(find.text('My Celengan'), findsOneWidget);
    expect(find.text('Belum ada tabungan aktif.'), findsOneWidget);

    // Aktifkan mode gelap
    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();

    // Verifikasi teks tetap terlihat di mode gelap
    expect(find.text('My Celengan'), findsOneWidget);
    expect(find.text('Belum ada tabungan aktif.'), findsOneWidget);
  });
}