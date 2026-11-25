// Pure-Dart tests for the arcade rules. No widgets, no storage: they run
// quickly and check that every generated case is internally consistent.
import 'package:flutter_test/flutter_test.dart';
import 'package:scamouflage/services/arcade_generator.dart';
import 'package:scamouflage/models/arcade_models.dart';
import 'package:scamouflage/controllers/arcade_session.dart';

final _placeholder = RegExp(r'\{[a-zA-Z0-9]+\}');

/// A guaranteed-wrong answer in each mode's own format.
List<int> wrongAnswer(ArcadeCase c) {
  switch (c.mode) {
    case ArcadeMode.comments:
      return c.correct.isEmpty ? [0] : <int>[];
    case ArcadeMode.inbox:
      return [for (final v in c.correct) 1 - v];
    case ArcadeMode.rumor:
      switch (c.rumorTask!) {
        case RumorTask.order:
          return c.correct.reversed.toList();
        case RumorTask.wordEdit:
          final other = [for (var i = 0; i < c.tokens.length; i++) i]
              .firstWhere((i) => !c.correct.contains(i));
          return [other];
        default:
          return [(c.correct.first + 1) % c.cards.length];
      }
    default:
      return [(c.correct.first + 1) % c.choices.length];
  }
}

Iterable<String> visibleText(ArcadeCase c) => [
  c.title, c.text, c.subtext, c.lesson, c.hint, c.author, c.handle,
  ...c.directory, ...c.chatIn, ...c.activity,
  ...c.choices.map((e) => e.text), ...c.tokens,
  ...c.tools.map((t) => t.text),
  ...c.cards.expand((e) => [e.title, e.body, e.meta]),
  ...c.emails.expand((e) => [e.fromName, e.fromAddress, e.subject, e.body,
    e.why, e.linkLabel, e.linkTarget, e.attachment, e.replyTo]),
  ...c.comments.expand((e) => [e.handle, e.body, e.context, e.reason]),
  ...c.beats.expand((b) => [b.scene, b.viralLine, b.fullLine]),
  ...c.followUps.values.expand((e) => e),
  if (c.leftProfile != null) ...[c.leftProfile!.bio, ...c.leftProfile!.recent],
  if (c.rightProfile != null) ...[c.rightProfile!.bio, ...c.rightProfile!.recent],
];

