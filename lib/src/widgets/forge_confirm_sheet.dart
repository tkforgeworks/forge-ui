import 'package:flutter/material.dart';

import '../theme/forge_theme.dart';
import '../theme/forge_type.dart';

/// Destructive or discard confirmation as a bottom sheet (radius 16 top):
/// title, optional serif-italic aside, a neutral `OutlinedButton` and a
/// `FilledButton` coloured `error` when [destructive].
/// Resolves to `true` on confirm, `false` on cancel or dismiss.
Future<bool> showForgeConfirmSheet(
  BuildContext context, {
  required String title,
  String? aside,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = true,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    builder: (_) => ForgeConfirmSheet(
      title: title,
      aside: aside,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
    ),
  );
  return result ?? false;
}

/// The content of [showForgeConfirmSheet]. Pops its route with the answer.
class ForgeConfirmSheet extends StatelessWidget {
  const ForgeConfirmSheet({
    super.key,
    required this.title,
    this.aside,
    required this.confirmLabel,
    this.cancelLabel = 'Cancel',
    this.destructive = true,
  });

  final String title;
  final String? aside;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.text.titleMedium),
            if (aside != null) ...[
              const SizedBox(height: 6),
              Text(
                aside!,
                style: ForgeType.serif(
                  size: 13.5,
                  italic: true,
                  color: context.forge.textTertiary,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(cancelLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: destructive
                        ? FilledButton.styleFrom(
                            backgroundColor: c.error,
                            foregroundColor: c.onError,
                          )
                        : null,
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
