import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import '../theme/forge_provider_brand.dart';
import '../theme/forge_theme.dart';
import '../theme/forge_type.dart';
import 'forge_boxed_field.dart';
import 'forge_confirm_sheet.dart';
import 'forge_error_card.dart';
import 'forge_settings_group.dart';
import 'forge_sign_in_button.dart';
import 'forge_sign_out_sheet.dart';
import 'forge_status_capsule.dart';

/// The shared account page body: signed out, it shows [signedOut] (usually a
/// `ForgeSignInPanel`); signed in, the account's email, the username field,
/// the linked sign-in methods with link / set-password actions, a slot for
/// the app's backup status, sign out and delete.
///
/// Callbacks in, no auth logic. The sign-out and delete rows open the shared
/// sheets themselves: [onSignOut] receives the "also erase this phone"
/// choice, and [onDeleteAccount] runs inside the typed confirmation sheet
/// (return null on success, a message to keep the sheet open). The app's own
/// profile header (avatar, member-since line) goes above this widget.
class ForgeAccountSettings extends StatefulWidget {
  const ForgeAccountSettings({
    super.key,
    this.email,
    this.username,
    this.onUsernameChanged,
    this.linked = const [],
    this.onLink,
    this.onSetPassword,
    this.status,
    this.statusLabel = 'Backup',
    required this.onSignOut,
    this.onDeleteAccount,
    this.signedOut,
    this.busy = false,
    this.errorText,
    this.offerLocalErase = true,
    this.signOutAside,
    this.eraseAside,
    this.deleteTitle = 'Delete your account?',
    this.deleteAside =
        'Everything in the account is removed. '
        'Your data on this phone stays unless you erase it too.',
    this.deleteConfirmLabel = 'Delete account',
    this.deleteWord = 'DELETE',
  });

  static const usernameFieldKey = Key('forge-account-username');
  static const linkGoogleKey = Key('forge-account-link-google');
  static const setPasswordKey = Key('forge-account-set-password');
  static const signOutKey = Key('forge-account-sign-out');
  static const deleteKey = Key('forge-account-delete');

  /// The account's primary email. Null means signed out.
  final String? email;

  /// Null until the user sets one.
  final String? username;

  /// Saved on Done / blur with the trimmed value (null when cleared). Null
  /// hides the field.
  final ValueChanged<String?>? onUsernameChanged;

  final List<ForgeLinkedSignIn> linked;

  /// Offers "Link Google" when Google is not yet linked. Null hides it.
  final void Function(ForgeSignInProvider provider)? onLink;

  /// Offers "Set a password" when there is no email/password method. Null
  /// hides it.
  final VoidCallback? onSetPassword;

  /// The app's sync status row, drawn in its own group under [statusLabel].
  final Widget? status;
  final String statusLabel;

  /// Runs after the sign-out sheet; [eraseLocal] is the user's choice.
  final Future<void> Function({required bool eraseLocal}) onSignOut;

  /// Runs inside the typed confirmation sheet. Null hides the row.
  final Future<String?> Function()? onDeleteAccount;

  /// What to show when [email] is null.
  final Widget? signedOut;

  /// Disables every action while the app talks to the backend.
  final bool busy;

  /// A form-level error from the last action.
  final String? errorText;

  final bool offerLocalErase;
  final String? signOutAside;
  final String? eraseAside;
  final String deleteTitle;
  final String deleteAside;
  final String deleteConfirmLabel;
  final String deleteWord;

  @override
  State<ForgeAccountSettings> createState() => _ForgeAccountSettingsState();
}

class _ForgeAccountSettingsState extends State<ForgeAccountSettings> {
  late final _username = TextEditingController(text: widget.username ?? '');
  final _usernameFocus = FocusNode();

  /// What was last handed to `onUsernameChanged`, so Done followed by the
  /// focus loss (or two blurs) saves once. Null until the first save.
  String? _lastSaved;

  @override
  void initState() {
    super.initState();
    _usernameFocus.addListener(() {
      if (!_usernameFocus.hasFocus) _saveUsername();
    });
  }

