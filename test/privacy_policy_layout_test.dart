import 'package:app/app/widgets/privacy_policy_link.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('privacy footer leaves room for login content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(
          body: Center(child: Text('Login content')),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: PrivacyPolicyLink(),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(PrivacyPolicyLink)).height, lessThan(100));
    expect(find.text('Login content').hitTestable(), findsOneWidget);
    expect(find.text('Privacy Policy').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
