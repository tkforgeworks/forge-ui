import 'package:flutter/material.dart';

import '../theme/forge_theme.dart';

/// Field and group label: JetBrains Mono 10/500, uppercase, tracking 1.4,
/// tertiary colour. Uppercases its content itself.
class ForgeMonoLabel extends StatelessWidget {
  const ForgeMonoLabel(
    this.text, {
    super.key,
    this.color,
    this.size,
    this.emphasis = false,
    this.textAlign,
  });

  final String text;
  final Color? color;
  final double? size;

  /// Emphasis = `onPrimaryContainer` colour at weight 600.
  final bool emphasis;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final base = context.text.labelSmall!;
    return Text(
      text.toUpperCase(),
      textAlign: textAlign,
      style: base.copyWith(
        color: color ?? (emphasis ? context.colors.onPrimaryContainer : null),
        fontSize: size,
        fontWeight: emphasis ? FontWeight.w600 : null,
      ),
    );
  }
}