  @override
  void didUpdateWidget(ForgeAccountSettings old) {
    super.didUpdateWidget(old);
    if (old.username != widget.username) {
      _lastSaved = null;
      if (!_usernameFocus.hasFocus) _username.text = widget.username ?? '';
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  void _saveUsername() {
    final save = widget.onUsernameChanged;
    if (save == null) return;
    final value = _username.text.trim();
    final current = _lastSaved ?? widget.username ?? '';
    if (value == current) return;
    _lastSaved = value;
    save(value.isEmpty ? null : value);
  }

  Future<void> _signOut() async {
    final choice = await showForgeSignOutSheet(
      context,
      aside:
          widget.signOutAside ??
          (widget.offerLocalErase
              ? 'Your data stays on this phone unless you say otherwise.'
              : null),
      offerErase: widget.offerLocalErase,
      eraseAside:
          widget.eraseAside ??
          'Everything local goes; the account keeps its copy.',
    );
    if (choice == null) return;
    await widget.onSignOut(eraseLocal: choice.eraseLocal);
  }

  Future<void> _delete() => showForgeConfirmSheet(
    context,
    title: widget.deleteTitle,
    aside: widget.deleteAside,
    confirmLabel: widget.deleteConfirmLabel,
    typeToConfirm: widget.deleteWord,
    onConfirmAsync: widget.onDeleteAccount,
  );

  bool get _hasGoogle =>
      widget.linked.any((l) => l.provider == ForgeSignInProvider.google);
  bool get _hasEmail =>
      widget.linked.any((l) => l.provider == ForgeSignInProvider.email);

  @override
  Widget build(BuildContext context) {
    final email = widget.email;
    if (email == null) return widget.signedOut ?? const SizedBox.shrink();
    final c = context.colors;
    final x = context.forge;
    final enabled = !widget.busy;
    final chevron = HeroIcon(
      HeroIcons.chevronRight,
      size: 18,
      color: x.textTertiary,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ForgeSettingsGroup(
          label: 'Account',
          children: [
            ListTile(
              leading: HeroIcon(HeroIcons.userCircle, color: x.textTertiary),
              title: Text(email),
              subtitle: const Text('Signed in'),
            ),
            if (widget.onUsernameChanged != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: ForgeBoxedField(
                  key: ForgeAccountSettings.usernameFieldKey,
                  label: 'Username',
                  hint: 'Pick a name for your account',
                  controller: _username,
                  focusNode: _usernameFocus,
                  enabled: enabled,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (_) => _saveUsername(),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        ForgeSettingsGroup(
          label: 'Sign-in methods',
          children: [
            for (final method in widget.linked)
              ListTile(
                leading: _ProviderIcon(method.provider),
                title: Text(method.provider.label),
                subtitle: method.email == null ? null : Text(method.email!),
                trailing: const ForgeStatusCapsule('Connected', active: true),
              ),
            if (widget.onLink != null && !_hasGoogle)
              ListTile(
                key: ForgeAccountSettings.linkGoogleKey,
                leading: const _ProviderIcon(ForgeSignInProvider.google),
                title: const Text('Link Google'),
                subtitle: const Text('Sign in with either from now on'),
                trailing: chevron,
                enabled: enabled,
                onTap: enabled
                    ? () => widget.onLink!(ForgeSignInProvider.google)
                    : null,
              ),
            if (widget.onSetPassword != null && !_hasEmail)
              ListTile(
                key: ForgeAccountSettings.setPasswordKey,
                leading: const _ProviderIcon(ForgeSignInProvider.email),
                title: const Text('Set a password'),
                subtitle: Text('Sign in with $email and a password too'),
                trailing: chevron,
                enabled: enabled,
                onTap: enabled ? widget.onSetPassword : null,
              ),
          ],
        ),
        if (widget.status != null) ...[
          const SizedBox(height: 20),
          ForgeSettingsGroup(
            label: widget.statusLabel,
            children: [widget.status!],
          ),
        ],
        if (widget.errorText != null) ...[
          const SizedBox(height: 20),
          ForgeErrorCard(message: widget.errorText!),
        ],
        const SizedBox(height: 20),
        ForgeSettingsGroup(
          children: [
            ListTile(
              key: ForgeAccountSettings.signOutKey,
              leading: HeroIcon(
                HeroIcons.arrowRightStartOnRectangle,
                color: x.textTertiary,
              ),
              title: const Text('Sign out'),
              enabled: enabled,
              onTap: enabled ? _signOut : null,
            ),
            if (widget.onDeleteAccount != null)
              ListTile(
                key: ForgeAccountSettings.deleteKey,
                leading: HeroIcon(HeroIcons.trash, color: c.error),
                title: Text('Delete account', style: TextStyle(color: c.error)),
                enabled: enabled,
                onTap: enabled ? _delete : null,
              ),
          ],
        ),
      ],
    );
  }
}

/// A provider's mark at list-tile size: Google's official "G", an envelope
/// for email.
class _ProviderIcon extends StatelessWidget {
  const _ProviderIcon(this.provider);

  final ForgeSignInProvider provider;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 24,
    child: switch (provider) {
      ForgeSignInProvider.google => Image(
        image: const AssetImage(
          ForgeProviderBrand.googleLogoAsset,
          package: ForgeType.package,
        ),
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
      ForgeSignInProvider.email => HeroIcon(
        HeroIcons.envelope,
        color: context.forge.textTertiary,
      ),
      ForgeSignInProvider.apple => HeroIcon(
        HeroIcons.devicePhoneMobile,
        color: context.forge.textTertiary,
      ),
    },
  );
}
