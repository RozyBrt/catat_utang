import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catat_utang/main.dart';
import 'package:provider/provider.dart';
import 'package:catat_utang/providers/debt_provider.dart';
import 'package:catat_utang/models/debt.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Mock PathProvider for testing
class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '.';
  }
}

void main() {
  setUpAll(() async {
    PathProviderPlatform.instance = MockPathProviderPlatform();
    await Hive.initFlutter();
    Hive.registerAdapter(DebtAdapter());
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('Main App Widget Tests', () {
    testWidgets('App should build without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should show bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Should have bottom navigation with 4 items
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Check for navigation items
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Riwayat'), findsOneWidget);
      expect(find.text('Jadwal'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('App should navigate between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tap on Riwayat tab
      await tester.tap(find.text('Riwayat'));
      await tester.pumpAndSettle();

      // Tap on Jadwal tab
      await tester.tap(find.text('Jadwal'));
      await tester.pumpAndSettle();

      // Tap on Profil tab
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      // Should find version info in Profil tab
      expect(find.text('1.1.0'), findsOneWidget);
    });

    testWidgets('App should show floating action button on Beranda', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Should have FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('App should display app title', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Should show "Catat Utang" title
      expect(find.text('Catat Utang'), findsWidgets);
    });

    testWidgets('Profil tab should show app information', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to Profil tab
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      // Should show version
      expect(find.text('Versi'), findsOneWidget);
      expect(find.text('1.1.0'), findsOneWidget);

      // Should show storage info
      expect(find.text('Penyimpanan'), findsOneWidget);
      expect(find.text('Local (Hive)'), findsOneWidget);

      // Should show privacy info
      expect(find.text('Privasi'), findsOneWidget);
      expect(find.text('100% Offline'), findsOneWidget);
    });

    testWidgets('Profil tab should have test notification button', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to Profil tab
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      // Should have notification test button
      expect(find.text('Kirim Notifikasi Tes'), findsOneWidget);
    });
  });

  group('Dashboard Widget Tests', () {
    testWidgets('Dashboard should show statistics cards', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Should show Total Hutang card
      expect(find.text('Total Hutang'), findsOneWidget);
      
      // Should show Belum Lunas card
      expect(find.text('Belum Lunas'), findsOneWidget);
      
      // Should show Sudah Lunas card
      expect(find.text('Sudah Lunas'), findsOneWidget);
    });

    testWidgets('Dashboard should show empty state when no data', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Should show Rp 0 for all stats initially
      expect(find.text('Rp 0'), findsWidgets);
    });
  });

  group('Theme Tests', () {
    testWidgets('App should use correct theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      
      // Check primary color
      expect(app.theme?.primaryColor, const Color(0xFF6C63FF));
      
      // Check if useMaterial3 is enabled
      expect(app.theme?.useMaterial3, true);
    });
  });
}
