import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import '../theme/forge_theme.dart';
import '../theme/forge_type.dart';
import '../widgets/forge_mono_label.dart';
import '../widgets/forge_settings_group.dart';
import '../widgets/forge_works_mark.dart';
import '../widgets/nav_bar_inset.dart';

/// The about screen every tkforgeworks app shares: the app's badge, name and
/// version, one paragraph in the app's voice, the maker line with the
/// TK ForgeWorks mark, a card of links and a closing line.
///
/// The screen opens nothing itself. Each link is a callback the app wires to
/// its own URL launcher or router, and a null callback leaves that row out.
/// The privacy policy link is required: both stores expect it in the app.
class ForgeAboutScreen extends StatelessWidget {
  const ForgeAboutScreen({
    super.key,
    required this.appName,
    required this.onOpenPrivacyPolicy,
    this.title,
    this.leading,
    this.badge,
    this.version,
    this.blurb,
    this.onSendFeedback,
    this.onOpenWebsite,
    this.onOpenDeleteAccount,
    this.onOpenLicenses,
    this.footnote,
    this.tintMark = false,
  });

  static const feedbackKey = Key('forge-about-feedback');
  static const websiteKey = Key('forge-about-website');
  static const privacyKey = Key('forge-about-privacy');
  static const deleteAccountKey = Key('forge-about-delete-account');
  static const licensesKey = Key('forge-about-licenses');

  /// The line beside the mark. The same in every app.
  static const makerLine = 'A TK ForgeWorks product';

  final String appName;

  /// App bar title. Defaults to "About [appName]".
  final String? title;

  /// App bar leading widget, for an app whose about screen sits in a drawer
  /// shell. Null gives the usual back button when there is a route to pop.
  final Widget? leading;

  /// The app's logo, shown at the top (64 px in the cheese app).
  final Widget? badge;

  /// For example "0.1.0". Null shows a dash while it loads.
  final String? version;

  /// One paragraph about the app, in the app's voice.
  final String? blurb;

  /// Opens the app's own feedback screen. Leave null to hide the row.
  final VoidCallback? onSendFeedback;

  /// Opens tkforgeworks.com.
  final VoidCallback? onOpenWebsite;

  /// Opens the app's privacy policy page.
  final VoidCallback onOpenPrivacyPolicy;

  /// Opens the app's account deletion page. Leave null in an app that has
  /// no accounts.
  final VoidCallback? onOpenDeleteAccount;

  /// Opens the licences summary (see `ForgeLicensesScreen`).
  final VoidCallback? onOpenLicenses;

  /// A closing line under the links, such as a one-sentence privacy promise.
  final String? footnote;

  /// Paints the TK ForgeWorks mark in the tertiary text colour instead of
  /// its brand gradients, for an app whose palette they would clash with.
  final bool tintMark;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final x = context.forge;
    Widget link(
      Key key,
      String label,
      VoidCallback onTap, {
      bool external = true,
    }) => ListTile(
      key: key,
      title: Text(label),
      trailing: HeroIcon(
        external ? HeroIcons.arrowTopRightOnSquare : HeroIcons.chevronRight,
        size: 18,
        color: x.textTertiary,
      ),
      onTap: onTap,
    );
    return Scaffold(
      appBar: AppBar(leading: leading, title: Text(title ?? 'About $appName')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          28,
          24,
          28,
          40,
        ).withNavBarInset(context),
        children: [
          if (badge != null) ...[
            Center(child: badge),
            const SizedBox(height: 16),
          ],
          Text(
            appName,
            textAlign: TextAlign.center,
            style: ForgeType.ui(
              size: 30,
              weight: FontWeight.w700,
              color: c.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          ForgeMonoLabel(
            version == null ? 'Version —' : 'Version $version',
            textAlign: TextAlign.center,
          ),
          if (blurb != null) ...[
            const SizedBox(height: 22),
            Text(blurb!, style: context.text.bodyLarge),
          ],
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ForgeWorksMark(size: 18, color: tintMark ? x.textTertiary : null),
              const SizedBox(width: 8),
              ForgeMonoLabel(makerLine, size: 9.5, color: x.textTertiary),
            ],
          ),
          const SizedBox(height: 22),
          ForgeSettingsGroup(
            children: [
              if (onSendFeedback != null)
                link(
                  feedbackKey,
                  'Send feedback',
                  onSendFeedback!,
                  external: false,
                ),
              if (onOpenWebsite != null)
                link(websiteKey, 'tkforgeworks.com', onOpenWebsite!),
              link(privacyKey, 'Privacy policy', onOpenPrivacyPolicy),
              if (onOpenDeleteAccount != null)
                link(
                  deleteAccountKey,
                  'Delete your account',
                  onOpenDeleteAccount!,
                ),
              if (onOpenLicenses != null)
                link(
                  licensesKey,
                  'Open-source licenses',
                  onOpenLicenses!,
                  external: false,
                ),
            ],
          ),
          if (footnote != null) ...[
            const SizedBox(height: 22),
            Text(
              footnote!,
              textAlign: TextAlign.center,
              style: ForgeType.serif(
                size: 13.5,
                italic: true,
                color: x.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
