import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:heroicons/heroicons.dart';

import 'support.dart';

void main() {
  Material googleSurface(WidgetTester tester) => tester.widget<Material>(
    find
        .ancestor(
          of: find.text('Continue with Google'),
          matching: find.byType(Material),
        )
        .first,
  );

  testWidgets('Google: light colours, Google Sans Flex, pill, 40 high', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        ForgeSignInButton(
          provider: ForgeSignInProvider.google,
          onPressed: () => taps++,
        ),
      ),
    );
    final surface = googleSurface(tester);
    expect(surface.color, ForgeProviderBrand.googleLightFill);
    final shape = surface.shape! as StadiumBorder;
    expect(shape.side.color, ForgeProviderBrand.googleLightStroke);
    final style = tester.widget<Text>(find.text('Continue with Google')).style!;
    expect(style.fontFamily, 'packages/forge_ui/Google Sans Flex');
    expect(style.fontWeight, FontWeight.w500);
    expect(style.fontSize, 14);
    expect(style.color, ForgeProviderBrand.googleLightText);
    expect(tester.getSize(find.byType(InkWell)).height, 40);
    await tester.tap(find.text('Continue with Google'));
    expect(taps, 1);
  });

  testWidgets('Google follows a dark theme, or the neutral override', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ForgeSignInButton(
          provider: ForgeSignInProvider.google,
          onPressed: () {},
        ),
        dark: true,
      ),
    );
    var surface = googleSurface(tester);
    expect(surface.color, ForgeProviderBrand.googleDarkFill);
    expect(
      (surface.shape! as StadiumBorder).side.color,
      ForgeProviderBrand.googleDarkStroke,
    );
    expect(
      tester.widget<Text>(find.text('Continue with Google')).style!.color,
      ForgeProviderBrand.googleDarkText,
    );

    await tester.pumpWidget(
      wrap(
        ForgeSignInButton(
          provider: ForgeSignInProvider.google,
          theme: ForgeProviderButtonTheme.neutral,
          onPressed: () {},
        ),
        dark: true,
      ),
    );
    surface = googleSurface(tester);
    expect(surface.color, ForgeProviderBrand.googleNeutralFill);
    expect((surface.shape! as StadiumBorder).side, BorderSide.none);
  });

  testWidgets('busy shows a progress ring and ignores taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        ForgeSignInButton(
          provider: ForgeSignInProvider.google,
          busy: true,
          onPressed: () => taps++,
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    await tester.tap(find.text('Continue with Google'));
    expect(taps, 0);
    expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNull);
  });

  testWidgets('email is an outlined button with an envelope', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        ForgeSignInButton(
          provider: ForgeSignInProvider.email,
          label: 'Use my email',
          onPressed: () => taps++,
        ),
      ),
    );
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.text('Use my email'), findsOneWidget);
    expect(
      tester.widget<HeroIcon>(find.byType(HeroIcon)).icon,
      HeroIcons.envelope,
    );
    await tester.tap(find.text('Use my email'));
    expect(taps, 1);
  });

  test('Apple is reserved; labels and linked sign-ins are plain values', () {
    expect(
      () => ForgeSignInButton(
        provider: ForgeSignInProvider.apple,
        onPressed: () {},
      ),
      throwsAssertionError,
    );
    expect(
      ForgeSignInButton.labelFor(ForgeSignInProvider.email),
      'Continue with Email',
    );
    expect(ForgeSignInProvider.google.label, 'Google');
    expect(
      const ForgeLinkedSignIn(
        provider: ForgeSignInProvider.google,
        email: 'a@b.c',
      ),
      const ForgeLinkedSignIn(
        provider: ForgeSignInProvider.google,
        email: 'a@b.c',
      ),
    );
  });
}
