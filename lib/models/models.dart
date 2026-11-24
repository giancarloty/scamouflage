import 'package:flutter/material.dart';

enum CaseKind { post, profile, sms, email, report, video }
enum Verdict { approve, reject }
enum Mode { career, endless, training }
enum EvidenceSignal { suspicious, supporting, ambiguous, neutral }
enum EvidenceTag { unset, suspicious, supporting, unsure }

extension EvidenceSignalInfo on EvidenceSignal {
  String get name => switch (this) {
    EvidenceSignal.suspicious => 'SUSPICIOUS',
    EvidenceSignal.supporting => 'SUPPORTS',
    EvidenceSignal.ambiguous => 'UNCERTAIN',
    EvidenceSignal.neutral => 'BACKGROUND',
  };
  IconData get icon => switch (this) {
    EvidenceSignal.suspicious => Icons.flag_rounded,
    EvidenceSignal.supporting => Icons.check_circle_rounded,
    EvidenceSignal.ambiguous => Icons.help_outline_rounded,
    EvidenceSignal.neutral => Icons.remove_circle_outline_rounded,
  };
}

extension EvidenceTagInfo on EvidenceTag {
  String get label => switch (this) {
    EvidenceTag.unset => 'MARK',
    EvidenceTag.suspicious => 'FLAG',
    EvidenceTag.supporting => 'BACKS',
    EvidenceTag.unsure => 'UNSURE',
  };
  EvidenceTag get next => switch (this) {
    EvidenceTag.unset => EvidenceTag.suspicious,
    EvidenceTag.suspicious => EvidenceTag.supporting,
    EvidenceTag.supporting => EvidenceTag.unsure,
    EvidenceTag.unsure => EvidenceTag.unset,
  };
}

extension CaseKindInfo on CaseKind {
  String get label => switch (this) {
    CaseKind.post => 'SOCIAL POST', CaseKind.profile => 'ACCOUNT PROFILE',
    CaseKind.sms => 'TEXT MESSAGE', CaseKind.email => 'EMAIL INBOX',
    CaseKind.report => 'USER REPORT', CaseKind.video => 'VIDEO CLIP',
  };
  IconData get icon => switch (this) {
    CaseKind.post => Icons.dynamic_feed_rounded,
    CaseKind.profile => Icons.account_circle_rounded,
    CaseKind.sms => Icons.sms_rounded,
    CaseKind.email => Icons.alternate_email_rounded,
    CaseKind.report => Icons.report_gmailerrorred_rounded,
    CaseKind.video => Icons.smart_display_rounded,
  };
}

class Hotspot {
  final String id;
  final String label;
  final String reveal;
  final IconData icon;
  final EvidenceSignal signal;
  final int strength;
  final bool verification;
  final String principle;
  const Hotspot(
    this.id, this.label, this.reveal, this.icon, {
    this.signal = EvidenceSignal.neutral,
    this.strength = 1,
    this.verification = false,
    this.principle = 'check_the_source',
  });
}

class PlayCase {
  final String id, archetypeId, topic, author, handle, headline, body;
  final String artifact, secondary, timestamp, accountAge, rationale, variant;
  final CaseKind kind;
  final Verdict correct;
  final int ageDays, followers, likes, reports, tier;
  final bool verified;
  final List<Hotspot> clues;
  const PlayCase({
    required this.id, required this.kind, required this.correct,
    required this.topic, required this.author, required this.handle,
    required this.headline, required this.body, required this.artifact,
    required this.secondary, required this.timestamp, required this.accountAge,
    required this.followers, required this.likes, required this.reports,
    required this.verified, required this.clues, required this.rationale,
    required this.variant, this.archetypeId = '', this.ageDays = 30,
    this.tier = 2,
  });
}

class ReviewResult {
  final PlayCase item;
  final Verdict answer;
  final int xp, tagsCorrect;
  final bool correct, verifiedSource;
  final Map<String, EvidenceTag> tags;
  final Set<String> opened;
  const ReviewResult(this.item, this.answer, this.xp, this.correct,
    this.tagsCorrect, this.verifiedSource, this.tags, this.opened);
}

class ShiftInfo {
  final String name, subtitle, hint;
  final IconData icon;
  final List<CaseKind> kinds;
  const ShiftInfo(this.name, this.subtitle, this.hint, this.icon, this.kinds);
}

const shifts = <ShiftInfo>[
  ShiftInfo('THE FEED', 'Headlines and opinion', 'Check a claim, not the tone.', Icons.dynamic_feed_rounded, [CaseKind.post]),
  ShiftInfo('IDENTITY CRISIS', 'Accounts and impersonators', 'Age alone proves nothing.', Icons.people_rounded, [CaseKind.profile, CaseKind.post]),
  ShiftInfo('INBOX MAYHEM', 'Texts and fraudulent rewards', 'Look for independent verification.', Icons.sms_rounded, [CaseKind.sms, CaseKind.profile]),
  ShiftInfo('REPORT RUSH', 'Fandom brigades and appeals', 'Report count is not proof.', Icons.flag_rounded, [CaseKind.report, CaseKind.post, CaseKind.profile]),
  ShiftInfo('MAILROOM CHAOS', 'Emails and benefit notices', 'Inspect the actual sender.', Icons.mark_email_unread_rounded, [CaseKind.email, CaseKind.sms, CaseKind.report]),
  ShiftInfo('MEDIA MELTDOWN', 'Edited clips and disclosures', 'Find the original source.', Icons.movie_filter_rounded, [CaseKind.video, CaseKind.post, CaseKind.report, CaseKind.email]),
];
