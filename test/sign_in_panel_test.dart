import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_ui/forge_ui.dart';

import 'support.dart';

class _Calls {
  final signIn = <(String, String)>[];
  final create = <(String, String)>[];
  final forgot = <String>[];
  var google = 0;
  final modes = <ForgeSignInMode>[];
}

Widget _panel(
  _Calls calls, {
  bool busy = false,
  String? errorText,
  ForgeSignInMode initialMode = ForgeSignInMode.signIn,
  bool google = true,
  bool dark = false,
}) => wrap(
  SingleChildScrollView(
    child: ForgeSignInPanel(
      onGoogle: google ? () => calls.google++ : null,
      onApple: google ? null : () {},
      onEmailSignIn: (e, p) => calls.signIn.add((e, p)),
      onEmailCreate: (e, p) => calls.create.add((e, p)),
      onForgotPassword: calls.forgot.add,
      onModeChanged: calls.modes.add,
      busy: busy,
      errorText: errorText,
      initialMode: initialMode,
      heading: 'Back up your notes',
      blurb: 'Sign in and they follow you.',
    ),
  ),
  dark: dark,
);

void main() {
  testWidgets('sign in: validates, then reports email and password', (
    tester,
  ) async {
    final calls = _Calls();
    await tester.pumpWidget(_panel(calls));
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);

    await tester.tap(find.byKey(ForgeSignInPanel.submitKey));
    await tester.pump();
    expect(find.text('Enter the email address you use.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(calls.signIn, isEmpty);

    await tester.enterText(
      find.byKey(ForgeSignInPanel.emailFieldKey),
      'not an email',
    );
    await tester.enterText(
      find.byKey(ForgeSignInPanel.passwordFieldKey),
      'hunter2',
    );
    await tester.pump();
    // Typing clears the field errors; a bad address comes back on submit.
    expect(find.text('Enter the email address you use.'), findsNothing);
    await tester.tap(find.byKey(ForgeSignInPanel.submitKey));
    await tester.pump();
    expect(find.text('Enter the email address you use.'), findsOneWidget);
    expect(calls.signIn, isEmpty);

    await tester.enterText(
      find.byKey(ForgeSignInPanel.emailFieldKey),
      '  tim@example.com ',
    );
    await tester.tap(find.byKey(ForgeSignInPanel.submitKey));
    await tester.pump();
    expect(calls.signIn, [('tim@example.com', 'hunter2')]);
    // Signing in accepts any password length; only creating enforces 8.
    expect(find.textContaining('at least 8'), findsNothing);
  });

  testWidgets('create: needs 8 characters; the password can be shown', (
    tester,
  ) async {
    final calls = _Calls();
    await tester.pumpWidget(_panel(calls));
    await tester.tap(find.byKey(ForgeSignInPanel.switchModeKey));
    await tester.pump();
    expect(calls.modes, [ForgeSignInMode.create]);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Have an account? Sign in'), findsOneWidget);
    expect(find.byKey(ForgeSignInPanel.forgotKey), findsNothing);

    await tester.enterText(
      find.byKey(ForgeSignInPanel.emailFieldKey),
      'a@b.co',
    );
    await tester.enterText(
      find.byKey(ForgeSignInPanel.passwordFieldKey),
      'short',
    );
    await tester.tap(find.byKey(ForgeSignInPanel.submitKey));
    await tester.pump();
    expect(find.text('Use at least 8 characters.'), findsOneWidget);
    expect(calls.create, isEmpty);

    EditableText field() => tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(ForgeSignInPanel.passwordFieldKey),
        matching: find.byType(EditableText),
      ),
    );
    expect(field().obscureText, isTrue);
    await tester.tap(find.byKey(ForgeSignInPanel.showPasswordKey));
    await tester.pump();
    expect(field().obscureText, isFalse);
    expect(find.text('Hide'), findsOneWidget);

    await tester.enterText(
      find.byKey(ForgeSignInPanel.passwordFieldKey),
      'longenough',
    );
    await tester.tap(find.byKey(ForgeSignInPanel.submitKey));
    await tester.pump();
    expect(calls.create, [('a@b.co', 'longenough')]);
  });

  testWidgets('forgot: email only, sends the reset, can go back', (
    tester,
  ) async {
    final calls = _Calls();
    await tester.pumpWidget(_panel(calls));
    await tester.tap(find.byKey(ForgeSignInPanel.forgotKey));
    await tester.pump();
    expect(calls.modes, [ForgeSignInMode.forgot]);
    expect(find.byKey(ForgeSignInPanel.passwordFieldKey), findsNothing);
    expect(find.text('Send reset link'), findsOneWidget);
    expect(find.text('reset by email'), findsOneWidget);

    await tester.enterText(
      find.byKey(ForgeSignInPanel.emailFieldKey),
      'a@b.co',
    );
    await tester.tap(find.byKey(ForgeSignInPanel.submitKey));
    await tester.pump();
    expect(calls.forgot, ['a@b.co']);

    await tester.tap(find.byKey(ForgeSignInPanel.switchModeKey));
    await tester.pump();
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byKey(ForgeSignInPanel.passwordFieldKey), findsOneWidget);
  });

  testWidgets('busy disables everything; errorText shows a card', (
    tester,
  ) async {
    final calls = _Calls();
    await tester.pumpWidget(
      _panel(calls, busy: true, errorText: 'Wrong password.'),
    );
    expect(find.text('Wrong password.'), findsOneWidget);
    expect(find.byType(ForgeErrorCard), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    expect(
      tester
          .widget<FilledButton>(find.byKey(ForgeSignInPanel.submitKey))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(find.byKey(ForgeSignInPanel.forgotKey))
          .onPressed,
      isNull,
    );
    final email = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(ForgeSignInPanel.emailFieldKey),
        matching: find.byType(TextField),
      ),
    );
    expect(email.enabled, isFalse);
    await tester.tap(find.text('Continue with Google'));
    expect(calls.google, 0);
  });

  testWidgets('provider buttons follow the callbacks; one is required', (
    tester,
  ) async {
    final calls = _Calls();
    await tester.pumpWidget(_panel(calls, dark: true));
    await tester.tap(find.text('Continue with Google'));
    expect(calls.google, 1);
    expect(
      () => ForgeSignInPanel(
        onEmailSignIn: (_, _) {},
        onEmailCreate: (_, _) {},
        onForgotPassword: (_) {},
      ),
      throwsAssertionError,
    );
    expect(ForgeSignInPanel.looksLikeEmail('tim@example.com'), isTrue);
    expect(ForgeSignInPanel.looksLikeEmail('tim@localhost'), isFalse);
    expect(ForgeSignInPanel.looksLikeEmail('@example.com'), isFalse);
  });

  testWidgets('ForgeSignInScreen wraps the panel and offers Not now', (
    tester,
  ) async {
    var skipped = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: forgeTheme(seed: testSeed),
        home: ForgeSignInScreen(
          onGoogle: () {},
          onEmailSignIn: (_, _) {},
          onEmailCreate: (_, _) {},
          onForgotPassword: (_) {},
          onSkip: () => skipped++,
          heading: 'Back up your notes',
        ),
      ),
    );
    expect(find.text('Sign in'), findsNWidgets(2)); // app bar + submit
    expect(find.byType(ForgeSignInPanel), findsOneWidget);
    await tester.tap(find.byKey(ForgeSignInScreen.skipKey));
    expect(skipped, 1);
  });
}
