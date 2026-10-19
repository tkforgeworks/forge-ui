import 'package:flutter/material.dart';

import '../theme/forge_theme.dart';
import '../theme/forge_type.dart';
import 'forge_boxed_field.dart';

/// Destructive or discard confirmation as a bottom sheet (radius 16 top):
/// title, optional serif-italic aside, a neutral `OutlinedButton` and a
/// `FilledButton` coloured `error` when [destructive].
/// Resolves to `true` on confirm, `false` on cancel or dismiss.
///
/// Two optional guards for the irreversible cases (account deletion):
/// [typeToConfirm] keeps the confirm button disabled until the user types
/// that word (case-insensitive unless [caseSensitive]); [onConfirmAsync]
/// runs the action inside the sheet, showing progress and blocking dismissal
/// while it runs, closing with `true` when it returns null and staying open
/// with the returned message as an error line otherwise.
Future<bool> showForgeConfirmSheet(
  BuildContext context, {
  required String title,
  String? aside,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = true,
  String? typeToConfirm,
  bool caseSensitive = false,
  Future<String?> Function()? onConfirmAsync,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: typeToConfirm != null,
    builder: (_) => ForgeConfirmSheet(
      title: title,
      aside: aside,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
      typeToConfirm: typeToConfirm,
      caseSensitive: caseSensitive,
      onConfirmAsync: onConfirmAsync,
    ),
  );
  return result ?? false;
}

/// The content of [showForgeConfirmSheet]. Pops its route with the answer.
class ForgeConfirmSheet extends StatefulWidget {
  const ForgeConfirmSheet({
    super.key,
    required this.title,
    this.aside,
    required this.confirmLabel,
    this.cancelLabel = 'Cancel',
    this.destructive = true,
    this.typeToConfirm,
    this.caseSensitive = false,
    this.onConfirmAsync,
  });

  static const fieldKey = Key('forge-confirm-field');
  static const confirmKey = Key('forge-confirm-confirm');
  static const cancelKey = Key('forge-confirm-cancel');

  final String title;
  final String? aside;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  /// The word the user must type before confirming (shown as the field's
  /// hint). Null means no field.
  final String? typeToConfirm;
  final bool caseSensitive;

  /// Runs on confirm. Null → the sheet pops `true` at once. Otherwise the
  /// sheet shows progress until it completes: a null result pops `true`; a
  /// message is shown under the field and the sheet stays open.
  final Future<String?> Function()? onConfirmAsync;

  @override
  State<ForgeConfirmSheet> createState() => _ForgeConfirmSheetState();
}

class _ForgeConfirmSheetState extends State<ForgeConfirmSheet> {
  final _typed = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  bool get _typedMatches {
    final word = widget.typeToConfirm;
    if (word == null) return true;
    final value = _typed.text.trim();
    return widget.caseSensitive
        ? value == word
        : value.toLowerCase() == word.toLowerCase();
  }

  Future<void> _confirm() async {
    final run = widget.onConfirmAsync;
    if (run == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await run();
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final word = widget.typeToConfirm;
    final canConfirm = !_busy && _typedMatches;
    return PopScope(
      canPop: !_busy,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            24,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: context.text.titleMedium),
              if (widget.aside != null) ...[
                const SizedBox(height: 6),
                Text(
                  widget.aside!,
                  style: ForgeType.serif(
                    size: 13.5,
                    italic: true,
                    color: context.forge.textTertiary,
                  ),
                ),
              ],
              if (word != null) ...[
                const SizedBox(height: 18),
                ForgeBoxedField(
                  key: ForgeConfirmSheet.fieldKey,
                  label: 'Type $word to confirm',
                  hint: word,
                  controller: _typed,
                  enabled: !_busy,
                  autofillHints: const [],
                  textCapitalization: TextCapitalization.characters,
                  errorText: _error,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) {
                    if (canConfirm) _confirm();
                  },
                ),
              ] else if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: context.text.bodySmall?.copyWith(color: c.error),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: ForgeConfirmSheet.cancelKey,
                      onPressed: _busy
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: Text(widget.cancelLabel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: ForgeConfirmSheet.confirmKey,
                      onPressed: canConfirm ? _confirm : null,
                      style: widget.destructive
                          ? FilledButton.styleFrom(
                              backgroundColor: c.error,
                              foregroundColor: c.onError,
                            )
                          : null,
                      child: _busy
                          ? SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: widget.destructive
                                    ? c.onError
                                    : c.onPrimary,
                              ),
                            )
                          : Text(widget.confirmLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
