import 'dart:async';
import 'package:flutter/material.dart';
import '../services/game_audio.dart';
import '../models/arcade_models.dart';
import 'arcade_widgets.dart';
import 'case_media.dart';
import 'theme.dart';

/// Shared state for modes that use five inspection chips with a limited
/// budget (Post Autopsy, Clip Check).
mixin _Inspect<T extends StatefulWidget> on State<T> {
  final List<String> opened = [];
  bool get hintOn;
  ArcadeCase get kase;
  ArcadeDifficulty get diff;
  int get left => diff.scanBudget - opened.length;

  void open(String id) {
    if (opened.contains(id)) return;
    if (left <= 0) return;
    GameAudio.instance.cue(GameCue.inspect);
    setState(() => opened.add(id));
  }

  bool get usedDecisive => kase.tools.any(
      (t) => t.relevance == Relevance.decisive && opened.contains(t.id));

  Widget chips({bool coachFirst = false}) => Wrap(spacing: 8, runSpacing: 8,
    children: [for (final t in kase.tools)
      ToolChip(emoji: t.emoji, label: t.label,
        opened: opened.contains(t.id), enabled: left > 0,
        glow: (hintOn && t.relevance == Relevance.decisive) ||
            (coachFirst && opened.isEmpty && t == kase.tools.first),
        onTap: () => open(t.id))]);

  Widget notebook() {
    if (opened.isEmpty) {
      return emptyNote('Nothing checked yet. Tap a check above.');
    }
    return Column(children: [for (final id in opened)
      FindingCard(
        emoji: kase.tools.firstWhere((t) => t.id == id).emoji,
        label: kase.tools.firstWhere((t) => t.id == id).label,
        text: kase.tools.firstWhere((t) => t.id == id).text)]);
  }

  Widget budgetTag() => Text(
    left > 0 ? '$left CHECK${left == 1 ? '' : 'S'} LEFT' : 'NO CHECKS LEFT',
    style: typewriter(12, color: left > 0 ? mustard : removeColor));
}

// ------------------------------------------------------------ TRUST OR BUST
class TrustView extends StatefulWidget {
  final ArcadeCase c;
  final ArcadeDifficulty d;
  final bool tutorial, hint;
  final SubmitFn onSubmit;
  const TrustView({super.key, required this.c, required this.d,
    required this.tutorial, required this.hint, required this.onSubmit});
  @override
  State<TrustView> createState() => _TrustViewState();
}

class _TrustViewState extends State<TrustView> with _Inspect<TrustView> {
  @override bool get hintOn => widget.hint;
  @override ArcadeCase get kase => widget.c;
  @override ArcadeDifficulty get diff => widget.d;

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final gate = widget.tutorial && opened.isEmpty;
    return ModeFrame(
      body: [
        if (widget.tutorial) CoachBanner(opened.isEmpty
            ? 'Tap the glowing check to investigate.'
            : 'Now decide: KEEP or REMOVE.'),
        Paper(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(radius: 19, backgroundColor: choicePink,
                child: Text(c.author.isEmpty ? '?' : c.author[0],
                  style: titleText(18, color: coal))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.author, style: captionText(15, color: coal,
                    weight: FontWeight.w800)),
                  Text(c.handle, style: captionText(12, color: mutedInk)),
                ])),
            ]),
            const SizedBox(height: 11),
            onPaper(c.text, size: 15.5),
            const SizedBox(height: 11),
            CaseMedia(topic: c.imageTopic, caption: c.imageCaption, height: 138),
            const SizedBox(height: 9),
            Text(c.reactions, style: captionText(12, color: mutedInk)),
          ])),
        sectionLabel('CHECKS', trailing: budgetTag()),
        chips(coachFirst: widget.tutorial),
        sectionLabel('NOTEBOOK'),
        notebook(),
      ],
      actions: Row(children: [
        Expanded(child: ArcadeButton('KEEP', color: keepColor,
          icon: Icons.check_circle_rounded, glow: widget.tutorial && !gate,
          onTap: gate ? null
              : () => widget.onSubmit([0], usedDecisive, opened: opened))),
        const SizedBox(width: 10),
        Expanded(child: ArcadeButton('REMOVE', color: removeColor,
          icon: Icons.block_rounded, glow: widget.tutorial && !gate,
          onTap: gate ? null
              : () => widget.onSubmit([1], usedDecisive, opened: opened))),
      ]),
    );
  }
}

