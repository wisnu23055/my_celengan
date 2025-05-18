import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_celengan/main.dart';
import 'package:my_celengan/services/theme_service.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Home screen UI test', (WidgetTester tester) async {
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

    // Verifikasi teks utama
    expect(find.text('My Celengan'), findsOneWidget);
    expect(find.text('Belum ada tabungan aktif.'), findsOneWidget);

    // Verifikasi tombol tambah tabungan
    final addButton = find.byType(FloatingActionButton);
    expect(addButton, findsOneWidget);
    expect(find.text('Tambah Celengan'), findsOneWidget); // Perbaikan di sini

    // Tap tombol tambah tabungan
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Verifikasi layar tambah tabungan muncul
    expect(find.text('Tambah Tabungan'), findsOneWidget);
  });
}