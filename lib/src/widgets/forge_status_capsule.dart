import 'package:flutter/material.dart';

import '../theme/forge_theme.dart';

/// What a [ForgeStatusCapsule] reports.
enum ForgeStatusTone {
  /// Neutral fill with tertiary text.
  neutral,

  /// The success pair ("CONNECTED").
  success,

  /// The warning container pair.
  warning,

  /// The info container pair.
  info,
}

/// Pill-shaped status capsule. [tone] picks the colour pair; the default is
/// neutral. [active] is the older spelling of `tone: ForgeStatusTone.success`
/// and is kept for existing callers; prefer [tone] in new code.
class ForgeStatusCapsule extends StatelessWidget {
  const ForgeStatusCapsule(
    this.text, {
    super.key,
    this.active = false,
    this.tone = ForgeStatusTone.neutral,
  });

  final String text;
  final bool active;
  final ForgeStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final x = context.forge;
    final effective = active && tone == ForgeStatusTone.neutral
        ? ForgeStatusTone.success
        : tone;
    final (fill, text0) = switch (effective) {
      ForgeStatusTone.success => (x.successContainer, x.onSuccessContainer),
      ForgeStatusTone.warning => (x.warningContainer, x.onWarningContainer),
      ForgeStatusTone.info => (x.infoContainer, x.onInfoContainer),
      ForgeStatusTone.neutral => (
        context.colors.surfaceContainer,
        x.textTertiary,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text.toUpperCase(),
        style: context.text.labelMedium!.copyWith(color: text0),
      ),
    );
  }
}
