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
      expect(
        (filled.shape!.resolve({})! as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(8),
      );
      final outlined = t.outlinedButtonTheme.style!;
      expect(outlined.minimumSize!.resolve({})!.height, 48);
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
}
