import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_ui/forge_ui.dart';

import 'support.dart';

void main() {
  group('forgeTheme from a seed', () {
    final light = forgeTheme(seed: testSeed);
    final dark = forgeTheme(seed: testSeed, brightness: Brightness.dark);

    test('generates the scheme for each brightness', () {
      expect(light.colorScheme.brightness, Brightness.light);
      expect(dark.colorScheme.brightness, Brightness.dark);
      expect(light.colorScheme, forgeColorScheme(seed: testSeed));
      expect(light.scaffoldBackgroundColor, light.colorScheme.surface);
    });

    test('softens the generated outline colours', () {
      final material = ColorScheme.fromSeed(seedColor: testSeed);
      expect(light.colorScheme.outline, material.outlineVariant);
      expect(light.colorScheme.outlineVariant, isNot(material.outlineVariant));
      expect(light.colorScheme.primary, material.primary);
    });

    test('derives the tokens from the scheme', () {
      final x = light.extension<ForgeTokens>()!;
      expect(x.accent, light.colorScheme.tertiary);
      expect(x.link, light.colorScheme.onPrimaryContainer);
      expect(x.rowDivider, light.colorScheme.outlineVariant);
      expect(x.skeletonBase, light.colorScheme.surfaceContainerHigh);
      expect(dark.extension<ForgeTokens>()!.link, dark.colorScheme.primary);
    });

    test('accent lands in the tokens', () {
      const accent = Color(0xFF00897B);
      final t = forgeTheme(seed: testSeed, accent: accent);
      expect(t.extension<ForgeTokens>()!.accent, accent);
    });

    test("carries the app's own extensions alongside the tokens", () {
      const app = AppColors(Color(0xFFB3641B));
      final t = forgeTheme(seed: testSeed, extensions: [app]);
      expect(t.extension<AppColors>(), app);
      expect(t.extension<ForgeTokens>(), isNotNull);
    });
  });

  group('forgeTheme with a designed scheme', () {
    final t = forgeTheme(
      seed: DesignedPalette.seed,
      colorScheme: DesignedPalette.lightScheme,
      tokens: DesignedPalette.lightTokens,
    );

    test("keeps the app's palette exactly", () {
      expect(t.colorScheme, DesignedPalette.lightScheme);
      expect(t.extension<ForgeTokens>(), DesignedPalette.lightTokens);
      expect(t.scaffoldBackgroundColor, const Color(0xFFFAF6EE));
      expect(t.colorScheme.primary, const Color(0xFFB3641B));
      expect(t.colorScheme.outline, const Color(0xFFE6D9BF));
      expect(t.textTheme.bodySmall!.color, const Color(0xFF8A7A5F));
      expect(t.dividerTheme.color, const Color(0xFFEFE4CF));
    });

    test('takes brightness from the scheme, not the argument', () {
      final dark = forgeTheme(
        seed: DesignedPalette.seed,
        brightness: Brightness.dark,
        colorScheme: DesignedPalette.lightScheme,
      );
      expect(dark.colorScheme.brightness, Brightness.light);
    });

    test('derives tokens from the scheme when none are passed', () {
      final derived = forgeTheme(
        seed: DesignedPalette.seed,
        colorScheme: DesignedPalette.lightScheme,
      ).extension<ForgeTokens>()!;
      expect(derived.rowDivider, DesignedPalette.lightScheme.outlineVariant);
      expect(derived.link, DesignedPalette.lightScheme.onPrimaryContainer);
    });
  });

  group('brand shapes and components', () {
    final t = forgeTheme(seed: testSeed);
    final c = t.colorScheme;

    test('cards and chips use radius 8 with a border and no elevation', () {
      final card = t.cardTheme.shape as RoundedRectangleBorder;
      expect(card.borderRadius, BorderRadius.circular(8));
      expect(card.side.color, c.outline);
      expect(t.cardTheme.elevation, 0);
      expect(t.cardTheme.color, c.surfaceContainerLowest);
      final chip = t.chipTheme.shape as RoundedRectangleBorder;
      expect(chip.borderRadius, BorderRadius.circular(8));
    });

    test('buttons are radius 8 at the brand heights', () {
      final filled = t.filledButtonTheme.style!;
      expect(filled.minimumSize!.resolve({})!.height, 50);
      // Touch buttons stretch to their parent's width.
      expect(filled.minimumSize!.resolve({})!.width, double.infinity);
      expect(
        (filled.shape!.resolve({})! as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(8),
      );
      final outlined = t.outlinedButtonTheme.style!;
      expect(outlined.minimumSize!.resolve({})!.height, 48);
      expect(outlined.minimumSize!.resolve({})!.width, double.infinity);
      expect(outlined.side!.resolve({})!.color, c.outline);
      expect(
        t.textButtonTheme.style!.foregroundColor!.resolve({}),
        t.extension<ForgeTokens>()!.link,
      );
    });

    test('inputs are filled, outlined and focus in primary', () {
      final input = t.inputDecorationTheme;
      expect(input.filled, isTrue);
      expect(input.fillColor, c.surfaceContainerLowest);
      final focused = input.focusedBorder! as OutlineInputBorder;
      expect(focused.borderSide.color, c.primary);
      expect(focused.borderRadius, BorderRadius.circular(8));
      expect(input.hintStyle!.fontStyle, FontStyle.italic);
    });

    test('app bar is flat; sheets and the drawer round at 16', () {
      expect(t.appBarTheme.elevation, 0);
      expect(t.appBarTheme.scrolledUnderElevation, 0);
      expect(t.appBarTheme.backgroundColor, c.surface);
      final sheet = t.bottomSheetTheme.shape! as RoundedRectangleBorder;
      expect(
        sheet.borderRadius,
        const BorderRadius.vertical(top: Radius.circular(16)),
      );
      expect(t.drawerTheme.width, 300);
    });

    test('a plain FAB keeps a visible Material colour', () {
      expect(t.floatingActionButtonTheme.backgroundColor, isNull);
      final shape =
          t.floatingActionButtonTheme.shape! as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(ForgeRadii.fab));
    });

    test("Material's own icons are replaced by Heroicons", () {
      final icons = t.actionIconTheme!;
      expect(icons.backButtonIconBuilder, isNotNull);
      expect(icons.closeButtonIconBuilder, isNotNull);
      expect(icons.drawerButtonIconBuilder, isNotNull);
    });
  });

  group('desktop density', () {
    final t = forgeTheme(seed: testSeed, density: ForgeDensity.desktop);
    final touch = forgeTheme(seed: testSeed, density: ForgeDensity.touch);
    final styles = {
      'filled': t.filledButtonTheme.style!,
      'outlined': t.outlinedButtonTheme.style!,
      'text': t.textButtonTheme.style!,
    };

    test('buttons are 36 high and only as wide as their label', () {
      for (final MapEntry(key: name, value: style) in styles.entries) {
        expect(style.minimumSize!.resolve({}), const Size(0, 36), reason: name);
        expect(
          style.padding!.resolve({}),
          const EdgeInsets.symmetric(horizontal: 16),
          reason: name,
        );
        expect(
          style.tapTargetSize,
          MaterialTapTargetSize.shrinkWrap,
          reason: name,
        );
      }
    });

    test('buttons keep the brand shapes and type', () {
      final filled = styles['filled']!;
      expect(
        (filled.shape!.resolve({})! as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(8),
      );
      expect(
        filled.textStyle!.resolve({}),
        touch.filledButtonTheme.style!.textStyle!.resolve({}),
      );
      expect(
        styles['outlined']!.side!.resolve({})!.color,
        t.colorScheme.outline,
      );
    });

    test('fields, search bars and list tiles tighten', () {
      expect(
        t.inputDecorationTheme.contentPadding,
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
      expect(t.searchBarTheme.constraints!.minHeight, 40);
      expect(t.listTileTheme.visualDensity, VisualDensity.compact);
      expect(t.visualDensity, VisualDensity.compact);
    });

    test('segmented buttons and chips are unchanged', () {
      final seg = t.segmentedButtonTheme.style!;
      final touchSeg = touch.segmentedButtonTheme.style!;
      expect(seg.minimumSize!.resolve({}), touchSeg.minimumSize!.resolve({}));
      expect(seg.padding!.resolve({}), touchSeg.padding!.resolve({}));
      expect(seg.visualDensity, touchSeg.visualDensity);
      expect(seg.tapTargetSize, touchSeg.tapTargetSize);
      expect(t.chipTheme.padding, touch.chipTheme.padding);
    });

    Widget row(ThemeData theme) => MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Row(
          children: [
            FilledButton(onPressed: () {}, child: const Text('Save')),
            OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
            TextButton(onPressed: () {}, child: const Text('Help')),
          ],
        ),
      ),
    );

    testWidgets('buttons lay out at their own width in an unbounded Row', (
      tester,
    ) async {
      await tester.pumpWidget(row(t));
      expect(tester.takeException(), isNull);
      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      for (final type in [FilledButton, OutlinedButton, TextButton]) {
        final size = tester.getSize(find.byType(type));
        expect(size.width, lessThan(screen.width), reason: '$type');
        expect(size.height, 36, reason: '$type');
      }
    });

    testWidgets('the same Row under touch density throws', (tester) async {
      // The infinite-width assertion cascades into several more, so collect
      // them all rather than reading one back with takeException.
      final errors = <FlutterErrorDetails>[];
      final previous = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        await tester.pumpWidget(row(touch));
      } finally {
        FlutterError.onError = previous;
      }
      expect(
        errors.map((e) => e.exceptionAsString()),
        contains(contains('BoxConstraints forces an infinite width')),
      );
    });
  });

  test('density defaults to touch', () {
    final byDefault = forgeTheme(seed: testSeed);
    final touch = forgeTheme(seed: testSeed, density: ForgeDensity.touch);
    for (final (a, b) in [
      (byDefault.filledButtonTheme.style!, touch.filledButtonTheme.style!),
      (byDefault.outlinedButtonTheme.style!, touch.outlinedButtonTheme.style!),
      (byDefault.textButtonTheme.style!, touch.textButtonTheme.style!),
    ]) {
      expect(a.minimumSize?.resolve({}), b.minimumSize?.resolve({}));
      expect(a.padding?.resolve({}), b.padding?.resolve({}));
      expect(a.tapTargetSize, b.tapTargetSize);
      expect(a.visualDensity, b.visualDensity);
    }
    expect(
      byDefault.inputDecorationTheme.contentPadding,
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
    expect(
      byDefault.inputDecorationTheme.contentPadding,
      touch.inputDecorationTheme.contentPadding,
    );
    expect(byDefault.searchBarTheme.constraints!.minHeight, 52);
    expect(byDefault.searchBarTheme, touch.searchBarTheme);
    expect(byDefault.listTileTheme.visualDensity, isNull);
    expect(byDefault.visualDensity, touch.visualDensity);
    expect(byDefault.textButtonTheme.style!.minimumSize, isNull);
  });

  group('type scale', () {
    final t = forgeTheme(seed: testSeed).textTheme;

    test('uses the three bundled families, from this package', () {
      expect(t.bodyMedium!.fontFamily, 'packages/forge_ui/Poppins');
      expect(t.titleLarge!.fontSize, 22);
      expect(t.displaySmall!.fontFamily, 'packages/forge_ui/Source Serif 4');
      expect(t.displaySmall!.fontSize, 27);
      expect(t.bodyLarge!.height, 1.7);
      expect(t.labelSmall!.fontFamily, 'packages/forge_ui/JetBrains Mono');
      expect(t.labelSmall!.letterSpacing, 1.4);
    });

    test('slots the scale leaves alone still use the UI face', () {
      expect(t.headlineLarge!.fontFamily, 'packages/forge_ui/Poppins');
    });

    test('helpers build each voice', () {
      expect(ForgeType.serif(italic: true).fontStyle, FontStyle.italic);
      expect(ForgeType.mono().fontWeight, FontWeight.w500);
      expect(ForgeType.ui(size: 30).fontSize, 30);
    });

    test('code is body-sized mono with no tracking', () {
      final code = ForgeType.code();
      expect(code.fontFamily, 'packages/forge_ui/JetBrains Mono');
      expect(code.fontSize, 13);
      expect(code.fontWeight, FontWeight.w400);
      expect(code.letterSpacing, 0);
      expect(ForgeType.mono().letterSpacing, 1.4);
      final custom = ForgeType.code(
        size: 15,
        weight: FontWeight.w600,
        height: 1.5,
      );
      expect(custom.fontSize, 15);
      expect(custom.fontWeight, FontWeight.w600);
      expect(custom.height, 1.5);
    });
  });

  group('ForgeTokens', () {
    final a = ForgeTokens.standard(forgeColorScheme(seed: testSeed));
    const b = DesignedPalette.lightTokens;

    test('copyWith replaces only what is passed', () {
      final copy = a.copyWith(link: b.link);
      expect(copy.link, b.link);
      expect(copy.textTertiary, a.textTertiary);
    });

    test('lerp moves every role', () {
      expect(a.lerp(b, 0).textGhost, a.textGhost);
      expect(a.lerp(b, 1).textGhost, b.textGhost);
      expect(a.lerp(b, 1).errorTint, b.errorTint);
      expect(a.lerp(null, 0.5), a);
    });

    test('standard derives the status roles per brightness', () {
      final light = ForgeTokens.standard(forgeColorScheme(seed: testSeed));
      final dark = ForgeTokens.standard(
        forgeColorScheme(seed: testSeed, brightness: Brightness.dark),
      );
      expect(light.warning, const Color(0xFFED6C02));
      expect(light.info, const Color(0xFF0288D1));
      expect(light.success, const Color(0xFF2E7D32));
      expect(light.onWarning, const Color(0xFFFFFFFF));
      expect(dark.warning, const Color(0xFFFFA726));
      expect(dark.info, const Color(0xFF29B6F6));
      expect(dark.success, const Color(0xFF66BB6A));
      expect(dark.onInfo, const Color(0xDE000000));
      expect(dark.onWarningContainer, dark.warning);
      expect(
        light.onInfoContainer,
        Color.lerp(light.info, const Color(0xFF000000), 0.3),
      );
      expect(light.warningContainer, isNot(light.infoContainer));
    });

    test('copyWith replaces each status role', () {
      const c = Color(0xFF123456);
      expect(a.copyWith(warning: c).warning, c);
      expect(a.copyWith(onWarning: c).onWarning, c);
      expect(a.copyWith(warningContainer: c).warningContainer, c);
      expect(a.copyWith(onWarningContainer: c).onWarningContainer, c);
      expect(a.copyWith(info: c).info, c);
      expect(a.copyWith(onInfo: c).onInfo, c);
      expect(a.copyWith(infoContainer: c).infoContainer, c);
      expect(a.copyWith(onInfoContainer: c).onInfoContainer, c);
      expect(a.copyWith(success: c).success, c);
      expect(a.copyWith(onSuccess: c).onSuccess, c);
      expect(a.copyWith(success: c).warning, a.warning);
    });

    test('lerp covers the status roles', () {
      final d = ForgeTokens.standard(
        forgeColorScheme(seed: testSeed, brightness: Brightness.dark),
      );
      expect(a.lerp(d, 0).warning, a.warning);
      expect(a.lerp(d, 1).warning, d.warning);
      expect(a.lerp(d, 1).infoContainer, d.infoContainer);
      expect(a.lerp(d, 1).onSuccess, d.onSuccess);
    });

    test('a literal without the status roles falls back by brightness', () {
      const old = DesignedPalette.lightTokens;
      expect(old.warning, const Color(0xFFED6C02));
      expect(old.onInfo, const Color(0xFFFFFFFF));
      expect(old.success, const Color(0xFF2E7D32));
      final dark = old.copyWith(successContainer: const Color(0xFF2B3D28));
      expect(dark.warning, const Color(0xFFFFA726));
      expect(dark.onSuccess, const Color(0xDE000000));
      expect(dark.onInfoContainer, dark.info);
    });

    testWidgets('of() falls back for a theme not built by forgeTheme', (
      tester,
    ) async {
      late ForgeTokens tokens;
      late ColorScheme scheme;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorSchemeSeed: testSeed),
          home: Builder(
            builder: (context) {
              tokens = context.forge;
              scheme = context.colors;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(tokens.rowDivider, scheme.outlineVariant);
    });
  });

  test('forge gradient is the brand spark, unchanged', () {
    expect(ForgeBrand.forgeGradient.colors.last, const Color(0xFFEE3423));
    expect(ForgeBrand.forgeStrip.colors, const [
      Color(0xFFFBDF19),
      Color(0xFFF68F25),
      Color(0xFFEE3423),
    ]);
  });

  group('scrollbar theme', () {
    for (final density in ForgeDensity.values) {
      test('${density.name}: palette thumb, 8 thick, tag radius', () {
        final t = forgeTheme(seed: testSeed, density: density);
        final x = t.extension<ForgeTokens>()!;
        final sb = t.scrollbarTheme;
        expect(sb.thumbColor!.resolve({}), x.textGhost);
        expect(sb.thumbColor!.resolve({WidgetState.hovered}), x.textTertiary);
        expect(sb.thumbColor!.resolve({WidgetState.dragged}), x.textTertiary);
        expect(sb.thickness!.resolve({}), 8);
        expect(sb.radius, const Radius.circular(ForgeRadii.tag));
        expect(sb.trackVisibility, isNull);
      });
    }

    test('thumb is always visible on desktop only', () {
      final desktop = forgeTheme(seed: testSeed, density: ForgeDensity.desktop);
      final touch = forgeTheme(seed: testSeed);
      expect(desktop.scrollbarTheme.thumbVisibility!.resolve({}), isTrue);
      expect(touch.scrollbarTheme.thumbVisibility, isNull);
    });

    testWidgets('a long list gets a scrollbar on desktop platforms', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 300);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: forgeTheme(seed: testSeed, density: ForgeDensity.desktop),
          home: Scaffold(
            body: ListView.builder(
              itemCount: 100,
              itemBuilder: (_, i) => Text('Row $i'),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(Scrollbar), findsOneWidget);
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant.desktop());
  });
}
