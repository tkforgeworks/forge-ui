import 'package:flutter/material.dart';
import 'package:forge_ui/forge_ui.dart';

/// One palette the showcase can wear: a seed alone, or a seed plus the
/// designed schemes and tokens an app with its own palette passes.
class ShowcaseSample {
  const ShowcaseSample({
    required this.name,
    required this.seed,
    this.accent,
    this.lightScheme,
    this.darkScheme,
    this.lightTokens,
    this.darkTokens,
    this.tintMark = false,
  });

  final String name;
  final Color seed;
  final Color? accent;
  final ColorScheme? lightScheme;
  final ColorScheme? darkScheme;
  final ForgeTokens? lightTokens;
  final ForgeTokens? darkTokens;

  /// Whether this palette paints the maker mark in one tint (see
  /// `ForgeAboutScreen.tintMark`).
  final bool tintMark;

  bool get designed => lightScheme != null;

  ThemeData theme(
    Brightness brightness, {
    ForgeDensity density = ForgeDensity.touch,
  }) {
    final dark = brightness == Brightness.dark;
    return forgeTheme(
      seed: seed,
      accent: accent,
      brightness: brightness,
      colorScheme: dark ? darkScheme : lightScheme,
      tokens: dark ? darkTokens : lightTokens,
      density: density,
    );
  }
}

/// Three seeds, each all an app would supply, and one designed palette.
const samples = [
  ShowcaseSample(name: 'Violet', seed: Color(0xFF6B4EFF)),
  ShowcaseSample(
    name: 'Teal',
    seed: Color(0xFF00796B),
    accent: Color(0xFFE0603A),
  ),
  ShowcaseSample(name: 'Ember', seed: Color(0xFFC2410C)),
  creamAndAmber,
];

/// A designed palette: Cheesy Scribe's "cream & rind amber" with its
/// charcoal dark theme, the first app to pass its own schemes.
const creamAndAmber = ShowcaseSample(
  name: 'Cream & amber',
  seed: Color(0xFFB3641B),
  tintMark: true,
  lightScheme: ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFB3641B),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFF6E5C8),
    onPrimaryContainer: Color(0xFF93500F),
    secondary: Color(0xFF5F5138),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF2E8D5),
    onSecondaryContainer: Color(0xFF6B5A3D),
    tertiary: Color(0xFF93500F),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFB3382B),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFFAF6EE),
    onSurface: Color(0xFF35291A),
    surfaceContainerLowest: Color(0xFFFFFDF8),
    surfaceContainerLow: Color(0xFFFAF6EE),
    surfaceContainer: Color(0xFFF2E8D5),
    surfaceContainerHigh: Color(0xFFF6E5C8),
    surfaceContainerHighest: Color(0xFFF6E5C8),
    onSurfaceVariant: Color(0xFF5F5138),
    outline: Color(0xFFE6D9BF),
    outlineVariant: Color(0xFFEFE4CF),
    shadow: Color(0x2E35291A),
    scrim: Color(0x61231808),
    inverseSurface: Color(0xFF35291A),
    onInverseSurface: Color(0xFFFAF6EE),
    inversePrimary: Color(0xFFF4B656),
  ),
  lightTokens: ForgeTokens(
    accent: Color(0xFF93500F),
    link: Color(0xFF93500F),
    textTertiary: Color(0xFF8A7A5F),
    textGhost: Color(0xFFB5A684),
    rowDivider: Color(0xFFEFE4CF),
    successContainer: Color(0xFFE8F2E5),
    onSuccessContainer: Color(0xFF3D7A33),
    errorTint: Color(0xFFFBEDEA),
    skeletonBase: Color(0xFFF2E8D5),
    skeletonHighlight: Color(0xFFF8EDD9),
  ),
  darkScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFF4B656),
    onPrimary: Color(0xFF3A2606),
    primaryContainer: Color(0xFF5C4315),
    onPrimaryContainer: Color(0xFFEEDBB6),
    secondary: Color(0xFFCBBFA8),
    onSecondary: Color(0xFF211D17),
    secondaryContainer: Color(0xFF3B342B),
    onSecondaryContainer: Color(0xFFCBBFA8),
    tertiary: Color(0xFFEEDBB6),
    onTertiary: Color(0xFF3A2606),
    error: Color(0xFFE5766A),
    onError: Color(0xFF2B0906),
    surface: Color(0xFF211D17),
    onSurface: Color(0xFFF3EAD9),
    surfaceContainerLowest: Color(0xFF2B2620),
    surfaceContainerLow: Color(0xFF211D17),
    surfaceContainer: Color(0xFF3B342B),
    surfaceContainerHigh: Color(0xFF453D32),
    surfaceContainerHighest: Color(0xFF4F463A),
    onSurfaceVariant: Color(0xFFCBBFA8),
    outline: Color(0xFF4A4237),
    outlineVariant: Color(0xFF3D362D),
    shadow: Color(0x66000000),
    scrim: Color(0x8014100A),
    inverseSurface: Color(0xFFF3EAD9),
    onInverseSurface: Color(0xFF211D17),
    inversePrimary: Color(0xFFB3641B),
  ),
  darkTokens: ForgeTokens(
    accent: Color(0xFFEEDBB6),
    link: Color(0xFFF4B656),
    textTertiary: Color(0xFFA89A80),
    textGhost: Color(0xFF7A6F5D),
    rowDivider: Color(0xFF3D362D),
    successContainer: Color(0xFF2B3D28),
    onSuccessContainer: Color(0xFF9CCB8F),
    errorTint: Color(0xFF3A2320),
    skeletonBase: Color(0xFF3B342B),
    skeletonHighlight: Color(0xFF4A3F2F),
  ),
);
