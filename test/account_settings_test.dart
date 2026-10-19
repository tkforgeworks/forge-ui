import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_ui/forge_ui.dart';

import 'support.dart';

void main() {
  Widget page(Widget child) => wrap(SingleChildScrollView(child: child));

  testWidgets('signed out shows the signedOut widget only', (tester) async {
    await tester.pumpWidget(
      page(
        ForgeAccountSettings(
          onSignOut: ({required eraseLocal}) async {},
          signedOut: const Text('PANEL'),
        ),
      ),
    );
    expect(find.text('PANEL'), findsOneWidget);
    expect(find.text('Sign out'), findsNothing);
  });

  testWidgets('signed in: groups, username saved on Done, link rows', (
    tester,
  ) async {
    final saved = <String?>[];
    ForgeSignInProvider? linked;
    var setPassword = 0;
    await tester.pumpWidget(
      page(
        ForgeAccountSettings(
          email: 'tim@example.com',
          username: 'Tim',
          onUsernameChanged: saved.add,
          linked: const [
            ForgeLinkedSignIn(
              provider: ForgeSignInProvider.email,
              email: 'tim@example.com',
            ),
          ],
          onLink: (p) => linked = p,
          onSetPassword: () => setPassword++,
          status: const Text('STATUS'),
          onSignOut: ({required eraseLocal}) async {},
          onDeleteAccount: () async => null,
        ),
      ),
    );
    expect(find.text('tim@example.com'), findsNWidgets(2)); // header + method
    expect(find.text('CONNECTED'), findsOneWidget);
    expect(find.text('STATUS'), findsOneWidget);
    expect(find.text('BACKUP'), findsOneWidget);
    // Email is linked, so "Set a password" is hidden; Google is not, so
    // "Link Google" shows.
    expect(find.byKey(ForgeAccountSettings.setPasswordKey), findsNothing);
    await tester.tap(find.byKey(ForgeAccountSettings.linkGoogleKey));
    expect(linked, ForgeSignInProvider.google);
    expect(setPassword, 0);

    await tester.enterText(
      find.byKey(ForgeAccountSettings.usernameFieldKey),
      '  Timothy ',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(saved, ['Timothy']);
    // Same value again is not re-saved; blank clears.
    await tester.enterText(
      find.byKey(ForgeAccountSettings.usernameFieldKey),
      '',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(saved, ['Timothy', null]);
  });

  testWidgets('a Google-only account offers Set a password, not Link Google', (
    tester,
  ) async {
    await tester.pumpWidget(
      page(
        ForgeAccountSettings(
          email: 'tim@example.com',
          linked: const [
            ForgeLinkedSignIn(
              provider: ForgeSignInProvider.google,
              email: 'tim@example.com',
            ),
          ],
          onLink: (_) {},
          onSetPassword: () {},
          onSignOut: ({required eraseLocal}) async {},
        ),
      ),
    );
    expect(find.byKey(ForgeAccountSettings.linkGoogleKey), findsNothing);
    expect(find.byKey(ForgeAccountSettings.setPasswordKey), findsOneWidget);
    expect(find.byKey(ForgeAccountSettings.usernameFieldKey), findsNothing);
    expect(find.byKey(ForgeAccountSettings.deleteKey), findsNothing);
  });

  testWidgets("sign out: the sheet's erase choice reaches the callback", (
    tester,
  ) async {
    final choices = <bool>[];
    await tester.pumpWidget(
      page(
        ForgeAccountSettings(
          email: 'tim@example.com',
          onSignOut: ({required eraseLocal}) async => choices.add(eraseLocal),
        ),
      ),
    );
    await tester.tap(find.byKey(ForgeAccountSettings.signOutKey));
    await tester.pumpAndSettle();
    expect(find.byType(ForgeSignOutSheet), findsOneWidget);
    await tester.tap(find.byKey(ForgeSignOutSheet.cancelKey));
    await tester.pumpAndSettle();
    expect(choices, isEmpty);

    await tester.tap(find.byKey(ForgeAccountSettings.signOutKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ForgeSignOutSheet.confirmKey));
    await tester.pumpAndSettle();
    expect(choices, [false]);

    await tester.tap(find.byKey(ForgeAccountSettings.signOutKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ForgeSignOutSheet.eraseKey));
    await tester.pump();
    expect(find.text('Sign out and erase'), findsOneWidget);
    await tester.tap(find.byKey(ForgeSignOutSheet.confirmKey));
    await tester.pumpAndSettle();
    expect(choices, [false, true]);
  });

  testWidgets('delete opens the typed sheet and runs the action', (
    tester,
  ) async {
    var deletes = 0;
    await tester.pumpWidget(
      page(
        ForgeAccountSettings(
          email: 'tim@example.com',
          onSignOut: ({required eraseLocal}) async {},
          onDeleteAccount: () async {
            deletes++;
            return null;
          },
        ),
      ),
    );
    await tester.tap(find.byKey(ForgeAccountSettings.deleteKey));
    await tester.pumpAndSettle();
    expect(find.text('Delete your account?'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(ForgeConfirmSheet.confirmKey))
          .onPressed,
      isNull,
    );
    await tester.enterText(find.byKey(ForgeConfirmSheet.fieldKey), 'delete');
    await tester.pump();
    await tester.tap(find.byKey(ForgeConfirmSheet.confirmKey));
    await tester.pumpAndSettle();
    expect(deletes, 1);
    expect(find.byType(ForgeConfirmSheet), findsNothing);
  });

  testWidgets('busy disables the rows; errorText shows a card', (tester) async {
    await tester.pumpWidget(
      page(
        ForgeAccountSettings(
          email: 'tim@example.com',
          busy: true,
          errorText: 'Could not reach the server.',
          onLink: (_) {},
          onSignOut: ({required eraseLocal}) async {},
          onDeleteAccount: () async => null,
        ),
      ),
    );
    expect(find.byType(ForgeErrorCard), findsOneWidget);
    for (final key in [
      ForgeAccountSettings.signOutKey,
      ForgeAccountSettings.deleteKey,
      ForgeAccountSettings.linkGoogleKey,
    ]) {
      expect(tester.widget<ListTile>(find.byKey(key)).enabled, isFalse);
    }
  });

  testWidgets('showForgeSignOutSheet without erase is a plain confirm', (
    tester,
  ) async {
    ForgeSignOutChoice? result;
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => FilledButton(
            onPressed: () async {
              result = await showForgeSignOutSheet(context, offerErase: false);
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byKey(ForgeSignOutSheet.eraseKey), findsNothing);
    await tester.tap(find.byKey(ForgeSignOutSheet.confirmKey));
    await tester.pumpAndSettle();
    expect(result, const ForgeSignOutChoice(eraseLocal: false));
  });
}
