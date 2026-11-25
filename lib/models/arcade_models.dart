/// Arcade game rules and data. This layer is UI-independent (pure Dart) so it
/// can be unit tested without Flutter.
enum ArcadeMode { trust, impostor, scamSlam, rumor, inbox, comments, clip }

enum ArcadeDifficulty { easy, medium, hard }

/// How a rumor puzzle is played. Each task uses a different control.
enum RumorTask { order, spotDiff, outdated, independent, wordEdit }

/// How useful an inspection result is. Never shown to the player; used for
/// XP bonuses, hints and generator validation.
enum Relevance { decisive, support, decoy }

extension ArcadeModeInfo on ArcadeMode {
  String get title => switch (this) {
    ArcadeMode.trust => 'TRUST OR BUST',
    ArcadeMode.impostor => 'IMPOSTOR HUNT',
    ArcadeMode.scamSlam => 'SCAM SLAM',
    ArcadeMode.rumor => 'RUMOR RADAR',
    ArcadeMode.inbox => 'INBOX SPRINT',
    ArcadeMode.comments => 'COMMENT CHAOS',
    ArcadeMode.clip => 'CLIP CHECK',
  };
  String get subtitle => switch (this) {
    ArcadeMode.trust => 'Inspect a viral post, then keep or remove',
    ArcadeMode.impostor => 'Cross-check two accounts with the directory',
    ArcadeMode.scamSlam => 'Chat back before the scammer wins',
    ArcadeMode.rumor => 'Rebuild chains, spot edits, find real proof',
    ArcadeMode.inbox => 'Swipe a whole inbox: spam or keep',
    ArcadeMode.comments => 'Flag only the comments that break rules',
    ArcadeMode.clip => 'Scrub the timeline: viral cut vs full video',
  };

  /// One short line shown during play.
  String get how => switch (this) {
    ArcadeMode.trust => 'Tap checks, then decide.',
    ArcadeMode.impostor => 'Open both. Compare with the directory.',
    ArcadeMode.scamSlam => 'Read the chat. Pick your reply.',
    ArcadeMode.rumor => 'Solve the puzzle, then lock it in.',
    ArcadeMode.inbox => 'Swipe left = spam, right = keep.',
    ArcadeMode.comments => 'Tap rule-breaking comments.',
    ArcadeMode.clip => 'Slide the timeline. Compare cuts.',
  };
  String get emoji => switch (this) {
    ArcadeMode.trust => '📣', ArcadeMode.impostor => '🕵️',
    ArcadeMode.scamSlam => '💬', ArcadeMode.rumor => '🧩',
    ArcadeMode.inbox => '✉️', ArcadeMode.comments => '👑',
    ArcadeMode.clip => '🎬',
  };
  int get unlockXp => switch (this) {
    ArcadeMode.trust || ArcadeMode.impostor || ArcadeMode.scamSlam => 0,
    ArcadeMode.inbox => 300,
    ArcadeMode.comments => 600,
    ArcadeMode.rumor => 900,
    ArcadeMode.clip => 1200,
  };
}

/// Shared difficulty settings. Difficulty should change the reasoning required,
/// not only the amount of punishment for a wrong answer.
class DifficultyProfile {
  final int startingHearts;
  final int scanBudget;
  final int? emailSeconds;
  final int reasoningLevel;
  final int decoyClues;
  final int conflictingEvidence;
  final bool requiresCrossChecking;

  const DifficultyProfile({
    required this.startingHearts,
    required this.scanBudget,
    required this.emailSeconds,
    required this.reasoningLevel,
    required this.decoyClues,
    required this.conflictingEvidence,
    required this.requiresCrossChecking,
  });
}

extension ArcadeDifficultyInfo on ArcadeDifficulty {
  String get title => switch (this) {
    ArcadeDifficulty.easy => 'EASY',
    ArcadeDifficulty.medium => 'MEDIUM',
    ArcadeDifficulty.hard => 'HARD',
  };

  DifficultyProfile get profile => switch (this) {
    ArcadeDifficulty.easy => const DifficultyProfile(
      startingHearts: 5, scanBudget: 5, emailSeconds: null,
      reasoningLevel: 1, decoyClues: 0, conflictingEvidence: 0,
      requiresCrossChecking: false,
    ),
    ArcadeDifficulty.medium => const DifficultyProfile(
      startingHearts: 4, scanBudget: 4, emailSeconds: 10,
      reasoningLevel: 2, decoyClues: 1, conflictingEvidence: 1,
      requiresCrossChecking: false,
    ),
    ArcadeDifficulty.hard => const DifficultyProfile(
      startingHearts: 3, scanBudget: 2, emailSeconds: null,
      reasoningLevel: 4, decoyClues: 3, conflictingEvidence: 3,
      requiresCrossChecking: true,
    ),
  };

  int get startingHearts => profile.startingHearts;
  int get bonusXp => index * 10;

  /// How many inspection tools a player may open on one case.
  int get scanBudget => profile.scanBudget;

  /// Seconds per email in Inbox Sprint; null means untimed.
  int? get emailSeconds => profile.emailSeconds;
}

