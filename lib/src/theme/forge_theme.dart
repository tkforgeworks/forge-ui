import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import 'forge_tokens.dart';
import 'forge_type.dart';

/// How tightly `forgeTheme` sizes its controls.
enum ForgeDensity {
  /// The phone defaults the brand started on: full-width, thumb-height
  /// buttons (50 filled, 48 outlined) and roomy fields. The default.
  touch,

  /// Mouse-driven apps such as Anvil: buttons sized to their label at 36
  /// high, tighter fields, search bars and list tiles, and
  /// `VisualDensity.compact` everywhere else.
  desktop,
}

/// The sizes that differ between the [ForgeDensity] values. A null leaves
/// Material's own default in place, which is how `touch` stays exactly as
/// it was before densities existed.
class _Metrics {
  const _Metrics({
    required this.filledMinimumSize,
    required this.outlinedMinimumSize,
    required this.textMinimumSize,
    required this.buttonPadding,
    required this.buttonTapTargetSize,
    required this.buttonVisualDensity,
    required this.inputPadding,
    required this.searchMinHeight,
    required this.visualDensity,
  });

  final Size filledMinimumSize;
  final Size outlinedMinimumSize;
  final Size? textMinimumSize;
  final EdgeInsetsGeometry? buttonPadding;
  final MaterialTapTargetSize? buttonTapTargetSize;

  /// Pinned to standard on desktop so the compact theme density does not
  /// shave another 8 off the 36 button height.
  final VisualDensity? buttonVisualDensity;
  final EdgeInsetsGeometry inputPadding;
  final double searchMinHeight;

  /// Theme-wide and list tiles; null keeps Material's platform default.
  final VisualDensity? visualDensity;

  static const touch = _Metrics(
    filledMinimumSize: Size.fromHeight(50),
    outlinedMinimumSize: Size.fromHeight(48),
    textMinimumSize: null,
    buttonPadding: null,
    buttonTapTargetSize: null,
    buttonVisualDensity: null,
    inputPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    searchMinHeight: 52,
    visualDensity: null,
  );

  static const desktop = _Metrics(
    filledMinimumSize: Size(0, 36),
    outlinedMinimumSize: Size(0, 36),
    textMinimumSize: Size(0, 36),
    buttonPadding: EdgeInsets.symmetric(horizontal: 16),
    buttonTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    buttonVisualDensity: VisualDensity.standard,
    inputPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    searchMinHeight: 40,
    visualDensity: VisualDensity.compact,
  );

  static _Metrics of(ForgeDensity density) => switch (density) {
    ForgeDensity.touch => touch,
    ForgeDensity.desktop => desktop,
  };
}

