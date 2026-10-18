import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_ui/forge_ui.dart';

import 'support.dart';

Widget _app(Widget screen) => MaterialApp(
  theme: forgeTheme(seed: testSeed),
  home: screen,
);

void main() {
  testWidgets('check email: copy per purpose, resend cooldown, actions', (
    tester,
  ) async {
    var resends = 0, changes = 0, dones = 0;
    await tester.pumpWidget(
      _app(
        ForgeCheckEmailScreen(
          email: 'tim@example.com',
          purpose: ForgeEmailPurpose.confirm,
          resendCooldown: const Duration(seconds: 3),
          onResend: () => resends++,
          onChangeEmail: () => changes++,
          onDone: () => dones++,
        ),
      ),
    );
    expect(find.text('One more step'), findsOneWidget);
    expect(find.textContaining('tim@example.com'), findsOneWidget);
    expect(find.text('Send again in 3s'), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(ForgeCheckEmailScreen.resendKey))
          .onPressed,
      isNull,
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Send again in 2s'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Send again'), findsOneWidget);
    await tester.tap(find.byKey(ForgeCheckEmailScreen.resendKey));
    await tester.pump();
    expect(resends, 1);
    expect(find.text('Send again in 3s'), findsOneWidget); // cooldown restarts
    await tester.tap(find.byKey(ForgeCheckEmailScreen.changeEmailKey));
    await tester.tap(find.byKey(ForgeCheckEmailScreen.doneKey));
    expect((changes, dones), (1, 1));
    await tester.pump(const Duration(seconds: 3)); // let the timer finish
  });

  testWidgets('check email: reset wording, busy, error, hidden actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        ForgeCheckEmailScreen(
          email: 'a@b.co',
          purpose: ForgeEmailPurpose.reset,
          resendCooldown: Duration.zero,
          busy: true,
          errorText: 'Too many emails. Try later.',
          onResend: () {},
        ),
      ),
    );
    expect(find.text('Reset link sent'), findsOneWidget);
    expect(find.byType(ForgeErrorCard), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(ForgeCheckEmailScreen.changeEmailKey), findsNothing);
    expect(find.byKey(ForgeCheckEmailScreen.doneKey), findsNothing);
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(ForgeCheckEmailScreen.resendKey))
          .onPressed,
      isNull,
    );
  });

  testWidgets('set password: length, match, show/hide, submit', (tester) async {
    final saved = <String>[];
    await tester.pumpWidget(_app(ForgeSetPasswordScreen(onSubmit: saved.add)));
    await tester.enterText(
      find.byKey(ForgeSetPasswordScreen.passwordFieldKey),
      'short',
    );
    await tester.tap(find.byKey(ForgeSetPasswordScreen.submitKey));
    await tester.pump();
    expect(find.text('Use at least 8 characters.'), findsOneWidget);
    expect(saved, isEmpty);

    await tester.enterText(
      find.byKey(ForgeSetPasswordScreen.passwordFieldKey),
      'longenough',
    );
    await tester.enterText(
      find.byKey(ForgeSetPasswordScreen.confirmFieldKey),
      'different1',
    );
    await tester.tap(find.byKey(ForgeSetPasswordScreen.submitKey));
    await tester.pump();
    expect(find.text('The two passwords differ.'), findsOneWidget);
    expect(saved, isEmpty);

    EditableText confirmField() => tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(ForgeSetPasswordScreen.confirmFieldKey),
        matching: find.byType(EditableText),
      ),
    );
    expect(confirmField().obscureText, isTrue);
    await tester.tap(find.byKey(ForgeSetPasswordScreen.showPasswordKey));
    await tester.pump();
    expect(confirmField().obscureText, isFalse); // both fields toggle

    await tester.enterText(
      find.byKey(ForgeSetPasswordScreen.confirmFieldKey),
      'longenough',
    );
    await tester.tap(find.byKey(ForgeSetPasswordScreen.submitKey));
    await tester.pump();
    expect(saved, ['longenough']);
  });

  testWidgets('set password: busy disables and errorText shows', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        ForgeSetPasswordScreen(
          onSubmit: (_) {},
          busy: true,
          errorText: 'That link has expired.',
          heading: 'Set a password',
          submitLabel: 'Set password',
        ),
      ),
    );
    expect(find.text('Set a password'), findsOneWidget);
    expect(find.text('That link has expired.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(ForgeSetPasswordScreen.submitKey))
          .onPressed,
      isNull,
    );
  });
}