class ArcadeOption {
  final String text;
  const ArcadeOption(this.text);
}

/// One inspection result (a "tool" the player can open on a case).
class Finding {
  final String id, label, emoji, text;
  final Relevance relevance;
  const Finding(this.id, this.label, this.emoji, this.text, this.relevance);
}

class ProfileView {
  final String name, handle, bio, link;
  final String? label;
  final bool badge;
  final List<String> recent;
  final int ageDays, followers;
  const ProfileView({
    required this.name, required this.handle, required this.bio,
    required this.ageDays, required this.followers,
    this.link = 'no link', this.label, this.badge = false,
    this.recent = const [],
  });
  String get ageLabel => ageDays < 7 ? '$ageDays days old' :
      ageDays < 365 ? '${(ageDays / 30).round()} months old' :
      '${(ageDays / 365).round()} yrs old';
}

class EmailItem {
  final String fromName, fromAddress, replyTo, subject, body;
  final String linkLabel, linkTarget, attachment;
  /// The sorting truth: true = spam/phishing, false = legitimate.
  final bool spam;
  final String why;
  const EmailItem({
    required this.fromName, required this.fromAddress, required this.subject,
    required this.body, required this.spam, required this.why,
    this.replyTo = '', this.linkLabel = '', this.linkTarget = '',
    this.attachment = '',
  });
}

class CommentView {
  final String handle, body, context, reason;
  /// True when this comment really breaks the community rules.
  final bool violates;
  const CommentView(this.handle, this.body,
      {this.context = '', this.violates = false, this.reason = ''});
}

class RumorCard {
  final String title, body, meta;
  const RumorCard(this.title, this.body, [this.meta = '']);
}

class ClipBeat {
  /// Seconds into the original video.
  final int second;
  final String scene, viralLine, fullLine;
  final bool inViral;
  const ClipBeat(this.second, this.scene, this.viralLine, this.fullLine,
      {this.inViral = true});
}

/// A complete scenario. Truth is generated first (see [deceptive] and
/// [correct]); visible wording and clues are derived from it.
/// Fictional people, brands and `.example` domains only.
class ArcadeCase {
  final String signature, scenario;
  final ArcadeMode mode;
  final String title, author, handle, text, subtext, lesson, hint, visual;
  final bool deceptive;

  /// The correct answer in the mode's own format:
  ///  single choice: [index]; comments: sorted flagged indices (may be empty);
  ///  rumor order: card indices in the right order; word edit: sorted token
  ///  indices; inbox: per email 0 = spam, 1 = keep.
  final List<int> correct;

  // Post Autopsy / Clip Check
  final String imageTopic, imageCaption, reactions;
  final List<Finding> tools;

  // Impostor Hunt
  final ProfileView? leftProfile, rightProfile;
  final List<String> directory;

  // Scam Slam
  final List<String> chatIn, activity;
  final String linkDomain;
  final List<ArcadeOption> choices;
  final Map<int, List<String>> followUps;

  // Rumor Radar
  final RumorTask? rumorTask;
  final List<RumorCard> cards;
  final List<String> tokens;

  // Inbox Sprint
  final List<EmailItem> emails;

  // Comment Chaos
  final List<CommentView> comments;

  // Clip Check
  final List<ClipBeat> beats;

  const ArcadeCase({
    required this.signature, required this.scenario, required this.mode,
    required this.title, required this.lesson, required this.hint,
    required this.correct, required this.deceptive,
    this.author = '', this.handle = '', this.text = '', this.subtext = '',
    this.visual = '', this.imageTopic = 'Government', this.imageCaption = '',
    this.reactions = '', this.tools = const [],
    this.leftProfile, this.rightProfile, this.directory = const [],
    this.chatIn = const [], this.activity = const [], this.linkDomain = '',
    this.choices = const [], this.followUps = const {},
    this.rumorTask, this.cards = const [], this.tokens = const [],
    this.emails = const [], this.comments = const [], this.beats = const [],
  });

  /// Single-choice convenience.
  int get correctChoice => correct.isEmpty ? -1 : correct.first;

  bool get isBatch => mode == ArcadeMode.inbox;

  bool get _sortsAnswer => mode == ArcadeMode.comments ||
      (mode == ArcadeMode.rumor && rumorTask == RumorTask.wordEdit);

  /// Number of sub-answers that match the truth (Inbox Sprint is partial).
  int matches(List<int> answer) {
    if (mode == ArcadeMode.inbox) {
      var n = 0;
      for (var i = 0; i < correct.length; i++) {
        if (i < answer.length && answer[i] == correct[i]) n++;
      }
      return n;
    }
    return isCorrect(answer) ? 1 : 0;
  }

  int get totalParts => mode == ArcadeMode.inbox ? correct.length : 1;

  bool isCorrect(List<int> answer) {
    final a = [...answer];
    if (_sortsAnswer) a.sort();
    if (a.length != correct.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != correct[i]) return false;
    }
    return true;
  }

  /// The tool ids that actually settle the question.
  List<String> get decisiveIds => tools
      .where((t) => t.relevance == Relevance.decisive)
      .map((t) => t.id).toList();
}
