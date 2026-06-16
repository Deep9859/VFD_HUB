import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vfd_param_app/core/security/security_service.dart';
import 'package:vfd_param_app/core/services/custom_vendor_service.dart';
import 'package:vfd_param_app/core/services/remote_catalog_service.dart';
import 'package:vfd_param_app/main.dart';
import 'package:vfd_param_app/presentation/widgets/feature_tile.dart';

Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  int maxFrames = 180,
}) async {
  for (var i = 0; i < maxFrames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
}

Future<void> dismissSetupGuideIfVisible(WidgetTester tester) async {
  final continueBtn = find.byType(FilledButton);
  if (continueBtn.evaluate().isNotEmpty) {
    await tester.tap(continueBtn.first);
    await tester.pump(const Duration(milliseconds: 300));
  }
}

Future<void> goToToolsHub(WidgetTester tester) async {
  await tapNavTab(tester, 'Tools');
  await pumpUntil(tester, find.text('Tools Hub'));
}

Future<void> scrollToolsHub(WidgetTester tester, double dy) async {
  final scroll = find.byType(CustomScrollView);
  if (scroll.evaluate().isNotEmpty) {
    await tester.drag(scroll.first, Offset(0, dy), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 300));
  }
}

Future<void> tapToolTile(WidgetTester tester, String label) async {
  await goToToolsHub(tester);
  await scrollToolsHub(tester, 1200);

  var tile = find.widgetWithText(FeatureTile, label);
  for (var i = 0; i < 14; i++) {
    if (tile.evaluate().isNotEmpty) break;
    await scrollToolsHub(tester, -350);
    tile = find.widgetWithText(FeatureTile, label);
  }

  expect(tile, findsOneWidget);
  await tester.ensureVisible(tile);
  await tester.pump(const Duration(milliseconds: 200));
  await tester.tap(tile);
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> loginAsGuest(WidgetTester tester) async {
  await tester.pumpWidget(const VfdParamApp());
  await pumpUntil(tester, find.text('Continue as Guest'));

  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isNotEmpty) {
    await tester.drag(scrollables.first, const Offset(0, -900));
    await tester.pump(const Duration(milliseconds: 200));
  }

  await tester.tap(find.text('Continue as Guest'));
  await pumpUntil(tester, find.byType(NavigationBar));
  await dismissSetupGuideIfVisible(tester);
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> tapNavTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(label),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> popScreen(WidgetTester tester) async {
  final back = find.byType(BackButton);
  if (back.evaluate().isNotEmpty) {
    await tester.tap(back);
  } else {
    await tester.pageBack();
  }
  for (var i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> openToolsScreen(
  WidgetTester tester,
  String tileLabel,
  Finder screenMarker,
) async {
  await tapToolTile(tester, tileLabel);
  await pumpUntil(tester, screenMarker);
  expect(screenMarker, findsWidgets);
  await popScreen(tester);
  await goToToolsHub(tester);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = true;
    await GoogleFonts.pendingFonts();

    await SecurityService.initialize();
    await RemoteCatalogService.loadCacheFromDisk();
    await CustomVendorService.loadCache();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('home_setup_guide_seen_v1', true);
  });

  setUp(() async {
    await SecurityService.clearAuth();
  });

  testWidgets('guest login opens configuration home', (tester) async {
    await loginAsGuest(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Configure'), findsOneWidget);
    expect(find.textContaining('Vendor'), findsWidgets);
  });

  testWidgets('tools hub navigation works', (tester) async {
    await loginAsGuest(tester);
    await tapNavTab(tester, 'Tools');
    await pumpUntil(tester, find.text('Smart Search'));

    expect(find.text('Smart Search'), findsWidgets);
    expect(find.text('Calculators'), findsOneWidget);
  });

  testWidgets('full application smoke test', (tester) async {
    await loginAsGuest(tester);

    // ── Configure tab ─────────────────────────────────────────────
    expect(find.text('Configure'), findsOneWidget);
    expect(find.textContaining('Vendor'), findsWidgets);

    // ── Tools hub — major screens ─────────────────────────────────
    await tapNavTab(tester, 'Tools');
    await pumpUntil(tester, find.text('Tools Hub'));

    const toolScreens = <(String, String)>[
      ('Smart Search', 'Smart Search'),
      ('Calculators', 'Calculation Tools'),
      ('Fault codes', 'Fault Code Lookup'),
      ('Generate QR', 'QR Code Generator'),
      ('Compare VFDs', 'Compare VFDs'),
      ('Unit converter', 'Unit Converter'),
      ('Manuals', 'Manual Import'),
      ('Audit log', 'Audit Log'),
    ];

    for (final (tile, title) in toolScreens) {
      await openToolsScreen(tester, tile, find.text(title));
    }

    // QR Scanner opens camera — verify screen only, then back
    await tapToolTile(tester, 'Scan QR');
    await pumpUntil(tester, find.text('Scan VFD QR Code'));
    expect(find.text('Scan VFD QR Code'), findsOneWidget);
    await popScreen(tester);
    await goToToolsHub(tester);

    // ── Projects tab ──────────────────────────────────────────────
    await tapNavTab(tester, 'Projects');
    await pumpUntil(tester, find.text('Saved Projects'));
    expect(find.text('Saved Projects'), findsWidgets);

    // ── Account tab — settings, about, enterprise ─────────────────
    await tapNavTab(tester, 'Account');
    await pumpUntil(tester, find.text('Account'));

    Future<void> openAccountScreen(String tileLabel, Finder marker) async {
      await tapNavTab(tester, 'Account');
      await pumpUntil(tester, find.text('Account'));

      final scroll = find.byType(CustomScrollView);
      if (scroll.evaluate().isNotEmpty) {
        await tester.drag(scroll.first, const Offset(0, 900), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 300));
      }

      var tile = find.text(tileLabel);
      for (var i = 0; i < 14; i++) {
        if (tile.evaluate().isNotEmpty) {
          try {
            await tester.ensureVisible(tile.first);
            break;
          } catch (_) {}
        }
        if (scroll.evaluate().isNotEmpty) {
          await tester.drag(scroll.first, const Offset(0, -320), warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 250));
        }
        tile = find.text(tileLabel);
      }

      expect(tile, findsOneWidget);
      await tester.ensureVisible(tile.first);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(tile.first);
      await pumpUntil(tester, marker);
      expect(marker, findsWidgets);
      await popScreen(tester);
    }

    await openAccountScreen('About VFD Hub', find.text('About'));
    await openAccountScreen('Join organization', find.text('Join Organization'));
    await openAccountScreen('Team workspace', find.text('Team Workspace'));
    await openAccountScreen('Platform settings', find.text('Platform Settings'));

    // Theme toggle
    final themeTile = find.textContaining('mode');
    for (var i = 0; i < 8; i++) {
      if (themeTile.evaluate().isNotEmpty) break;
      final scroll = find.byType(CustomScrollView);
      if (scroll.evaluate().isNotEmpty) {
        await tester.drag(scroll.first, const Offset(0, -300), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 250));
      }
    }
    await tester.tap(themeTile.first);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Back to Configure
    await tapNavTab(tester, 'Configure');
    await pumpUntil(tester, find.textContaining('Vendor'));
    expect(find.byType(NavigationBar), findsOneWidget);
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  });
}
