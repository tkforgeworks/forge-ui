import 'package:flutter/material.dart';

import '../theme/forge_theme.dart';
import '../theme/forge_type.dart';
import 'forge_boxed_field.dart';
import 'forge_error_card.dart';
import 'forge_sign_in_button.dart';

/// Which form the panel shows under the provider buttons.
enum ForgeSignInMode { signIn, create, forgot }

/// The shared sign-in surface: provider buttons above an always-present
/// email/password form that switches between signing in, creating an
/// account and asking for a password reset.
///
/// Callbacks in, no auth logic. The app runs the sign-in and drives [busy]
/// and [errorText] from the result; the panel validates the fields itself
/// (an address that looks like one, a password of at least
/// [minPasswordLength]) and shows field-level errors on submit.
///
/// `onGoogle` and `onApple` are nullable: a null callback leaves that button
/// out, which is how an Android app omits Apple. At least one is required in
/// debug builds (the spec's rule that every app offers Google). Embed the
/// panel in your own screen (cheesy-scribe's Account page does) or use
/// `ForgeSignInScreen`.
class ForgeSignInPanel extends StatefulWidget {
  const ForgeSignInPanel({
    super.key,
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
  }) : assert(
         onGoogle != null || onApple != null,
         'Offer at least one provider button (see the spec)',
       );

  static const emailFieldKey = Key('forge-sign-in-email');
  static const passwordFieldKey = Key('forge-sign-in-password');
  static const submitKey = Key('forge-sign-in-submit');
  static const switchModeKey = Key('forge-sign-in-switch-mode');
  static const forgotKey = Key('forge-sign-in-forgot');
  static const showPasswordKey = Key('forge-sign-in-show-password');

  /// Shortest password the form accepts (Supabase's default minimum).
  static const minPasswordLength = 8;

  /// Native Google sign-in. Null hides the button.
  final VoidCallback? onGoogle;

  /// Reserved for the first iOS app. Null hides the button.
  final VoidCallback? onApple;

  final void Function(String email, String password) onEmailSignIn;
  final void Function(String email, String password) onEmailCreate;
  final void Function(String email) onForgotPassword;

  /// Disables every input and shows progress in the active control while
  /// the app talks to the backend.
  final bool busy;

  /// A form-level error from the last attempt ("Wrong password", "That
  /// address is already registered"…). Shown in an error card; cleared by
  /// the app when the user tries again.
  final String? errorText;

  /// Optional title and one-liner above the buttons.
  final String? heading;
  final String? blurb;

  final ForgeSignInMode initialMode;
  final String? initialEmail;

  /// Called when the user switches between sign in, create and forgot.
  final ValueChanged<ForgeSignInMode>? onModeChanged;

  /// A loose check that the address has a local part, an @ and a dotted
  /// domain; the server does the real validation.
  static bool looksLikeEmail(String value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());

  @override
  State<ForgeSignInPanel> createState() => _ForgeSignInPanelState();
}

class _ForgeSignInPanelState extends State<ForgeSignInPanel> {
  late ForgeSignInMode _mode = widget.initialMode;
  late final _email = TextEditingController(text: widget.initialEmail);
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  String? _emailError;
  String? _passwordError;
  var _showPassword = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _switch(ForgeSignInMode mode) {
    setState(() {
      _mode = mode;
      _emailError = null;
      _passwordError = null;
    });
    widget.onModeChanged?.call(mode);
  }

