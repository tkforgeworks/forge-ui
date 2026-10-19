import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_ui/forge_ui.dart';

import 'support.dart';

void main() {
  /// Pumps an app with an "open" button, taps it and settles. The returned
  /// getter reads the sheet's answer once it has closed.
  Future<bool? Function()> open(
    WidgetTester tester, {
    String? typeToConfirm,
    bool caseSensitive = false,
    Future<String?> Function()? onConfirmAsync,
  }) async {
    bool? result;
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => FilledButton(
            onPressed: () async {
              result = await showForgeConfirmSheet(
                context,
                title: 'Delete your account?',
                aside: 'Everything goes with it.',
                confirmLabel: 'Delete',
                typeToConfirm: typeToConfirm,
                caseSensitive: caseSensitive,
                onConfirmAsync: onConfirmAsync,
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return () => result;
  }

  bool confirmEnabled(WidgetTester tester) =>
      tester
          .widget<FilledButton>(find.byKey(ForgeConfirmSheet.confirmKey))
          .onPressed !=
      null;

  testWidgets('typeToConfirm keeps Delete disabled until the word matches', (
    tester,
  ) async {
    final result = await open(tester, typeToConfirm: 'DELETE');
    expect(find.text('TYPE DELETE TO CONFIRM'), findsOneWidget); // mono label
    expect(confirmEnabled(tester), isFalse);
    await tester.enterText(find.byKey(ForgeConfirmSheet.fieldKey), 'DELET');
    await tester.pump();
    expect(confirmEnabled(tester), isFalse);
    await tester.enterText(find.byKey(ForgeConfirmSheet.fieldKey), ' delete ');
    await tester.pump();
    expect(confirmEnabled(tester), isTrue); // case-insensitive, trimmed
    await tester.tap(find.byKey(ForgeConfirmSheet.confirmKey));
    await tester.pumpAndSettle();
    expect(find.byType(ForgeConfirmSheet), findsNothing);
    expect(result(), isTrue);
  });

  testWidgets('caseSensitive requires the exact word', (tester) async {
    await open(tester, typeToConfirm: 'DELETE', caseSensitive: true);
    await tester.enterText(find.byKey(ForgeConfirmSheet.fieldKey), 'delete');
    await tester.pump();
    expect(confirmEnabled(tester), isFalse);
    await tester.enterText(find.byKey(ForgeConfirmSheet.fieldKey), 'DELETE');
    await tester.pump();
    expect(confirmEnabled(tester), isTrue);
  });

  testWidgets('onConfirmAsync shows progress, blocks cancel, pops on success', (
    tester,
  ) async {
    final gate = Completer<String?>();
    final result = await open(
      tester,
      typeToConfirm: 'DELETE',
      onConfirmAsync: () => gate.future,
    );
    await tester.enterText(find.byKey(ForgeConfirmSheet.fieldKey), 'DELETE');
    await tester.pump();
    await tester.tap(find.byKey(ForgeConfirmSheet.confirmKey));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(confirmEnabled(tester), isFalse);
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(ForgeConfirmSheet.cancelKey))
          .onPressed,
      isNull,
    );
    // Dismissing by back is refused while busy.
    final scope = tester.widget<PopScope>(
      find
          .ancestor(
            of: find.byKey(ForgeConfirmSheet.confirmKey),
            matching: find.byType(PopScope),
          )
          .first,
    );
    expect(scope.canPop, isFalse);
    gate.complete(null);
    await tester.pumpAndSettle();
    expect(find.byType(ForgeConfirmSheet), findsNothing);
    expect(result(), isTrue);
  });

  testWidgets('a failed action keeps the sheet open with the message', (
    tester,
  ) async {
    var attempts = 0;
    final result = await open(
      tester,
      typeToConfirm: 'DELETE',
      onConfirmAsync: () async =>
          ++attempts == 1 ? "Couldn't reach the server." : null,
    );
    await tester.enterText(find.byKey(ForgeConfirmSheet.fieldKey), 'DELETE');
    await tester.pump();
    await tester.tap(find.byKey(ForgeConfirmSheet.confirmKey));
    await tester.pumpAndSettle();
    expect(find.byType(ForgeConfirmSheet), findsOneWidget);
    expect(find.text("Couldn't reach the server."), findsOneWidget);
    expect(confirmEnabled(tester), isTrue); // the word still matches
    await tester.tap(find.byKey(ForgeConfirmSheet.confirmKey));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.byType(ForgeConfirmSheet), findsNothing);
    expect(result(), isTrue);
  });

  testWidgets('without a word, an async failure shows an error line', (
    tester,
  ) async {
    await open(tester, onConfirmAsync: () async => 'Nope.');
    expect(find.byKey(ForgeConfirmSheet.fieldKey), findsNothing);
    await tester.tap(find.byKey(ForgeConfirmSheet.confirmKey));
    await tester.pumpAndSettle();
    expect(find.text('Nope.'), findsOneWidget);
    expect(find.byType(ForgeConfirmSheet), findsOneWidget);
  });
}
