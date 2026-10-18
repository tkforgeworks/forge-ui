import 'dart:async';

import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import '../theme/forge_theme.dart';
import '../theme/forge_type.dart';
import '../widgets/forge_error_card.dart';
import '../widgets/nav_bar_inset.dart';

/// Why the user is being asked to look at their inbox.
enum ForgeEmailPurpose {
  /// A new account's confirmation link.
  confirm,

  /// A password-reset link.
  reset,
}

/// The waiting state after a sign-up or a reset request: which address the
/// email went to, a "Send again" that stays disabled for [resendCooldown]
/// after each send, a way back to change the address, and Done. The reset
/// wording is conditional ("if there is an account for …"): Supabase
/// reports success for an unknown address so the form cannot enumerate
/// accounts, and the screen must not promise a mail that may never come.
///
/// The screen opens the moment a mail was sent, so the cooldown starts at
/// once. Callbacks in: [onResend] sends the mail again (the app drives
/// [busy] and [errorText] from the result), [onChangeEmail] returns to the
/// form, [onDone] leaves.
class ForgeCheckEmailScreen extends StatefulWidget {
  const ForgeCheckEmailScreen({
    super.key,
    required this.email,
    required this.purpose,
    required this.onResend,
    this.onChangeEmail,
    this.onDone,
    this.busy = false,
    this.errorText,
    this.resendCooldown = const Duration(seconds: 30),
    this.title,
    this.leading,
  });

  static const resendKey = Key('forge-check-email-resend');
  static const changeEmailKey = Key('forge-check-email-change');
  static const doneKey = Key('forge-check-email-done');

  final String email;
  final ForgeEmailPurpose purpose;
  final VoidCallback onResend;

  /// Null hides "Use a different address".
  final VoidCallback? onChangeEmail;

  /// Null hides Done.
  final VoidCallback? onDone;
  final bool busy;
  final String? errorText;
  final Duration resendCooldown;
  final String? title;
  final Widget? leading;

  @override
  State<ForgeCheckEmailScreen> createState() => _ForgeCheckEmailScreenState();
}

class _ForgeCheckEmailScreenState extends State<ForgeCheckEmailScreen> {
  Timer? _timer;
  late int _secondsLeft;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    _secondsLeft = widget.resendCooldown.inSeconds;
    if (_secondsLeft == 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) t.cancel();
      });
    });
  }

  void _resend() {
    widget.onResend();
    setState(_startCooldown);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final x = context.forge;
    final text = context.text;
    final confirm = widget.purpose == ForgeEmailPurpose.confirm;
    final canResend = !widget.busy && _secondsLeft <= 0;
    return Scaffold(
      appBar: AppBar(
        leading: widget.leading,
        title: Text(widget.title ?? 'Check your email'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          28,
          32,
          28,
          32,
        ).withNavBarInset(context),
        children: [
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: c.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: HeroIcon(
                  HeroIcons.envelopeOpen,
                  size: 28,
                  color: c.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            confirm ? 'One more step' : 'Check your inbox',
            textAlign: TextAlign.center,
            style: ForgeType.ui(
              size: 22,
              weight: FontWeight.w600,
              color: c.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: text.bodyLarge,
              children: [
                TextSpan(
                  text: confirm
                      ? 'We sent a confirmation link to '
                      : 'If there is an account for ',
                ),
                TextSpan(
                  text: widget.email,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  // Reset: Supabase answers success for unknown addresses
                  // on purpose (no account enumeration), so the copy must
                  // not promise a mail that may never come.
                  text: confirm
                      ? '. Open it on this phone and you are in.'
                      : ', a link to set a new password is on its way. '
                            'Open it on this phone to choose a new one.',
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Nothing there? Give it a minute and check the spam folder.',
            textAlign: TextAlign.center,
            style: ForgeType.serif(
              size: 13.5,
              italic: true,
              color: x.textTertiary,
            ),
          ),
          if (widget.errorText != null) ...[
            const SizedBox(height: 18),
            ForgeErrorCard(message: widget.errorText!),
          ],
          const SizedBox(height: 26),
          OutlinedButton(
            key: ForgeCheckEmailScreen.resendKey,
            onPressed: canResend ? _resend : null,
            child: widget.busy
                ? SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: c.onSurfaceVariant,
                    ),
                  )
                : Text(
                    _secondsLeft > 0
                        ? 'Send again in ${_secondsLeft}s'
                        : 'Send again',
                  ),
          ),
          if (widget.onChangeEmail != null) ...[
            const SizedBox(height: 6),
            TextButton(
              key: ForgeCheckEmailScreen.changeEmailKey,
              onPressed: widget.busy ? null : widget.onChangeEmail,
              child: const Text('Use a different address'),
            ),
          ],
          if (widget.onDone != null) ...[
            const SizedBox(height: 18),
            FilledButton(
              key: ForgeCheckEmailScreen.doneKey,
              onPressed: widget.busy ? null : widget.onDone,
              child: const Text('Done'),
            ),
          ],
        ],
      ),
    );
  }
}