  void _submit() {
    if (widget.busy) return;
    final email = _email.text.trim();
    final password = _password.text;
    final emailError = ForgeSignInPanel.looksLikeEmail(email)
        ? null
        : 'Enter the email address you use.';
    String? passwordError;
    if (_mode != ForgeSignInMode.forgot) {
      if (password.isEmpty) {
        passwordError = 'Enter your password.';
      } else if (_mode == ForgeSignInMode.create &&
          password.length < ForgeSignInPanel.minPasswordLength) {
        passwordError =
            'Use at least ${ForgeSignInPanel.minPasswordLength} characters.';
      }
    }
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });
    if (emailError != null || passwordError != null) return;
    switch (_mode) {
      case ForgeSignInMode.signIn:
        widget.onEmailSignIn(email, password);
      case ForgeSignInMode.create:
        widget.onEmailCreate(email, password);
      case ForgeSignInMode.forgot:
        widget.onForgotPassword(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final x = context.forge;
    final text = context.text;
    final enabled = !widget.busy;
    final hasPassword = _mode != ForgeSignInMode.forgot;

    final (submitLabel, switchLabel, switchTo) = switch (_mode) {
      ForgeSignInMode.signIn => (
        'Sign in',
        'New here? Create an account',
        ForgeSignInMode.create,
      ),
      ForgeSignInMode.create => (
        'Create account',
        'Have an account? Sign in',
        ForgeSignInMode.signIn,
      ),
      ForgeSignInMode.forgot => (
        'Send reset link',
        'Back to sign in',
        ForgeSignInMode.signIn,
      ),
    };

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.heading != null) ...[
            Text(widget.heading!, style: text.titleLarge),
            const SizedBox(height: 4),
          ],
          if (widget.blurb != null) ...[
            Text(
              widget.blurb!,
              style: ForgeType.serif(
                size: 13.5,
                italic: true,
                color: x.textTertiary,
              ),
            ),
            const SizedBox(height: 18),
          ] else if (widget.heading != null)
            const SizedBox(height: 14),
          if (widget.onGoogle != null)
            ForgeSignInButton(
              provider: ForgeSignInProvider.google,
              onPressed: widget.onGoogle,
              busy: widget.busy,
            ),
          if (widget.onApple != null) ...[
            if (widget.onGoogle != null) const SizedBox(height: 12),
            ForgeSignInButton(
              provider: ForgeSignInProvider.apple,
              onPressed: widget.onApple,
              busy: widget.busy,
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: Divider(color: x.rowDivider)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  _mode == ForgeSignInMode.forgot
                      ? 'reset by email'
                      : 'or with email',
                  style: text.bodySmall?.copyWith(color: x.textTertiary),
                ),
              ),
              Expanded(child: Divider(color: x.rowDivider)),
            ],
          ),
          const SizedBox(height: 14),
          ForgeBoxedField(
            key: ForgeSignInPanel.emailFieldKey,
            label: 'Email',
            hint: 'you@example.com',
            controller: _email,
            enabled: enabled,
            errorText: _emailError,
            keyboardType: TextInputType.emailAddress,
            textInputAction: hasPassword
                ? TextInputAction.next
                : TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onChanged: (_) {
              if (_emailError != null) setState(() => _emailError = null);
            },
            onSubmitted: (_) =>
                hasPassword ? _passwordFocus.requestFocus() : _submit(),
          ),
          if (hasPassword) ...[
            const SizedBox(height: 14),
            Stack(
              alignment: Alignment.topRight,
              children: [
                ForgeBoxedField(
                  key: ForgeSignInPanel.passwordFieldKey,
                  label: 'Password',
                  hint: _mode == ForgeSignInMode.create
                      ? 'At least ${ForgeSignInPanel.minPasswordLength} '
                            'characters'
                      : null,
                  controller: _password,
                  focusNode: _passwordFocus,
                  enabled: enabled,
                  obscureText: !_showPassword,
                  errorText: _passwordError,
                  textInputAction: TextInputAction.done,
                  autofillHints: [
                    _mode == ForgeSignInMode.create
                        ? AutofillHints.newPassword
                        : AutofillHints.password,
                  ],
                  onChanged: (_) {
                    if (_passwordError != null) {
                      setState(() => _passwordError = null);
                    }
                  },
                  onSubmitted: (_) => _submit(),
                ),
                TextButton(
                  key: ForgeSignInPanel.showPasswordKey,
                  onPressed: enabled
                      ? () => setState(() => _showPassword = !_showPassword)
                      : null,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(_showPassword ? 'Hide' : 'Show'),
                ),
              ],
            ),
          ],
          if (widget.errorText != null) ...[
            const SizedBox(height: 14),
            ForgeErrorCard(message: widget.errorText!),
          ],
          const SizedBox(height: 18),
          FilledButton(
            key: ForgeSignInPanel.submitKey,
            onPressed: enabled ? _submit : null,
            child: widget.busy
                ? SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: c.onPrimary,
                    ),
                  )
                : Text(submitLabel),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: _mode == ForgeSignInMode.signIn
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              if (_mode == ForgeSignInMode.signIn)
                TextButton(
                  key: ForgeSignInPanel.forgotKey,
                  onPressed: enabled
                      ? () => _switch(ForgeSignInMode.forgot)
                      : null,
                  child: const Text('Forgot password?'),
                ),
              TextButton(
                key: ForgeSignInPanel.switchModeKey,
                onPressed: enabled ? () => _switch(switchTo) : null,
                child: Text(switchLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