/// Builds the tkforgeworks theme for an app.
///
/// An app passes its [seed] colour and gets the whole brand: type, shapes,
/// flat bordered surfaces and every component theme. Call it once per
/// brightness:
///
/// ```dart
/// MaterialApp(
///   theme: forgeTheme(seed: seed),
///   darkTheme: forgeTheme(seed: seed, brightness: Brightness.dark),
/// )
/// ```
///
/// An app with a designed palette passes its own [colorScheme] (one per
/// brightness) and, usually, matching [tokens]. The brand's type, shapes and
/// component themes are applied on top of it unchanged. [brightness] is then
/// taken from the scheme, and [seed] still names the app's identity colour.
///
/// [accent] is the app's optional second colour; it lands in
/// `ForgeTokens.accent` unless [tokens] is given. [extensions] carries any
/// `ThemeExtension`s of the app's own.
///
/// [density] picks the control sizes: [ForgeDensity.touch] (the default)
/// for phones, [ForgeDensity.desktop] for mouse-driven apps, where buttons
/// size to their label instead of stretching to their parent's width.
ThemeData forgeTheme({
  required Color seed,
  Color? accent,
  Brightness brightness = Brightness.light,
  ColorScheme? colorScheme,
  ForgeTokens? tokens,
  Iterable<ThemeExtension<dynamic>> extensions = const [],
  ForgeDensity density = ForgeDensity.touch,
}) {
  final m = _Metrics.of(density);
  final c = colorScheme ?? forgeColorScheme(seed: seed, brightness: brightness);
  final x = tokens ?? ForgeTokens.standard(c, accent: accent);
  final text = ForgeType.textTheme(c, x);
  final isDark = c.brightness == Brightness.dark;
  final cardRadius = BorderRadius.circular(ForgeRadii.card);
  return ThemeData(
    useMaterial3: true,
    colorScheme: c,
    scaffoldBackgroundColor: c.surface,
    // Styles the type scale does not set (and Material's own widgets) still
    // come out in the UI face.
    fontFamily: ForgeType.uiFamily,
    package: ForgeType.package,
    textTheme: text,
    extensions: [x, ...extensions],
    splashFactory: InkSparkle.splashFactory,
    visualDensity: m.visualDensity,
    // Heroicons, outline, wherever Material would draw its own icon.
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (_) => const HeroIcon(HeroIcons.arrowLeft),
      closeButtonIconBuilder: (_) => const HeroIcon(HeroIcons.xMark),
      drawerButtonIconBuilder: (_) => const HeroIcon(HeroIcons.bars3),
      endDrawerButtonIconBuilder: (_) => const HeroIcon(HeroIcons.bars3),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? c.surfaceContainerLowest : c.surface,
      foregroundColor: c.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleMedium,
      iconTheme: IconThemeData(color: c.onSurfaceVariant, size: 24),
    ),
    // Flat surfaces: border only, no resting shadow.
    cardTheme: CardThemeData(
      color: c.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: cardRadius,
        side: BorderSide(color: c.outline),
      ),
      margin: EdgeInsets.zero,
    ),
    // A thumb in the palette: the platform default ignores it and is often
    // invisible on dark surfaces. Desktop keeps the bar showing; touch keeps
    // Material's fade-out.
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.dragged)
            ? x.textTertiary
            : x.textGhost,
      ),
      thickness: const WidgetStatePropertyAll(8),
      radius: const Radius.circular(ForgeRadii.tag),
      crossAxisMargin: 2,
      mainAxisMargin: 4,
      thumbVisibility: density == ForgeDensity.desktop
          ? const WidgetStatePropertyAll(true)
          : null,
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStatePropertyAll(c.surfaceContainer),
      elevation: const WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ForgeRadii.pill),
        ),
      ),
      constraints: BoxConstraints(minHeight: m.searchMinHeight),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: m.filledMinimumSize,
        padding: m.buttonPadding,
        tapTargetSize: m.buttonTapTargetSize,
        visualDensity: m.buttonVisualDensity,
        shape: RoundedRectangleBorder(borderRadius: cardRadius),
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: m.outlinedMinimumSize,
        padding: m.buttonPadding,
        tapTargetSize: m.buttonTapTargetSize,
        visualDensity: m.buttonVisualDensity,
        side: BorderSide(color: c.outline),
        foregroundColor: c.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: cardRadius),
        textStyle: text.titleSmall,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: x.link,
        minimumSize: m.textMinimumSize,
        padding: m.buttonPadding,
        tapTargetSize: m.buttonTapTargetSize,
        visualDensity: m.buttonVisualDensity,
        textStyle: text.labelLarge?.copyWith(fontSize: 13),
      ),
    ),
    // Segmented toggle: compact, radius 8, selected = primaryContainer with
    // emphasis text.
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: const WidgetStatePropertyAll(Size(0, 30)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: cardRadius),
        ),
        side: WidgetStatePropertyAll(BorderSide(color: c.outline)),
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? c.primaryContainer
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? c.onPrimaryContainer
              : c.onSurfaceVariant,
        ),
        textStyle: WidgetStatePropertyAll(
          ForgeType.ui(size: 12, weight: FontWeight.w500),
        ),
      ),
    ),
    // Filter chips: radius 8 (not stock full), selected = primaryContainer
    // fill with a checkmark.
    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: c.primaryContainer,
      side: BorderSide(color: c.outline),
      shape: RoundedRectangleBorder(borderRadius: cardRadius),
      labelStyle: ForgeType.ui(
        size: 12,
        weight: FontWeight.w500,
        color: c.onSurfaceVariant,
      ),
      secondaryLabelStyle: ForgeType.ui(
        size: 12,
        weight: FontWeight.w500,
        color: c.onPrimaryContainer,
      ),
      showCheckmark: true,
      checkmarkColor: c.onPrimaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    ),
    // Boxed inputs. The mono label sits OUTSIDE the field (see
    // `ForgeBoxedField`), so there is no floating label.
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: c.surfaceContainerLowest,
      contentPadding: m.inputPadding,
      border: OutlineInputBorder(
        borderRadius: cardRadius,
        borderSide: BorderSide(color: c.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: cardRadius,
        borderSide: BorderSide(color: c.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: cardRadius,
        borderSide: BorderSide(color: c.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: cardRadius,
        borderSide: BorderSide(color: c.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: cardRadius,
        borderSide: BorderSide(color: c.error, width: 1.5),
      ),
      hintStyle: ForgeType.serif(size: 14, italic: true, color: x.textGhost),
      labelStyle: text.labelSmall,
      errorStyle: text.labelMedium?.copyWith(color: c.error),
    ),
    dividerTheme: DividerThemeData(color: x.rowDivider, thickness: 1, space: 1),
    // Drawer: 300 wide, right radius 16, scrim from the scheme; one of the
    // few places a shadow is allowed.
    drawerTheme: DrawerThemeData(
      backgroundColor: c.surfaceContainerLowest,
      scrimColor: c.scrim,
      elevation: 8,
      shadowColor: c.shadow,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(ForgeRadii.fab),
        ),
      ),
      width: 300,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: x.textTertiary,
      visualDensity: m.visualDensity,
      titleTextStyle: text.titleSmall,
      subtitleTextStyle: text.bodySmall,
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      indicatorColor: c.primaryContainer,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ForgeRadii.pill),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: c.primary,
      inactiveTrackColor: c.surfaceContainer,
      thumbColor: c.primary,
      trackHeight: 4,
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(c.surfaceContainerLowest),
      trackColor: WidgetStateProperty.resolveWith(
        (s) =>
            s.contains(WidgetState.selected) ? c.primary : c.surfaceContainer,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    // Shape and label only. `ForgeFab` paints the forge gradient itself, so a
    // plain `FloatingActionButton` keeps Material's colours.
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      extendedTextStyle: text.labelLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ForgeRadii.fab),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ForgeRadii.fab),
        ),
      ),
      showDragHandle: false,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.inverseSurface,
      contentTextStyle: text.bodyMedium?.copyWith(color: c.onInverseSurface),
      shape: RoundedRectangleBorder(borderRadius: cardRadius),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// The colour scheme `forgeTheme` generates from a [seed].
///
/// It is Material's seeded scheme with quieter lines. The brand draws card,
/// input and chip borders with `outline` and row dividers with
/// `outlineVariant`, and both are meant to be soft; Material's generated
/// `outline` is a high-contrast line.
ColorScheme forgeColorScheme({
  required Color seed,
  Brightness brightness = Brightness.light,
}) {
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  return scheme.copyWith(
    outline: scheme.outlineVariant,
    outlineVariant: Color.lerp(scheme.outlineVariant, scheme.surface, 0.5),
  );
}

/// Shorthands so widgets read `context.colors.primary`,
/// `context.forge.textTertiary` and `context.text.titleSmall` instead of the
/// `Theme.of` chain.
extension ForgeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  ForgeTokens get forge => ForgeTokens.of(this);
}
