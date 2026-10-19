import 'package:flutter/material.dart';

import '../theme/forge_theme.dart';
import '../theme/forge_type.dart';

/// What the user chose on the sign-out sheet.
class ForgeSignOutChoice {
  const ForgeSignOutChoice({required this.eraseLocal});

  /// Also wipe this device's copy of the account's data.
  final bool eraseLocal;

  @override
  bool operator ==(Object other) =>
      other is ForgeSignOutChoice && other.eraseLocal == eraseLocal;

  @override
  int get hashCode => eraseLocal.hashCode;
}

/// The sign-out confirmation: a plain sheet with, by default, an "Also erase
/// this phone" checkbox, since local-first apps keep the data on the device
/// unless told otherwise. Resolves to the choice, or null on cancel.
Future<ForgeSignOutChoice?> showForgeSignOutSheet(
  BuildContext context, {
  String title = 'Sign out?',
  String? aside = 'Your data stays on this phone unless you say otherwise.',
  String confirmLabel = 'Sign out',
  String cancelLabel = 'Cancel',
  bool offerErase = true,
  String eraseLabel = 'Also erase this phone',
  String? eraseAside = 'Everything local goes; the account keeps its copy.',
}) => showModalBottomSheet<ForgeSignOutChoice>(
  context: context,
  builder: (_) => ForgeSignOutSheet(
    title: title,
    aside: aside,
    confirmLabel: confirmLabel,
    cancelLabel: cancelLabel,
    offerErase: offerErase,
    eraseLabel: eraseLabel,
    eraseAside: eraseAside,
  ),
);

/// The content of [showForgeSignOutSheet]. Pops with the choice.
class ForgeSignOutSheet extends StatefulWidget {
  const ForgeSignOutSheet({
    super.key,
    this.title = 'Sign out?',
    this.aside,
    this.confirmLabel = 'Sign out',
    this.cancelLabel = 'Cancel',
    this.offerErase = true,
    this.eraseLabel = 'Also erase this phone',
    this.eraseAside,
  });

  static const eraseKey = Key('forge-sign-out-erase');
  static const confirmKey = Key('forge-sign-out-confirm');
  static const cancelKey = Key('forge-sign-out-cancel');

  final String title;
  final String? aside;
  final String confirmLabel;
  final String cancelLabel;
  final bool offerErase;
  final String eraseLabel;
  final String? eraseAside;

  @override
  State<ForgeSignOutSheet> createState() => _ForgeSignOutSheetState();
}

class _ForgeSignOutSheetState extends State<ForgeSignOutSheet> {
  var _erase = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final x = context.forge;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
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
                  color: x.textTertiary,
                ),
              ),
            ],
            if (widget.offerErase) ...[
              const SizedBox(height: 12),
              CheckboxListTile(
                key: ForgeSignOutSheet.eraseKey,
                value: _erase,
                onChanged: (v) => setState(() => _erase = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(widget.eraseLabel),
                subtitle: widget.eraseAside == null
                    ? null
                    : Text(widget.eraseAside!, style: context.text.bodySmall),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: ForgeSignOutSheet.cancelKey,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(widget.cancelLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: ForgeSignOutSheet.confirmKey,
                    onPressed: () =>
                        Navigator.of(context)
                            .pop(ForgeSignOutChoice(eraseLocal: _erase)),
                    style: _erase
                        ? FilledButton.styleFrom(
                            backgroundColor: c.error,
                            foregroundColor: c.onError,
                          )
                        : null,
                    child: Text(
                      _erase
                          ? '${widget.confirmLabel} and erase'
                          : widget.confirmLabel,
                    ),
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
