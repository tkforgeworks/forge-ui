import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import '../theme/forge_provider_brand.dart';
import '../theme/forge_type.dart';

/// A way of signing in. `forge_ui` owns each provider's label and look, so
/// every app shows them the same way; the app maps forge_core's identities
/// onto these.
enum ForgeSignInProvider {
  google,
  email,

  /// Reserved: the button arrives with the first iOS app.
  apple;

  /// How the provider is named in UI ("Google", "Email", "Apple").
  String get label => switch (this) {
    google => 'Google',
    email => 'Email',
    apple => 'Apple',
  };
}

/// One linked sign-in method of an account, as the account page lists it.
@immutable
class ForgeLinkedSignIn {
  const ForgeLinkedSignIn({required this.provider, this.email});

  final ForgeSignInProvider provider;

  /// The address that provider knows the user by, when there is one.
  final String? email;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForgeLinkedSignIn &&
          other.provider == provider &&
          other.email == email;

  @override
  int get hashCode => Object.hash(provider, email);
}

/// The "Continue with …" button for a sign-in provider.
///
/// Google's is drawn to Google's branding guidelines (their colours, their
/// "G", Google Sans Medium) through `ForgeProviderBrand`; it is the one
/// widget in the package whose colours do not come from the theme. The
/// email button is an ordinary outlined button with an envelope. Apple is
/// reserved until an iOS app exists.
///
/// [busy] shows a small progress ring in place of the logo and disables the
/// button; a null [onPressed] disables it too.
class ForgeSignInButton extends StatelessWidget {
  const ForgeSignInButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.busy = false,
    this.label,
    this.theme = ForgeProviderButtonTheme.auto,
  }) : assert(
         provider != ForgeSignInProvider.apple,
         'Apple sign-in arrives with the first iOS app',
       );

  final ForgeSignInProvider provider;
  final VoidCallback? onPressed;
  final bool busy;

  /// Overrides the default `Continue with …` label.
  final String? label;

  /// Google only: which of its approved themes to draw.
  final ForgeProviderButtonTheme theme;

  /// The default label for [provider].
  static String labelFor(ForgeSignInProvider provider) =>
      'Continue with ${provider.label}';

  bool get _enabled => onPressed != null && !busy;

  @override
  Widget build(BuildContext context) => switch (provider) {
    ForgeSignInProvider.google => _google(context),
    ForgeSignInProvider.email => _email(context),
    ForgeSignInProvider.apple => throw UnsupportedError('Apple sign-in'),
  };

  Widget _google(BuildContext context) {
    final resolved = switch (theme) {
      ForgeProviderButtonTheme.auto =>
        Theme.of(context).brightness == Brightness.dark
            ? ForgeProviderButtonTheme.dark
            : ForgeProviderButtonTheme.light,
      _ => theme,
    };
    final (fill, stroke, textColor) = switch (resolved) {
      ForgeProviderButtonTheme.dark => (
        ForgeProviderBrand.googleDarkFill,
        ForgeProviderBrand.googleDarkStroke,
        ForgeProviderBrand.googleDarkText,
      ),
      ForgeProviderButtonTheme.neutral => (
        ForgeProviderBrand.googleNeutralFill,
        null,
        ForgeProviderBrand.googleNeutralText,
      ),
      _ => (
        ForgeProviderBrand.googleLightFill,
        ForgeProviderBrand.googleLightStroke,
        ForgeProviderBrand.googleLightText,
      ),
    };
    final shape = StadiumBorder(
      side: stroke == null ? BorderSide.none : BorderSide(color: stroke),
    );
    return Semantics(
      button: true,
      enabled: _enabled,
      child: Opacity(
        opacity: _enabled ? 1 : 0.62,
        child: Material(
          color: fill,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _enabled ? onPressed : null,
            customBorder: shape,
            child: SizedBox(
              height: ForgeProviderBrand.googleHeight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: ForgeProviderBrand.googlePaddingBeforeLogo,
                  ),
                  SizedBox.square(
                    dimension: ForgeProviderBrand.googleLogoSize,
                    child: busy
                        ? Padding(
                            padding: const EdgeInsets.all(2),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: textColor,
                            ),
                          )
                        : Image(
                            image: const AssetImage(
                              ForgeProviderBrand.googleLogoAsset,
                              package: ForgeType.package,
                            ),
                            filterQuality: FilterQuality.medium,
                            // The asset resolves as a dependency's
                            // (`packages/forge_ui/…`); this package's own
                            // widget tests have no such prefix, so draw
                            // nothing there rather than fail.
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                  ),
                  const SizedBox(
                    width: ForgeProviderBrand.googlePaddingAfterLogo,
                  ),
                  Text(
                    label ?? labelFor(provider),
                    style: TextStyle(
                      fontFamily: ForgeProviderBrand.googleFamily,
                      package: ForgeType.package,
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(
                    width: ForgeProviderBrand.googlePaddingAfterText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _email(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: _enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(ForgeProviderBrand.googleHeight),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      icon: busy
          ? SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: c.onSurfaceVariant,
              ),
            )
          : const HeroIcon(HeroIcons.envelope, size: 18),
      label: Text(label ?? labelFor(provider)),
    );
  }
}
