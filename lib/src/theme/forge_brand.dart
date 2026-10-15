import 'package:flutter/painting.dart';

/// The TK ForgeWorks brand colours: the forge gradient and the colours of
/// the hammer-and-anvil mark. They are the brand itself, so they are the
/// same in every app and never change with an app's theme.
///
/// This is the only place in `forge_ui` where a colour is written as a
/// literal for painting. Every other colour comes from
/// `Theme.of(context).colorScheme` or the `ForgeTokens` extension.
abstract final class ForgeBrand {
  static const forgeYellow = Color(0xFFFBDF19);
  static const forgeOrange = Color(0xFFF68F25);
  static const forgeRed = Color(0xFFEE3423);

  /// The forge gradient at 135°, as painted on `ForgeFab` and on an app's
  /// logo badge. It starts a touch deeper than [forgeYellow] so white
  /// content stays readable across the whole surface.
  static const forgeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF9A825), forgeOrange, forgeRed],
    stops: [0.0, 0.45, 1.0],
  );

  /// The full yellow → orange → red run, left to right, for thin accents
  /// such as the 4 px strip on a featured card.
  static const forgeStrip = LinearGradient(
    colors: [forgeYellow, forgeOrange, forgeRed],
  );

  /// Text and icons on [forgeGradient].
  static const onForge = Color(0xFFFFFFFF);

  /// The warm shadow under a gradient surface (`0 6 18 rgba(238,52,35,.35)`).
  static const forgeShadow = BoxShadow(
    color: Color(0x59EE3423),
    offset: Offset(0, 6),
    blurRadius: 18,
  );

  /// The mark's anvil: top-to-bottom purple.
  static const anvilGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF9632F3), Color(0xFF8532D6), Color(0xFF601BBC)],
    stops: [0.0, 0.52, 1.0],
  );

  /// The mark's hammer: the forge colours along the handle.
  static const hammerGradient = LinearGradient(
    begin: Alignment(-0.7, -0.8),
    end: Alignment(0.95, 0.5),
    colors: [forgeYellow, forgeOrange, forgeRed],
    stops: [0.0, 0.52, 1.0],
  );
}
