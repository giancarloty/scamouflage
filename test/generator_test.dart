import 'package:flutter_test/flutter_test.dart';
import 'package:scamouflage/services/generator.dart';
import 'package:scamouflage/models/models.dart';

void main() {
  test('Every shift produces seven unique archetypes and both verdicts', () {
    for (var shift = 1; shift <= 6; shift++) {
      for (var seed = 1; seed <= 120; seed++) {
        final bundle = CaseGenerator(seed).generate(shift, seed: seed);
        expect(bundle.cases.length, 7);
        expect(bundle.cases.map((c) => c.archetypeId).toSet().length, 7);
        expect(bundle.cases.any((c) => c.correct == Verdict.approve), isTrue);
        expect(bundle.cases.any((c) => c.correct == Verdict.reject), isTrue);
      }
    }
  });

  test('Source evidence is decisive but must be verified', () {
    for (final p in patterns) {
      final item = CaseGenerator(patterns.indexOf(p) + 10).build(p, 'test');
      expect(item.clues.length, 3);
      expect(item.clues.where((c) => c.verification).length, 1);
      final source = item.clues.singleWhere((c) => c.verification);
      expect(source.strength, 3);
      expect(
        source.signal,
        item.correct == Verdict.reject
            ? EvidenceSignal.suspicious
            : EvidenceSignal.supporting,
      );
      for (final free in item.clues.where((c) => !c.verification)) {
        expect(free.strength, lessThan(3));
      }
    }
  });

  test('Account ages are consistent with join-date descriptions', () {
    final dayOld = patterns.firstWhere(
      (p) => p.kind == CaseKind.profile && p.secondary.contains('2-day-old'),
    );
    final page = CaseGenerator(66).build(dayOld, 'account');
    expect(page.ageDays, 2);
    expect(page.accountAge, '2 days ago');
    expect(page.followers, lessThan(2000));
  });

  test('Common superficial signals do not imply the verdict', () {
    final sms = patterns.where((p) => p.kind == CaseKind.sms);
    expect(
      sms.any((p) => p.verdict == Verdict.approve && p.body.contains('₱')),
      isTrue,
    );
    expect(
      sms.any((p) => p.verdict == Verdict.reject && p.body.contains('₱')),
      isTrue,
    );
    final profiles = patterns.where((p) => p.kind == CaseKind.profile);
    expect(
      profiles.any(
        (p) => p.verdict == Verdict.approve && p.secondary.contains('2-day'),
      ),
      isTrue,
    );
  });

  test('Recent archetypes are avoided when other candidates exist', () {
    final a = CaseGenerator(19).generate(1, seed: 19);
    final b = CaseGenerator(
      20,
    ).generate(1, seed: 20, recent: a.signatures.toSet());
    expect(b.cases.length, 7);
    expect(b.cases.map((c) => c.id).toSet().length, 7);
    expect(b.cases.map((c) => c.archetypeId).toSet().length, 7);
  });
}
