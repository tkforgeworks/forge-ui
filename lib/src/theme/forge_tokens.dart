import 'package:flutter/material.dart';

/// The brand's corner radii. Fixed in `forge_ui`; apps don't override them.
abstract final class ForgeRadii {
  /// Cards, buttons, inputs, chips.
  static const card = 8.0;

  /// Mono tag capsules.
  static const tag = 4.0;

  /// The extended FAB, the top of a bottom sheet, the drawer's open edge.
  static const fab = 16.0;

  /// The search bar and drawer item pills.
  static const pill = 28.0;
}

/// Colour roles the brand uses that [ColorScheme] has no slot for. Read it
/// with `context.forge` (see `ForgeContext`) or [ForgeTokens.of].
///
/// `forgeTheme` builds one with [ForgeTokens.standard] unless the app passes
/// its own. An app with roles of its own (a star colour, a chart grid) keeps
/// those in a separate `ThemeExtension` and passes it through `forgeTheme`'s
/// `extensions`.
@immutable
class ForgeTokens extends ThemeExtension<ForgeTokens> {
  const ForgeTokens({
    required this.accent,
    required this.link,
    required this.textTertiary,
    required this.textGhost,
    required this.rowDivider,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.errorTint,
    required this.skeletonBase,
    required this.skeletonHighlight,
  });

  /// Derives every role from [scheme], for apps that only supply a seed.
  /// [accent] defaults to the scheme's tertiary colour.
  factory ForgeTokens.standard(ColorScheme scheme, {Color? accent}) {
    final dark = scheme.brightness == Brightness.dark;
    return ForgeTokens(
      accent: accent ?? scheme.tertiary,
      link: dark ? scheme.primary : scheme.onPrimaryContainer,
      textTertiary: Color.lerp(scheme.onSurfaceVariant, scheme.surface, 0.25)!,
      textGhost: Color.lerp(scheme.onSurfaceVariant, scheme.surface, 0.5)!,
      rowDivider: scheme.outlineVariant,
      successContainer: dark ? _successContainerDark : _successContainerLight,
      onSuccessContainer: dark
          ? _onSuccessContainerDark
          : _onSuccessContainerLight,
      errorTint: Color.alphaBlend(
        scheme.error.withValues(alpha: dark ? 0.16 : 0.08),
        scheme.surface,
      ),
      // One step stronger than the search-bar fill, or a seeded scheme's
      // placeholders all but vanish on the page.
      skeletonBase: scheme.surfaceContainerHigh,
      skeletonHighlight: dark
          ? scheme.surfaceContainerHighest
          : scheme.surfaceContainerLow,
    );
  }

  // "Success" is the same green in every app; a seed can't produce it.
  static const _successContainerLight = Color(0xFFE8F2E5);
  static const _onSuccessContainerLight = Color(0xFF3D7A33);
  static const _successContainerDark = Color(0xFF2B3D28);
  static const _onSuccessContainerDark = Color(0xFF9CCB8F);

  /// The app's optional second colour. Nothing in `forge_ui` paints with it;
  /// it is there for the app's own screens.
  final Color accent;

  /// Text buttons, links and other emphasised, tappable text.
  final Color link;

  /// Third-level text: field labels, row meta, list tile icons.
  final Color textTertiary;

  /// Hints, disabled text and fine print.
  final Color textGhost;

  /// The line between rows inside a card or list.
  final Color rowDivider;

  /// Fill of a positive status capsule ("CONNECTED"). Status only.
  final Color successContainer;

  /// Text on [successContainer].
  final Color onSuccessContainer;

  /// Background of an inline error card.
  final Color errorTint;

  /// Skeleton placeholders shimmer between these two.
  final Color skeletonBase;
  final Color skeletonHighlight;

  /// The tokens of the nearest theme. Falls back to [ForgeTokens.standard]
  /// for a theme that was not built with `forgeTheme`.
  static ForgeTokens of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<ForgeTokens>() ??
        ForgeTokens.standard(theme.colorScheme);
  }

  @override
  ForgeTokens copyWith({
    Color? accent,
    Color? link,
    Color? textTertiary,
    Color? textGhost,
    Color? rowDivider,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? errorTint,
    Color? skeletonBase,
    Color? skeletonHighlight,
  }) => ForgeTokens(
    accent: accent ?? this.accent,
    link: link ?? this.link,
    textTertiary: textTertiary ?? this.textTertiary,
    textGhost: textGhost ?? this.textGhost,
    rowDivider: rowDivider ?? this.rowDivider,
    successContainer: successContainer ?? this.successContainer,
    onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
    errorTint: errorTint ?? this.errorTint,
    skeletonBase: skeletonBase ?? this.skeletonBase,
    skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
  );

  @override
  ForgeTokens lerp(ForgeTokens? other, double t) {
    if (other == null) return this;
    return ForgeTokens(
      accent: Color.lerp(accent, other.accent, t)!,
      link: Color.lerp(link, other.link, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textGhost: Color.lerp(textGhost, other.textGhost, t)!,
      rowDivider: Color.lerp(rowDivider, other.rowDivider, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      errorTint: Color.lerp(errorTint, other.errorTint, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(
        skeletonHighlight,
        other.skeletonHighlight,
        t,
      )!,
    );
  }
}
