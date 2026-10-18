import 'package:flutter/material.dart';

import '../theme/forge_theme.dart';
import '../theme/forge_type.dart';
import '../widgets/forge_boxed_field.dart';
import '../widgets/forge_error_card.dart';
import '../widgets/forge_sign_in_panel.dart';
import '../widgets/nav_bar_inset.dart';

/// The form shown when the app opens from a password-reset link (the auth
/// state reports `passwordRecovery`), and reused by "Set a password" on a
/// Google-only account. Two fields that must match and reach
/// [ForgeSignInPanel.minPasswordLength]; the app runs the update and drives
/// [busy] and [errorText].
class ForgeSetPasswordScreen extends StatefulWidget {
  const ForgeSetPasswordScreen({
    super.key,
    required this.onSubmit,
    this.busy = false,
    this.errorText,
    this.title = 'New password',
    this.heading = 'Choose a new password',
    this.blurb,
    this.submitLabel = 'Save password',
    this.leading,
  });

  static const passwordFieldKey = Key('forge-set-password');
  static const confirmFieldKey = Key('forge-set-password-confirm');
  static const submitKey = Key('forge-set-password-submit');
  static const showPasswordKey = Key('forge-set-password-show');

  final ValueChanged<String> onSubmit;
  final bool busy;
  final String? errorText;
  final String title;
  final String heading;

  /// One line under the heading; defaults to the length rule.
  final String? blurb;
  final String submitLabel;
  final Widget? leading;

  @override
  State<ForgeSetPasswordScreen> createState() => _ForgeSetPasswordScreenState();
}

class _ForgeSetPasswordScreenState extends State<ForgeSetPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _confirmFocus = FocusNode();
  String? _passwordError;
  String? _confirmError;
  var _show = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.busy) return;
    final password = _password.text;
    final passwordError = password.length < ForgeSignInPanel.minPasswordLength
        ? 'Use at least ${ForgeSignInPanel.minPasswordLength} characters.'
        : null;
    final confirmError = passwordError == null && _confirm.text != password
        ? 'The two passwords differ.'
        : null;
    setState(() {
      _passwordError = passwordError;
      _confirmError = confirmError;
    });
    if (passwordError != null || confirmError != null) return;
    widget.onSubmit(password);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final x = context.forge;
    final enabled = !widget.busy;
    return Scaffold(
      appBar: AppBar(leading: widget.leading, title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          24,
          16,
          24,
          32,
        ).withNavBarInset(context),
        children: [
          Text(widget.heading, style: context.text.titleLarge),
          const SizedBox(height: 4),
          Text(
            widget.blurb ??
                'At least ${ForgeSignInPanel.minPasswordLength} characters. '
                    'Longer is better.',
            style: ForgeType.serif(
              size: 13.5,
              italic: true,
              color: x.textTertiary,
            ),
          ),
          const SizedBox(height: 18),
          Stack(
            alignment: Alignment.topRight,
            children: [
              ForgeBoxedField(
                key: ForgeSetPasswordScreen.passwordFieldKey,
                label: 'New password',
                controller: _password,
                enabled: enabled,
                obscureText: !_show,
                errorText: _passwordError,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
                onSubmitted: (_) => _confirmFocus.requestFocus(),
              ),
              TextButton(
                key: ForgeSetPasswordScreen.showPasswordKey,
                onPressed: enabled
                    ? () => setState(() => _show = !_show)
                    : null,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(_show ? 'Hide' : 'Show'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ForgeBoxedField(
            key: ForgeSetPasswordScreen.confirmFieldKey,
            label: 'Again, to be sure',
            controller: _confirm,
            focusNode: _confirmFocus,
            enabled: enabled,
            obscureText: !_show,
            errorText: _confirmError,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            onChanged: (_) {
              if (_confirmError != null) setState(() => _confirmError = null);
            },
            onSubmitted: (_) => _submit(),
          ),
          if (widget.errorText != null) ...[
            const SizedBox(height: 14),
            ForgeErrorCard(message: widget.errorText!),
          ],
          const SizedBox(height: 22),
          FilledButton(
            key: ForgeSetPasswordScreen.submitKey,
            onPressed: enabled ? _submit : null,
            child: widget.busy
                ? SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: c.onPrimary,
                    ),
                  )
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}
