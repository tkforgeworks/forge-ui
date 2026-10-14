import 'package:flutter/material.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:heroicons/heroicons.dart';

import 'samples.dart';

/// Every `forge_ui` component on one scrolling page, under the selected
/// sample palette. The drawer picks the palette.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({
    super.key,
    required this.sample,
    required this.sampleIndex,
    required this.onSampleChanged,
    required this.dark,
    required this.onToggleBrightness,
  });

  final ShowcaseSample sample;
  final int sampleIndex;
  final ValueChanged<int> onSampleChanged;
  final bool dark;
  final VoidCallback onToggleBrightness;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final _filters = {'Recent'};
  var _view = 'List';
  var _notifications = true;
  var _volume = 0.6;

  void _say(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirm({required bool destructive}) async {
    final confirmed = await showForgeConfirmSheet(
      context,
      title: destructive ? 'Delete your account?' : 'Sign out?',
      aside: destructive ? 'Everything goes with it. Just saying.' : null,
      confirmLabel: destructive ? 'Delete' : 'Sign out',
      destructive: destructive,
    );
    if (mounted) _say(confirmed ? 'Confirmed.' : 'Cancelled.');
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  Widget _about() => ForgeAboutScreen(
    appName: 'Showcase',
    version: '0.1.0',
    badge: const _SampleBadge(),
    blurb:
        'I show every shared component in one place, so nobody has to '
        'guess what a button looks like in dark mode. Pick a palette, flip '
        'the lights, and check your work against mine.',
    footnote: 'Nothing here leaves this device.',
    tintMark: widget.sample.tintMark,
    onSendFeedback: () => _say('Would open the feedback screen.'),
    onOpenWebsite: () => _say('Would open tkforgeworks.com.'),
    onOpenPrivacyPolicy: () => _say('Would open the privacy policy.'),
    onOpenDeleteAccount: () => _say('Would open the deletion page.'),
    onOpenLicenses: () => _open(_licenses()),
  );

  Widget _licenses() => ForgeLicensesScreen(
    appName: 'Showcase',
    licenseName: 'Apache License 2.0',
    version: '0.1.0',
    sourceLabel: 'github.com/tkforgeworks/forge-ui',
    onOpenSource: () => _say('Would open the repository.'),
    footnote: 'The TK ForgeWorks mark is all rights reserved.',
  );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final x = context.forge;
    final text = context.text;
    return Scaffold(
      appBar: AppBar(
        title: const Text('forge_ui showcase'),
        actions: [
          IconButton(
            tooltip: widget.dark ? 'Switch to light' : 'Switch to dark',
            onPressed: widget.onToggleBrightness,
            icon: HeroIcon(widget.dark ? HeroIcons.sun : HeroIcons.moon),
          ),
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: widget.sampleIndex,
        onDestinationSelected: (i) {
          Navigator.of(context).pop();
          widget.onSampleChanged(i);
        },
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 24, 28, 12),
            child: ForgeMonoLabel('Palette'),
          ),
          for (final sample in samples)
            NavigationDrawerDestination(
              icon: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: sample.seed,
                  shape: BoxShape.circle,
                ),
              ),
              label: Text(sample.name),
            ),
        ],
      ),
      floatingActionButton: ForgeFab(
        label: 'New entry',
        onPressed: () => _say('The one gradient button.'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 96,
        ).withNavBarInset(context),
        children: [
          _Section(
            'Palette',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.sample.name, style: text.titleLarge),
                const SizedBox(height: 2),
                Text(
                  widget.sample.designed
                      ? 'A designed scheme and tokens, passed to forgeTheme.'
                      : 'Generated from one seed colour.',
                  style: ForgeType.serif(
                    size: 13.5,
                    italic: true,
                    color: x.textTertiary,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Swatch('primary', c.primary),
                    _Swatch('primary\ncontainer', c.primaryContainer),
                    _Swatch('surface', c.surface),
                    _Swatch('card', c.surfaceContainerLowest),
                    _Swatch('field', c.surfaceContainer),
                    _Swatch('outline', c.outline),
                    _Swatch('error', c.error),
                    _Swatch('accent', x.accent),
                    _Swatch('link', x.link),
                    _Swatch('tertiary\ntext', x.textTertiary),
                    _Swatch('ghost\ntext', x.textGhost),
                    _Swatch('success', x.successContainer),
                  ],
                ),
              ],
            ),
          ),
          _Section(
            'Brand',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const ForgeWorksMark(size: 48),
                    const SizedBox(width: 16),
                    ForgeWorksMark(size: 48, color: x.textTertiary),
                    const SizedBox(width: 16),
                    const _SampleBadge(size: 48),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(ForgeRadii.card),
                  child: const SizedBox(
                    height: 4,
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: ForgeBrand.forgeStrip,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _Section(
            'Type',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Display small, serif 27', style: text.displaySmall),
                Text('Headline small, serif 21', style: text.headlineSmall),
                const SizedBox(height: 6),
                Text('Title large, 22', style: text.titleLarge),
                Text('Title medium, 18', style: text.titleMedium),
                Text('Title small, 15', style: text.titleSmall),
                const SizedBox(height: 6),
                Text(
                  'Body large is prose, set in the serif at 14.5 with room '
                  'between the lines, for text people actually read.',
                  style: text.bodyLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Body medium, the UI default at 14',
                  style: text.bodyMedium,
                ),
                Text('Body small, row meta at 11.5', style: text.bodySmall),
                const SizedBox(height: 8),
                Text(
                  'A serif italic aside, for hints and dry remarks.',
                  style: ForgeType.serif(
                    size: 13.5,
                    italic: true,
                    color: x.textTertiary,
                  ),
                ),
                const SizedBox(height: 8),
                const ForgeMonoLabel('Mono label'),
                const SizedBox(height: 4),
                const ForgeMonoLabel('Mono label, emphasis', emphasis: true),
              ],
            ),
          ),
          _Section(
            'Buttons',
            child: Column(
              children: [
                FilledButton(
                  onPressed: () => _say('Filled.'),
                  child: const Text('Save changes'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _say('Outlined.'),
                        child: const Text('Google'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _say('Outlined.'),
                        child: const Text('Apple'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const FilledButton(onPressed: null, child: Text('Disabled')),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _say('Text.'),
                    child: const Text('Forgot password?'),
                  ),
                ),
              ],
            ),
          ),
          const _Section(
            'Fields',
            child: Column(
              children: [
                ForgeBoxedField(
                  label: 'Display name',
                  hint: 'What to call you',
                ),
                SizedBox(height: 14),
                ForgeBoxedField(
                  label: 'Email',
                  hint: 'you@example.com',
                  errorText: 'That is not an email address.',
                ),
                SizedBox(height: 14),
                SearchBar(hintText: 'Search'),
              ],
            ),
          ),
          _Section(
            'Selection',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    for (final label in ['Recent', 'Starred', 'Shared'])
                      FilterChip(
                        label: Text(label),
                        selected: _filters.contains(label),
                        onSelected: (on) => setState(
                          () =>
                              on ? _filters.add(label) : _filters.remove(label),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 'List', label: Text('List')),
                    ButtonSegment(value: 'Grid', label: Text('Grid')),
                  ],
                  selected: {_view},
                  onSelectionChanged: (s) => setState(() => _view = s.first),
                ),
                const SizedBox(height: 4),
                Slider(
                  value: _volume,
                  onChanged: (v) => setState(() => _volume = v),
                ),
              ],
            ),
          ),
          _Section(
            'Main action',
            // Room underneath for the forge shadow.
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ForgeFab(
                  heroTag: 'gallery-inline-fab',
                  label: 'New entry',
                  onPressed: () => _say('The one gradient button.'),
                ),
              ),
            ),
          ),
          const _Section(
            'Capsules',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ForgeTagCapsule('Neutral'),
                ForgeTagCapsule('Emphasis', tone: ForgeCapsuleTone.emphasis),
                ForgeStatusCapsule('Connected', active: true),
                ForgeStatusCapsule('Not connected'),
              ],
            ),
          ),
          _Section(
            'Settings group',
            child: ForgeSettingsGroup(
              label: 'Account',
              children: [
                ListTile(
                  title: const Text('Google'),
                  subtitle: const Text('you@example.com'),
                  trailing: const ForgeStatusCapsule('Connected', active: true),
                  onTap: () => _say('Row.'),
                ),
                SwitchListTile(
                  title: const Text('Notifications'),
                  subtitle: const Text('Only the ones that matter'),
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
                ListTile(
                  title: const Text('About'),
                  trailing: HeroIcon(
                    HeroIcons.chevronRight,
                    size: 18,
                    color: x.textTertiary,
                  ),
                  onTap: () => _open(_about()),
                ),
              ],
            ),
          ),
          _Section(
            'Empty state',
            child: Card(
              child: ForgeEmptyState(
                icon: const HeroIcon(HeroIcons.documentText),
                title: 'Nothing here yet',
                aside: "It isn't going to write itself.",
                action: FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                  onPressed: () => _say('Action.'),
                  child: const Text('Start one'),
                ),
              ),
            ),
          ),
          _Section(
            'Error',
            child: ForgeErrorCard(
              message: "Couldn't reach the server.",
              onRetry: () => _say('Retrying.'),
            ),
          ),
          const _Section('Loading', child: ForgeSkeletonList()),
          _Section(
            'Confirm sheet',
            child: Column(
              children: [
                Material(
                  color: c.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ForgeRadii.fab),
                    side: BorderSide(color: c.outline),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: IgnorePointer(
                    child: const ForgeConfirmSheet(
                      title: 'Delete your account?',
                      aside: 'Everything goes with it. Just saying.',
                      confirmLabel: 'Delete',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _confirm(destructive: true),
                        child: const Text('Open destructive'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _confirm(destructive: false),
                        child: const Text('Open plain'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _Section(
            'Screens',
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _open(_about()),
                    child: const Text('About'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _open(_licenses()),
                    child: const Text('Licences'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The gallery's sections, top to bottom. The golden tests photograph each
/// one for the README, so a section added here needs a heading there.
const gallerySections = [
  'Palette',
  'Brand',
  'Type',
  'Buttons',
  'Fields',
  'Selection',
  'Main action',
  'Capsules',
  'Settings group',
  'Empty state',
  'Error',
  'Loading',
  'Confirm sheet',
  'Screens',
];

/// The key on a section's repaint boundary, for tests that photograph it.
Key gallerySectionKey(String title) => ValueKey('gallery-section-$title');

/// A gallery block: mono heading, then the component. Each block paints its
/// own background inside a repaint boundary, so it can be captured alone.
class _Section extends StatelessWidget {
  const _Section(this.title, {required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    key: gallerySectionKey(title),
    child: ColoredBox(
      color: context.colors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ForgeMonoLabel(title, emphasis: true),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    ),
  );
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 62,
    child: Column(
      children: [
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(ForgeRadii.card),
            border: Border.all(color: context.colors.outline),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: context.text.labelMedium!.copyWith(fontSize: 8),
        ),
      ],
    ),
  );
}

/// Stands in for an app's logo badge: the forge gradient circle every
/// tkforgeworks app puts its own glyph on.
class _SampleBadge extends StatelessWidget {
  const _SampleBadge({this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: ForgeBrand.forgeGradient,
    ),
    child: Center(
      child: HeroIcon(
        HeroIcons.sparkles,
        size: size * 0.5,
        color: ForgeBrand.onForge,
      ),
    ),
  );
}
