import 'package:flutter/material.dart';

import '../theme/forge_theme.dart';
import 'forge_mono_label.dart';

/// Mono group label over a bordered card whose rows are divider-separated.
/// The rows are usually `ListTile`s. Used by settings, account and about
/// pages.
class ForgeSettingsGroup extends StatelessWidget {
  const ForgeSettingsGroup({super.key, this.label, required this.children});

  /// Null leaves the label out and shows the card alone.
  final String? label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label != null)
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: ForgeMonoLabel(label!),
        ),
      Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (final (i, child) in children.indexed) ...[
              if (i > 0) Divider(height: 1, color: context.forge.rowDivider),
              child,
            ],
          ],
        ),
      ),
    ],
  );
}
