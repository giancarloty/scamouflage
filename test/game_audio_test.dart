import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamouflage/services/game_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('original music and sound effects are bundled as local assets', () async {
    // No HTTP requests or runtime downloads are needed to play these sounds.
    final music = MusicScene.values.map((scene) => scene.asset).toSet();
    expect(music.length, greaterThanOrEqualTo(8));
    for (final name in music) {
      final sound = await rootBundle.load('assets/audio/music/$name.mp3');
      expect(sound.lengthInBytes, greaterThan(1500), reason: name);
    }
    for (final sound in GameCue.values) {
      final bytes = await rootBundle.load('assets/audio/sfx/${sound.asset}.mp3');
      expect(bytes.lengthInBytes, greaterThan(500), reason: sound.asset);
    }
  });

  test('saved audio preferences load without starting playback', () async {
    SharedPreferences.setMockInitialValues({
      'scamouflage_audio_music_v1': false,
      'scamouflage_audio_effects_v1': false,
      'scamouflage_audio_volume_v1': .35,
    });
    final audio = GameAudio.instance;
    await audio.initialize();
    expect(audio.musicEnabled, false);
    expect(audio.effectsEnabled, false);
    expect(audio.volume, closeTo(.35, .001));
    expect(audio.activated, false);
  });


  test('new sound-effect intensity preference loads; gameplay uses own music', () async {
    SharedPreferences.setMockInitialValues({
      'scamouflage_audio_effect_level_v2': .25,
    });
    final audio = GameAudio.instance;
    await audio.initialize();
    expect(audio.effectsLevel, closeTo(.25, .001));
    expect(MusicScene.trust.asset, 'trust');
    expect(MusicScene.menu.asset, isNot(MusicScene.career.asset));
    audio.setEffectsLevel(.40);
    expect(audio.effectsLevel, closeTo(.40, .001));
  });

  test('changing scene without tapping play does not activate audio', () {
    final audio = GameAudio.instance;
    audio.setScene(MusicScene.rumor);
    expect(audio.scene, MusicScene.rumor);
    expect(audio.activated, false);
  });
}
