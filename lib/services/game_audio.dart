import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/theme.dart';

/// Original, locally bundled audio. Playback never uses network connections.
/// Music is only activated after a player's gesture to satisfy mobile browsers.
enum MusicScene {
  menu('menu'), career('career'), arcade('arcade'),
  trust('trust'), impostor('impostor'), scamSlam('scam'),
  rumor('rumor'), inbox('inbox'), comments('comments'), clip('clip');

  const MusicScene(this.asset);
  final String asset;
}

enum GameCue {
  tap('tap'), inspect('inspect'), hint('hint'), flip('flip'),
  swipe('swipe'), snap('snap'), correct('correct'), wrong('wrong'),
  unlock('unlock'), victory('victory'), defeat('defeat'), choose('choose');

  const GameCue(this.asset);
  final String asset;
}

/// Shared audio mixer: one looped music channel and a rotating set of short
/// effect channels (effects can overlap without interrupting the music).
class GameAudio extends ChangeNotifier {
  GameAudio._();
  static final GameAudio instance = GameAudio._();

  static const String _musicKey = 'scamouflage_audio_music_v1';
  static const String _effectsKey = 'scamouflage_audio_effects_v1';
  static const String _volumeKey = 'scamouflage_audio_volume_v1';
  static const String _effectLevelKey = 'scamouflage_audio_effect_level_v2';

  bool musicEnabled = true;
  bool effectsEnabled = true;
  double volume = .60;
  double effectsLevel = .60; // Subtle by default; players can fine-tune.

  bool _activated = false;
  bool _paused = false;
  bool _closed = false;
  SharedPreferences? _preferences;
  AudioPlayer? _musicPlayer;
  final List<AudioPlayer> _effectPlayers = [];
  int _nextEffect = 0;
  MusicScene _desiredScene = MusicScene.menu;
  String? _playingAsset;
  int _requestId = 0;
  Future<void> _transitionQueue = Future<void>.value();

  MusicScene get scene => _desiredScene;
  bool get activated => _activated;

  Future<void> initialize() async {
    try {
      _preferences = await SharedPreferences.getInstance();
      musicEnabled = _preferences!.getBool(_musicKey) ?? true;
      effectsEnabled = _preferences!.getBool(_effectsKey) ?? true;
      volume = (_preferences!.getDouble(_volumeKey) ?? .60).clamp(0.0, 1.0).toDouble();
      effectsLevel = (_preferences!.getDouble(_effectLevelKey) ?? .60)
          .clamp(0.0, 1.0).toDouble();
      notifyListeners();
    } catch (e) {
      debugPrint('Scamouflage audio preferences could not load: $e');
    }
  }

  /// Call synchronously inside an onPressed/onTap callback. Safari refuses
  /// autonomous playback before the user interacts with the page.
  void enter(MusicScene next) {
    if (_closed) return;
    final shouldRequest = !_activated || _desiredScene != next ||
        (musicEnabled && volume > 0 && !_paused && _playingAsset != next.asset);
    _activated = true;
    _desiredScene = next;
    if (shouldRequest) _requestMusic();
  }

  void setScene(MusicScene next) {
    if (_closed) return;
    if (_desiredScene == next) return;
    _desiredScene = next;
    if (_activated) _requestMusic();
  }

  void setMusicEnabled(bool enabled) {
    if (_closed) return;
    musicEnabled = enabled;
    if (enabled) _activated = true; // User toggled it on themselves.
    notifyListeners();
    unawaited(_save());
    _requestMusic();
  }

  void setEffectsEnabled(bool enabled) {
    if (_closed) return;
    effectsEnabled = enabled;
    notifyListeners();
    unawaited(_save());
    if (enabled) cue(GameCue.tap);
  }

  void setVolume(double next) {
    if (_closed) return;
    final previous = volume;
    volume = next.clamp(0.0, 1.0).toDouble();
    notifyListeners();
    unawaited(_save());
    final player = _musicPlayer;
    if ((previous == 0) != (volume == 0)) {
      if (_activated) _requestMusic();
    } else if (player != null) {
      unawaited(_safeSetVolume(player, _musicVolume));
    }
  }

  /// Bright menus; gameplay intentionally sits lower in the audio mix.
  double get _musicVolume => (volume *
      ((_desiredScene == MusicScene.menu || _desiredScene == MusicScene.arcade)
          ? .34 : .25)).clamp(0.0, 1.0).toDouble();

  /// Frequent interactions are unobtrusive. Important success / victory
  /// jingles remain noticeable; the player still controls overall SFX level.
  double _effectVolume(GameCue cue) {
    final gain = switch (cue) {
      GameCue.correct || GameCue.victory => 1.10,
      GameCue.unlock => .86,
      GameCue.wrong || GameCue.defeat => .50,
      GameCue.hint => .42,
      GameCue.tap || GameCue.choose => .31,
      GameCue.swipe => .29,
      GameCue.flip || GameCue.inspect || GameCue.snap => .25,
    };
    return (volume * gain * effectsLevel).clamp(0.0, 1.0).toDouble();
  }

  void setEffectsLevel(double next) {
    if (_closed) return;
    effectsLevel = next.clamp(0.0, 1.0).toDouble();
    notifyListeners();
    unawaited(_save());
  }

  Future<void> _save() async {
    try {
      final prefs = _preferences ?? await SharedPreferences.getInstance();
      _preferences ??= prefs;
      await prefs.setBool(_musicKey, musicEnabled);
      await prefs.setBool(_effectsKey, effectsEnabled);
      await prefs.setDouble(_volumeKey, volume);
      await prefs.setDouble(_effectLevelKey, effectsLevel);
    } catch (e) {
      debugPrint('Unable to save audio preference: $e');
    }
  }

