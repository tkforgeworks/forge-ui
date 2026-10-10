import 'package:flutter/material.dart';

import '../theme/forge_theme.dart';
import '../theme/forge_type.dart';

/// Centred empty state: 56 px icon circle on `primaryContainer`, an 18/600
/// title, a serif-italic aside and an optional action.
/// Voice rule: one plain statement and one dry aside. Never "Oops!".
class ForgeEmptyState extends StatelessWidget {
  const ForgeEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.aside,
    this.action,
  });

  /// Rendered at about 28 px inside the circle; pass a `HeroIcon` or the
  /// app's own glyph.
  final Widget icon;
  final String title;
  final String aside;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: c.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: IconTheme(
                  data: IconThemeData(color: c.onPrimaryContainer, size: 28),
                  child: icon,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: ForgeType.ui(
                size: 18,
                weight: FontWeight.w600,
                color: c.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              aside,
              textAlign: TextAlign.center,
              style: ForgeType.serif(
                size: 13.5,
                italic: true,
                color: context.forge.textTertiary,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}
