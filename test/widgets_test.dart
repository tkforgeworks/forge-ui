import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:heroicons/heroicons.dart';

import 'support.dart';

void main() {
  testWidgets('ForgeMonoLabel and capsules uppercase their content', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const Column(
          children: [
            ForgeMonoLabel('Display name'),
            ForgeTagCapsule('cow', tone: ForgeCapsuleTone.emphasis),
            ForgeStatusCapsule('connected', active: true),
          ],
        ),
      ),
    );
    expect(find.text('DISPLAY NAME'), findsOneWidget);
    expect(find.text('COW'), findsOneWidget);
    expect(find.text('CONNECTED'), findsOneWidget);
  });

  testWidgets('capsules take their colours from the theme', (tester) async {
    await tester.pumpWidget(
      wrap(
        const Column(
          children: [
            ForgeTagCapsule('raw', tone: ForgeCapsuleTone.emphasis),
            ForgeStatusCapsule('connected', active: true),
            ForgeStatusCapsule('not connected'),
          ],
        ),
      ),
    );
    final context = tester.element(find.byType(ForgeTagCapsule));
    final c = context.colors;
    final x = context.forge;
    Color? fill(String text) {
      final box = tester.widget<Container>(
        find.ancestor(of: find.text(text), matching: find.byType(Container)),
      );
      return (box.decoration! as BoxDecoration).color;
    }

    expect(fill('RAW'), c.primaryContainer);
    expect(fill('CONNECTED'), x.successContainer);
    expect(fill('NOT CONNECTED'), c.surfaceContainer);
    expect(
      tester.widget<Text>(find.text('CONNECTED')).style!.color,
      x.onSuccessContainer,
    );
  });

  testWidgets('status capsule tones pick their container pairs', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const Column(
          children: [
            ForgeStatusCapsule('low mana', tone: ForgeStatusTone.warning),
            ForgeStatusCapsule('tip', tone: ForgeStatusTone.info),
            ForgeStatusCapsule('ok', tone: ForgeStatusTone.success),
            ForgeStatusCapsule('legacy', active: true),
          ],
        ),
      ),
    );
    final x = tester.element(find.text('LOW MANA')).forge;
    Color? fill(String text) {
      final box = tester.widget<Container>(
        find.ancestor(of: find.text(text), matching: find.byType(Container)),
      );
      return (box.decoration! as BoxDecoration).color;
    }

    expect(fill('LOW MANA'), x.warningContainer);
    expect(fill('TIP'), x.infoContainer);
    expect(fill('OK'), x.successContainer);
    expect(fill('LEGACY'), x.successContainer);
    expect(
      tester.widget<Text>(find.text('LOW MANA')).style!.color,
      x.onWarningContainer,
    );
  });

  testWidgets('ForgeMonoLabel emphasis uses onPrimaryContainer at 600', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const ForgeMonoLabel('12', emphasis: true)));
    final style = tester.widget<Text>(find.text('12')).style!;
    final c = tester.element(find.text('12')).colors;
    expect(style.color, c.onPrimaryContainer);
    expect(style.fontWeight, FontWeight.w600);
  });

  testWidgets('ForgeBoxedField accepts input and shows label and error', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      wrap(
        ForgeBoxedField(
          label: 'Email',
          hint: 'you@example.com',
          controller: controller,
          errorText: 'That is not an email address.',
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'tyler@example.com');
    expect(controller.text, 'tyler@example.com');
    expect(find.text('EMAIL'), findsOneWidget);
    expect(find.text('That is not an email address.'), findsOneWidget);
  });

  testWidgets('confirm sheet resolves true on confirm, false on cancel', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => FilledButton(
            onPressed: () async {
              result = await showForgeConfirmSheet(
                context,
                title: 'Delete your account?',
                aside: 'Your notes go with it. Just saying.',
                confirmLabel: 'Delete',
                cancelLabel: 'Keep it',
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Delete your account?'), findsOneWidget);
    expect(find.text('Your notes go with it. Just saying.'), findsOneWidget);
    final c = tester.element(find.byType(ForgeConfirmSheet)).colors;
    final confirm = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Delete'),
    );
    expect(confirm.style!.backgroundColor!.resolve({}), c.error);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(result, isTrue);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep it'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('a non-destructive confirm keeps the primary button colour', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const ForgeConfirmSheet(
          title: 'Sign out?',
          confirmLabel: 'Sign out',
          destructive: false,
        ),
      ),
    );
    final confirm = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Sign out'),
    );
    expect(confirm.style, isNull);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('ForgeEmptyState renders title, aside and action', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(
        ForgeEmptyState(
          icon: const HeroIcon(HeroIcons.documentText),
          title: 'Nothing here yet',
          aside: "It isn't going to write itself.",
          action: FilledButton(
            onPressed: () => tapped = true,
            child: const Text('Start one'),
          ),
        ),
      ),
    );
    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.text("It isn't going to write itself."), findsOneWidget);
    await tester.tap(find.text('Start one'));
    expect(tapped, isTrue);
  });

  testWidgets('ForgeErrorCard shows the message and calls retry', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      wrap(
        ForgeErrorCard(
          message: "Couldn't reach the server.",
          onRetry: () => retried = true,
        ),
      ),
    );
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);

    await tester.pumpWidget(
      wrap(const ForgeErrorCard(message: "Couldn't reach the server.")),
    );
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('ForgeSkeletonList shimmers between the two skeleton tokens', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const ForgeSkeletonList(count: 4)));
    expect(find.byType(ForgeSkeletonRow), findsNWidgets(4));
    expect(find.byType(Divider), findsNWidgets(3));
    final x = tester.element(find.byType(ForgeSkeletonList)).forge;
    Color circle() {
      final box = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ForgeSkeletonRow).first,
              matching: find.byType(Container),
            )
            .first,
      );
      return (box.decoration! as BoxDecoration).color!;
    }

    expect(circle(), x.skeletonBase);
    await tester.pump(const Duration(milliseconds: 1200));
    expect(circle(), x.skeletonHighlight);
    // The shimmer repeats forever; unmount so no ticker outlives the test.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('ForgeSettingsGroup labels a card of divided rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const ForgeSettingsGroup(
          label: 'Appearance',
          children: [
            ListTile(title: Text('Theme')),
            ListTile(title: Text('Units')),
            ListTile(title: Text('Language')),
          ],
        ),
      ),
    );
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
    expect(find.byType(Divider), findsNWidgets(2));

    await tester.pumpWidget(
      wrap(
        const ForgeSettingsGroup(children: [ListTile(title: Text('Theme'))]),
      ),
    );
    expect(find.byType(ForgeMonoLabel), findsNothing);
  });

  testWidgets('ForgeFab paints the forge gradient and reports taps', (
    tester,
  ) async {
    var pressed = 0;
    for (final dark in [false, true]) {
      await tester.pumpWidget(
        wrap(
          ForgeFab(onPressed: () => pressed++, label: 'New entry'),
          dark: dark,
        ),
      );
      await tester.pumpAndSettle();
      final box = tester.widget<DecoratedBox>(
        find
            .ancestor(
              of: find.byType(FloatingActionButton),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(
        (box.decoration as BoxDecoration).gradient,
        ForgeBrand.forgeGradient,
      );
      await tester.tap(find.text('New entry'));
    }
    expect(pressed, 2);
  });

  testWidgets('withNavBarInset adds the system bar to the bottom padding', (
    tester,
  ) async {
    late EdgeInsets padding;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.only(bottom: 48)),
        child: Builder(
          builder: (context) {
            padding = const EdgeInsets.all(16).withNavBarInset(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(padding, const EdgeInsets.fromLTRB(16, 16, 16, 64));
  });
}
