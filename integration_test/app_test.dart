import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vfd_param_app/core/security/security_service.dart';
import 'package:vfd_param_app/core/services/custom_vendor_service.dart';
import 'package:vfd_param_app/core/services/remote_catalog_service.dart';
import 'package:vfd_param_app/main.dart';

Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  int maxFrames = 120,
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

Future<void> loginAsGuest(WidgetTester tester) async {
  await tester.pumpWidget(const VfdParamApp());
  await pumpUntil(tester, find.text('Continue as Guest'));

  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isNotEmpty) {
    await tester.drag(scrollables.first, const Offset(0, -900));
    await tester.pump(const Duration(milliseconds: 200));
  }

  await tester.tap(find.text('Continue as Guest'));
  // Wait for MainShell — not welcome copy like "21 VFD Vendors".
  await pumpUntil(tester, find.byType(NavigationBar));
  await dismissSetupGuideIfVisible(tester);
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
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
    await tester.tap(find.text('Tools'));
    await pumpUntil(tester, find.text('Smart Search'));

    expect(find.text('Smart Search'), findsWidgets);
    expect(find.text('Calculators'), findsOneWidget);
  });
}
