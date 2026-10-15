import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:forge_ui/src/font_licenses.dart';

import 'support.dart';

Widget _app(Widget home, {bool dark = false}) => MaterialApp(
  theme: forgeTheme(seed: testSeed),
  darkTheme: forgeTheme(seed: testSeed, brightness: Brightness.dark),
  themeMode: dark ? ThemeMode.dark : ThemeMode.light,
  home: home,
);

void _tallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  group('ForgeAboutScreen', () {
    testWidgets('shows the app, the maker line and every wired link', (
      tester,
    ) async {
      _tallView(tester);
      final opened = <String>[];
      await tester.pumpWidget(
        _app(
          ForgeAboutScreen(
            appName: 'Cheesy Scribe',
            version: '0.1.0',
            badge: const FlutterLogo(size: 64),
            blurb: 'I keep your cheese notes.',
            footnote: 'Your notes stay on this device.',
            onSendFeedback: () => opened.add('feedback'),
            onOpenWebsite: () => opened.add('site'),
            onOpenPrivacyPolicy: () => opened.add('privacy'),
            onOpenDeleteAccount: () => opened.add('delete'),
            onOpenLicenses: () => opened.add('licenses'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(AppBar, 'About Cheesy Scribe'),
        findsOneWidget,
      );
      expect(find.text('Cheesy Scribe'), findsOneWidget);
      expect(find.text('VERSION 0.1.0'), findsOneWidget);
      expect(find.text('I keep your cheese notes.'), findsOneWidget);
      expect(find.text('A TK FORGEWORKS PRODUCT'), findsOneWidget);
      expect(find.byType(ForgeWorksMark), findsOneWidget);
      expect(find.byType(FlutterLogo), findsOneWidget);
      expect(find.text('Your notes stay on this device.'), findsOneWidget);

      await tester.tap(find.byKey(ForgeAboutScreen.feedbackKey));
      await tester.tap(find.byKey(ForgeAboutScreen.websiteKey));
      await tester.tap(find.byKey(ForgeAboutScreen.privacyKey));
      await tester.tap(find.byKey(ForgeAboutScreen.deleteAccountKey));
      await tester.tap(find.byKey(ForgeAboutScreen.licensesKey));
      expect(opened, ['feedback', 'site', 'privacy', 'delete', 'licenses']);
    });

    testWidgets('a null callback leaves that link out', (tester) async {
      _tallView(tester);
      await tester.pumpWidget(
        _app(ForgeAboutScreen(appName: 'Sample', onOpenPrivacyPolicy: () {})),
      );
      await tester.pumpAndSettle();
      expect(find.text('Privacy policy'), findsOneWidget);
      expect(find.text('Send feedback'), findsNothing);
      expect(find.text('tkforgeworks.com'), findsNothing);
      expect(find.text('Delete your account'), findsNothing);
      expect(find.text('Open-source licenses'), findsNothing);
      expect(find.text('VERSION —'), findsOneWidget);
    });

    testWidgets('the mark wears brand colours unless tinted', (tester) async {
      _tallView(tester);
      for (final tint in [false, true]) {
        await tester.pumpWidget(
          _app(
            ForgeAboutScreen(
              appName: 'Sample',
              tintMark: tint,
              onOpenPrivacyPolicy: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        final mark = tester.widget<ForgeWorksMark>(find.byType(ForgeWorksMark));
        final x = tester.element(find.byType(ForgeWorksMark)).forge;
        expect(mark.color, tint ? x.textTertiary : isNull);
      }
    });

    testWidgets('takes a custom title and leading widget', (tester) async {
      _tallView(tester);
      await tester.pumpWidget(
        _app(
          ForgeAboutScreen(
            appName: 'Sample',
            title: 'About',
            leading: const Icon(Icons.menu, key: Key('menu')),
            onOpenPrivacyPolicy: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'About'), findsOneWidget);
      expect(find.byKey(const Key('menu')), findsOneWidget);
    });
  });

  group('ForgeLicensesScreen', () {
    testWidgets('summarises the licences and opens the full notices', (
      tester,
    ) async {
      _tallView(tester);
      var sourceOpened = false;
      await tester.pumpWidget(
        _app(
          ForgeLicensesScreen(
            appName: 'Cheesy Scribe',
            licenseName: 'Apache License 2.0',
            version: '0.1.0',
            sourceLabel: 'github.com/tkforgeworks/cheesy-scribe',
            onOpenSource: () => sourceOpened = true,
            footnote: 'The app icon is all rights reserved.',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(AppBar, 'Open-source licenses'),
        findsOneWidget,
      );
      expect(find.textContaining('Cheesy Scribe is built on'), findsOneWidget);
      expect(find.text('Apache License 2.0'), findsOneWidget);
      expect(find.text(ForgeLicensesScreen.fontsLine), findsOneWidget);
      expect(find.text('The app icon is all rights reserved.'), findsOneWidget);

      await tester.tap(find.byKey(ForgeLicensesScreen.sourceKey));
      expect(sourceOpened, isTrue);

      await tester.tap(find.byKey(ForgeLicensesScreen.allNoticesKey));
      await tester.pumpAndSettle();
      expect(find.byType(LicensePage), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(ForgeLicensesScreen), findsOneWidget);
    });

    testWidgets('leaves the source row out and takes a custom intro', (
      tester,
    ) async {
      _tallView(tester);
      await tester.pumpWidget(
        _app(
          const ForgeLicensesScreen(
            appName: 'Sample',
            licenseName: 'All rights reserved',
            intro: 'The short version.',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('The short version.'), findsOneWidget);
      expect(find.text('Source code'), findsNothing);
    });

    testWidgets('gets a back button when pushed', (tester) async {
      _tallView(tester);
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ForgeLicensesScreen(
                      appName: 'Sample',
                      licenseName: 'Apache License 2.0',
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(ForgeLicensesScreen), findsNothing);
    });
  });

  test('registers the bundled font licences once', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerForgeFontLicenses();
    registerForgeFontLicenses();
    final entries = await LicenseRegistry.licenses.toList();
    for (final (family, _) in forgeFontLicenses) {
      final matches = entries.where((e) => e.packages.contains(family));
      expect(matches, hasLength(1), reason: family);
      final text = matches.single.paragraphs.map((p) => p.text).join('\n');
      expect(text, contains('SIL Open Font License'), reason: family);
    }
  });
}
