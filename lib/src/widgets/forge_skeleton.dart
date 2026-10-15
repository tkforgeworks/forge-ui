import 'package:flutter/material.dart';

import '../theme/forge_theme.dart';

/// Loading placeholder for a list row: 42 px circle and two text bars,
/// colour shimmering base → highlight over 1.2 s. Colour-only motion.
class ForgeSkeletonRow extends StatefulWidget {
  const ForgeSkeletonRow({super.key});

  @override
  State<ForgeSkeletonRow> createState() => _ForgeSkeletonRowState();
}

class _ForgeSkeletonRowState extends State<ForgeSkeletonRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final x = context.forge;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final color = Color.lerp(
          x.skeletonBase,
          x.skeletonHighlight,
          _controller.value,
        )!;
        Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        );
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bar(160, 12),
                    const SizedBox(height: 8),
                    bar(110, 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The standard loading state: [count] skeleton rows separated by dividers.
class ForgeSkeletonList extends StatelessWidget {
  const ForgeSkeletonList({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const Divider(),
          const ForgeSkeletonRow(),
        ],
      ],
    );
  }
}