// ----------------------------------------------------------- IMPOSTOR HUNT
class ImpostorView extends StatefulWidget {
  final ArcadeCase c;
  final ArcadeDifficulty d;
  final bool tutorial, hint;
  final SubmitFn onSubmit;
  const ImpostorView({super.key, required this.c, required this.d,
    required this.tutorial, required this.hint, required this.onSubmit});
  @override
  State<ImpostorView> createState() => _ImpostorViewState();
}

class _ImpostorViewState extends State<ImpostorView> {
  bool a = false, b = false;

  Future<void> _open(ProfileView p, String tag, bool left) async {
    GameAudio.instance.cue(GameCue.inspect);
    setState(() { if (left) { a = true; } else { b = true; } });
    await showDetailSheet(context, title: 'PROFILE $tag', children: [
      Text(p.name, style: captionText(18, color: coal, weight: FontWeight.w800)),
      Text(p.handle, style: captionText(14, color: mutedInk)),
      const SizedBox(height: 10),
      onPaper(p.bio),
      const SizedBox(height: 10),
      _line('Link in bio', p.link),
      _line('Account age', p.ageLabel),
      _line('Followers', '${p.followers}'),
      _line('Badge', p.badge ? 'Has a verified-style badge' : 'No badge'),
      if (p.label != null) _line('Self-label', p.label!),
      const SizedBox(height: 6),
      Text('RECENT POSTS', style: typewriter(11, color: coal)),
      const SizedBox(height: 6),
      for (final r in p.recent)
        Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: chipFill,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: stroke, width: 1.4)),
          child: onPaper(r, size: 14)),
    ]);
  }

  Widget _line(String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 104, child: Text(k,
        style: captionText(13, color: mutedInk, weight: FontWeight.w700))),
      Expanded(child: Text(v, style: captionText(14, color: coal,
        weight: FontWeight.w700))),
    ]));

  Widget _card(ProfileView p, String tag, bool opened, bool left, Color tint) =>
    Expanded(child: Pulse(active: widget.tutorial && !opened, child: InkWell(
      onTap: () => _open(p, tag, left),
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(color: paperWhite,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: tint, width: 3)),
        child: Column(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: tint,
              borderRadius: BorderRadius.circular(8)),
            child: Text(tag, style: typewriter(12, color: stroke))),
          const SizedBox(height: 8),
          CircleAvatar(radius: 23, backgroundColor: tint.withValues(alpha: .5),
            child: Text(p.name.isEmpty ? '?' : p.name[0],
              style: titleText(22, color: coal))),
          const SizedBox(height: 7),
          Text(p.name, textAlign: TextAlign.center, maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: captionText(14, color: coal, weight: FontWeight.w800)),
          Text(p.handle, textAlign: TextAlign.center, maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: captionText(12, color: mutedInk)),
          const SizedBox(height: 5),
          Text('${p.followers} followers', style: captionText(12, color: mutedInk)),
          const SizedBox(height: 8),
          Container(width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: opened ? chipOpenFill : chipFill,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: stroke, width: 1.5)),
            child: Text(opened ? 'OPENED ✓' : 'OPEN PROFILE',
              textAlign: TextAlign.center,
              style: typewriter(11, color: coal))),
        ]),
      ),
    )));

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final both = a && b;
    final gate = widget.tutorial && !both;
    return ModeFrame(
      body: [
        if (widget.tutorial) CoachBanner(both
            ? 'Now check the directory. Who is copying?'
            : 'Tap both profiles to read them.'),
        Paper(fill: const Color(0xFFE9F1FB), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('📖  OFFICIAL DIRECTORY', style: typewriter(12, color: coal)),
            const SizedBox(height: 7),
            for (final line in c.directory) onPaper(line, size: 14.5),
          ])),
        const SizedBox(height: 4),
        sectionLabel('TWO ACCOUNTS'),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _card(c.leftProfile!, 'A', a, true, choiceOrange),
          const SizedBox(width: 10),
          _card(c.rightProfile!, 'B', b, false, choiceBlue),
        ]),
        const SizedBox(height: 10),
        Text(c.subtext,
          style: captionText(13, color: paperWhite)),
      ],
      actions: Row(children: [
        Expanded(child: ArcadeButton('FLAG A', color: removeColor,
          icon: Icons.flag_rounded,
          onTap: gate ? null : () => widget.onSubmit([0], a && b))),
        const SizedBox(width: 8),
        Expanded(child: ArcadeButton('FLAG B', color: removeColor,
          icon: Icons.flag_rounded,
          onTap: gate ? null : () => widget.onSubmit([1], a && b))),
        const SizedBox(width: 8),
        Expanded(child: ArcadeButton('BOTH OK', color: keepColor,
          icon: Icons.check_rounded,
          onTap: gate ? null : () => widget.onSubmit([2], a && b))),
      ]),
    );
  }
}

