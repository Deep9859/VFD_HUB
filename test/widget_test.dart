import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:vfd_param_app/presentation/providers/auth_provider.dart';
import 'package:vfd_param_app/presentation/screens/app_gate_screen.dart';
import 'package:vfd_param_app/presentation/screens/welcome_screen.dart';
import 'helpers/pump_helpers.dart';

Widget _app(Widget home) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: home,
  );
}

void main() {
  group('WelcomeScreen', () {
    testWidgets('shows sign-in options', (tester) async {
      await tester.pumpWidget(_app(const WelcomeScreen()));
      await tester.pump();

      expect(find.text('VFD Hub'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });
  });

  group('AppGateScreen', () {
    testWidgets('shows loading then routes to welcome', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: _app(const AppGateScreen()),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading VFD Hub...'), findsOneWidget);

      await pumpUntil(tester, find.text('Continue as Guest'));

      expect(find.text('VFD Hub'), findsOneWidget);
    });
  });
}
