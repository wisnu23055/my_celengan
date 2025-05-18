import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_celengan/main.dart';
import 'package:my_celengan/services/storage_service.dart';
import 'package:my_celengan/services/theme_service.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUp(() async {
    // Reset mock storage sebelum tiap test
    await StorageService.initialize(testing: true);
  });
  
  testWidgets('Create a new savings goal', (WidgetTester tester) async {
    // Setup app
    final themeService = ThemeService();
    await themeService.initialize(testing: true);
    
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeService>.value(
        value: themeService,
        child: const MyCelenganApp(),
      ),
    );
    await tester.pumpAndSettle();
    
    // Verifikasi awalnya tidak ada tabungan
    expect(find.text('Belum ada tabungan aktif.'), findsOneWidget);
    
    // Tap tombol tambah
    await tester.tap(find.text('Tambah Celengan'));
    await tester.pumpAndSettle();
    
    // Mengisi form
    await tester.enterText(
      find.widgetWithText(TextField, 'Nama Tabungan'), 
      'Liburan Bali'
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Target Tabungan'), 
      '1000000'
    );
    
    // Pilih kategori Liburan
    await tester.tap(find.text('Liburan'));
    await tester.pumpAndSettle();
    
    // Pilih frekuensi Mingguan
    await tester.tap(find.text('Mingguan'));
    await tester.pumpAndSettle();
    
    // Isi nominal pengisian
    await tester.enterText(
      find.widgetWithText(TextField, 'Nominal Pengisian'), 
      '100000'
    );
    
    // Tap tombol simpan
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    
    // Verifikasi tabungan sudah muncul di home screen
    expect(find.text('Liburan Bali'), findsOneWidget);
    expect(find.text('Belum ada tabungan aktif.'), findsNothing);
    
    // Verifikasi informasi tabungan
    expect(find.text('Rp 0'), findsOneWidget);
    expect(find.text('Liburan'), findsOneWidget);
  });
}