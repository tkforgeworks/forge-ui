import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import '../theme/forge_brand.dart';
import '../theme/forge_tokens.dart';

/// The one gradient button in an app: an extended FAB on the forge gradient,
/// radius 16, with the warm forge shadow. Use it for the app's single main
/// action; the gradient goes on no other button.
class ForgeFab extends StatelessWidget {
  const ForgeFab({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon = HeroIcons.plus,
    this.heroTag,
  });

  final VoidCallback? onPressed;
  final String label;
  final HeroIcons icon;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: ForgeBrand.forgeGradient,
        borderRadius: BorderRadius.circular(ForgeRadii.fab),
        boxShadow: const [ForgeBrand.forgeShadow],
      ),
      // The FAB itself is see-through and flat; the box behind it carries
      // the gradient, which a FAB can't paint natively.
      child: FloatingActionButton.extended(
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        foregroundColor: ForgeBrand.onForge,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        icon: HeroIcon(icon, color: ForgeBrand.onForge, size: 20),
        label: Text(label),
      ),
    );
  }
}
