import 'package:flutter/material.dart';
import 'mascot.dart';
import '../controllers/engine.dart';
import '../services/game_audio.dart';
import '../models/player_progression.dart';
import 'theme.dart';

/// Local-only cosmetics. Accounts and public scores are visible future-feature
/// previews, not working authentication or cloud storage.
class CareerIdentityScreen extends StatelessWidget {
  final GameEngine game;
  final VoidCallback? onBack;
  const CareerIdentityScreen({super.key, required this.game, this.onBack});

  static const _framePalette = <String, Color>{
    'classic': blue,
    'sunny': mustard,
    'bubblegum': pink,
    'mint': mint,
    'violet': Color(0xFFBCA5FF),
  };

  void _equip(bool Function() action) {
    if (action()) GameAudio.instance.cue(GameCue.choose);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: midnight,
    body: SafeArea(child: DeskBackdrop(child: AnimatedBuilder(
      animation: game,
      builder: (context, _) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              IconButton(
                tooltip: 'Back to the game',
                onPressed: onBack ?? () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: paperWhite),
              ),
              Expanded(child: Text('MY INVESTIGATOR',
                style: titleText(23, color: mustard))),
            ]),
            const SizedBox(height: 10),
            _identityCard(),
            const SizedBox(height: 22),
            _sectionTitle("CHAMELEO'S EVOLUTIONS", '10 outfits • each rank gets a new look.'),
            const SizedBox(height: 10),
            _evolutionPreview(),
            const SizedBox(height: 20),
            _sectionTitle('MASCOT NICKNAMES', 'Choose a new nickname for your companion.'),
            const SizedBox(height: 10),
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (final item in CareerProgression.mascotNames)
                _cosmeticTile(item.name, item.symbol, item.xp,
                  game.equippedMascotNameId == item.id,
                  () => _equip(() => game.equipMascotName(item.id)), context: context),
            ]),
            const SizedBox(height: 20),
            _sectionTitle('MASCOT COLORS', 'Unlocked colors change the mascot, not your XP.'),
            const SizedBox(height: 10),
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (final item in CareerProgression.mascotColors)
                _cosmeticTile(item.name, item.symbol, item.xp,
                  game.equippedMascotColorId == item.id,
                  () => _equip(() => game.equipMascotColor(item.id)),
                  accent: MascotPalette.forId(item.id), context: context),
            ]),
            const SizedBox(height: 20),
            _sectionTitle('EARNED TITLES', 'Choose the title under your name.'),
            const SizedBox(height: 10),
            ...CareerProgression.ranks.map((rank) => _choice(
              rank.title, 'LEVEL ${rank.level} • ${rank.xp} XP',
              rank.xp <= game.careerXp, game.equippedTitleId == rank.id,
              Icons.verified_outlined,
              () => _equip(() => game.equipCareerTitle(rank.id)))),
            const SizedBox(height: 20),
            _sectionTitle('BADGE COLLECTION', 'Your chosen badge appears on your profile.'),
            const SizedBox(height: 10),
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (final badge in CareerProgression.badges)
                _cosmeticTile(
                  badge.name, badge.symbol, badge.xp,
                  game.equippedBadgeId == badge.id,
                  () => _equip(() => game.equipBadge(badge.id)), context: context),
            ]),
            const SizedBox(height: 20),
            _sectionTitle('PROFILE FRAMES', 'Earn a color frame through Career XP.'),
            const SizedBox(height: 10),
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (final frame in CareerProgression.frames)
                _cosmeticTile(
                  frame.name, frame.symbol, frame.xp,
                  game.equippedFrameId == frame.id,
                  () => _equip(() => game.equipFrame(frame.id)),
                  accent: _framePalette[frame.id], context: context,),
            ]),
            const SizedBox(height: 24),
            _futureFeatures(),
          ]),
        )),
      ),
    ))),
  );

  Widget _identityCard() {
    final current = game.careerRank;
    final next = game.nextCareerRank;
    final frame = _framePalette[game.equippedFrameId] ?? blue;
    final badge = CareerProgression.badgeById(game.equippedBadgeId)?.symbol ?? '🦎';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: frame, width: 3),
        gradient: LinearGradient(colors: [deskBlue, frame.withValues(alpha: .24)]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(width: 128, height: 128, child: Stack(
            alignment: Alignment.center, clipBehavior: Clip.none, children: [
              SizedBox(width: 120, height: 120, child: CircularProgressIndicator(
                value: game.careerLevelProgress, strokeWidth: 8,
                strokeCap: StrokeCap.round, color: frame,
                backgroundColor: midnight)),
              MascotAvatar(game: game, size: 105),
              Positioned(bottom: -3, right: 2, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(color: midnight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: frame, width: 2)),
                child: Text('LV ${current.level}',
                  style: typewriter(10, color: mustard)))),
              Positioned(bottom: -5, left: 0, child: Text(badge,
                style: const TextStyle(fontSize: 24))),
            ])),
          const SizedBox(width: 17),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(game.mascotName.toUpperCase(), style: typewriter(11, color: frame)),
            const SizedBox(height: 5),
            Text('LEVEL ${current.level} / 10', style: typewriter(12, color: mustard)),
            const SizedBox(height: 7),
            Text(game.equippedTitle, style: titleText(22, color: paperWhite)),
            const SizedBox(height: 7),
            Text('${game.careerXp} CAREER XP', style: captionText(14, color: mustard)),
            const SizedBox(height: 5),
            Text('Local investigator profile',
              style: captionText(12, color: parchment)),
          ])),
        ]),
        const SizedBox(height: 19),
        ClipRRect(borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: game.careerLevelProgress,
            backgroundColor: midnight,
            color: frame,
            minHeight: 9)),
        const SizedBox(height: 7),
        Text(next == null
            ? 'MAX LEVEL REACHED • All investigator ranks earned!'
            : '${next.xp - game.careerXp} XP TO LEVEL ${next.level} • ${next.title}',
          style: captionText(12, color: paperWhite)),
        const SizedBox(height: 8),
        Text('XP unlocks titles and cosmetics automatically. Equipping is free.',
          style: captionText(12, color: parchment)),
      ]),
    );
  }

  Widget _evolutionPreview() => SizedBox(height: 154,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: CareerProgression.ranks.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final rank = CareerProgression.ranks[index];
        final unlocked = game.careerXp >= rank.xp;
        return Container(width: 112,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: deskBlue, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: unlocked ? mustard : deskLight)),
          child: Column(children: [
            Opacity(opacity: unlocked ? 1 : .45,
              child: MascotAvatar(game: game, size: 91, level: rank.level)),
            const SizedBox(height: 3),
            Text('LV ${rank.level}', style: typewriter(10, color: unlocked ? mustard : parchment)),
            Text(unlocked ? rank.title : '${rank.xp} XP',
              style: captionText(10, color: parchment),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        );
      },
    ),
  );

  Widget _sectionTitle(String title, String caption) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: titleText(21, color: paperWhite)),
      const SizedBox(height: 3),
      Text(caption, style: captionText(12, color: parchment)),
    ]);

  Widget _choice(String title, String threshold, bool unlocked,
      bool selected, IconData icon, VoidCallback select) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Material(color: Colors.transparent, child: InkWell(
      onTap: unlocked ? select : null,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? deskLight : deskBlue,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: selected ? mint : deskLight, width: selected ? 2 : 1),
        ),
        child: Row(children: [
          Icon(unlocked ? icon : Icons.lock_outline_rounded,
            color: unlocked ? mustard : parchment, size: 24),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: captionText(15,
              color: unlocked ? paperWhite : parchment)),
            Text(unlocked ? threshold : 'LOCKED • $threshold',
              style: typewriter(10, color: unlocked ? blue : parchment)),
          ])),
          if (selected) const Icon(Icons.check_circle_rounded, color: mint)
          else if (unlocked) const Icon(Icons.radio_button_unchecked_rounded,
            color: parchment),
        ]),
      ),
    )),
  );

  Widget _cosmeticTile(String title, String symbol, int xp, bool selected,
    VoidCallback select, {Color? accent, required BuildContext context}) {
    final unlocked = xp <= game.careerXp;
    return Material(color: Colors.transparent, child: InkWell(
      onTap: unlocked ? select : null,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: MediaQuery.sizeOf(context).width < 380 ? 132 : 153,
        constraints: const BoxConstraints(minHeight: 116),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? deskLight : deskBlue,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: selected ? (accent ?? mint) : deskLight,
            width: selected ? 2.5 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Opacity(opacity: unlocked ? 1 : .4,
              child: accent == null
                ? Text(symbol, style: const TextStyle(fontSize: 27))
                : Container(width: 29, height: 29,
                    decoration: BoxDecoration(color: accent, shape: BoxShape.circle,
                      border: Border.all(color: paperWhite, width: 2)))),
            const Spacer(),
            Icon(selected ? Icons.check_circle_rounded :
              unlocked ? Icons.radio_button_unchecked_rounded : Icons.lock_outline_rounded,
              size: 17, color: selected ? mint : parchment),
          ]),
          const SizedBox(height: 5),
          Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: captionText(13, color: unlocked ? paperWhite : parchment)),
          const SizedBox(height: 4),
          Text(unlocked ? (selected ? 'EQUIPPED' : 'TAP TO EQUIP') : '$xp XP TO UNLOCK',
            style: typewriter(10, color: unlocked ? blue : parchment)),
        ]),
      ),
    ));
  }

  Widget _futureFeatures() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: deskBlue.withValues(alpha: .80),
      border: Border.all(color: deskLight, width: 1.5),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.cloud_off_outlined, color: parchment),
        const SizedBox(width: 9),
        Expanded(child: Text('ONLINE FEATURES',
          style: titleText(20, color: paperWhite))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(color: deskLight,
            borderRadius: BorderRadius.circular(8)),
          child: Text('COMING SOON', style: typewriter(10, color: paperWhite))),
      ]),
      const SizedBox(height: 8),
      Text('Preview only — sign-in, usernames, cloud saving and rankings are not active.',
        style: captionText(13, color: parchment)),
      const SizedBox(height: 15),
      const TextField(
        enabled: false,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.alternate_email_rounded),
          labelText: 'Username (future account)',
          border: OutlineInputBorder(),
          isDense: true,
        )),
      const SizedBox(height: 9),
      const TextField(
        enabled: false,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.mail_outline_rounded),
          labelText: 'Email address (future sign-in)',
          border: OutlineInputBorder(),
          isDense: true,
        )),
      const SizedBox(height: 9),
      SizedBox(width: double.infinity, child: FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.login_rounded),
        label: const Text('CREATE ACCOUNT / SIGN IN • SOON'),
      )),
      const Divider(color: deskLight, height: 25),
      Row(children: [
        const Icon(Icons.leaderboard_outlined, color: parchment),
        const SizedBox(width: 9),
        Expanded(child: Text('GLOBAL LEADERBOARDS',
          style: captionText(16, color: paperWhite))),
        const Icon(Icons.lock_outline_rounded, color: parchment),
      ]),
      const SizedBox(height: 5),
      Text('Rankings will require optional accounts, a secure backend, and fair-play protections.',
        style: captionText(12, color: parchment)),
      const SizedBox(height: 9),
      Text('For now, progress and cosmetics are saved only on this device.',
        style: captionText(12, color: mustard)),
    ]),
  );
}
