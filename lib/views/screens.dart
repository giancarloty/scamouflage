import 'account_screens.dart';
import 'package:flutter/material.dart';
import 'arcade_screens.dart';
import 'case_media.dart';
import 'career_identity.dart';
import '../controllers/engine.dart';
import '../controllers/navigation_controller.dart';
import '../services/game_audio.dart';
import '../models/models.dart';
import 'mascot.dart';
import 'theme.dart';

class GameScreens extends StatefulWidget {
  final GameEngine game;
  const GameScreens({super.key, required this.game});

  @override
  State<GameScreens> createState() => _GameScreensState();
}

class _GameScreensState extends State<GameScreens> {
  final navigation = NavigationController();
  GameView get view => navigation.current;
  set view(GameView next) { navigation.current = next; }
  GameEngine get g => widget.game;
  PlayCase get item => g.currentCase;
  double timeline = 0;
  double compare = 0;
  double videoPosition = .25;
  bool showingResult = false;
  bool arcadePlaying = false;
  bool mascotIntroScheduled = false;
  @override
  void initState() {
    super.initState();
    g.addListener(_refresh);
  }

  @override
  void dispose() {
    g.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {});
    if (g.ready && !g.mascotIntroduced && !mascotIntroScheduled) {
      mascotIntroScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _welcomeMascot());
    }
  }

  Future<void> _welcomeMascot() async {
    if (!mounted || !g.ready || g.mascotIntroduced) return;
    await g.introduceMascot();
    if (!mounted || view != GameView.home) return;
    await showDialog<void>(context: context, builder: (dialogContext) => Dialog(
      backgroundColor: deskBlue,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: mustard, width: 3)),
      child: SingleChildScrollView(child: Padding(
        padding: const EdgeInsets.all(22), child: Column(
          mainAxisSize: MainAxisSize.min, children: [
            MascotAvatar(game: g, size: 142),
            const SizedBox(height: 10),
            Text('MEET CHAMELEO!', style: titleText(27, color: mustard)),
            const SizedBox(height: 9),
            Text('Uy, welcome! I\'m ChameLeo, your fact-checking chameleon. '
              'Catch scams, earn XP, and unlock my disguises and nicknames!',
              style: captionText(14, color: paperWhite), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text('Tap Arcade for minigames or Shifts for the story campaign.',
              style: captionText(13, color: blue), textAlign: TextAlign.center),
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, child: GameButton('LET\'S INVESTIGATE!',
              onTap: () => Navigator.pop(dialogContext),
              icon: Icons.rocket_launch_rounded)),
          ],
        ),
      )),
    ));
  }

  void _selectTab(GameView target) {
    if (!navigation.openTab(target, arcadePlaying: arcadePlaying)) return;
    // Only an actual challenge can switch the menu music to a game track.
    GameAudio.instance.enter(MusicScene.menu);
    GameAudio.instance.cue(GameCue.choose);
    setState(() {});
  }

  void _openIdentity() => _selectTab(GameView.profile);
  void _openArcade() => _selectTab(GameView.arcade);

  Future<void> _offerLevelUp() async {
    final next = g.takeLevelUp();
    if (!mounted || next == null) return;
    GameAudio.instance.cue(GameCue.unlock);
    await showLevelUpCelebration(context, g, next);
  }

  void _startFromMenu(int shift, {bool endless = false}) {
    GameAudio.instance.cue(GameCue.choose);
    if (!g.tutorialFinished) {
      g.startTutorial();
    } else {
      g.startShift(shift, endless: endless);
    }
    if (g.inShift) {
      // Switch tracks only after a shift really started.
      GameAudio.instance.enter(MusicScene.career);
      setState(() {
        navigation.enterCareerChallenge();
        showingResult = false;
        timeline = 0;
        compare = 0;
        videoPosition = .25;
      });
      if (g.isTraining) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _welcomeTraining());
      }
    }
  }

  void _inspect(String key) {
    GameAudio.instance.cue(GameCue.inspect);
    final hit = g.inspect(key);
    if (hit == null && key == 'source') {
      _verify();
    }
  }

  void _verify() {
    GameAudio.instance.cue(GameCue.inspect);
    if (g.verifiedSource) {
      _toast('Already checked this source.');
      return;
    }
    final result = g.verify();
    if (result != null && mounted) {
      _showSourcePopup(result);
    }
  }

  void _toast(String message) {
    // Fixed contrast: the default Material snack bar theme made some messages
    // unreadable against the light-yellow game palette on iPhone Safari.
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF24334D),
      margin: EdgeInsets.fromLTRB(12, 4, 12, PhoneLayout.short(context)?64:90),
      content: Text(message, style: captionText(14, color: paperWhite)),
      duration: const Duration(seconds: 2),
    ));
  }

  void _stamp(Verdict verdict) {
    if (g.isTraining && g.currentIndex == 0 && g.tutorialStep < 2) {
      _toast('First tap the message, then check its source!');
      return;
    }
    final result = g.decide(verdict);
    if (result == null) return;
    GameAudio.instance.cue(result.correct ? GameCue.correct : GameCue.wrong);
    setState(() {
      showingResult = true;
    });
  }

  void _next() {
    GameAudio.instance.cue(GameCue.tap);
    g.next();
    if (g.finished) {
      GameAudio.instance.enter(MusicScene.menu);
      GameAudio.instance.cue(GameCue.victory);
    }
    setState(() {
      timeline = 0;
      compare = 0;
      videoPosition = .25;
      showingResult = false;
      if (g.finished) {
        navigation.showCareerSummary();
      } else {
        navigation.enterCareerChallenge();
      }
    });
    if (g.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _offerLevelUp());
    }
  }

  void _exit() {
    GameAudio.instance.enter(MusicScene.menu);
    GameAudio.instance.cue(GameCue.tap);
    setState(() {
      showingResult = false;
      navigation.returnHome();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _offerLevelUp());
  }

  void _openCareer() => _selectTab(GameView.career);

  void _continueCareer() {
    if (g.isTraining) {
      _startFromMenu(1);
      return;
    }
    if (g.mode == Mode.endless) {
      _startFromMenu(7, endless: true);
      return;
    }
    if (g.shiftNumber >= 6) {
      _openCareer();
      return;
    }
    _startFromMenu(g.shiftNumber + 1);
  }

  Future<void> _skipTraining() async {
    await g.skipTutorial();
    if (mounted) _startFromMenu(1);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: view == GameView.home,
      onPopInvokedWithResult: (popped, _) {
        if (!popped && !(view == GameView.arcade && arcadePlaying)) _exit();
      },
      child: Scaffold(
        backgroundColor: midnight,
        bottomNavigationBar: _showTabs ? _bottomNav() : null,
        body: SafeArea(
          child: DeskBackdrop(
            child: g.ready
                ? Stack(children: [
                    Positioned.fill(
                      child: switch (view) {
                        GameView.home => _home(),
                        GameView.arcade => ArcadeHub(
                          game: g, embedded: true,
                          onBack: () => _selectTab(GameView.home),
                          onOpenProfile: _openIdentity,
                          onPlayingChanged: (active) {
                            if (mounted) setState(() => arcadePlaying = active);
                          }),
                        GameView.career => _careerHub(),
                        GameView.profile => CareerIdentityScreen(
                          game: g, onBack: () => _selectTab(GameView.home)),
                        GameView.desk => _desk(),
                        GameView.summary => _summary(),
                        GameView.leaderboard => const LeaderboardScreen(embedded: true),
                      },
                    ),
                    if (view == GameView.desk && showingResult && g.pendingResult != null)
                      _resultOverlay(),
                  ])
                : Center(child: Text('BOOTING TAMBAYAN...',style: typewriter(13,color:mustard))),
          ),
        ),
      ),
    );
  }

  bool get _showTabs => navigation.onMenu && !arcadePlaying;

  Widget _bottomNav() {
    const tabs = <(GameView, String, IconData)>[
      (GameView.home, 'HOME', Icons.home_rounded),
      (GameView.arcade, 'ARCADE', Icons.sports_esports_rounded),
      (GameView.career, 'SHIFTS', Icons.work_history_rounded),
      (GameView.leaderboard, 'RANKS', Icons.emoji_events_rounded),
      (GameView.profile, 'PROFILE', Icons.person_rounded),
    ];
    
    return SafeArea(top: false, child: Container(
      decoration: const BoxDecoration(color: deskBlue,
        border: Border(top: BorderSide(color: deskLight, width: 1.5))),
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 5),
      child: Row(children: [
        for (final tab in tabs) Expanded(child: Semantics(
          button: true, selected: view == tab.$1,
          label: '${tab.$2} tab',
          child: InkWell(
            key: ValueKey('nav-${tab.$2.toLowerCase()}'),
            borderRadius: BorderRadius.circular(14),
            onTap: () => _selectTab(tab.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 190),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                color: view == tab.$1 ? mustard : Colors.transparent,
                borderRadius: BorderRadius.circular(14)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(tab.$3, size: 23,
                  color: view == tab.$1 ? coal : parchment),
                const SizedBox(height: 3),
                Text(tab.$2,
                  style: typewriter(9,
                    color: view == tab.$1 ? coal : parchment),
                  maxLines: 1, overflow: TextOverflow.fade),
              ]),
            ),
          ),
        )),
      ]),
    ));
  }

  Widget _page(List<Widget> widgets) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(17,16,17,28),
      child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:widgets),
      )),
    );
  }

  Widget _home() {
    return _page([
      Row(children:[
        Expanded(child:Text('SCAMOUFLAGE',style:titleText(26,color:mustard))),
        IconButton(
          tooltip: 'Play menu music',
          onPressed: () {
            GameAudio.instance.enter(MusicScene.menu);
            GameAudio.instance.cue(GameCue.choose);
          },
          icon: const Icon(Icons.music_note_rounded, color: mint)),
        IconButton(onPressed:_settings,tooltip:'Settings',icon:const Icon(Icons.settings_rounded,color:paperWhite)),
      ]),
      const SizedBox(height:12),
      Material(color:Colors.transparent,child:InkWell(
        onTap:_openArcade,
        borderRadius:BorderRadius.circular(25),
        child:Container(width:double.infinity,padding:const EdgeInsets.all(18),
          decoration:BoxDecoration(
            gradient:const LinearGradient(colors:[Color(0xFF58457B),Color(0xFF21445A)]),
            borderRadius:BorderRadius.circular(25),
            border:Border.all(color:mustard,width:3),
          ),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            InkTag(g.arcadeUnlocked ? 'TAP TO ENTER ARCADE' : 'TAP FOR ARCADE FIRST DAY',color:mustard,icon:Icons.touch_app_rounded),
            const SizedBox(height:12),
            Row(children:[
              Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text('SCAMOUFLAGE\nARCADE!',style:titleText(PhoneLayout.narrow(context)?25:32,color:paperWhite)),
                const SizedBox(height:10),
                Text('Seven different ways to catch digital tricks.',style:captionText(14,color:paperWhite)),
                const SizedBox(height:16),
                const Icon(Icons.play_circle_fill_rounded,color:mustard,size:48),
              ])),
              MascotAvatar(game:g,size:PhoneLayout.narrow(context)?93:142),
            ]),
          ]),
        ),
      )),
      const SizedBox(height:15),
      GameButton(g.arcadeUnlocked ? 'OPEN ARCADE HUB' : 'ARCADE FIRST DAY • 5 MINI-GAMES',
        onTap: _openArcade, color:mustard,
        icon: g.arcadeUnlocked ? Icons.sports_esports_rounded : Icons.school_rounded),
      const SizedBox(height:20),
      Row(children:[
        Expanded(child:_miniStat('SAFETY','${g.safety}%',Icons.shield_outlined,blue)),
        const SizedBox(width:9),
        Expanded(child:_miniStat('FAIR PLAY','${g.fairness}%',Icons.balance_rounded,pink)),
      ]),
      const SizedBox(height:23),
      Material(color:Colors.transparent, child:InkWell(
        onTap:_openCareer,
        borderRadius:BorderRadius.circular(20),
        child:Container(width:double.infinity,padding:const EdgeInsets.all(18),
          decoration:BoxDecoration(color:deskBlue,borderRadius:BorderRadius.circular(20),
            border:Border.all(color:blue,width:2)),
          child:Row(children:[
            Container(padding:const EdgeInsets.all(12),
              decoration:BoxDecoration(color:blue,borderRadius:BorderRadius.circular(14)),
              child:const Icon(Icons.work_history_rounded,color:coal,size:29)),
            const SizedBox(width:13),
            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text('CAREER SHIFTS',style:titleText(24,color:paperWhite)),
              const SizedBox(height:5),
              Text('Play Shift 1 → 2 → 3 in order. Replay any unlocked shift.',
                style:captionText(12,color:parchment)),
              const SizedBox(height:6),
              Text(g.unlockedShift > 6 ? 'CAREER FINISHED • 6/6' : 'NEXT • SHIFT ${g.unlockedShift}',style:typewriter(11,color:blue)),
            ])),
            const Icon(Icons.arrow_forward_ios_rounded,color:blue,size:22),
          ])),
      )),
      const SizedBox(height:18),
      Material(color: Colors.transparent, child: InkWell(
        onTap: _openIdentity,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: deskBlue, borderRadius: BorderRadius.circular(18),
            border: Border.all(color: mint, width: 1.5)),
          child: Row(children: [
            const Icon(Icons.workspace_premium_rounded, color: mint, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('LEVEL ${g.careerRank.level} • ${g.equippedTitle}',
                style: captionText(15, color: paperWhite)),
              Text('${g.careerXp} CAREER XP • TITLES, BADGES & FRAMES',
                style: typewriter(10, color: mint)),
              const SizedBox(height: 6),
              ClipRRect(borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: g.careerLevelProgress,
                  minHeight: 5, color: mint, backgroundColor: midnight)),
            ])),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: mint),
          ]),
        ),
      )),
      const SizedBox(height: 9),
      Center(child: Text('PROFILE & UNLOCKS • PLAY OFFLINE',
        style: captionText(12, color: parchment))),
    ]);
  }

  Widget _careerHub() => _page([
    Row(children:[
      IconButton(onPressed:_exit,tooltip:'Back to main menu',
        icon:const Icon(Icons.arrow_back_rounded,color:paperWhite)),
      Expanded(child:Text('CAREER SHIFTS',style:titleText(27,color:paperWhite))),
    ]),
    const SizedBox(height:8),
    Text('STORY CAMPAIGN  •  SIX SHIFTS IN ORDER',style:typewriter(11,color:blue)),
    const SizedBox(height:9),
    Text('Finish each shift to unlock the next. Arcade minigames are on the main menu.',
      style:captionText(13,color:parchment)),
    const SizedBox(height:15),
    GameButton(g.tutorialFinished
        ? (g.unlockedShift > 6 ? 'CAREER COMPLETE • REPLAY SHIFT 6' : 'PLAY NEXT • SHIFT ${g.unlockedShift}')
        : 'START CAREER TRAINING',
      onTap:()=>_startFromMenu(g.unlockedShift.clamp(1,6).toInt()),
      color:mustard,icon:Icons.play_arrow_rounded),
    const SizedBox(height:19),
    Text('YOUR SHIFT PATH',style:typewriter(11,color:blue)),
    const SizedBox(height:10),
    ...List.generate(shifts.length,(i){
      final number=i+1;
      final unlocked=number<=g.unlockedShift;
      final next=g.unlockedShift<=6 && number==g.unlockedShift;
      final info=shifts[i];
      final tint=[mustard,blue,coral,pink,mint,parchment][i];
      return Padding(padding:const EdgeInsets.only(bottom:11),child:Material(
        color:Colors.transparent,child:InkWell(
          onTap:unlocked?()=>_startFromMenu(number):null,
          borderRadius:BorderRadius.circular(16),
          child:Container(padding:const EdgeInsets.all(14),
            decoration:BoxDecoration(color:deskBlue,borderRadius:BorderRadius.circular(16),
              border:Border.all(color:next?mustard:unlocked?tint:deskLight,
                width:next?2.3:1.2)),
            child:Row(children:[
              Container(height:45,width:45,alignment:Alignment.center,
                decoration:BoxDecoration(color:unlocked?tint:deskLight,borderRadius:BorderRadius.circular(12)),
                child:Icon(unlocked?info.icon:Icons.lock_outline_rounded,color:coal,size:25)),
              const SizedBox(width:13),
              Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text('SHIFT $number${next?' • UP NEXT':''}',style:typewriter(10,color:next?mustard:blue)),
                const SizedBox(height:3),
                Text(info.name,style:captionText(16,color:paperWhite,weight:FontWeight.w800)),
                const SizedBox(height:3),
                Text(!unlocked?'LOCKED • FINISH THE PREVIOUS SHIFT':
                  next?'TAP TO PLAY':'UNLOCKED • TAP TO REPLAY',
                  style:captionText(11,color:parchment)),
              ])),
              Icon(unlocked?Icons.chevron_right_rounded:Icons.lock_rounded,color:tint),
            ])),
        ),
      ));
    }),
    if (g.canPlayEndless) ...[
      const SizedBox(height:10),
      GameButton('CAREER ENDLESS • CLASSIC MODERATION',
        onTap:()=>_startFromMenu(7,endless:true),
        color:blue,icon:Icons.all_inclusive_rounded),
    ],
    const SizedBox(height:10),
    GameButton('BACK TO MAIN MENU',onTap:_exit,outlined:true,color:blue,
      icon:Icons.home_rounded),
  ]);

  Widget _miniStat(String label,String value,IconData icon,Color color){
    return Container(padding:const EdgeInsets.all(12),
      decoration:BoxDecoration(color:deskBlue,borderRadius:BorderRadius.circular(15),border:Border.all(color:deskLight)),
      child:Row(children:[Icon(icon,color:color),const SizedBox(width:9),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(value,style:titleText(23)),Text(label,style:typewriter(11,color:parchment)),
      ]))]),
    );
  }

  void _settings(){
    GameAudio.instance.enter(MusicScene.menu);
    GameAudio.instance.cue(GameCue.tap);
    showModalBottomSheet<void>(
      context:context,backgroundColor:deskBlue,isScrollControlled:true,
      shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(24))),
      builder:(context)=>SafeArea(child:SingleChildScrollView(child:Padding(
        padding:const EdgeInsets.all(20),
        child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('SETTINGS',style:titleText(26,color:mustard)),
          const SizedBox(height:8),
          const ScamouflageAudioControls(),
          const Divider(color: deskLight, height: 22),
          SwitchListTile(
            title:Text('Haptic feedback',style:captionText(14)),
            value:g.haptics,onChanged:(v){g.setHaptics(v);Navigator.pop(context);_settings();},
            activeThumbColor:mustard,
          ),
          ListTile(
            leading:const Icon(Icons.school_outlined,color:blue),
            title:Text('Replay interactive tutorial',style:captionText(14)),
            onTap: () async {
              Navigator.pop(context);
              await g.resetTutorial();
              if (!mounted) return;
              g.startTutorial();
              GameAudio.instance.enter(MusicScene.career);
              setState(() => navigation.enterCareerChallenge());
              WidgetsBinding.instance.addPostFrameCallback((_) => _welcomeTraining());
            },
          ),
          const SizedBox(height:8),
          Text('Progress stays on this device. No account or internet connection.',style:captionText(12,color:parchment)),
        ]),
      ))),
    );
  }

  /// The three essential areas always stay visible on a phone:
  /// short lesson at the top, case in the middle, and actions at the bottom.
  Widget _desk(){
    return Column(children:[
      Container(color:deskBlue,padding:const EdgeInsets.fromLTRB(6,5,12,7),child:Row(children:[
        IconButton(onPressed:_exit,tooltip:'Exit shift',icon:const Icon(Icons.close_rounded,color:parchment,size:23)),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(g.isTraining?'YOUR FIRST SHIFT':'SHIFT ${g.shiftNumber}  •  ${item.kind.label}',style:typewriter(11,color:blue),maxLines:1,overflow:TextOverflow.ellipsis),
          Text('Case ${g.currentIndex+1} of ${g.queue.length}',style:captionText(13,color:parchment)),
        ])),
        if(g.isTraining) TextButton(onPressed:_skipTraining,child:Text('SKIP',style:typewriter(11,color:mustard)))
        else IconButton(icon:const Icon(Icons.help_outline_rounded,color:mustard,size:24),tooltip:'How do I play?',onPressed:_quickHelp),
        Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:5),decoration:BoxDecoration(color:midnight,borderRadius:BorderRadius.circular(10)),child:Text('${g.shiftXp>=0?'+':''}${g.shiftXp} XP',style:titleText(18,color:mustard))),
      ])),
      LinearProgressIndicator(value:(g.currentIndex+1)/g.queue.length,color:mustard,backgroundColor:deskLight,minHeight:4),
      if(g.isTraining) _tutorialHint(),
      Expanded(child:SingleChildScrollView(
        key:ValueKey('case-scroll-${g.currentIndex}'),
        padding:const EdgeInsets.fromLTRB(14,12,14,12),
        physics:const BouncingScrollPhysics(),
        child:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:520),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(children:[InkTag(item.kind.label,color:blue,icon:item.kind.icon),const Spacer(),_hintButton()]),
          const SizedBox(height:10),
          _caseSurface(),
          const SizedBox(height:7),
        ]))),
      )),
      _bottomControls(),
    ]);
  }

  Widget _bottomControls(){
    return Container(
      width:double.infinity,
      padding:EdgeInsets.fromLTRB(12,PhoneLayout.short(context)?6:10,12,8),
      decoration:const BoxDecoration(color:deskBlue,border:Border(top:BorderSide(color:blue,width:1.2))),
      child:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:520),child:
        ConstrainedBox(constraints:BoxConstraints(
          maxHeight:PhoneLayout.footerLimit(context,multipleChoices:true)),
          child:Column(mainAxisSize:MainAxisSize.min,children:[
            Flexible(fit:FlexFit.loose,child:SingleChildScrollView(
              physics:const BouncingScrollPhysics(),
              child:Column(mainAxisSize:MainAxisSize.min,children:[
                _evidenceTray(),
                const SizedBox(height:6),
                SizedBox(width:double.infinity,child:GameButton(
                  g.verifiedSource?'SOURCE READ':'CHECK SOURCE',
                  onTap:g.verifiedSource?null:_verify,
                  icon:Icons.fact_check_outlined,color:blue,compact:true)),
                const SizedBox(height:8),
              ]),
            )),
            Row(children:[
              Expanded(child:Stamp(text:_approveLabel(),icon:Icons.check_circle_rounded,
                color:const Color(0xFF188865),onTap:()=>_stamp(Verdict.approve))),
              const SizedBox(width:11),
              Expanded(child:Stamp(text:_rejectLabel(),icon:Icons.block_rounded,
                color:const Color(0xFFB64657),onTap:()=>_stamp(Verdict.reject))),
            ]),
          ]),
        ))),
    );
  }

  void _quickHelp(){
    showDialog<void>(context:context,builder:(dialogContext)=>PhoneDialog(
      backgroundColor:paperWhite,
      shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(20)),
      child:Padding(padding:const EdgeInsets.all(20),child:Column(mainAxisSize:MainAxisSize.min,children:[
        MascotAvatar(game:g,size:85),
        Text('YOU GOT THIS!',style:titleText(24,color:coal)),
        const SizedBox(height:12),
        _helpLine(Icons.touch_app_rounded,'Tap the case for a clue.'),
        _helpLine(Icons.fact_check_outlined,'Read source information, then decide. Blue means neutral.'),
        _helpLine(Icons.check_circle_rounded,'Green keeps; red removes.'),
        const SizedBox(height:15),
        GameButton('BACK TO THE CASE',onTap:()=>Navigator.pop(dialogContext)),
      ])),
    ));
  }

  Widget _helpLine(IconData icon,String text)=>Padding(padding:const EdgeInsets.symmetric(vertical:6),child:Row(children:[
    Icon(icon,color:coal,size:23),const SizedBox(width:10),
    Expanded(child:Text(text,style:captionText(14,color:coal))),
  ]));

  void _welcomeTraining(){
    if (!mounted || !g.isTraining || g.currentIndex!=0 || g.tutorialStep!=0 || showingResult) return;
    showDialog<void>(context:context,barrierDismissible:true,builder:(dialogContext)=>PhoneDialog(
      backgroundColor:paperWhite,
      shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(22)),
      child:Padding(padding:const EdgeInsets.all(20),child:Column(mainAxisSize:MainAxisSize.min,children:[
        MascotAvatar(game:g,size:110),
        const SizedBox(height:4),
        Text('HEY, ROOKIE!',style:titleText(27,color:coal)),
        const SizedBox(height:10),
        Text('Help Chief sort two messages.\nTap what looks interesting, check the source, then choose.',style:captionText(15,color:coal),textAlign:TextAlign.center),
        const SizedBox(height:17),
        GameButton('LET ME TRY!',onTap:()=>Navigator.pop(dialogContext),icon:Icons.play_arrow_rounded),
      ])),
    ));
  }

  void _showSourcePopup(Hotspot finding){
    showDialog<void>(context:context,builder:(dialogContext)=>PhoneDialog(
      backgroundColor:paperWhite,
      shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(22)),
      child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:390),child:Padding(padding:const EdgeInsets.all(18),child:Column(mainAxisSize:MainAxisSize.min,children:[
        const Icon(Icons.manage_search_rounded,color:Color(0xFF326A98),size:50),
        const SizedBox(height:8),
        Text('SOURCE INFORMATION',style:titleText(23,color:coal)),
        const SizedBox(height:8),
        Text(finding.reveal,style:captionText(15,color:coal),textAlign:TextAlign.center),
        const SizedBox(height:14),
        GameButton('GOT IT',onTap:()=>Navigator.pop(dialogContext),icon:Icons.check_rounded),
      ]))),
    ));
  }

  String _approveLabel()=>switch(item.kind){
    CaseKind.report=>'DISMISS',CaseKind.sms=>'DELIVER',CaseKind.email=>'DELIVER',CaseKind.profile=>'ALLOW',_=>'KEEP',
  };
  String _rejectLabel()=>switch(item.kind){
    CaseKind.report=>'UPHOLD',CaseKind.sms=>'BLOCK',CaseKind.email=>'BLOCK',CaseKind.profile=>'BLOCK',_=>'REMOVE',
  };

  Widget _tutorialHint(){
    final second=g.currentIndex>0;
    final step=g.tutorialStep;
    final message=second?'Your turn! A price alone is not proof.':
      step==0?'1. Tap the white message.':
      step==1?'2. Tap CHECK SOURCE below.':
      '3. Stamp BLOCK at the bottom!';
    return Container(width:double.infinity,padding:const EdgeInsets.fromLTRB(13,10,13,10),color:mustard,child:Row(children:[
      const Icon(Icons.touch_app_rounded,color:coal,size:24),
      const SizedBox(width:9),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(second?'PRACTICE ON YOUR OWN': 'CHIEF • QUICK TUTORIAL',style:typewriter(11,color:coal)),
        const SizedBox(height:2),
        Text(message,style:captionText(14,color:coal,weight:FontWeight.w800)),
      ])),
      if(!second)Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:5),decoration:BoxDecoration(color:coal,borderRadius:BorderRadius.circular(9)),child:Text('${step+1}/3',style:typewriter(11,color:paperWhite))),
    ]));
  }

  /// A single compact evidence strip. Full clue paragraphs don't pile up.
  /// Selecting a clue cycles its interpretation, but is OPTIONAL for beginners.
  /// No extra MARK button: tapping the content itself collects the clue.
  /// All source notes remain neutral blue; never show a verdict color.
  Widget _evidenceTray() {
    final findings = item.clues.where((h) => g.revealed.contains(h.id)).toList();
    if (findings.isEmpty) {
      return Row(children: [
        const Icon(Icons.touch_app_rounded, color: blue, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text('Tap a detail to inspect it.',
          style: captionText(13, color: parchment))),
      ]);
    }
    final last = findings.last;
    const tint = blue; // Inspection never color-codes the eventual verdict.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFF374961),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tint, width: 1.5)),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded, color: blue, size: 23),
        const SizedBox(width: 9),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(last.verification ? 'SOURCE NOTES' : 'WHAT YOU FOUND',
            style: typewriter(11, color: tint)),
          Text(last.reveal, style: captionText(12, color: paperWhite),
            maxLines: 3, overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }

  Widget _hintButton() => TextButton.icon(
    onPressed: _hint,
    icon: const Icon(Icons.lightbulb_rounded, color: coal, size: 17),
    label: Text('HINT ${g.hintsAvailable}', style: typewriter(11, color: coal)),
    style: TextButton.styleFrom(backgroundColor: mustard,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
  );

  void _hint() {
    GameAudio.instance.cue(GameCue.hint);
    if (!g.spendHint()) {
      _toast('Get another hint after earning 50 more Career XP.');
      return;
    }
    final text = switch (item.kind) {
      CaseKind.post => 'Check the original date and whether the caption matches the document.',
      CaseKind.profile => 'Account age alone proves nothing. Compare identity claims and official contact.',
      CaseKind.sms => 'Think about the request, not just the amount of money mentioned.',
      CaseKind.email => 'Read the sender address and look for requests for private login codes.',
      CaseKind.report => 'A lot of reports do not automatically mean a rule was broken.',
      CaseKind.video => 'Look for what the full recording says before judging the short clip.',
    };
    _toast('💡 $text');
  }

  Widget _caseSurface()=>switch(item.kind){
    CaseKind.post=>_post(), CaseKind.profile=>_profile(),
    CaseKind.sms=>_sms(), CaseKind.email=>_email(),
    CaseKind.report=>_report(), CaseKind.video=>_video(),
  };

  // Identical neutral cue on every tappable clue. The UI never gives away
  // the correct verdict before an independent source check.
  Widget _hot(Widget child,String key){
    return Material(color:Colors.transparent,child:InkWell(
      onTap:()=>_inspect(key),borderRadius:BorderRadius.circular(9),
      child:Container(
        padding:const EdgeInsets.symmetric(horizontal:4,vertical:4),
        decoration:const BoxDecoration(border:Border(bottom:BorderSide(color:Color(0xFFB5B8CB),width:1,style:BorderStyle.solid))),
        child:child,
      ),
    ));
  }
  Widget _sheet({required Widget child,Color background=paperWhite}){
    return Container(width:double.infinity,decoration:BoxDecoration(
      color:background,borderRadius:BorderRadius.circular(18),
      border:Border.all(color:stroke,width:2),
      boxShadow:const [BoxShadow(color:stroke,offset:Offset(3,5))],
    ),child:child);
  }
  Widget _author(){
    return _hot(Row(mainAxisSize:MainAxisSize.min,children:[
      CircleAvatar(radius:20,backgroundColor:mustard,
        child:Text(item.author.isEmpty?'?':item.author.substring(0,1),style:titleText(23,color:coal))),
      const SizedBox(width:9),
      Flexible(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(item.author,style:captionText(14,color:coal,weight:FontWeight.bold),maxLines:1,overflow:TextOverflow.ellipsis),
        Text(item.handle,style:captionText(11,color:mutedInk),maxLines:1,overflow:TextOverflow.ellipsis),
      ])),
    ]),'identity');
  }

  Widget _post(){
    final original=compare>.5;
    return _sheet(child:Padding(padding:const EdgeInsets.all(13),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _author(),
      const SizedBox(height:10),
      _hot(Text(item.body,style:captionText(14,color:coal)),'context'),
      const SizedBox(height:12),
      GestureDetector(
        onTap:()=>_toggleCompare(),
        onHorizontalDragEnd:(_)=>_toggleCompare(),
        child:Semantics(button:true,label:'Compare the shared image to its source. Tap or swipe.',child:AnimatedSwitcher(
          duration:const Duration(milliseconds:200),
          child:CaseMedia(key:ValueKey('post:${item.id}:$original'),topic:item.topic,caption:item.artifact,sourceCaption:'Original source view • check dates and context',original:original,height:210),
        )),
      ),
      const SizedBox(height:10),
      SizedBox(width:double.infinity,child:GameButton(original?'SHOW SHARED POST':'COMPARE ORIGINAL',onTap:_toggleCompare,icon:Icons.compare_rounded,color:blue,compact:true)),
      const SizedBox(height:8),
      Row(children:[const Icon(Icons.favorite_border_rounded,color:mutedInk,size:17),Text(' ${item.likes}',style:captionText(12,color:mutedInk)),const SizedBox(width:15),const Icon(Icons.chat_bubble_outline,color:mutedInk,size:17),Text(' ${item.reports} replies',style:captionText(12,color:mutedInk))]),
    ])));
  }

  void _toggleCompare(){
    setState(()=>compare=compare>.5?0:1);
    _inspect('context');
  }

  Widget _profile(){
    return _sheet(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      CaseMedia(topic:item.topic,caption:item.headline,height:116),
      Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        _author(),const SizedBox(height:9),
        _hot(Row(children:[const Icon(Icons.calendar_month_outlined,color:coal,size:18),const SizedBox(width:8),
          Text('Joined ${item.accountAge}',style:captionText(12,color:coal))]),'identity'),
        const SizedBox(height:7),Text('${item.followers} followers',style:captionText(12,color:mutedInk)),
        const SizedBox(height:10),Text(item.body,style:captionText(13,color:coal)),
        const SizedBox(height:9),
        SizedBox(width:double.infinity,child:GameButton(
          timeline>.65?'HIDE ACCOUNT HISTORY':'VIEW ACCOUNT HISTORY',
          onTap:(){setState(()=>timeline=timeline>.65?0:1);_inspect('context');},
          color:blue,icon:Icons.history_rounded,compact:true,
        )),
        if(timeline>.65)...[
          const SizedBox(height:8),
          Text('Recent activity: ${item.headline}',style:captionText(12,color:coal)),
        ],
        const SizedBox(height:10),
        _hot(Row(children:[const Icon(Icons.open_in_new_rounded,color:coal,size:18),const SizedBox(width:7),
          Expanded(child:Text('Compare to original directory',style:captionText(13,color:coal)))]),'source'),
      ])),
    ]));
  }

  Widget _sms(){
    return _sheet(background:const Color(0xFFEDF1FD),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Container(padding:const EdgeInsets.all(12),decoration:const BoxDecoration(
        color:Color(0xFFE0E9FA),borderRadius:BorderRadius.vertical(top:Radius.circular(16))),
        child:Row(children:[const Icon(Icons.sms_rounded,color:coal),const SizedBox(width:9),Expanded(child:_author()),
          const Icon(Icons.call_outlined,color:coal)])),
      const SizedBox(height:17),
      Padding(padding:const EdgeInsets.fromLTRB(14,0,50,0),child:_hot(Container(
        padding:const EdgeInsets.all(15),decoration:const BoxDecoration(color:Colors.white,borderRadius:BorderRadius.only(
          topRight:Radius.circular(18),bottomLeft:Radius.circular(18),bottomRight:Radius.circular(18))),
        child:Text(item.body,style:captionText(15,color:coal)),
      ),'context')),
      const SizedBox(height:16),
      Padding(padding:const EdgeInsets.fromLTRB(14,0,14,12),child:_hot(Row(children:[
        const Icon(Icons.link_rounded,color:coal),const SizedBox(width:9),
        Expanded(child:Text('Examine sender details',style:captionText(13,color:coal))),
        const Icon(Icons.search_rounded,color:coal),
      ]),'identity')),
      if(item.body.contains('.example'))
        Padding(padding:const EdgeInsets.fromLTRB(14,0,14,15),child:TextButton.icon(
          onPressed:_linkAnatomy,
          icon:const Icon(Icons.manage_search_rounded,color:coal),
          label:Text('EXPLORE THE LINK',style:typewriter(11,color:coal)),
        )),
    ]));
  }


  void _linkAnatomy() {
    final found = RegExp(r'[a-z0-9-]+\.example',caseSensitive:false).firstMatch(item.body);
    final address = found?.group(0) ?? 'example.invalid';
    showDialog<void>(context:context,builder:(dialogContext)=>PhoneDialog(
      backgroundColor:paperWhite,
      shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(22)),
      child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:390),child:SingleChildScrollView(
        padding:const EdgeInsets.all(20),
        child:Column(mainAxisSize:MainAxisSize.min,children:[
          const Icon(Icons.link_rounded,color:coal,size:44),
          const SizedBox(height:10),
          Text('CHECK THE LINK',style:titleText(24,color:coal)),
          const SizedBox(height:12),
          Container(width:double.infinity,padding:const EdgeInsets.all(13),
            decoration:BoxDecoration(color:const Color(0xFFE4E9F2),borderRadius:BorderRadius.circular(11)),
            child:Text(address,style:typewriter(12,color:coal),textAlign:TextAlign.center)),
          const SizedBox(height:11),
          Text('Who owns this address? Always check it through the official app.',
            style:captionText(14,color:coal),textAlign:TextAlign.center),
          const SizedBox(height:17),
          SizedBox(width:double.infinity,child:GameButton('GOT IT',onTap:(){Navigator.pop(dialogContext);_inspect('context');},color:blue)),
        ]),
      )),
    ));
  }

  Widget _email(){
    return _sheet(child:Padding(padding:const EdgeInsets.all(16),child:Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[const Icon(Icons.mail_outline_rounded,color:coal),const SizedBox(width:9),
          Text('TAMBAYAN MAIL',style:typewriter(12,color:coal))]),
        const Divider(height:27),
        Text(item.headline,style:titleText(21,color:coal)),
        const SizedBox(height:11),_author(),
        const SizedBox(height:16),
        _hot(Text(item.body,style:captionText(14,color:coal)),'context'),
        const SizedBox(height:16),
        _hot(Row(children:[const Icon(Icons.attach_file_rounded,color:coal),const SizedBox(width:9),
          Expanded(child:Text(item.secondary,style:captionText(12,color:coal)))]),'source'),
      ])));
  }

  Widget _report(){
    return _sheet(child:Padding(padding:const EdgeInsets.all(15),child:Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[const Icon(Icons.flag_rounded,color:coal),const SizedBox(width:8),
          Text('MODERATION REPORT',style:typewriter(12,color:coal))]),
        const SizedBox(height:14),
        _hot(Container(padding:const EdgeInsets.all(11),color:const Color(0xFFF0E9F5),
          child:Text('${item.reports+1} reports received',style:captionText(14,color:coal))),'identity'),
        const SizedBox(height:12),
        _hot(Text(item.body,style:captionText(14,color:coal)),'context'),
        const SizedBox(height:12),
        _hot(Row(children:[const Icon(Icons.find_in_page_outlined,color:coal),const SizedBox(width:8),
          Expanded(child:Text('Read the original source',style:captionText(13,color:coal)))]),'source'),
      ])));
  }

  Widget _video(){
    final original=videoPosition>.5;
    return _sheet(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      GestureDetector(onHorizontalDragEnd:(_)=>_toggleVideo(),onTap:_toggleVideo,child:AnimatedSwitcher(
        duration:const Duration(milliseconds:200),
        child:CaseMedia(key:ValueKey('video:${item.id}:$original'),topic:item.topic,caption:item.artifact,sourceCaption:'Original source view • check dates and context',original:original,height:225),
      )),
      Padding(padding:const EdgeInsets.all(13),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        SizedBox(width:double.infinity,child:GameButton(original?'REPLAY SHARED CLIP':'CHECK ORIGINAL CLIP',onTap:_toggleVideo,color:blue,compact:true,icon:Icons.smart_display_rounded)),
        const SizedBox(height:12),
        _hot(Text(item.body,style:captionText(14,color:coal)),'context'),
        const SizedBox(height:12),
        _author(),
        const SizedBox(height:9),
        _hot(Row(children:[const Icon(Icons.source_rounded,color:coal),const SizedBox(width:8),Expanded(child:Text('Trace original uploader',style:captionText(13,color:coal)))]),'source'),
      ])),
    ]));
  }

  void _toggleVideo(){
    setState(() => videoPosition = videoPosition > .5 ? .1 : .9);
    _inspect('context');
  }

  Widget _resultOverlay() {
    final result = g.pendingResult!;
    final message = result.correct ? 'Nice call!' : 'Good try!';
    return Positioned.fill(
      child: Material(
        color: midnight.withValues(alpha: .83),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 440,
                  maxHeight: constraints.maxHeight - 24,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: paperWhite,
                      border: Border.all(color: mustard, width: 3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          result.correct ? Icons.stars_rounded : Icons.lightbulb_circle_rounded,
                          color: result.correct ? const Color(0xFF13775D) : coral,
                          size: 58,
                        ),
                        const SizedBox(height: 7),
                        Text(message, style: titleText(26, color: coal)),
                        const SizedBox(height: 8),
                        InkTag('${result.xp >= 0 ? '+' : ''}${result.xp} XP',
                          color: result.correct ? mint : coral),
                        const SizedBox(height: 12),
                        Text(result.item.rationale,
                          style: captionText(15, color: coal),
                          textAlign: TextAlign.center),
                        if (result.verifiedSource) ...[
                          const SizedBox(height: 10),
                          Text('Source checked ✓',
                            style: captionText(12, color: coal)),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: GameButton(
                            g.currentIndex + 1 == g.queue.length
                              ? 'SEE MY SCORE' : 'NEXT CASE',
                            onTap: _next,
                            icon: Icons.arrow_forward_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summary(){
    return _page([
      Row(children:[IconButton(onPressed:_exit,icon:const Icon(Icons.arrow_back_rounded)),
        Text(g.isTraining?'TRAINING COMPLETE':'SHIFT REPORT',style:typewriter(12,color:blue))]),
      const SizedBox(height:12),
      Center(child:Column(children:[
        MascotAvatar(game:g,size:148),
        Text(g.isTraining?'CLOCKED IN!':'GRADE ${g.grade}',style:titleText(36,color:mustard)),
        const SizedBox(height: 8),
        Text('INVESTIGATOR LEVEL ${g.careerRank.level} • ${g.equippedTitle}',
          style: captionText(14, color: mint), textAlign: TextAlign.center),
        const SizedBox(height:6),
        Text(g.isTraining?'Now try your first Career Shift.':g.mode == Mode.endless?'Endless mode complete.':g.shiftNumber>=6?'All six career shifts completed!':'Shift ${g.shiftNumber+1} is next. Your grade does not block progress.',
          style:captionText(13),textAlign:TextAlign.center),
      ])),
      const SizedBox(height:18),
      Row(children:[
        Expanded(child:_miniStat('SHIFT XP','${g.shiftXp}',Icons.bolt_rounded,mustard)),
        const SizedBox(width:9),
        Expanded(child:_miniStat('ACCURACY','${g.correctCount}/${g.results.length}',Icons.task_alt_rounded,blue)),
      ]),
      const SizedBox(height:10),
      Row(children:[
        Expanded(child:_miniStat('SAFETY','${g.safety}%',Icons.shield_rounded,blue)),
        const SizedBox(width:9),
        Expanded(child:_miniStat('FAIRNESS','${g.fairness}%',Icons.balance_rounded,pink)),
      ]),
      const SizedBox(height:16),
      if(!g.isTraining && g.callbacks.isNotEmpty)
        Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(
          color:deskBlue,borderRadius:BorderRadius.circular(13),border:Border.all(color:mustard)),
          child:Row(children:[const Icon(Icons.notifications_active_outlined,color:mustard),const SizedBox(width:9),
            Expanded(child:Text('${g.callbacks.length} follow-up report(s) may arrive in your next shift.',style:captionText(12)))])),
      const SizedBox(height:15),
      ...g.results.map((r)=>Padding(padding:const EdgeInsets.only(bottom:7),child:Row(children:[
        Icon(r.correct?Icons.check_circle_outline:Icons.cancel_outlined,color:r.correct?mint:coral),
        const SizedBox(width:9),
        Expanded(child:Text('${r.item.kind.label} • ${r.item.topic}',style:captionText(12))),
        Text('${r.xp>=0?'+':''}${r.xp}',style:typewriter(11,color:r.xp>=0?mint:coral)),
      ]))),
      const SizedBox(height:16),
      GameButton(g.isTraining ? 'START CAREER SHIFT 1' :
        g.mode == Mode.endless ? 'NEW ENDLESS SHIFT' :
        g.shiftNumber >= 6 ? 'VIEW CAREER SHIFTS' :
        'CONTINUE TO SHIFT ${g.shiftNumber+1}',
        onTap:_continueCareer,
        color:mustard,
        icon:g.shiftNumber>=6?Icons.map_rounded:Icons.arrow_forward_rounded),
      const SizedBox(height:12),
      GameButton('MY INVESTIGATOR • UNLOCKABLES',
        onTap: _openIdentity, color: mint,
        icon: Icons.workspace_premium_rounded),
      const SizedBox(height: 12),
      GameButton('MAIN MENU',onTap:_exit,outlined:true,color:blue,icon:Icons.home_rounded),
    ]);
  }
}

class PillCredits extends StatelessWidget {
  final int count;
  const PillCredits({super.key,required this.count});
  @override Widget build(BuildContext context){
    return Row(mainAxisSize:MainAxisSize.min,children:[
      const Icon(Icons.manage_search_rounded,color:mustard,size:18),
      Text(' $count LOOKUPS',style:typewriter(11,color:mustard)),
    ]);
  }
}

