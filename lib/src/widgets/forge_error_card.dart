import 'package:flutter/material.dart';

import '../theme/forge_theme.dart';
import '../theme/forge_tokens.dart';

/// Inline error card (not a toast): error-tint background, one plain
/// statement and an optional Retry text button.
class ForgeErrorCard extends StatelessWidget {
  const ForgeErrorCard({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  final String message;

  /// Null hides the retry button.
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: context.forge.errorTint,
        borderRadius: BorderRadius.circular(ForgeRadii.card),
      ),
      child: Row(
        children: [
          Expanded(child: Text(message, style: context.text.bodyMedium)),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(foregroundColor: c.error),
              child: Text(retryLabel),
            ),
        ],
      ),
    );
  }
}