void main() {
  group('generated cases are coherent', () {
    test('every mode and difficulty yields complete, resolved cases', () {
      for (final mode in ArcadeMode.values) {
        for (final d in ArcadeDifficulty.values) {
          for (var seed = 0; seed < 120; seed++) {
            final c = ArcadeGenerator(seed * 31 + mode.index).generate(mode, d);
            expect(c.mode, mode);
            expect(c.lesson, isNotEmpty);
            expect(c.hint, isNotEmpty);
            for (final s in visibleText(c)) {
              expect(_placeholder.hasMatch(s), isFalse,
                  reason: '$mode left a slot unfilled in: $s');
            }
          }
        }
      }
    });

    test('Post Autopsy and Clip Check always have a decisive check', () {
      for (final mode in [ArcadeMode.trust, ArcadeMode.clip]) {
        for (var seed = 0; seed < 200; seed++) {
          final c = ArcadeGenerator(seed).generate(mode, ArcadeDifficulty.hard);
          expect(c.tools.length, 5);
          expect(c.decisiveIds, isNotEmpty);
          expect(c.correct, [c.deceptive ? 1 : 0]);
          // The hint points at a real tool, not a decoy.
          final id = c.tools.firstWhere(
              (t) => t.relevance == Relevance.decisive).label;
          expect(c.hint, contains(id));
        }
      }
    });

    test('hard mode adds popular-opinion noise without changing the truth', () {
      var noisy = 0;
      for (var seed = 0; seed < 100; seed++) {
        final hard = ArcadeGenerator(seed).generate(
            ArcadeMode.trust, ArcadeDifficulty.hard);
        final replies = hard.tools.firstWhere((t) => t.id == 'replies').text;
        if (replies.contains('Top comment')) noisy++;
      }
      expect(noisy, 100);
    });

    test('Post Autopsy tone is independent of the verdict', () {
      var hypeBad = 0, bad = 0, hypeGood = 0, good = 0;
      for (var seed = 0; seed < 600; seed++) {
        final c = ArcadeGenerator(seed).generate(
            ArcadeMode.trust, ArcadeDifficulty.medium);
        final hype = c.text.contains('SHARE NA') || c.text.contains('Pa-viral') ||
            c.text.contains('Basahin hanggang');
        if (c.deceptive) { bad++; if (hype) hypeBad++; }
        else { good++; if (hype) hypeGood++; }
      }
      expect((hypeBad / bad - hypeGood / good).abs(), lessThan(.12));
    });

    test('Impostor Hunt: rules decide who is flagged', () {
      final answers = <int>{};
      final stories = <String>{};
      for (var seed = 0; seed < 400; seed++) {
        final c = ArcadeGenerator(seed).generate(
            ArcadeMode.impostor, ArcadeDifficulty.medium);
        answers.add(c.correct.first);
        stories.add(c.scenario);
        expect(c.directory, isNotEmpty);
        expect(c.leftProfile!.handle == c.rightProfile!.handle, isFalse);
        expect(c.deceptive, c.correct.first != 2);
      }
      expect(answers, {0, 1, 2});
      expect(stories.length, greaterThanOrEqualTo(10));
    });

    test('Scam Slam: three distinct replies, one best, consequences for each', () {
      final positions = <int>{};
      var legit = 0, scam = 0;
      for (var seed = 0; seed < 300; seed++) {
        final c = ArcadeGenerator(seed).generate(
            ArcadeMode.scamSlam, ArcadeDifficulty.medium);
        expect(c.choices.length, 3);
        expect(c.choices.map((e) => e.text).toSet().length, 3);
        for (var i = 0; i < 3; i++) {
          expect(c.followUps[i], isNotEmpty);
        }
        positions.add(c.correct.first);
        if (c.deceptive) { scam++; } else { legit++; }
      }
      expect(positions, {0, 1, 2});
      expect(legit, greaterThan(80));
      expect(scam, greaterThan(80));
    });

    test('Rumor Radar covers all five different puzzles', () {
      final tasks = <RumorTask>{};
      for (var seed = 0; seed < 200; seed++) {
        final c = ArcadeGenerator(seed).generate(
            ArcadeMode.rumor, ArcadeDifficulty.medium);
        tasks.add(c.rumorTask!);
        switch (c.rumorTask!) {
          case RumorTask.order:
            final sorted = [...c.correct]..sort();
            expect(sorted, [for (var i = 0; i < c.cards.length; i++) i]);
            expect(c.correct, isNot([for (var i = 0; i < c.cards.length; i++) i]));
          case RumorTask.spotDiff:
            final texts = c.cards.map((e) => e.body).toList();
            final odd = texts[c.correct.first];
            expect(texts.where((t) => t != odd).length, texts.length - 1);
          case RumorTask.wordEdit:
            expect(c.correct, isNotEmpty);
          default:
            expect(c.correct.first, lessThan(c.cards.length));
        }
      }
      expect(tasks.length, 5);
    });

    test('Inbox Sprint supports mixed and homogeneous batches after tutorial', () {
      for (final entry in {
        ArcadeDifficulty.easy: 3, ArcadeDifficulty.medium: 4,
        ArcadeDifficulty.hard: 5}.entries) {
        var allLegitimate = 0, allSpam = 0, mixed = 0;
        for (var seed = 0; seed < 250; seed++) {
          final c = ArcadeGenerator(seed).generate(ArcadeMode.inbox, entry.key);
          expect(c.emails.length, entry.value);
          final spamCount = c.emails.where((e) => e.spam).length;
          if (spamCount == 0) allLegitimate++;
          else if (spamCount == c.emails.length) allSpam++;
          else mixed++;
          expect(c.correct, [for (final e in c.emails) e.spam ? 0 : 1]);
        }
        expect(allLegitimate, greaterThan(0));
        expect(allSpam, greaterThan(0));
        expect(mixed, greaterThan(0));
      }
      final firstDay = ArcadeGenerator(4).generate(ArcadeMode.inbox,
          ArcadeDifficulty.easy, tutorial: true);
      expect(firstDay.emails.any((e) => e.spam), true);
      expect(firstDay.emails.any((e) => !e.spam), true);
      expect(ArcadeDifficulty.easy.emailSeconds, isNull);
      expect(ArcadeDifficulty.hard.emailSeconds, isNull);
    });

    test('Comment Chaos: zero, one or two rule breakers; criticism stays allowed', () {
      final counts = <int>{};
      for (var seed = 0; seed < 300; seed++) {
        final c = ArcadeGenerator(seed).generate(
            ArcadeMode.comments, ArcadeDifficulty.hard);
        final bad = [for (var i = 0; i < c.comments.length; i++)
          if (c.comments[i].violates) i];
        expect(c.correct, bad);
        counts.add(bad.length);
        expect(c.comments.length - bad.length, greaterThanOrEqualTo(4));
      }
      expect(counts, {0, 1, 2});
    });

    test('easy Comment Chaos can legitimately have zero violations', () {
      final totals = <int>{};
      for (var seed = 0; seed < 240; seed++) {
        final c = ArcadeGenerator(seed).generate(
            ArcadeMode.comments, ArcadeDifficulty.easy);
        totals.add(c.correct.length);
      }
      expect(totals, contains(0));
      expect(totals, contains(1));
      expect(totals, contains(2));
    });

    test('recent archetypes are avoided across consecutive plays', () {
      for (final mode in [ArcadeMode.trust, ArcadeMode.scamSlam,
          ArcadeMode.rumor, ArcadeMode.clip]) {
        final gen = ArcadeGenerator(837 + mode.index);
        final excluded = <String>{};
        final limit = mode == ArcadeMode.rumor ? 5 : 8;
        for (var n = 0; n < limit; n++) {
          final c = gen.generate(mode, ArcadeDifficulty.medium,
              excludeFamilies: excluded);
          final key = ArcadeGenerator.familyOfSignature(c.signature);
          expect(excluded.contains(key), isFalse, reason: '$mode round $n');
          excluded.add(key);
        }
      }
    });

    test('Hard-mode popular opinion cannot be inverted into an answer key', () {
      final seen = <String>{};
      final likes = <String>{};
      for (var seed = 0; seed < 300; seed++) {
        final c = ArcadeGenerator(seed).generate(
            ArcadeMode.trust, ArcadeDifficulty.hard);
        final replies = c.tools.firstWhere((t) => t.id == 'replies').text;
        final comment = replies.split('Top comment (').last;
        if (comment.contains('Legit')) seen.add('legit:${c.deceptive}');
        if (comment.contains('Fake')) seen.add('fake:${c.deceptive}');
        likes.add(comment.split(' likes)').first);
      }
      expect(seen, containsAll(['legit:true', 'legit:false',
          'fake:true', 'fake:false']));
      expect(likes.length, greaterThan(20));
    });

    test('every mode has plenty of distinct cases', () {
      for (final mode in ArcadeMode.values) {
        final seen = <String>{};
        for (var seed = 0; seed < 300; seed++) {
          seen.add(ArcadeGenerator(seed).generate(mode, ArcadeDifficulty.medium).signature);
        }
        expect(seen.length, greaterThanOrEqualTo(9), reason: '$mode');
      }
    });

    test('recent signatures are avoided when other cases exist', () {
      final generator = ArcadeGenerator(15);
      final seen = <String>{};
      for (var i = 0; i < 25; i++) {
        final c = generator.generate(ArcadeMode.inbox, ArcadeDifficulty.medium,
            exclude: seen);
        expect(seen.contains(c.signature), isFalse);
        seen.add(c.signature);
      }
    });
  });

  group('session rules', () {
    ArcadeSession start({ArcadeMode? mode, ArcadeDifficulty d = ArcadeDifficulty.medium,
        bool firstDay = false, int seed = 5, int xp = 0, List<int>? sink}) =>
        ArcadeSession(
          difficulty: d, selectedMode: mode, firstDay: firstDay, seed: seed,
          careerXp: () => xp,
          awardCareerXp: (v) => sink?.add(v),
        );

    test('a right answer earns XP and builds a streak; a wrong one costs a heart', () {
      final earned = <int>[];
      final s = start(mode: ArcadeMode.trust, sink: earned);
      expect(s.hearts, 4);
      expect(s.submit(s.current.correct, usedDecisive: true), isTrue);
      expect(s.lastEarnedXp, greaterThanOrEqualTo(40));
      expect(s.streak, 1);
      s.next();
      expect(s.submit(wrongAnswer(s.current)), isFalse);
      expect(s.hearts, 3);
      expect(s.streak, 0);
      expect(earned.length, 1);
    });

    test('streak bonus is capped and XP never goes down', () {
      final earned = <int>[];
      final s = start(mode: ArcadeMode.scamSlam, d: ArcadeDifficulty.easy, sink: earned);
      for (var i = 0; i < 8; i++) {
        s.submit(s.current.correct);
        s.next();
      }
      expect(earned.last - earned.first, 12);
      expect(earned.every((v) => v > 0), isTrue);
    });

    test('Inbox Sprint gives partial XP but any miss costs one heart', () {
      final earned = <int>[];
      final s = start(mode: ArcadeMode.inbox, d: ArcadeDifficulty.hard, sink: earned);
      final c = s.current;
      final answer = [...c.correct];
      answer[0] = 1 - answer[0];
      expect(s.submit(answer), isFalse);
      expect(s.lastParts, c.correct.length - 1);
      expect(s.hearts, 2);
      expect(earned.single, greaterThan(0));
    });

    test('a run ends when hearts reach zero and keeps earned XP', () {
      final s = start(mode: ArcadeMode.comments, d: ArcadeDifficulty.hard);
      var rounds = 0;
      while (!s.finished && rounds < 10) {
        s.submit(wrongAnswer(s.current));
        if (!s.finished) s.next();
        rounds++;
      }
      expect(s.finished, isTrue);
      expect(s.hearts, 0);
      expect(rounds, 3);
    });

    test('first day runs five different modes and never locks anyone out', () {
      final s = start(firstDay: true, d: ArcadeDifficulty.easy);
      for (var i = 0; i < ArcadeSession.firstDayModes.length; i++) {
        expect(s.current.mode, ArcadeSession.firstDayModes[i]);
        s.submit(wrongAnswer(s.current));
        if (i < 4) { s.next(); }
      }
      expect(s.finished, isTrue);
      expect(s.hearts, greaterThanOrEqualTo(1));
    });

    test('first day scenarios are the clear teaching cases', () {
      final s = start(firstDay: true, d: ArcadeDifficulty.easy);
      expect(s.current.scenario, 'recycled_flood');
      s.submit(s.current.correct); s.next();
      expect(s.current.scenario, 'lookalike');
      s.submit(s.current.correct); s.next();
      expect(s.current.scenario, 'parcel_fee');
      s.submit(s.current.correct); s.next();
      expect(s.current.emails.length, 3);
      s.submit(s.current.correct); s.next();
      expect(s.current.correct.length, 1);
    });

    test('Endless Mix only uses modes unlocked by cumulative XP', () {
      final s = start(d: ArcadeDifficulty.easy, xp: 0);
      for (var i = 0; i < 20; i++) {
        expect(s.current.mode.unlockXp, 0);
        s.submit(s.current.correct); s.next();
      }
      final rich = start(d: ArcadeDifficulty.easy, xp: 1300, seed: 9);
      final seen = <ArcadeMode>{};
      for (var i = 0; i < 120; i++) {
        seen.add(rich.current.mode);
        rich.submit(rich.current.correct);
        rich.next();
      }
      expect(seen, containsAll(ArcadeMode.values));
    });

    test('XP thresholds are unchanged', () {
      expect(ArcadeMode.trust.unlockXp, 0);
      expect(ArcadeMode.impostor.unlockXp, 0);
      expect(ArcadeMode.scamSlam.unlockXp, 0);
      expect(ArcadeMode.inbox.unlockXp, 300);
      expect(ArcadeMode.comments.unlockXp, 600);
      expect(ArcadeMode.rumor.unlockXp, 900);
      expect(ArcadeMode.clip.unlockXp, 1200);
      expect(ArcadeDifficulty.easy.startingHearts, 5);
      expect(ArcadeDifficulty.medium.startingHearts, 4);
      expect(ArcadeDifficulty.hard.startingHearts, 3);
    });
  });
}
