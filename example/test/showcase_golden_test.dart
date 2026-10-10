import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:forge_ui_showcase/samples.dart';
import 'package:forge_ui_showcase/showcase_app.dart';

/// Golden images of the showcase: the whole gallery for every sample palette
/// in light and dark, plus the about and licences screens.
///
/// After an intended visual change, regenerate with
/// `flutter test --update-goldens` and look at the images before committing.
void main() {
  // A phone-width page tall enough to hold the whole gallery.
  const gallerySize = Size(412, 3080);
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

  void useSurface(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  for (final (index, sample) in samples.indexed) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('gallery: ${sample.name}, ${mode.name}', (tester) async {
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

      testWidgets('about: ${sample.name}, ${brightness.name}', (tester) async {
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
            onOpenWebsite: () {},
            onOpenPrivacyPolicy: () {},
            onOpenDeleteAccount: () {},
            onOpenLicenses: () {},
          ),
        );
      });

      testWidgets('licences: ${sample.name}, ${brightness.name}', (
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
