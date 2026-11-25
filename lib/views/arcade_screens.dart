import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/arcade_models.dart';
import 'arcade_modes_a.dart';
import 'arcade_modes_b.dart';
import '../controllers/arcade_session.dart';
import '../controllers/daily_challenge_controller.dart';
import 'daily_challenges_screen.dart';
import 'arcade_widgets.dart';
import 'career_identity.dart';
import '../controllers/engine.dart';
import '../services/game_audio.dart';
import 'mascot.dart';
import '../models/player_progression.dart';
import 'theme.dart';
import '../models/run_stats.dart';
import 'run_summary.dart';
import '../services/leaderboard_service.dart';

/// The Arcade: seven minigames, each with its own mechanic. All people,
/// brands and links are fictional. See arcade_modes_a/b.dart for the games.
class ArcadeHub extends StatefulWidget {
  final GameEngine game;
  final bool embedded;
  final VoidCallback? onBack;
  final VoidCallback? onOpenProfile;
  final ValueChanged<bool>? onPlayingChanged;
  const ArcadeHub({super.key, required this.game, this.embedded = false,
    this.onBack, this.onOpenProfile, this.onPlayingChanged});

  @override
  State<ArcadeHub> createState() => _ArcadeHubState();
}

class _ArcadeHubState extends State<ArcadeHub> {
  ArcadeDifficulty difficulty = ArcadeDifficulty.easy;
  ArcadeSession? session;
  bool introJustCompleted = false;
  bool hintOn = false;
  ArcadeSession? _summarySession;
  String? newestCareerReward;
  late final DailyChallengeController dailyChallenges;

  @override
  void initState() {
    super.initState();
    dailyChallenges = DailyChallengeController(
      awardXp: widget.game.awardArcadeXp,
    );
    dailyChallenges.initialize();
  }

  /// One-time server ticket for the current ranked run. It is requested when
  /// the run starts and redeemed by [_submitScore] when the run ends.
  Future<String?>? runTicket;

  /// The last session already reported, so a run is never counted twice.
  ArcadeSession? _reportedSession;

  static const modeColors = [mustard, blue, mint, coral, pink, parchment,
    Color(0xFFBCAAFF)];
  Color get accent => modeColors[session?.current.mode.index ?? 0];

  @override
  void dispose() {
    GameAudio.instance.setScene(MusicScene.menu);
    dailyChallenges.dispose();
    super.dispose();
  }

