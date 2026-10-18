import 'package:flutter/material.dart';

import '../theme/forge_theme.dart';
import '../widgets/forge_sign_in_panel.dart';
import '../widgets/nav_bar_inset.dart';

/// `ForgeSignInPanel` on its own page, for an app that sends people to a
/// sign-in screen rather than embedding the panel. [onSkip] adds a quiet
/// "Not now" at the bottom for apps where sign-in is optional; null hides
/// it. Every other parameter is passed straight to the panel.
class ForgeSignInScreen extends StatelessWidget {
  const ForgeSignInScreen({
    super.key,
    this.title = 'Sign in',
    this.leading,
    this.onGoogle,
    this.onApple,
    required this.onEmailSignIn,
    required this.onEmailCreate,
    required this.onForgotPassword,
    this.busy = false,
    this.errorText,
    this.heading,
    this.blurb,
    this.initialMode = ForgeSignInMode.signIn,
    this.initialEmail,
    this.onModeChanged,
    this.onSkip,
    this.skipLabel = 'Not now',
  });

  static const skipKey = Key('forge-sign-in-skip');

  final String title;

  /// App bar leading widget; null gives the usual back button.
  final Widget? leading;
  final VoidCallback? onGoogle;
  final VoidCallback? onApple;
  final void Function(String email, String password) onEmailSignIn;
  final void Function(String email, String password) onEmailCreate;
  final void Function(String email) onForgotPassword;
  final bool busy;
  final String? errorText;
  final String? heading;
  final String? blurb;
  final ForgeSignInMode initialMode;
  final String? initialEmail;
  final ValueChanged<ForgeSignInMode>? onModeChanged;

  /// Leaves without signing in. Null hides the button.
  final VoidCallback? onSkip;
  final String skipLabel;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: leading, title: Text(title)),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(
        24,
        16,
        24,
        32,
      ).withNavBarInset(context),
      children: [
        ForgeSignInPanel(
          onGoogle: onGoogle,
          onApple: onApple,
          onEmailSignIn: onEmailSignIn,
          onEmailCreate: onEmailCreate,
          onForgotPassword: onForgotPassword,
          busy: busy,
          errorText: errorText,
          heading: heading,
          blurb: blurb,
          initialMode: initialMode,
          initialEmail: initialEmail,
          onModeChanged: onModeChanged,
        ),
        if (onSkip != null) ...[
          const SizedBox(height: 18),
          Center(
            child: TextButton(
              key: skipKey,
              onPressed: busy ? null : onSkip,
              style: TextButton.styleFrom(
                foregroundColor: context.forge.textTertiary,
              ),
              child: Text(skipLabel),
            ),
          ),
        ],
      ],
    ),
  );
}
