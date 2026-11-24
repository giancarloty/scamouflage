import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scamouflage/controllers/engine.dart';
import 'package:scamouflage/views/screens.dart';
import 'package:scamouflage/services/game_audio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Four mobile tabs move between home, arcade, shifts and profile',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    SharedPreferences.setMockInitialValues({
      'arcade_intro_v7': true,
      'mascot_intro_v12': true,
      'tutorial_v5': true,
    });
    final g = GameEngine();
    await g.load();
    await tester.pumpWidget(MaterialApp(home: GameScreens(game: g)));
    await tester.pump();
    expect(find.byKey(const ValueKey('nav-home')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav-arcade')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav-shifts')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav-profile')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('nav-shifts')));
    await tester.pump();
    expect(GameAudio.instance.scene, MusicScene.menu);
    expect(find.text('YOUR SHIFT PATH'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('nav-profile')));
    await tester.pump();
    expect(GameAudio.instance.scene, MusicScene.menu);
    expect(find.text('MY INVESTIGATOR'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('nav-arcade')));
    await tester.pump();
    expect(GameAudio.instance.scene, MusicScene.menu);
    expect(find.text('SCAMOUFLAGE ARCADE'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    g.dispose();
  });
}