  MusicScene _sceneFor(ArcadeMode mode) => switch (mode) {
    ArcadeMode.trust => MusicScene.trust,
    ArcadeMode.impostor => MusicScene.impostor,
    ArcadeMode.scamSlam => MusicScene.scamSlam,
    ArcadeMode.rumor => MusicScene.rumor,
    ArcadeMode.inbox => MusicScene.inbox,
    ArcadeMode.comments => MusicScene.comments,
    ArcadeMode.clip => MusicScene.clip,
  };

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: session == null,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && session != null) _confirmExit();
    },
    child: Scaffold(
      backgroundColor: midnight,
      body: SafeArea(child: DeskBackdrop(child: session == null
          ? (widget.game.arcadeUnlocked ? _hub() : _firstDayStart())
          : _gameplay())),
    ),
  );

  Widget _scroll(List<Widget> children) => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(17, 14, 17, 26),
    child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 540),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children))),
  );

  Widget _header(String title) => Row(children: [
    IconButton(onPressed: widget.onBack ?? () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: paperWhite),
      tooltip: 'Back to main menu'),
    const SizedBox(width: 4),
    Expanded(child: Text(title, style: titleText(23, color: mustard),
      maxLines: 1, overflow: TextOverflow.ellipsis)),
    IconButton(
      tooltip: 'Investigator profile and unlockables',
      icon: const Icon(Icons.workspace_premium_rounded, color: mint),
      onPressed: () {
        GameAudio.instance.cue(GameCue.choose);
        if (widget.onOpenProfile != null) {
          widget.onOpenProfile!();
        } else {
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => CareerIdentityScreen(game: widget.game)));
        }
      },
    ),
    IconButton(
      tooltip: 'Music and sound settings',
      icon: const Icon(Icons.volume_up_rounded, color: paperWhite),
      onPressed: _openAudioSettings,
    ),
    if (!MediaQuery.sizeOf(context).width.isFinite ||
        MediaQuery.sizeOf(context).width > 395)
      InkTag('${widget.game.careerXp} XP', color: mustard, icon: Icons.bolt_rounded),
  ]);

  Widget _firstDayStart() => _scroll([
    _header('FIRST DAY'),
    const SizedBox(height: 22),
    GestureDetector(onTap: _startIntro, child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF514079), Color(0xFF245B65)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: mustard, width: 2.5),
      ),
      child: Column(children: [
        MascotAvatar(game: widget.game, size: 155),
        const SizedBox(height: 8),
        Text('WELCOME TO\nBANTAY TAMBAYAN!',
          style: titleText(31, color: paperWhite), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text('5 quick tries. Tap the glowing things. That\'s it!',
          style: captionText(15, color: paperWhite), textAlign: TextAlign.center),
        const SizedBox(height: 15),
        const InkTag('TAP ANYWHERE TO START', color: mustard,
          icon: Icons.touch_app_rounded),
      ]),
    )),
    const SizedBox(height: 22),
    SizedBox(width: double.infinity, child: GameButton('PLAY MY FIRST DAY',
      onTap: _startIntro, icon: Icons.play_arrow_rounded, color: mustard)),
    const SizedBox(height: 8),
    Center(child: TextButton(
      onPressed: _skipIntro,
      child: Text('ALREADY PLAYED? SKIP INTRO',
        style: typewriter(11, color: paperWhite)))),
    const SizedBox(height: 10),
    Text('All examples are fictional. Never enter real passwords or OTPs.',
      style: captionText(12, color: paperWhite), textAlign: TextAlign.center),
  ]);

  void _startIntro() {
    GameAudio.instance.cue(GameCue.unlock);
    _begin(null, firstDay: true);
  }

  void _skipIntro() {
    GameAudio.instance.enter(MusicScene.menu);
    GameAudio.instance.cue(GameCue.unlock);
    widget.game.finishArcadeIntro();
    setState(() { introJustCompleted = true; session = null; });
  }

  Widget _dailyChallengesCard() => AnimatedBuilder(
    animation: dailyChallenges,
    builder: (context, _) {
      final completed = dailyChallenges.completedCount;
      final total = dailyChallenges.challenges.length;
      final ready = dailyChallenges.ready;
      return Material(
        color: const Color(0xFF143A4C),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () async {
            await dailyChallenges.refreshForDateChange();
            if (!context.mounted) return;
            Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => DailyChallengesScreen(controller: dailyChallenges),
            ));
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: mint.withValues(alpha: .8), width: 1.5),
            ),
            child: Row(children: [
              Container(
                height: 48, width: 48,
                decoration: BoxDecoration(
                  color: mint.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.today_rounded, color: mint, size: 27),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DAILY CHALLENGES',
                    style: titleText(17, color: paperWhite)),
                  const SizedBox(height: 3),
                  Text(ready ? '$completed / $total completed • bonus XP' : 'Loading today’s missions…',
                    style: captionText(12, color: paperWhite)),
                  if (ready && total > 0) ...[
                    const SizedBox(height: 7),
                    LinearProgressIndicator(
                      value: completed / total,
                      minHeight: 5,
                      backgroundColor: Colors.white12,
                      color: mint,
                    ),
                  ],
                ],
              )),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: mint),
            ]),
          ),
        ),
      );
    },
  );

  Widget _hub() => _scroll([
    _header('SCAMOUFLAGE ARCADE'),
    const SizedBox(height: 12),
    _dailyChallengesCard(),
    const SizedBox(height: 16),
    Material(color: Colors.transparent, child: InkWell(
      onTap: () => _begin(null),
      borderRadius: BorderRadius.circular(23),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF544472), Color(0xFF255B69)]),
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: mustard, width: 2),
        ),
        child: Row(children: [
          MascotAvatar(game: widget.game, size: 104),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ENDLESS MIX!', style: titleText(28, color: paperWhite)),
              const SizedBox(height: 7),
              Text('All your unlocked minigames, shuffled. How long can you last?',
                style: captionText(13, color: paperWhite)),
              const SizedBox(height: 9),
              const InkTag('TAP TO PLAY', color: mustard, icon: Icons.shuffle_rounded),
            ])),
        ]),
      ),
    )),
    if (introJustCompleted) ...[
      const SizedBox(height: 12),
      Container(width: double.infinity, padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: const Color(0xFFE5F3EB),
          borderRadius: BorderRadius.circular(13)),
        child: Text('🎉 Arcade unlocked! Earn XP to open more games.',
          style: captionText(14, color: coal))),
    ],
    const SizedBox(height: 22),
    Text('HOW TRICKY?', style: typewriter(12, color: blue)),
    const SizedBox(height: 9),
    Row(children: ArcadeDifficulty.values.map((level) {
      final active = difficulty == level;
      return Expanded(child: Padding(
        padding: const EdgeInsets.only(right: 5),
        child: GameButton(level.title, compact: true,
          color: active ? mustard : blue, outlined: !active,
          icon: active ? Icons.check_rounded : Icons.adjust_rounded,
          onTap: () => setState(() => difficulty = level)),
      ));
    }).toList()),
    const SizedBox(height: 8),
    Row(children: [
      const Icon(Icons.favorite_rounded, color: coral, size: 18),
      const SizedBox(width: 7),
      Expanded(child: Text('${difficulty.startingHearts} hearts • ${_difficultyNote()}',
        style: captionText(12.5, color: paperWhite))),
    ]),
    const SizedBox(height: 23),
    Text('ARCADE MINIGAMES • FREE PLAY', style: typewriter(12, color: blue)),
    const SizedBox(height: 10),
    ...([...ArcadeMode.values]..sort((a, b) => a.unlockXp.compareTo(b.unlockXp))).map((mode) {
      final unlocked = widget.game.careerXp >= mode.unlockXp;
      final color = modeColors[mode.index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(color: Colors.transparent, child: InkWell(
          onTap: () => unlocked ? _begin(mode) : _showLocked(mode),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: deskBlue, borderRadius: BorderRadius.circular(18),
              border: Border.all(color: unlocked ? color : deskLight,
                width: unlocked ? 1.8 : 1),
            ),
            child: Row(children: [
              Container(height: 52, width: 52, alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: unlocked ? .22 : .08),
                  borderRadius: BorderRadius.circular(14)),
                child: Text(unlocked ? mode.emoji : '🔒',
                  style: const TextStyle(fontSize: 27))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mode.title, style: titleText(19,
                    color: unlocked ? paperWhite : parchment)),
                  const SizedBox(height: 2),
                  Text(unlocked ? mode.subtitle : 'UNLOCK AT ${mode.unlockXp} CAREER XP',
                    style: captionText(12, color: unlocked ? paperWhite : mustard)),
                ])),
              Icon(unlocked ? Icons.play_circle_rounded : Icons.lock_rounded,
                size: 25, color: unlocked ? color : parchment),
            ]),
          ),
        )),
      );
    }),
    const SizedBox(height: 14),
    Center(child: Text('XP IS PERMANENT • UNLOCKS COST NOTHING',
      style: typewriter(11, color: paperWhite), textAlign: TextAlign.center)),
    const SizedBox(height: 12),
    Center(child: TextButton.icon(onPressed: () => _begin(null, firstDay: true),
      icon: const Icon(Icons.school_rounded, color: blue),
      label: Text('REPLAY FIRST DAY', style: captionText(13, color: paperWhite)))),
  ]);

  String _difficultyNote() => switch (difficulty) {
    ArcadeDifficulty.easy => 'all checks open, no timers',
    ArcadeDifficulty.medium => 'fewer checks, timed inbox',
    ArcadeDifficulty.hard => 'few checks, noisy replies, fast inbox',
  };

  void _openAudioSettings() {
    GameAudio.instance.cue(GameCue.tap);
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true, backgroundColor: deskBlue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('AUDIO SETTINGS', style: titleText(24, color: mustard)),
          const SizedBox(height: 10),
          const ScamouflageAudioControls(),
        ]),
      )),
    );
  }

  void _showLocked(ArcadeMode mode) {
    final remaining = mode.unlockXp - widget.game.careerXp;
    _showMessage('${mode.title} unlocks in $remaining more XP. Play a free mode or Endless Mix!');
  }

  void _begin(ArcadeMode? selected, {bool firstDay = false}) {
    if (!firstDay && !widget.game.arcadeUnlocked) {
      _startIntro();
      return;
    }
    if (!firstDay && selected != null && widget.game.careerXp < selected.unlockXp) {
      _showLocked(selected);
      return;
    }
    GameAudio.instance.cue(GameCue.choose);
    setState(() {
      session = ArcadeSession(
        difficulty: firstDay ? ArcadeDifficulty.easy : difficulty,
        selectedMode: selected,
        firstDay: firstDay,
        awardCareerXp: widget.game.awardArcadeXp,
        careerXp: () => widget.game.careerXp,
        recentHistory: widget.game.arcadeHistory.toSet(),
        onCaseGenerated: widget.game.recordArcadeCase,
      );
      hintOn = false;
    });
    // Ranked runs get a one-time server ticket; the tutorial day is unranked.
    runTicket = firstDay
        ? null
        : LeaderboardService.instance.startRun(
            mode: selected, difficulty: difficulty);
    final started = session;
    if (started != null) {
      widget.onPlayingChanged?.call(true);
      GameAudio.instance.enter(_sceneFor(started.current.mode));
    }
  }

  void _useHint() {
    final s = session;
    if (s == null || s.waitingForNext || hintOn) return;
    // Hints are free during the first-day tutorial.
    if (!s.firstDay && !widget.game.spendHint()) {
      _showMessage('Earn 50 Career XP to get another hint.');
      return;
    }
    HapticFeedback.selectionClick();
    GameAudio.instance.cue(GameCue.hint);
    setState(() => hintOn = true);
  }

  void _submitScore(ArcadeSession s) {
    if (identical(_reportedSession, s)) return;
    _reportedSession = s;

    // Lifetime stats are part of the synced player profile.
    widget.game.recordRun(
      rounds: s.round,
      correct: s.successful,
      bestStreak: s.bestStreak,
      score: s.score,
    );

    // The tutorial day never reaches the leaderboard.
    if (s.firstDay) return;
    final ticket = runTicket ?? Future<String?>.value(null);
    runTicket = null;
    LeaderboardService.instance.finishRun(
      ticket: ticket,
      score: s.score,
      rounds: s.round,
      correct: s.successful,
      bestStreak: s.bestStreak,
    );
  }

  void _submit(List<int> answer, bool usedDecisive, {List<String> opened = const []}) {
    final s = session;
    if (s == null || s.waitingForNext) return;
    final xpBefore = widget.game.careerXp;
    final submittedCase = s.current;
    setState(() => s.submit(answer, usedDecisive: usedDecisive));
    final correct = s.lastCorrect == true;
    if (!s.firstDay) {
      dailyChallenges.onAnswer(
        correct: correct,
        correctlyIdentifiedScam: correct && submittedCase.deceptive,
      );
      dailyChallenges.onRoundCompleted(perfect: correct);
    }
    if (s.finished) _submitScore(s);
    final xpAfter = widget.game.careerXp;
    final unlocked = ArcadeMode.values.any((m) =>
        m.unlockXp > xpBefore && m.unlockXp <= xpAfter);
    final gainedRank = CareerProgression.rankAt(xpAfter);
    final newRank = CareerProgression.rankAt(xpBefore).level < gainedRank.level;
    final newBadge = CareerProgression.badges.where((b) =>
        b.xp > xpBefore && b.xp <= xpAfter).toList();
    final newFrame = CareerProgression.frames.where((f) =>
        f.xp > xpBefore && f.xp <= xpAfter).toList();
    newestCareerReward = newRank
        ? 'LEVEL ${gainedRank.level} • ${gainedRank.title} unlocked!'
        : newBadge.isNotEmpty
            ? 'NEW BADGE • ${newBadge.last.name}!'
            : newFrame.isNotEmpty
                ? 'NEW FRAME • ${newFrame.last.name}!'
                : null;
    GameAudio.instance.cue(unlocked || newestCareerReward != null ? GameCue.unlock
        : s.finished ? (s.firstDay ? GameCue.victory : GameCue.defeat)
        : s.lastCorrect == true ? GameCue.correct : GameCue.wrong);
    if (s.firstDay && s.finished) {
      widget.game.finishArcadeIntro();
      introJustCompleted = true;
    }
    HapticFeedback.selectionClick();
  }

  void _next() {
    final s = session;
    if (s == null) return;
    GameAudio.instance.cue(GameCue.tap);
    if (s.finished) {
      newestCareerReward = null;
      setState(() => session = null);
      widget.onPlayingChanged?.call(false);
      GameAudio.instance.enter(MusicScene.menu);
      final level = widget.game.takeLevelUp();
      if (level != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) showLevelUpCelebration(context, widget.game, level);
        });
      }
    } else {
      setState(() { s.next(); hintOn = false; newestCareerReward = null; });
      GameAudio.instance.setScene(_sceneFor(s.current.mode));
    }
  }

  void _showRunOver(ArcadeSession s) {
    GameAudio.instance.cue(GameCue.tap);
    setState(() => _summarySession = s);
  }

  Widget _runOverPopup(ArcadeSession s) {
    final maxH = MediaQuery.sizeOf(context).height * .8;
    return Container(
      color: Colors.black.withValues(alpha: .6),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxH, maxWidth: 520),
        decoration: BoxDecoration(
          color: paperWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: coal, width: 4)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Flexible(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.firstDay ? 'DAY COMPLETE 🎉' : 'RUN OVER',
                  style: titleText(26, color: coal)),
              const SizedBox(height: 6),
              Text(s.firstDay
                  ? 'ARCADE UNLOCKED'
                  : '${s.successful}/${s.round} correct • ${s.score} XP',
                style: captionText(15, color: coal, weight: FontWeight.w800)),
              if (!s.firstDay) ...[
                const SizedBox(height: 14),
                RunSummary(stats: RunStats(s.log)),
              ],
            ]),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: SizedBox(width: double.infinity,
              child: ArcadeButton(
                s.firstDay ? 'OPEN ARCADE!' : 'BACK TO ARCADE',
                color: mustard, onTap: _next))),
        ]),
      ),
    );
  }

  Future<void> _confirmExit() async {
    final shouldExit = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: paperWhite,
      title: Text('LEAVE THIS RUN?', style: titleText(24, color: coal)),
      content: Text('Your earned Career XP stays saved.',
        style: captionText(15, color: coal)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false),
          child: Text('STAY', style: captionText(15, color: coal))),
        TextButton(onPressed: () => Navigator.pop(ctx, true),
          child: Text('LEAVE', style: captionText(15, color: coal))),
      ],
    ));
    if (!mounted || shouldExit != true) return;
    final leaving = session;
    if (leaving != null && !leaving.finished) _submitScore(leaving);
    setState(() => session = null);
    widget.onPlayingChanged?.call(false);
    GameAudio.instance.enter(MusicScene.menu);
    // XP remains earned if the player leaves early; celebrate any new rank.
    final level = widget.game.takeLevelUp();
    if (level != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showLevelUpCelebration(context, widget.game, level);
      });
    }
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      backgroundColor: const Color(0xFF293D5B),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 82),
      duration: const Duration(seconds: 3),
      content: Text(message, style: captionText(14, color: paperWhite)),
    ));
  }

  // ------------------------------------------------------------- gameplay
  Widget _mobileGameHeader(ArcadeSession s, ArcadeCase c) {
    final name = s.firstDay
        ? 'FIRST DAY • ${s.round + (s.waitingForNext ? 0 : 1)}/5'
        : c.mode.title;
    final subtitle = s.firstDay ? c.mode.title
        : '${s.selectedMode == null ? 'ENDLESS MIX' : difficulty.title} • ROUND ${s.round + (s.waitingForNext ? 0 : 1)}';
    final compact = PhoneLayout.compact(context);
    final title = Column(crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, children: [
        Text(name, style: titleText(compact ? 16 : 18, color: accent),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(subtitle, style: typewriter(11, color: paperWhite),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      ]);
    final audioButton = IconButton(
      tooltip: 'Audio settings',
      visualDensity: VisualDensity.compact,
      onPressed: _openAudioSettings,
      icon: const Icon(Icons.volume_up_rounded, size: 21, color: paperWhite),
    );
    final hint = Tooltip(message: 'Hint • +1 every 50 Career XP', child:
      TextButton.icon(
        onPressed: _useHint,
        style: TextButton.styleFrom(backgroundColor: mustard,
          minimumSize: const Size(49, 42),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6)),
        icon: const Icon(Icons.lightbulb_rounded, size: 19, color: coal),
        label: Text(s.firstDay ? 'FREE' : '${widget.game.hintsAvailable}',
          style: typewriter(11, color: coal)),
      ));
    final status = Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.favorite_rounded, color: coal, size: 0),
      for (var i = 0; i < difficulty.startingHearts && !s.firstDay; i++)
        Icon(i < s.hearts ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: coral, size: 16),
      if (s.firstDay) ...[
        const Icon(Icons.favorite_rounded, color: coral, size: 17),
        Text(' ${s.hearts}', style: captionText(13, color: paperWhite)),
      ],
      const SizedBox(width: 9),
      Text('${s.score} XP', style: typewriter(11, color: mustard)),
      if (s.streak >= 2) Text('  🔥${s.streak}',
        style: captionText(13, color: paperWhite)),
    ]);
    return Container(
      padding: EdgeInsets.fromLTRB(5, 6, 12, compact ? 8 : 9),
      decoration: BoxDecoration(color: deskBlue,
        border: Border(bottom: BorderSide(color: accent, width: 2))),
      child: compact
        ? Column(children: [
            Row(children: [
              IconButton(onPressed: _confirmExit,
                tooltip: 'Leave run', icon: const Icon(Icons.close_rounded, color: paperWhite)),
              Expanded(child: title),
              audioButton,
              hint,
            ]),
            Padding(padding: const EdgeInsets.only(left: 48, top: 1),
              child: Align(alignment: Alignment.centerRight, child: status)),
          ])
        : Row(children: [
            IconButton(onPressed: _confirmExit,
              tooltip: 'Leave run', icon: const Icon(Icons.close_rounded, color: paperWhite)),
            Expanded(child: title),
            audioButton,
            hint,
            const SizedBox(width: 10),
            status,
          ]),
    );
  }

  Widget _gameplay() {
    final s = session!;
    final c = s.current;
    return Column(children: [
      _mobileGameHeader(s, c),
      if (!s.firstDay || hintOn) Padding(
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 0),
        child: hintOn ? _hintPanel(c.hint) : _howTo(c.mode)),
      Expanded(child: Stack(children: [
        Positioned.fill(child: KeyedSubtree(
          key: ValueKey('${c.signature}:${s.waitingForNext ? s.round - 1 : s.round}'),
          child: _surface(s, c))),
        if (s.waitingForNext) Positioned.fill(
          child: s.finished && identical(_summarySession, s)
          ? _runOverPopup(s) : _resultOverlay(s, c)),
      ])),
    ]);
  }

  Widget _howTo(ArcadeMode mode) => Row(children: [
    Text(mode.emoji, style: const TextStyle(fontSize: 18)),
    const SizedBox(width: 8),
    Expanded(child: Text(mode.how, style: captionText(13.5, color: paperWhite,
      weight: FontWeight.w700))),
  ]);

  Widget _hintPanel(String message) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFFFF1CC),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: mustard, width: 2)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.lightbulb_rounded, color: coal, size: 22),
      const SizedBox(width: 9),
      Expanded(child: Text(message, style: captionText(14, color: coal))),
    ]),
  );

  Widget _surface(ArcadeSession s, ArcadeCase c) {
    final tut = s.firstDay;
    final d = s.firstDay ? ArcadeDifficulty.easy : difficulty;
    return switch (c.mode) {
      ArcadeMode.trust => TrustView(c: c, d: d, tutorial: tut, hint: hintOn, onSubmit: _submit),
      ArcadeMode.impostor => ImpostorView(c: c, d: d, tutorial: tut, hint: hintOn, onSubmit: _submit),
      ArcadeMode.scamSlam => ChatView(c: c, d: d, tutorial: tut, hint: hintOn, onSubmit: _submit),
      ArcadeMode.rumor => RumorView(c: c, d: d, tutorial: tut, hint: hintOn, onSubmit: _submit),
      ArcadeMode.inbox => InboxView(c: c, d: d, tutorial: tut, hint: hintOn, onSubmit: _submit),
      ArcadeMode.comments => ThreadView(c: c, d: d, tutorial: tut, hint: hintOn, onSubmit: _submit),
      ArcadeMode.clip => ClipView(c: c, d: d, tutorial: tut, hint: hintOn, onSubmit: _submit),
    };
  }

  // --------------------------------------------------------------- result
  Widget _resultOverlay(ArcadeSession s, ArcadeCase c) {
    final correct = s.lastCorrect == true;
    final partial = c.isBatch && !correct && s.lastParts > 0;
    final maxH = MediaQuery.sizeOf(context).height * .72;
    final bg = correct ? const Color(0xFFE5F3E9) : const Color(0xFFFFEDEA);
    final edge = correct ? const Color(0xFF397E61) : const Color(0xFFB7515E);
    final headline = correct ? 'NICE! +${s.lastEarnedXp} XP'
        : partial ? '${s.lastParts}/${c.totalParts} RIGHT • −1 ♥'
        : s.firstDay ? 'GOOD TRY! LET\'S LEARN' : 'NOT QUITE • −1 ♥';
    return Container(
      color: Colors.black.withValues(alpha: .5),
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxH, maxWidth: 560),
        decoration: BoxDecoration(color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: edge, width: 4))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Flexible(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(correct ? Icons.verified_rounded : Icons.lightbulb_outline_rounded,
                  color: coal, size: 30),
                const SizedBox(width: 9),
                Expanded(child: Text(headline, style: titleText(23, color: coal))),
              ]),
              if (correct && s.lastUsedDecisive) ...[
                const SizedBox(height: 6),
                Text('Includes +15 XP for checking decisive evidence!',
                    style: captionText(12, color: coal)),
              ],
              if (newestCareerReward != null) ...[
                const SizedBox(height: 9),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE8A6),
                    borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const Icon(Icons.workspace_premium_rounded, color: coal),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      '$newestCareerReward Visit My Investigator to customize.',
                      style: captionText(13, color: coal))),
                  ]),
                ),
              ],
              if (partial && s.lastEarnedXp > 0) Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('+${s.lastEarnedXp} XP for the right ones',
                  style: captionText(14, color: coal, weight: FontWeight.w700))),
              if (s.streak >= 2) Padding(padding: const EdgeInsets.only(top: 4),
                child: Text('🔥 ${s.streak} in a row',
                  style: captionText(14, color: coal, weight: FontWeight.w800))),
              const SizedBox(height: 12),
              ..._recap(c, s),
              const SizedBox(height: 12),
              Text('WHY IT MATTERS', style: typewriter(11, color: coal)),
              const SizedBox(height: 4),
              Text(c.lesson, style: captionText(15, color: coal)),
              if (c.ruleOfThumb.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('RULE OF THUMB', style: typewriter(11, color: coal)),
                const SizedBox(height: 4),
                Text(c.ruleOfThumb, style: captionText(15, color: coal, weight: FontWeight.w700)),
              ],
            ]),
          )),
          Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SafeArea(top: false, child: SizedBox(width: double.infinity,
              child: ArcadeButton(s.finished ? 'SEE RESULTS' : 'NEXT CHALLENGE',
              color: mustard,
              onTap: s.finished ? () => _showRunOver(s) : _next)))),
        ]),
      ),
    );
  }

  Widget _recapLine(String label, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: typewriter(11, color: coal)),
      const SizedBox(height: 3),
      Text(text, style: captionText(14.5, color: coal, weight: FontWeight.w700)),
    ]));

  Widget _bubble(String text) => Container(
    margin: const EdgeInsets.only(bottom: 7),
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(color: paperWhite,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: stroke, width: 1.5)),
    child: Text(text, style: captionText(14.5, color: coal)));

  List<Widget> _recap(ArcadeCase c, ArcadeSession s) {
    final a = s.lastAnswer;
    switch (c.mode) {
      case ArcadeMode.trust:
      case ArcadeMode.clip:
        final opened = s.lastOpened;
        final wrong = s.lastCorrect == false;
        final settled = c.decisiveIds.any(opened.contains);
        final keyClue = c.tools.firstWhere(
            (t) => t.relevance == Relevance.decisive);
        return [
          for (final t in c.tools)
            if (t.relevance == Relevance.decisive)
              _recapLine('KEY CLUE • ${t.emoji} ${t.label}', t.text),
          if (wrong)
            for (final t in c.tools)
              if (t.relevance == Relevance.decoy && opened.contains(t.id))
                _recapLine('DIDN\'T SETTLE IT • ${t.emoji} ${t.label}',
                    'You opened this, but it doesn\'t decide the case on its own.'),
          if (!settled)
            _recapLine('YOU SKIPPED • ${keyClue.emoji} ${keyClue.label}',
                wrong
                    ? 'This check would have settled it. Open it before you decide.'
                    : 'You got it right without it. Opening it makes the answer certain.'),
        ];
      case ArcadeMode.impostor:
        return [_recapLine('ANSWER', c.correctChoice == 2
            ? 'Both accounts are OK.'
            : 'Flag account ${c.correctChoice == 0 ? 'A' : 'B'}.')];
      case ArcadeMode.scamSlam:
        final chosen = a.isEmpty ? 0 : a.first;
        return [
          if (s.lastCorrect != true)
            _recapLine('BEST MOVE', c.choices[c.correctChoice].text),
          Text('WHAT HAPPENS NEXT', style: typewriter(11, color: coal)),
          const SizedBox(height: 6),
          for (final f in c.followUps[chosen] ?? const <String>[]) _bubble(f),
        ];
      case ArcadeMode.rumor:
        return switch (c.rumorTask!) {
          RumorTask.order => [_recapLine('CORRECT ORDER',
              [for (var i = 0; i < c.correct.length; i++)
                '${i + 1}. ${c.cards[c.correct[i]].title}'].join('\n'))],
          RumorTask.wordEdit => [_recapLine('CHANGED WORDS',
              c.correct.map((i) => c.tokens[i]).join(' '))],
          _ => [_recapLine('RIGHT ANSWER',
              '${c.cards[c.correctChoice].title}: ${c.cards[c.correctChoice].body}')],
        };
      case ArcadeMode.inbox:
        return [for (var i = 0; i < c.emails.length; i++) Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(i < a.length && a[i] == c.correct[i]
                ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: coal, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${c.emails[i].spam ? 'SPAM' : 'KEEP'} • ${c.emails[i].subject}',
                  style: captionText(14, color: coal, weight: FontWeight.w800)),
                Text(c.emails[i].why, style: captionText(13.5, color: coal)),
              ])),
          ]))];
      case ArcadeMode.comments:
        final wrong = [for (final i in a) if (!c.comments[i].violates) i];
        return [
          if (c.correct.isEmpty) _recapLine('ANSWER',
              'None of these comments break the rules.'),
          for (final i in c.correct) _recapLine('REMOVE • ${c.comments[i].handle}',
              c.comments[i].reason),
          for (final i in wrong) _recapLine('ALLOWED • ${c.comments[i].handle}',
              'Harsh or annoying, but not a rule break.'),
        ];
    }
  }
}