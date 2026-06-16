import 'package:flutter_test/flutter_test.dart';

/// Fast alternative to [WidgetTester.pumpAndSettle] — no animation settle wait.
Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  int maxFrames = 30,
  Duration step = const Duration(milliseconds: 16),
}) async {
  for (var i = 0; i < maxFrames; i++) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
  }
}
