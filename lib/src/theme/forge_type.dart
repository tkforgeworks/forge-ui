import 'package:flutter/material.dart';

import 'forge_tokens.dart';

/// The brand's three typefaces and its type scale. The font files are
/// bundled in this package (`assets/fonts/`), so an app gets them through
/// the dependency and declares nothing.
///
/// Poppins is the UI voice, Source Serif 4 the editorial voice (names, prose,
/// taglines; often italic) and JetBrains Mono the labels and tag capsules
/// (always uppercase, letterspaced).
///
/// JetBrains Mono has two styles. [mono] is for labels and capsules:
/// uppercase, letterspaced. [code] is for identifiers, export keys, formulas,
/// file paths and log lines: body-sized, as typed, no tracking.
abstract final class ForgeType {
  /// The package the font families are declared in. Flutter registers a
  /// dependency's fonts as `packages/<package>/<family>`.
  static const package = 'forge_ui';

  static const uiFamily = 'Poppins';
  static const serifFamily = 'Source Serif 4';
  static const monoFamily = 'JetBrains Mono';

  /// Poppins UI text.
  static TextStyle ui({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) => TextStyle(
    fontFamily: uiFamily,
    package: package,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );

  /// Source Serif 4: names and prose. Pass `italic: true` for taglines,
  /// hints and asides.
  static TextStyle serif({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    bool italic = false,
    Color? color,
    double? height,
  }) => TextStyle(
    fontFamily: serifFamily,
    package: package,
    fontSize: size,
    fontWeight: weight,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    color: color,
    height: height,
  );

  /// JetBrains Mono: labels and capsules. Callers uppercase the content
  /// themselves (see `ForgeMonoLabel` and `ForgeTagCapsule`).
  static TextStyle mono({
    double size = 10,
    FontWeight weight = FontWeight.w500,
    double letterSpacing = 1.4,
    Color? color,
  }) => TextStyle(
    fontFamily: monoFamily,
    package: package,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    color: color,
  );

  /// JetBrains Mono as body text for code: identifiers, export keys, formulas,
  /// file paths and log lines. Unlike [mono] it has no letterspacing and the
  /// content is shown as typed, not uppercased.
  static TextStyle code({
    double size = 13,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) => TextStyle(
    fontFamily: monoFamily,
    package: package,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: 0,
    color: color,
    height: height,
  );

  /// The type scale, coloured from [scheme] and [tokens].
  static TextTheme textTheme(ColorScheme scheme, ForgeTokens tokens) {
    final onSurface = scheme.onSurface;
    return TextTheme(
      // Editorial display: names on detail pages and featured cards.
      displaySmall: serif(
        size: 27,
        weight: FontWeight.w600,
        height: 1.2,
        color: onSurface,
      ),
      headlineSmall: serif(size: 21, weight: FontWeight.w600, color: onSurface),
      // UI headers.
      titleLarge: ui(size: 22, weight: FontWeight.w600, color: onSurface),
      titleMedium: ui(size: 18, weight: FontWeight.w600, color: onSurface),
      titleSmall: ui(size: 15, weight: FontWeight.w500, color: onSurface),
      // Body. `bodyLarge` is prose, so it is the serif.
      bodyLarge: serif(size: 14.5, height: 1.7, color: onSurface),
      bodyMedium: ui(size: 14, color: onSurface),
      bodySmall: ui(size: 11.5, color: tokens.textTertiary), // row meta
      // Field labels: uppercase content, tracking 1.4.
      labelSmall: mono(size: 10, color: tokens.textTertiary),
      // Tag capsules and stat labels.
      labelMedium: mono(
        size: 9.5,
        letterSpacing: 0.5,
        color: tokens.textTertiary,
      ),
      // Button labels.
      labelLarge: ui(size: 14, weight: FontWeight.w600, color: onSurface),
    );
  }
}
