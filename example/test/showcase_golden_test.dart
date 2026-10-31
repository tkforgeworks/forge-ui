import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:forge_ui_showcase/gallery.dart';
import 'package:forge_ui_showcase/samples.dart';
import 'package:forge_ui_showcase/showcase_app.dart';

/// Golden images of the showcase: the whole gallery for every sample palette
/// in light and dark, plus the about and licences screens.
///
/// After an intended visual change, regenerate with
/// `flutter test --update-goldens` and look at the images before committing.
void main() {
  // A phone-width page tall enough to hold the whole gallery.
  const gallerySize = Size(412, 5100);
  const screenSize = Size(412, 900);

  String slug(String name) =>
      name.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '_');

  /// Icons are SVG assets that load off the fake clock, and the skeleton
  /// shimmer never settles, so pump a fixed number of frames instead of
  /// `pumpAndSettle`.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  /// flutter_test paints every shadow as a solid block unless told otherwise,
  /// which would misdraw the forge shadow under `ForgeFab`. The flag has to
  /// be back to true before the test body returns.
  void goldenTest(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      debugDisableShadows = false;
      try {
        await body(tester);
      } finally {
        debugDisableShadows = true;
      }
    });
  }

  void useSurface(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  for (final (index, sample) in samples.indexed) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      goldenTest('gallery: ${sample.name}, ${mode.name}', (tester) async {
        useSurface(tester, gallerySize);
        await tester.pumpWidget(
          ShowcaseApp(initialSample: index, initialMode: mode),
        );
        await settle(tester);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/gallery_${slug(sample.name)}_${mode.name}.png',
          ),
        );
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  // Images for the README, at 2x: every gallery section in the first sample
  // (Violet, the plain seed-only case most apps will look like), and the
  // palette and buttons sections in each of the others.
  for (final (index, sample) in samples.indexed) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      goldenTest('sections: ${sample.name}, ${mode.name}', (tester) async {
        useSurface(tester, gallerySize);
        await tester.pumpWidget(
          ShowcaseApp(initialSample: index, initialMode: mode),
        );
        await settle(tester);
        final first = index == 0;
        // The "Screens" sections are only buttons; the screens themselves
        // are photographed below.
        final titles = first
            ? gallerySections.where(
                (title) => title != 'Screens' && title != 'Email screens',
              )
            : ['Palette', 'Buttons'];
        for (final title in titles) {
          final section = find.byKey(gallerySectionKey(title));
          expect(section, findsOneWidget, reason: title);
          final boundary = tester.renderObject<RenderRepaintBoundary>(section);
          final file = first
              ? 'components/${slug(title)}_${mode.name}.png'
              : 'palettes/${slug(sample.name)}_${slug(title)}_${mode.name}.png';
          await expectLater(
            boundary.toImage(pixelRatio: 2),
            matchesGoldenFile('goldens/$file'),
          );
        }
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  // The buttons under desktop density, for the README: sized to their
  // labels at 36 high instead of stretched to thumb height.
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    goldenTest('buttons, desktop density: ${mode.name}', (tester) async {
      useSurface(tester, gallerySize);
      await tester.pumpWidget(
        ShowcaseApp(
          initialSample: 0,
          initialMode: mode,
          initialDensity: ForgeDensity.desktop,
        ),
      );
      await settle(tester);
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(gallerySectionKey('Buttons')),
      );
      await expectLater(
        boundary.toImage(pixelRatio: 2),
        matchesGoldenFile(
          'goldens/components/buttons_desktop_${mode.name}.png',
        ),
      );
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final sample in [samples.first, creamAndAmber]) {
    for (final brightness in Brightness.values) {
      Future<void> shoot(
        WidgetTester tester,
        String name,
        Widget screen,
      ) async {
        useSurface(tester, screenSize);
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: sample.theme(brightness),
            home: screen,
          ),
        );
        await settle(tester);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/${name}_${slug(sample.name)}_${brightness.name}.png',
          ),
        );
      }

      goldenTest('about: ${sample.name}, ${brightness.name}', (tester) async {
        await shoot(
          tester,
          'about',
          ForgeAboutScreen(
            appName: 'Showcase',
            version: '0.1.0',
            badge: const FlutterLogo(size: 64),
            blurb:
                'I show every shared component in one place, so nobody has '
                'to guess what a button looks like in dark mode.',
            footnote: 'Nothing here leaves this device.',
            tintMark: sample.tintMark,
            onSendFeedback: () {},
            onOpenWebsite: () {},
            onOpenPrivacyPolicy: () {},
            onOpenDeleteAccount: () {},
            onOpenLicenses: () {},
          ),
        );
      });

      goldenTest('sign-in: ${sample.name}, ${brightness.name}', (tester) async {
        await shoot(
          tester,
          'sign_in',
          ForgeSignInScreen(
            heading: 'Back up your notes',
            blurb: 'Sign in and they follow you to your next phone.',
            onGoogle: () {},
            onEmailSignIn: (_, _) {},
            onEmailCreate: (_, _) {},
            onForgotPassword: (_) {},
            onSkip: () {},
          ),
        );
      });

      goldenTest('check-email: ${sample.name}, ${brightness.name}', (
        tester,
      ) async {
        await shoot(
          tester,
          'check_email',
          ForgeCheckEmailScreen(
            email: 'tim@example.com',
            purpose: ForgeEmailPurpose.confirm,
            onResend: () {},
            onChangeEmail: () {},
            onDone: () {},
          ),
        );
      });

      goldenTest('set-password: ${sample.name}, ${brightness.name}', (
        tester,
      ) async {
        await shoot(
          tester,
          'set_password',
          ForgeSetPasswordScreen(onSubmit: (_) {}),
        );
      });

      goldenTest('licences: ${sample.name}, ${brightness.name}', (
        tester,
      ) async {
        await shoot(
          tester,
          'licences',
          ForgeLicensesScreen(
            appName: 'Showcase',
            licenseName: 'Apache License 2.0',
            sourceLabel: 'github.com/tkforgeworks/forge-ui',
            onOpenSource: () {},
            footnote: 'The TK ForgeWorks mark is all rights reserved.',
          ),
        );
      });
    }
  }
}
