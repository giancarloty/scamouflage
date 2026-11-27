import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamouflage/controllers/inbox_motion.dart';
import 'package:scamouflage/models/arcade_models.dart';
import 'package:scamouflage/views/arcade_rumor_inbox_thread_views.dart';
import 'package:scamouflage/views/theme.dart';

const _testEmails = [
  EmailItem(
    fromName: 'Campus Office',
    fromAddress: 'office@campus.example',
    subject: 'Your enrollment update',
    body: 'Your documents were received. Check the usual student portal.',
    spam: false,
    why: 'Uses the established student portal.',
    linkTarget: 'portal.campus.example',
  ),
  EmailItem(
    fromName: 'Parcel Help',
    fromAddress: 'delivery@parcel-check.example',
    subject: 'Delivery notice',
    body: 'Verify an unexpected payment request in your official app.',
    spam: true,
    why: 'An unrelated domain requests payment.',
  ),
];

const _case = ArcadeCase(
  signature: 'motion-test',
  scenario: 'mobile-ui-test',
  mode: ArcadeMode.inbox,
  title: 'Inbox Sprint',
  lesson: 'Check the sender and context.',
  hint: 'Examine sender details.',
  correct: [1, 0],
  deceptive: true,
  emails: _testEmails,
);

void main() {
  group('swipe mechanics', () {
    test('short gestures return; deliberate swipes and flicks commit', () {
      expect(
        inboxSwipeVerdict(displacement: 40, velocity: 0, viewportWidth: 375),
        isNull,
      );
      expect(
        inboxSwipeVerdict(displacement: 110, velocity: 0, viewportWidth: 375),
        1,
      );
      expect(
        inboxSwipeVerdict(displacement: -110, velocity: 0, viewportWidth: 375),
        0,
      );
      expect(
        inboxSwipeVerdict(
          displacement: -35,
          velocity: -850,
          viewportWidth: 375,
        ),
        0,
      );
      expect(
        inboxSwipeVerdict(displacement: 15, velocity: 900, viewportWidth: 375),
        isNull,
      );
    });

    test('card tint follows drag direction and fades back to its base', () {
      expect(
        inboxSwipeTint(base: paperWhite, displacement: 0, viewportWidth: 375),
        paperWhite,
      );
      final softRed = inboxSwipeTint(
        base: paperWhite,
        displacement: -45,
        viewportWidth: 375,
      );
      final softGreen = inboxSwipeTint(
        base: paperWhite,
        displacement: 45,
        viewportWidth: 375,
      );
      final strongRed = inboxSwipeTint(
        base: paperWhite,
        displacement: -150,
        viewportWidth: 375,
      );
      expect(softRed, isNot(paperWhite));
      expect(softGreen, isNot(paperWhite));
      expect(softRed, isNot(softGreen));
      expect(strongRed, isNot(softRed));
    });
  });

  Future<void> mountInbox(
    WidgetTester tester, {
    double width = 375,
    double height = 812,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, height);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InboxView(
            c: _case,
            d: ArcadeDifficulty.easy,
            tutorial: false,
            hint: false,
            onSubmit: _ignoreResult,
          ),
        ),
      ),
    );
  }

  testWidgets('tap flips through a half-turn then flips back', (tester) async {
    await mountInbox(tester);

    expect(find.byKey(const ValueKey('inbox-visible-front')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('inbox-swipe-card')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 270));

    expect(find.byKey(const ValueKey('inbox-visible-back')), findsOneWidget);

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('inbox-swipe-card')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('inbox-visible-front')), findsOneWidget);
  });

  testWidgets('a partial right drag tints the card and smoothly snaps back', (
    tester,
  ) async {
    await mountInbox(tester, width: 320, height: 568);

    final card = find.byKey(const ValueKey('inbox-swipe-card'));
    final gesture = await tester.startGesture(tester.getCenter(card));

    await gesture.moveBy(const Offset(27, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(26, 0));
    await tester.pump();

    final visible = find.descendant(
      of: find.byKey(const ValueKey('inbox-visible-front')),
      matching: find.byType(Container),
    );

    final tinted =
        (tester.widget<Container>(visible.first).decoration! as BoxDecoration)
            .color;

    expect(tinted, isNot(paperWhite));

    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 330));

    final restored =
        (tester.widget<Container>(visible.first).decoration! as BoxDecoration)
            .color;

    expect(restored, paperWhite);
    expect(find.text('EMAIL 1 OF 2'), findsOneWidget);
  });

  testWidgets('a committed swipe completes before the next email appears', (
    tester,
  ) async {
    await mountInbox(tester, width: 390, height: 844);

    await tester.drag(
      find.byKey(const ValueKey('inbox-swipe-card')),
      const Offset(-145, 0),
    );

    await tester.pump();

    // Still showing the old email during the exit animation.
    expect(find.text('EMAIL 1 OF 2'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('EMAIL 2 OF 2'), findsOneWidget);
  });
}

// FIX: Match the SubmitFn signature by including the named `opened` parameter.
void _ignoreResult(
  List<int> answer,
  bool flipped, {
  List<String> opened = const [],
}) {}