  void _requestMusic() {
    final id = ++_requestId;
    // Serialize changes: two rapid screens cannot race to restart a track.
    _transitionQueue = _transitionQueue.then((_) => _switchMusic(id))
        .catchError((Object error) {
      debugPrint('Audio transition skipped: $error');
    });
  }

  Future<void> _switchMusic(int id) async {
    if (_closed || id != _requestId) return;
    final player = _musicPlayer ??= AudioPlayer();
    final shouldPlay = _activated && !_paused && musicEnabled && volume > 0;
    if (!shouldPlay) {
      _playingAsset = null;
      try { await player.stop(); } catch (e) { debugPrint('$e'); }
      return;
    }
    final asset = _desiredScene.asset;
    if (_playingAsset == asset) {
      await _safeSetVolume(player, _musicVolume);
      return;
    }
    try {
      await player.stop();
      if (id != _requestId || _closed) return;
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(_musicVolume);
      if (id != _requestId || _closed) return;
      await player.play(AssetSource('audio/music/$asset.mp3'));
      _playingAsset = asset;
    } catch (e) {
      _playingAsset = null;
      // Mobile Safari can block playback until its first user gesture.
      debugPrint('Music was not started (tap a game control to retry): $e');
    }
  }

  Future<void> _safeSetVolume(AudioPlayer player, double value) async {
    try { await player.setVolume(value); } catch (e) { debugPrint('$e'); }
  }

  /// Fire and forget on interaction. Uses multiple channels so rapid taps,
  /// flips and feedback do not cut each other off.
  void cue(GameCue sound) {
    if (_closed || !effectsEnabled || volume <= 0 || effectsLevel <= 0 || _paused) return;
    unawaited(_playCue(sound));
  }

  Future<void> _playCue(GameCue sound) async {
    try {
      while (_effectPlayers.length < 4) {
        _effectPlayers.add(AudioPlayer());
      }
      final player = _effectPlayers[_nextEffect++ % _effectPlayers.length];
      await player.stop();
      if (_closed || !effectsEnabled || _paused) return;
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(_effectVolume(sound));
      await player.play(AssetSource('audio/sfx/${sound.asset}.mp3'));
    } catch (e) {
      debugPrint('Sound effect skipped: $e');
    }
  }

  /// Stops background audio when the app/tab is hidden, without changing
  /// saved settings. Re-enters the requested scene on return.
  void appVisible(bool visible) {
    if (_closed || _paused == !visible) return;
    _paused = !visible;
    _requestMusic();
  }

  @override
  void dispose() {
    _closed = true;
    ++_requestId;
    final music = _musicPlayer;
    if (music != null) unawaited(music.dispose());
    for (final player in _effectPlayers) {
      unawaited(player.dispose());
    }
    super.dispose();
  }
}

/// A single reusable phone-friendly control panel for Career and Arcade.
class ScamouflageAudioControls extends StatelessWidget {
  const ScamouflageAudioControls({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: GameAudio.instance,
    builder: (context, _) {
      final audio = GameAudio.instance;
      return Column(mainAxisSize: MainAxisSize.min, children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.music_note_rounded, color: mustard),
          title: Text('Background music', style: captionText(15)),
          subtitle: Text('Energetic menus, mellow during investigations',
            style: captionText(12, color: parchment)),
          value: audio.musicEnabled,
          activeTrackColor: mustard.withValues(alpha: .45),
          activeThumbColor: mustard,
          onChanged: audio.setMusicEnabled,
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.graphic_eq_rounded, color: blue),
          title: Text('Sound effects', style: captionText(15)),
          subtitle: Text('Soft clicks and swipes; clear success jingles',
            style: captionText(12, color: parchment)),
          value: audio.effectsEnabled,
          activeTrackColor: mustard.withValues(alpha: .45),
          activeThumbColor: mustard,
          onChanged: audio.setEffectsEnabled,
        ),
        Padding(padding: const EdgeInsets.fromLTRB(4, 5, 4, 0),
          child: Row(children: [
            const Icon(Icons.volume_up_rounded, color: mint),
            const SizedBox(width: 10),
            Expanded(child: Text('Master volume', style: captionText(15))),
            Text('${(audio.volume * 100).round()}%',
              style: typewriter(13, color: mustard)),
          ])),
        Slider(
          value: audio.volume,
          min: 0, max: 1, divisions: 20,
          activeColor: mustard,
          inactiveColor: deskLight,
          onChanged: audio.setVolume,
          onChangeEnd: (_) => audio.cue(GameCue.choose),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(4, 9, 4, 0),
          child: Row(children: [
            const Icon(Icons.tune_rounded, color: blue),
            const SizedBox(width: 10),
            Expanded(child: Text('Sound effect intensity', style: captionText(15))),
            Text('${(audio.effectsLevel * 100).round()}%',
              style: typewriter(13, color: blue)),
          ])),
        Slider(
          value: audio.effectsLevel,
          min: 0, max: 1, divisions: 20,
          activeColor: blue,
          inactiveColor: deskLight,
          onChanged: audio.effectsEnabled ? audio.setEffectsLevel : null,
          onChangeEnd: (_) => audio.cue(GameCue.tap),
        ),
        TextButton.icon(
          onPressed: () {
            audio.enter(audio.scene);
            audio.cue(GameCue.correct);
          },
          icon: const Icon(Icons.play_circle_outline_rounded, color: blue),
          label: Text('TEST SOUND', style: captionText(13, color: paperWhite)),
        ),
      ]);
    },
  );
}
