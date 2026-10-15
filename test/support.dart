import 'package:flutter/material.dart';
import 'package:forge_ui/forge_ui.dart';

/// The seed the tests theme with when the colours don't matter.
const testSeed = Color(0xFF5B4BDB);

/// Wraps [child] in a `forgeTheme`d MaterialApp + Scaffold.
Widget wrap(Widget child, {bool dark = false}) => MaterialApp(
  theme: forgeTheme(seed: testSeed),
  darkTheme: forgeTheme(seed: testSeed, brightness: Brightness.dark),
  themeMode: dark ? ThemeMode.dark : ThemeMode.light,
  home: Scaffold(body: Center(child: child)),
);

/// A hand-tuned palette, passed to `forgeTheme` the way an app with a
/// designed scheme does. The values are Cheesy Scribe's "cream & rind amber"
/// light theme, the first consumer of the override path.
abstract final class DesignedPalette {
  static const seed = Color(0xFFB3641B);

  static const lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: seed,
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
  );

  static const lightTokens = ForgeTokens(
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
  );
}

/// Stands in for an app's own theme extension.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors(this.star);

  final Color star;

  @override
  AppColors copyWith({Color? star}) => AppColors(star ?? this.star);

  @override
  AppColors lerp(AppColors? other, double t) =>
      other == null ? this : AppColors(Color.lerp(star, other.star, t)!);
}
