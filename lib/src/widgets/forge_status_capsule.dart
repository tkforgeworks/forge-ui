import 'package:flutter/material.dart';

import '../theme/forge_theme.dart';

/// Pill-shaped status capsule: [active] uses the success pair ("CONNECTED"),
/// anything else the neutral fill with tertiary text.
class ForgeStatusCapsule extends StatelessWidget {
  const ForgeStatusCapsule(this.text, {super.key, this.active = false});

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final x = context.forge;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
      decoration: BoxDecoration(
        color: active ? x.successContainer : context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text.toUpperCase(),
        style: context.text.labelMedium!.copyWith(
          color: active ? x.onSuccessContainer : x.textTertiary,
        ),
      ),
    );
  }
}
