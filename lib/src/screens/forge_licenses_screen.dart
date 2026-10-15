import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import '../theme/forge_theme.dart';
import '../theme/forge_type.dart';
import '../widgets/forge_settings_group.dart';
import '../widgets/nav_bar_inset.dart';

/// A short summary of what the app is licensed under and what it is built
/// with, in place of dropping people straight into Flutter's generated list.
/// That list stays one tap away ("View all notices"), because the engine and
/// packages compiled into the app require their notices to ship with it.
///
/// Call `registerForgeFontLicenses()` at startup so the full list includes
/// the bundled fonts.
class ForgeLicensesScreen extends StatelessWidget {
  const ForgeLicensesScreen({
    super.key,
    required this.appName,
    required this.licenseName,
    this.version,
    this.leading,
    this.intro,
    this.sourceLabel,
    this.onOpenSource,
    this.footnote,
  });

  static const sourceKey = Key('forge-licenses-source');
  static const allNoticesKey = Key('forge-licenses-all');

  /// The "Fonts" row. The same in every app, since the fonts are the brand's.
  static const fontsLine =
      'Poppins, Source Serif 4 and JetBrains Mono: '
      'SIL Open Font License 1.1';

  final String appName;

  /// What the app itself is licensed under, for example "Apache License 2.0"
  /// or "All rights reserved".
  final String licenseName;

  /// Passed to the full notices page.
  final String? version;

  /// App bar leading widget. Null gives the usual back button.
  final Widget? leading;

  /// The opening paragraph. Null uses a plain default.
  final String? intro;

  /// Where the source lives, for example
  /// "github.com/tkforgeworks/cheesy-scribe". Null leaves the row out.
  final String? sourceLabel;

  /// Opens the source repository.
  final VoidCallback? onOpenSource;

  /// A closing line, such as which assets are all rights reserved.
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final x = context.forge;
    return Scaffold(
      appBar: AppBar(
        leading: leading,
        title: const Text('Open-source licenses'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          32,
        ).withNavBarInset(context),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 22),
            child: Text(
              intro ??
                  "$appName is built on other people's open-source work. "
                      'Here is the short version; every notice is one tap '
                      'further down.',
              style: context.text.bodyLarge,
            ),
          ),
          ForgeSettingsGroup(
            label: 'This app',
            children: [
              ListTile(title: Text(appName), subtitle: Text(licenseName)),
              if (sourceLabel != null)
                ListTile(
                  key: sourceKey,
                  title: const Text('Source code'),
                  subtitle: Text(sourceLabel!),
                  trailing: onOpenSource == null
                      ? null
                      : HeroIcon(
                          HeroIcons.arrowTopRightOnSquare,
                          size: 18,
                          color: x.textTertiary,
                        ),
                  onTap: onOpenSource,
                ),
            ],
          ),
          const SizedBox(height: 18),
          const ForgeSettingsGroup(
            label: 'Built with',
            children: [
              ListTile(
                title: Text('Flutter and Dart packages'),
                subtitle: Text('BSD, MIT, Apache 2.0 and similar licences'),
              ),
              ListTile(title: Text('Fonts'), subtitle: Text(fontsLine)),
            ],
          ),
          const SizedBox(height: 18),
          ForgeSettingsGroup(
            label: 'Full text',
            children: [
              ListTile(
                key: allNoticesKey,
                title: const Text('View all notices'),
                subtitle: const Text('Every licence that ships with the app'),
                trailing: HeroIcon(
                  HeroIcons.chevronRight,
                  size: 18,
                  color: x.textTertiary,
                ),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: appName,
                  applicationVersion: version,
                ),
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
