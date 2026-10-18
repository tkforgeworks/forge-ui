import 'package:flutter/painting.dart';

/// The colours and assets a sign-in provider mandates for its button. These
/// are the provider's rules, not the brand's, so they live apart from
/// `ForgeBrand` and are the second place in `forge_ui` allowed to write a
/// colour literal. Nothing else may use them.
///
/// Google: https://developers.google.com/identity/branding-guidelines (the
/// "G" always in its standard colours; the label in Google Sans Medium 14/20;
/// 12 px before the logo, 10 px after it, 12 px after the text on Android).
abstract final class ForgeProviderBrand {
  // Google, light theme.
  static const googleLightFill = Color(0xFFFFFFFF);
  static const googleLightStroke = Color(0xFF747775);
  static const googleLightText = Color(0xFF1F1F1F);

  // Google, dark theme.
  static const googleDarkFill = Color(0xFF131314);
  static const googleDarkStroke = Color(0xFF8E918F);
  static const googleDarkText = Color(0xFFE3E3E3);

  // Google, neutral theme (no stroke).
  static const googleNeutralFill = Color(0xFFF2F2F2);
  static const googleNeutralText = Color(0xFF1F1F1F);

  /// The button label's typeface: a static Medium instance of Google Sans
  /// Flex (OFL 1.1), bundled in this package. The guideline names Google
  /// Sans Medium; Flex is Google's open rebuild of it.
  static const googleFamily = 'Google Sans Flex';

  /// Google's official "G", cropped from the pre-approved button assets,
  /// with 2x, 3x and 4x variants. All rights reserved by Google (see
  /// `NOTICE`); it is never recoloured or restyled.
  static const googleLogoAsset = 'assets/brand/providers/google_g.png';

  /// The guideline's logo size and paddings for Android.
  static const googleLogoSize = 20.0;
  static const googlePaddingBeforeLogo = 12.0;
  static const googlePaddingAfterLogo = 10.0;
  static const googlePaddingAfterText = 12.0;
  static const googleHeight = 40.0;
}

/// Which of Google's three approved button themes to draw. [auto] follows the
/// app theme's brightness.
enum ForgeProviderButtonTheme { auto, light, dark, neutral }
