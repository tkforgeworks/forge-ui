import 'package:flutter/material.dart';

import '../theme/forge_theme.dart';
import '../theme/forge_tokens.dart';

enum ForgeCapsuleTone { neutral, emphasis }

/// Mono tag capsule: radius 4, JetBrains Mono 9.5 uppercase, padding
/// 4.5 × 8.5. Neutral for plain information, emphasis for the tags that
/// matter most.
class ForgeTagCapsule extends StatelessWidget {
  const ForgeTagCapsule(
    this.text, {
    super.key,
    this.tone = ForgeCapsuleTone.neutral,
  });

  final String text;
  final ForgeCapsuleTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final emphasis = tone == ForgeCapsuleTone.emphasis;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.5, vertical: 4.5),
      decoration: BoxDecoration(
        color: emphasis ? c.primaryContainer : c.surfaceContainer,
        borderRadius: BorderRadius.circular(ForgeRadii.tag),
      ),
      child: Text(
        text.toUpperCase(),
        style: context.text.labelMedium!.copyWith(
          color: emphasis ? c.onPrimaryContainer : c.onSecondaryContainer,
        ),
      ),
    );
  }
}
