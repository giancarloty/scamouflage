import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/arcade_models.dart';
import 'arcade_widgets.dart';
import '../controllers/inbox_motion.dart';
import '../services/game_audio.dart';
import 'theme.dart';

// ------------------------------------------------------------- RUMOR RADAR
class RumorView extends StatefulWidget {
  final ArcadeCase c;
  final ArcadeDifficulty d;
  final bool tutorial, hint;
  final SubmitFn onSubmit;
  const RumorView({
    super.key,
    required this.c,
    required this.d,
    required this.tutorial,
    required this.hint,
    required this.onSubmit,
  });
  @override
  State<RumorView> createState() => _RumorViewState();
}

class _RumorViewState extends State<RumorView> {
  late List<int> order = [for (var i = 0; i < widget.c.cards.length; i++) i];
  int? picked;
  final Set<int> words = {};

  Widget _prompt() => Paper(
    fill: const Color(0xFFE9F1FB),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🧩  ${widget.c.title.toUpperCase()}',
          style: typewriter(12, color: coal),
        ),
        const SizedBox(height: 7),
        onPaper(widget.c.text, size: 15.5, weight: FontWeight.w800),
        if (widget.c.subtext.isNotEmpty) ...[
          const SizedBox(height: 8),
          onPaper(widget.c.subtext, size: 14),
        ],
      ],
    ),
  );

  Widget _cardBody(RumorCard r) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        r.title,
        style: captionText(13, color: mutedInk, weight: FontWeight.w800),
      ),
      const SizedBox(height: 4),
      onPaper(r.body, size: 14.5),
      if (r.meta.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(
          r.meta,
          style: captionText(
            12.5,
            color: const Color(0xFF3C5F8A),
            weight: FontWeight.w800,
          ),
        ),
      ],
    ],
  );

  void _move(int pos, int delta) {
    GameAudio.instance.cue(GameCue.choose);
    setState(() {
      final item = order.removeAt(pos);
      order.insert(pos + delta, item);
    });
  }

  Widget _arrow(IconData icon, VoidCallback? onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(9),
    child: Container(
      width: 38,
      height: 34,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: onTap == null ? deskLight.withValues(alpha: .25) : chipFill,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: stroke, width: 1.4),
      ),
      child: Icon(icon, color: coal),
    ),
  );

  Widget _orderPuzzle() => Column(
    children: [
      for (var pos = 0; pos < order.length; pos++)
        Container(
          key: ValueKey('r${order[pos]}'),
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: paperWhite,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: choiceBlue, width: 2.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: choiceBlue,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text('${pos + 1}', style: typewriter(13, color: stroke)),
              ),
              const SizedBox(width: 10),
              Expanded(child: _cardBody(widget.c.cards[order[pos]])),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _arrow(
                    Icons.keyboard_arrow_up_rounded,
                    pos > 0 ? () => _move(pos, -1) : null,
                  ),
                  _arrow(
                    Icons.keyboard_arrow_down_rounded,
                    pos < order.length - 1 ? () => _move(pos, 1) : null,
                  ),
                ],
              ),
            ],
          ),
        ),
    ],
  );

  Widget _pickCards() => Column(
    children: [
      for (var i = 0; i < widget.c.cards.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: InkWell(
            onTap: () {
              GameAudio.instance.cue(GameCue.choose);
              setState(() => picked = i);
            },
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: picked == i ? const Color(0xFFFFF1DA) : paperWhite,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: picked == i ? choiceOrange : stroke,
                  width: picked == i ? 3 : 1.8,
                ),
              ),
              child: _cardBody(widget.c.cards[i]),
            ),
          ),
        ),
    ],
  );

  Widget _wordPuzzle() => Paper(
    child: Wrap(
      spacing: 6,
      runSpacing: 8,
      children: [
        for (var i = 0; i < widget.c.tokens.length; i++)
          InkWell(
            onTap: () {
              GameAudio.instance.cue(GameCue.choose);
              setState(() {
                if (!words.add(i)) words.remove(i);
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: words.contains(i) ? choicePink : chipFill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: stroke, width: 1.6),
              ),
              child: Text(
                widget.c.tokens[i],
                style: captionText(15, color: coal, weight: FontWeight.w700),
              ),
            ),
          ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final task = c.rumorTask!;
    final ready = switch (task) {
      RumorTask.order => true,
      RumorTask.wordEdit => words.isNotEmpty,
      _ => picked != null,
    };
    final label = switch (task) {
      RumorTask.order => 'LOCK IN THIS ORDER',
      RumorTask.wordEdit =>
        words.isEmpty
            ? 'TAP CHANGED WORDS'
            : 'LOCK IN ${words.length} WORD${words.length == 1 ? '' : 'S'}',
      _ => picked == null ? 'TAP AN ITEM' : 'LOCK IN ITEM ${picked! + 1}',
    };
    return ModeFrame(
      body: [
        _prompt(),
        const SizedBox(height: 12),
        if (task == RumorTask.order)
          _orderPuzzle()
        else if (task == RumorTask.wordEdit)
          _wordPuzzle()
        else
          _pickCards(),
      ],
      actions: ArcadeButton(
        label,
        color: choiceOrange,
        icon: Icons.lock_rounded,
        onTap: !ready
            ? null
            : () {
                final answer = switch (task) {
                  RumorTask.order => order,
                  RumorTask.wordEdit => words.toList(),
                  _ => [picked!],
                };
                widget.onSubmit(answer, true);
              },
      ),
    );
  }
}

// ------------------------------------------------------------ INBOX SPRINT
class InboxView extends StatefulWidget {
  final ArcadeCase c;
  final ArcadeDifficulty d;
  final bool tutorial, hint;
  final SubmitFn onSubmit;
  const InboxView({
    super.key,
    required this.c,
    required this.d,
    required this.tutorial,
    required this.hint,
    required this.onSubmit,
  });
  @override
  State<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> with TickerProviderStateMixin {
  int idx = 0;
  bool flipped = false, flippedEver = false, flying = false, _submitted = false;
  final List<int> decisions = [];

  late final AnimationController _flipController;
  late final AnimationController _slideController;
  AnimationController? _timer;

  Offset _dragOffset = Offset.zero;
  Offset _slideFrom = Offset.zero;
  Offset _slideTo = Offset.zero;
  Curve _slideCurve = Curves.easeOutCubic;

  int? get seconds => widget.tutorial ? null : widget.d.emailSeconds;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 430),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(_onSlideTick);
    final s = seconds;
    if (s != null) {
      _timer = AnimationController(
        vsync: this,
        duration: Duration(seconds: s),
      )..addStatusListener(_onTimerStatus);
    }
    _startTimer();
  }

  void _onTimerStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        !flying &&
        !_submitted &&
        mounted) {
      _decide(2);
    }
  }

  void _onSlideTick() {
    if (!mounted) return;
    final t = _slideCurve.transform(_slideController.value);
    setState(() {
      _dragOffset = Offset.lerp(_slideFrom, _slideTo, t)!;
    });
  }

  void _startTimer() {
    final timer = _timer;
    if (timer == null || _submitted || !mounted) return;
    timer.stop();
    timer.reset();
    timer.forward();
  }

  @override
  void dispose() {
    _timer?.removeStatusListener(_onTimerStatus);
    _timer?.dispose();
    _flipController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _flip() {
    if (flying) return;
    GameAudio.instance.cue(GameCue.flip);
    setState(() {
      flipped = !flipped;
      flippedEver = true;
    });
    if (flipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  void _slideToOffset(
    Offset destination, {
    required Duration duration,
    required Curve curve,
    required VoidCallback onFinished,
  }) {
    _slideController.stop();
    _slideFrom = _dragOffset;
    _slideTo = destination;
    _slideCurve = curve;
    _slideController.duration = duration;
    _slideController.forward(from: 0).then((_) {
      if (mounted) onFinished();
    });
  }

  void _release(DragEndDetails details) {
    if (flying) return;
    final width = MediaQuery.sizeOf(context).width;
    final answer = inboxSwipeVerdict(
      displacement: _dragOffset.dx,
      velocity: details.primaryVelocity ?? details.velocity.pixelsPerSecond.dx,
      viewportWidth: width,
    );
    if (answer != null) {
      _decide(answer);
    } else {
      GameAudio.instance.cue(GameCue.snap);
      _slideToOffset(
        Offset.zero,
        duration: const Duration(milliseconds: 290),
        curve: Curves.easeOutCubic,
        onFinished: () {},
      );
    }
  }

  void _decide(int value) {
    if (flying || _submitted || !mounted) return;
    GameAudio.instance.cue(value == 2 ? GameCue.wrong : GameCue.swipe);
    _timer?.stop();
    setState(() => flying = true);
    final size = MediaQuery.sizeOf(context);
    // Fully exits the viewport, regardless of the phone's screen width.
    final end = switch (value) {
      0 => Offset(-size.width - 230, -22),
      1 => Offset(size.width + 230, -22),
      _ => Offset(0, -size.height - 150), // Timer expired.
    };
    _slideToOffset(
      end,
      duration: const Duration(milliseconds: 325),
      curve: Curves.easeInCubic,
      onFinished: () => _finishEmail(value),
    );
  }

  void _finishEmail(int decision) {
    if (!mounted || _submitted) return;
    decisions.add(decision);
    if (decisions.length >= widget.c.emails.length) {
      _submitted = true;
      _timer?.stop();
      widget.onSubmit(decisions, flippedEver);
      return;
    }
    _flipController.value = 0;
    setState(() {
      idx++;
      flipped = false;
      flying = false;
      _dragOffset = Offset.zero;
    });
    _startTimer();
  }

  Widget _front(EmailItem e) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        e.fromName,
        style: captionText(15, color: coal, weight: FontWeight.w800),
      ),
      const SizedBox(height: 3),
      Text(
        e.subject,
        style: captionText(16, color: coal, weight: FontWeight.w800),
      ),
      const SizedBox(height: 10),
      Text(e.body, style: captionText(14.5, color: coal)),
      if (e.attachment.isNotEmpty) ...[
        const SizedBox(height: 10),
        Text('📎 ${e.attachment}', style: typewriter(12, color: coal)),
      ],
      if (e.linkLabel.isNotEmpty) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: choiceBlue,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: stroke, width: 1.6),
          ),
          child: Text(
            e.linkLabel,
            style: captionText(13.5, color: coal, weight: FontWeight.w800),
          ),
        ),
      ],
    ],
  );

  Widget _back(EmailItem e) {
    Widget row(String k, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: typewriter(11, color: mutedInk)),
          Text(
            v,
            style: captionText(14.5, color: coal, weight: FontWeight.w800),
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DETAILS', style: typewriter(12, color: coal)),
        const SizedBox(height: 10),
        row('FROM', '${e.fromName} <${e.fromAddress}>'),
        row('REPLIES GO TO', e.replyTo.isEmpty ? 'Same as sender' : e.replyTo),
        row(
          'LINK REALLY GOES TO',
          e.linkTarget.isEmpty ? 'No link' : e.linkTarget,
        ),
        row('ATTACHMENT', e.attachment.isEmpty ? 'None' : e.attachment),
      ],
    );
  }

  Widget _face(
    EmailItem e, {
    required bool back,
    required double viewportWidth,
  }) {
    final base = back ? const Color(0xFFE9F1FB) : paperWhite;
    final tint = inboxSwipeTint(
      base: base,
      displacement: _dragOffset.dx,
      viewportWidth: viewportWidth,
    );
    final outline = inboxSwipeBorder(
      base: stroke,
      displacement: _dragOffset.dx,
      viewportWidth: viewportWidth,
    );
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 270),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: outline, width: 2.2),
        boxShadow: const [BoxShadow(color: stroke, offset: Offset(0, 4))],
      ),
      child: back ? _back(e) : _front(e),
    );
  }

  /// Both faces participate in layout so the card stays the same height
  /// throughout the 3D turn, including with long email addresses on phones.
  Widget _sizedFace(EmailItem e, bool back, double viewportWidth) => Stack(
    children: [
      IgnorePointer(
        child: ExcludeSemantics(
          child: Opacity(
            opacity: 0,
            child: _face(e, back: false, viewportWidth: viewportWidth),
          ),
        ),
      ),
      IgnorePointer(
        child: ExcludeSemantics(
          child: Opacity(
            opacity: 0,
            child: _face(e, back: true, viewportWidth: viewportWidth),
          ),
        ),
      ),
      Positioned.fill(
        child: KeyedSubtree(
          key: ValueKey(back ? 'inbox-visible-back' : 'inbox-visible-front'),
          child: _face(e, back: back, viewportWidth: viewportWidth),
        ),
      ),
    ],
  );

  Widget _animatedCard(EmailItem e, double viewportWidth) => AnimatedBuilder(
    animation: _flipController,
    builder: (context, _) {
      // A half-turn around the Y axis, with the reverse face un-mirrored.
      // This looks like a physical flashcard rather than a content swap.
      final turn = Curves.easeInOutCubic.transform(_flipController.value);
      final back = turn >= .5;
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, .0011)
          ..rotateY(math.pi * turn),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(back ? math.pi : 0),
          child: _sizedFace(e, back, viewportWidth),
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final e = c.emails[idx];
    final width = MediaQuery.sizeOf(context).width;
    final tilt = (_dragOffset.dx / (width * .75)).clamp(-1.0, 1.0) * .14;
    return ModeFrame(
      body: [
        if (widget.tutorial)
          CoachBanner(
            !flippedEver
                ? 'Tap the card to see who really sent it.'
                : 'Swipe left = SPAM, right = KEEP. Or use the buttons.',
          ),
        Row(
          children: [
            for (var i = 0; i < c.emails.length; i++)
              Expanded(
                child: Container(
                  height: 7,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    color: i < idx
                        ? mustard
                        : i == idx
                        ? paperWhite
                        : deskLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'EMAIL ${idx + 1} OF ${c.emails.length}',
              style: typewriter(12, color: blue),
            ),
            const Spacer(),
            if (_timer != null)
              SizedBox(
                width: 120,
                child: AnimatedBuilder(
                  animation: _timer!,
                  builder: (context, _) => LinearProgressIndicator(
                    value: 1 - _timer!.value,
                    minHeight: 7,
                    color: _timer!.value > .7 ? removeColor : mustard,
                    backgroundColor: deskLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Pulse(
          active: widget.tutorial && !flippedEver,
          radius: 20,
          child: GestureDetector(
            key: const ValueKey('inbox-swipe-card'),
            behavior: HitTestBehavior.opaque,
            onTap: _flip,
            onHorizontalDragStart: flying
                ? null
                : (_) {
                    // Interrupt a snap-back and let the card follow the new gesture.
                    _slideController.stop();
                  },
            onHorizontalDragUpdate: flying
                ? null
                : (details) {
                    final next = (_dragOffset.dx + details.delta.dx)
                        .clamp(-width * 1.2, width * 1.2)
                        .toDouble();
                    setState(() => _dragOffset = Offset(next, 0));
                  },
            onHorizontalDragEnd: flying ? null : _release,
            onHorizontalDragCancel: flying
                ? null
                : () {
                    _slideToOffset(
                      Offset.zero,
                      duration: const Duration(milliseconds: 290),
                      curve: Curves.easeOutCubic,
                      onFinished: () {},
                    );
                  },
            child: Transform.translate(
              offset: _dragOffset,
              child: Transform.rotate(
                angle: tilt,
                child: RepaintBoundary(child: _animatedCard(e, width)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            flipped
                ? 'Tap to flip back • Swipe to sort'
                : 'Tap to inspect • Swipe left or right to sort',
            textAlign: TextAlign.center,
            style: captionText(13, color: paperWhite),
          ),
        ),
      ],
      actions: Row(
        children: [
          Expanded(
            child: ArcadeButton(
              'SPAM',
              color: removeColor,
              icon: Icons.arrow_back_rounded,
              onTap: flying ? null : () => _decide(0),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ArcadeButton(
              'KEEP',
              color: keepColor,
              icon: Icons.arrow_forward_rounded,
              onTap: flying ? null : () => _decide(1),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------- COMMENT CHAOS
class ThreadView extends StatefulWidget {
  final ArcadeCase c;
  final ArcadeDifficulty d;
  final bool tutorial, hint;
  final SubmitFn onSubmit;
  const ThreadView({
    super.key,
    required this.c,
    required this.d,
    required this.tutorial,
    required this.hint,
    required this.onSubmit,
  });
  @override
  State<ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadView> {
  final Set<int> flagged = {};

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return ModeFrame(
      body: [
        if (widget.tutorial)
          CoachBanner(
            flagged.isEmpty
                ? 'Tap the comment that crosses the line.'
                : 'Tap REMOVE to take it down.',
          ),
        Paper(
          fill: const Color(0xFFE9F1FB),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📌  THREAD', style: typewriter(12, color: coal)),
              const SizedBox(height: 6),
              onPaper(c.title, size: 15.5, weight: FontWeight.w800),
              const SizedBox(height: 6),
              Text(c.subtext, style: captionText(13, color: mutedInk)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < c.comments.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: InkWell(
              onTap: () {
                GameAudio.instance.cue(GameCue.choose);
                setState(() {
                  if (!flagged.add(i)) flagged.remove(i);
                });
              },
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: flagged.contains(i)
                      ? const Color(0xFFFFE5E5)
                      : paperWhite,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: flagged.contains(i) ? removeColor : stroke,
                    width: flagged.contains(i) ? 3 : 1.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.comments[i].handle,
                            style: captionText(
                              13,
                              color: mutedInk,
                              weight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (flagged.contains(i))
                          Text(
                            '🚩 FLAGGED',
                            style: typewriter(11, color: coal),
                          ),
                      ],
                    ),
                    if (c.comments[i].context.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          '↳ ${c.comments[i].context}',
                          style: captionText(
                            12.5,
                            color: const Color(0xFF3C5F8A),
                          ),
                        ),
                      ),
                    const SizedBox(height: 5),
                    onPaper(c.comments[i].body, size: 15),
                  ],
                ),
              ),
            ),
          ),
      ],
      actions: Row(
        children: [
          Expanded(
            child: ArcadeButton(
              flagged.isEmpty ? 'REMOVE' : 'REMOVE (${flagged.length})',
              color: removeColor,
              icon: Icons.delete_outline_rounded,
              glow: widget.tutorial && flagged.isNotEmpty,
              onTap: flagged.isEmpty
                  ? null
                  : () => widget.onSubmit(
                      flagged.toList()..sort(),
                      flagged.isNotEmpty,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ArcadeButton(
              'ALLOW ALL',
              color: keepColor,
              icon: Icons.check_rounded,
              onTap: flagged.isNotEmpty || widget.tutorial
                  ? null
                  : () => widget.onSubmit(const [], true),
            ),
          ),
        ],
      ),
    );
  }
}