// -------------------------------------------------------------- SCAM SLAM
class ChatView extends StatefulWidget {
  final ArcadeCase c;
  final ArcadeDifficulty d;
  final bool tutorial, hint;
  final SubmitFn onSubmit;
  const ChatView({super.key, required this.c, required this.d,
    required this.tutorial, required this.hint, required this.onSubmit});
  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  bool phoneOpen = false, linkSeen = false;
  int shown = 0;
  int? picked;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 650), (t) {
      if (!mounted) { t.cancel(); return; }
      if (shown >= widget.c.chatIn.length) { t.cancel(); return; }
      setState(() => shown++);
    });
    shown = 1;
  }

  @override
  void dispose() { _t?.cancel(); super.dispose(); }

  Widget _bubble(String text, {bool mine = false}) => Align(
    alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 310),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: mine ? choiceBlue : const Color(0xFFEFEFF4),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(mine ? 16 : 4),
          bottomRight: Radius.circular(mine ? 4 : 16)),
        border: Border.all(color: stroke, width: 1.5)),
      child: onPaper(text, size: 15),
    ));

  void _pick(int i) {
    if (picked != null) return;
    GameAudio.instance.cue(GameCue.choose);
    setState(() => picked = i);
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      widget.onSubmit([i], phoneOpen || linkSeen);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    const colors = [choiceOrange, choicePink, choiceBlue];
    return ModeFrame(
      body: [
        if (widget.tutorial) CoachBanner(phoneOpen
            ? 'Does the message match your phone? Pick a reply.'
            : 'Tap YOUR PHONE to check what you really did.'),
        Pulse(active: widget.tutorial && !phoneOpen || widget.hint && !phoneOpen,
          child: InkWell(
            onTap: () {
              GameAudio.instance.cue(GameCue.inspect);
              setState(() => phoneOpen = !phoneOpen);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity, padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(color: const Color(0xFFFFF4CF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: stroke, width: 2)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('📱', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(child: Text('YOUR PHONE: RECENT ACTIVITY',
                      style: typewriter(12, color: coal))),
                    Icon(phoneOpen ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded, color: coal),
                  ]),
                  if (phoneOpen) ...[
                    const SizedBox(height: 8),
                    for (final a in c.activity)
                      Padding(padding: const EdgeInsets.only(bottom: 5),
                        child: onPaper('• $a', size: 14.5)),
                  ] else Text('Tap to see what you did lately',
                    style: captionText(13, color: mutedInk)),
                ]),
            ))),
        const SizedBox(height: 12),
        Paper(fill: Colors.white, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const CircleAvatar(radius: 18, backgroundColor: choiceBlue,
                child: Icon(Icons.person_rounded, color: coal)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.author, style: captionText(15, color: coal,
                    weight: FontWeight.w800)),
                  Text(c.handle, style: captionText(12.5, color: mutedInk)),
                ])),
            ]),
            if (c.subtext.isNotEmpty) Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 4),
              child: Text(c.subtext, style: captionText(12.5, color: mutedInk))),
            const Divider(height: 18),
            for (var i = 0; i < c.chatIn.length && i < shown; i++)
              _bubble(c.chatIn[i]),
            if (shown < c.chatIn.length)
              Text('typing…', style: captionText(12.5, color: mutedInk)),
            if (c.linkDomain.isNotEmpty && shown >= c.chatIn.length)
              Align(alignment: Alignment.centerLeft, child: InkWell(
                onTap: () {
                  setState(() => linkSeen = true);
                  showDetailSheet(context, title: 'LINK PREVIEW', children: [
                    onPaper('This link goes to:'),
                    const SizedBox(height: 6),
                    Text(c.linkDomain, style: typewriter(15, color: coal)),
                    const SizedBox(height: 10),
                    onPaper('Only a preview. Nothing was opened.', size: 13.5),
                  ]);
                },
                child: Container(padding: const EdgeInsets.symmetric(
                    horizontal: 11, vertical: 9),
                  decoration: BoxDecoration(color: chipFill,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: stroke, width: 1.5)),
                  child: Text('🔗 PREVIEW LINK${linkSeen ? ' ✓' : ''}',
                    style: typewriter(11, color: coal)))) ),
            if (picked != null)
              _bubble(c.choices[picked!].text, mine: true),
          ])),
      ],
      actions: Column(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < c.choices.length; i++)
          Padding(padding: const EdgeInsets.only(bottom: 7),
            child: SizedBox(width: double.infinity, child: ArcadeButton(
              c.choices[i].text, color: colors[i % 3],
              icon: Icons.send_rounded,
              onTap: picked == null && shown >= c.chatIn.length
                  ? () => _pick(i) : null))),
      ]),
    );
  }
}

