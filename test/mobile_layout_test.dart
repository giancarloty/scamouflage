import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamouflage/views/theme.dart';

void main() {
  final sizes = <Size>[
    const Size(320, 568), // smallest supported iPhone-style portrait viewport
    const Size(360, 640), // narrow Android
    const Size(375, 667), // compact iPhone
    const Size(390, 844), // modern iPhone
    const Size(430, 932), // larger iPhone
  ];

  for (final size in sizes) {
    testWidgets('Mobile dialogs fit ${size.width}x${size.height}', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => PhoneDialog(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('HELP IS HERE'),
                            ...List.generate(
                              14,
                              (i) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 7,
                                ),
                                child: Text(
                                  'Step $i: tap or scroll to continue',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  child: const Text('Open help'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open help'));
      await tester.pumpAndSettle();
      expect(find.text('HELP IS HERE'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Compact and narrow breakpoints reflect phone width', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    late bool compact;
    late bool narrow;
    late double footer;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            compact = PhoneLayout.compact(context);
            narrow = PhoneLayout.narrow(context);
            footer = PhoneLayout.footerLimit(context, multipleChoices: true);
            return const Scaffold(body: SizedBox());
          },
        ),
      ),
    );
    expect(compact, isTrue);
    expect(narrow, isTrue);
    expect(footer, inInclusiveRange(116, 250));
  });
}
