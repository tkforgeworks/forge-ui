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
    this._warning,
    this._onWarning,
    this._warningContainer,
    this._onWarningContainer,
    this._info,
    this._onInfo,
    this._infoContainer,
    this._onInfoContainer,
    this._success,
    this._onSuccess,
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
      warning: dark ? _warningDark : _warningLight,
      onWarning: dark ? _onIntentDark : _onIntentLight,
      warningContainer: _container(
        scheme.surfaceContainerLowest,
        dark ? _warningDark : _warningLight,
        dark,
      ),
      onWarningContainer: _onContainer(
        dark ? _warningDark : _warningLight,
        dark,
      ),
      info: dark ? _infoDark : _infoLight,
      onInfo: dark ? _onIntentDark : _onIntentLight,
      infoContainer: _container(
        scheme.surfaceContainerLowest,
        dark ? _infoDark : _infoLight,
        dark,
      ),
      onInfoContainer: _onContainer(dark ? _infoDark : _infoLight, dark),
      success: dark ? _successDark : _successLight,
      onSuccess: dark ? _onIntentDark : _onIntentLight,
    );
  }

  static Color _container(Color surface, Color intent, bool dark) =>
      Color.alphaBlend(intent.withValues(alpha: dark ? 0.16 : 0.08), surface);

  static Color _onContainer(Color intent, bool dark) =>
      dark ? intent : Color.lerp(intent, const Color(0xFF000000), 0.3)!;

  // "Success" is the same green in every app; a seed can't produce it.
  static const _successContainerLight = Color(0xFFE8F2E5);
  static const _onSuccessContainerLight = Color(0xFF3D7A33);
  static const _successContainerDark = Color(0xFF2B3D28);
  static const _onSuccessContainerDark = Color(0xFF9CCB8F);

  // The semantic intent hues (the MUI defaults), fixed like the greens above.
  static const _warningDark = Color(0xFFFFA726);
  static const _infoDark = Color(0xFF29B6F6);
  static const _successDark = Color(0xFF66BB6A);
  static const _warningLight = Color(0xFFED6C02);
  static const _infoLight = Color(0xFF0288D1);
  static const _successLight = Color(0xFF2E7D32);
  static const _onIntentDark = Color(0xDE000000);
  static const _onIntentLight = Color(0xFFFFFFFF);

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

  final Color? _warning;
  final Color? _onWarning;
  final Color? _warningContainer;
  final Color? _onWarningContainer;
  final Color? _info;
  final Color? _onInfo;
  final Color? _infoContainer;
  final Color? _onInfoContainer;
  final Color? _success;
  final Color? _onSuccess;

  // Literals written before FU-9 omit the intent roles. The fallbacks pick
  // the dark hues when the success container is dark, so a dark-looking
  // literal does not get light-mode colours. Fallback containers blend over
  // [skeletonHighlight], the nearest card-toned role a literal has.
  // [ForgeTokens.standard] always passes every role, so this only matters
  // for hand-written literals.
  bool get _dark => successContainer.computeLuminance() < 0.5;

  /// Warning intent (amber): icons, strokes and emphasised text.
  Color get warning => _warning ?? (_dark ? _warningDark : _warningLight);

  /// Text or icons on [warning].
  Color get onWarning => _onWarning ?? (_dark ? _onIntentDark : _onIntentLight);

  /// Fill of a warning capsule or banner.
  Color get warningContainer =>
      _warningContainer ?? _container(skeletonHighlight, warning, _dark);

  /// Text on [warningContainer].
  Color get onWarningContainer =>
      _onWarningContainer ?? _onContainer(warning, _dark);

  /// Info intent (blue).
  Color get info => _info ?? (_dark ? _infoDark : _infoLight);

  /// Text or icons on [info].
  Color get onInfo => _onInfo ?? (_dark ? _onIntentDark : _onIntentLight);

  /// Fill of an info capsule or banner.
  Color get infoContainer =>
      _infoContainer ?? _container(skeletonHighlight, info, _dark);

  /// Text on [infoContainer].
  Color get onInfoContainer => _onInfoContainer ?? _onContainer(info, _dark);

  /// Success intent (green): the semantic colour, for icons, strokes and
  /// emphasised text. [successContainer] is the fixed "capsule green" fill
  /// of the status capsule and is a different, older role; they are not
  /// derived from each other.
  Color get success => _success ?? (_dark ? _successDark : _successLight);

  /// Text or icons on [success].
  Color get onSuccess => _onSuccess ?? (_dark ? _onIntentDark : _onIntentLight);

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
  // Roles left out stay unset, so a fallback keeps following successContainer.
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
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? success,
    Color? onSuccess,
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
    warning: warning ?? _warning,
    onWarning: onWarning ?? _onWarning,
    warningContainer: warningContainer ?? _warningContainer,
    onWarningContainer: onWarningContainer ?? _onWarningContainer,
    info: info ?? _info,
    onInfo: onInfo ?? _onInfo,
    infoContainer: infoContainer ?? _infoContainer,
    onInfoContainer: onInfoContainer ?? _onInfoContainer,
    success: success ?? _success,
    onSuccess: onSuccess ?? _onSuccess,
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
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
    );
  }
}