// -------------------------------------------------------------- CLIP CHECK
class ClipView extends StatefulWidget {
  final ArcadeCase c;
  final ArcadeDifficulty d;
  final bool tutorial, hint;
  final SubmitFn onSubmit;
  const ClipView({super.key, required this.c, required this.d,
    required this.tutorial, required this.hint, required this.onSubmit});
  @override
  State<ClipView> createState() => _ClipViewState();
}

class _ClipViewState extends State<ClipView> with _Inspect<ClipView> {
  @override bool get hintOn => widget.hint;
  @override ArcadeCase get kase => widget.c;
  @override ArcadeDifficulty get diff => widget.d;
  int beat = 0;

  Widget _line(String label, String text, Color tint, {bool dim = false}) =>
    Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: dim ? deskBlue : paperWhite,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: tint, width: 2.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: typewriter(11, color: dim ? paperWhite : coal)),
        const SizedBox(height: 4),
        Text(text, style: captionText(15, color: dim ? paperWhite : coal,
          weight: FontWeight.w700)),
      ]));

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final b = c.beats[beat];
    return ModeFrame(
      body: [
        Paper(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.author, style: captionText(13, color: mutedInk)),
            const SizedBox(height: 5),
            onPaper(c.text, size: 15.5, weight: FontWeight.w800),
            const SizedBox(height: 10),
            CaseMedia(topic: c.imageTopic, caption: b.scene, height: 120, badge: 'VIDEO • ${b.second}s'),
          ])),
        sectionLabel('TIMELINE • ${b.second}s',
          trailing: Text('${beat + 1}/${c.beats.length}',
            style: typewriter(12, color: paperWhite))),
        Row(children: [
          for (var i = 0; i < c.beats.length; i++) Expanded(child: InkWell(
            onTap: () {
              GameAudio.instance.cue(GameCue.choose);
              setState(() => beat = i);
            },
            child: Container(height: 34, margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                color: i == beat ? mustard : chipFill,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: stroke, width: 1.6)),
              alignment: Alignment.center,
              child: Text('${c.beats[i].second}s',
                style: typewriter(11, color: coal))))),
        ]),
        Slider(value: beat.toDouble(), min: 0,
          max: (c.beats.length - 1).toDouble(), divisions: c.beats.length - 1,
          activeColor: mustard, inactiveColor: deskLight,
          onChanged: (v) => setState(() => beat = v.round())),
        _line('VIRAL CUT', b.inViral ? b.viralLine : '— this moment is not in the viral cut —',
          choiceOrange, dim: !b.inViral),
        _line('FULL VIDEO', b.fullLine, choiceBlue),
        sectionLabel('CHECKS', trailing: budgetTag()),
        chips(),
        sectionLabel('NOTEBOOK'),
        notebook(),
      ],
      actions: Row(children: [
        Expanded(child: ArcadeButton('KEEP', color: keepColor,
          icon: Icons.check_circle_rounded,
          onTap: () => widget.onSubmit([0], usedDecisive, opened: opened))),
        const SizedBox(width: 10),
        Expanded(child: ArcadeButton('REMOVE', color: removeColor,
          icon: Icons.block_rounded,
          onTap: () => widget.onSubmit([1], usedDecisive, opened: opened))),
      ]),
    );
  }
}
