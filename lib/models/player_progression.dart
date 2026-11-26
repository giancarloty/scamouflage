/// Offline-only career identity unlocks. XP never gets spent, and these
/// cosmetic levels do not replace the numbered Career Shifts.
class CareerRank {
  final int level;
  final int xp;
  final String id;
  final String title;
  final String description;
  const CareerRank(this.level, this.xp, this.id, this.title, this.description);
}

class ProfileCollectible {
  final String id;
  final String name;
  final String symbol;
  final int xp;
  final String description;
  const ProfileCollectible(
    this.id,
    this.name,
    this.symbol,
    this.xp,
    this.description,
  );
}

class CareerProgression {
  static const List<CareerRank> ranks = [
    CareerRank(
      1,
      0,
      'rookie',
      'Rookie Spotter',
      'Every great investigator starts somewhere.',
    ),
    CareerRank(
      2,
      150,
      'link_sleuth',
      'Link Sleuth',
      'You check before you click.',
    ),
    CareerRank(
      3,
      400,
      'scam_detective',
      'Scam Detective',
      'You can spot the red flags AND false alarms.',
    ),
    CareerRank(
      4,
      850,
      'fact_finder',
      'Fact Finder',
      'Evidence beats assumptions.',
    ),
    CareerRank(
      5,
      1400,
      'source_scout',
      'Source Scout',
      'You follow claims back to their origins.',
    ),
    CareerRank(
      6,
      2300,
      'newsroom_analyst',
      'Newsroom Analyst',
      'Context is your superpower.',
    ),
    CareerRank(
      7,
      3600,
      'verification_expert',
      'Verification Expert',
      'Even convincing fakes face your scrutiny.',
    ),
    CareerRank(
      8,
      5200,
      'digital_sentinel',
      'Digital Sentinel',
      'You protect the online community with care.',
    ),
    CareerRank(
      9,
      7400,
      'cyber_guardian',
      'Cyber Guardian',
      'You keep your community safe with sharp judgment.',
    ),
    CareerRank(
      10,
      10000,
      'truth_legend',
      'Truth Legend',
      'Your reputation is built on evidence and empathy.',
    ),
  ];

  static const List<ProfileCollectible> badges = [
    ProfileCollectible(
      'chameleon',
      'Bantay Buddy',
      '🦎',
      0,
      'Your first Scamouflage badge.',
    ),
    ProfileCollectible(
      'magnifier',
      'Clue Collector',
      '🔎',
      200,
      'Unlocked by careful investigation.',
    ),
    ProfileCollectible(
      'shield',
      'Safe Clicker',
      '🛡️',
      500,
      'Guard against suspicious links.',
    ),
    ProfileCollectible(
      'newspaper',
      'Press Pass',
      '📰',
      1000,
      'Follow the full story.',
    ),
    ProfileCollectible(
      'spark',
      'Fact Checker',
      '✨',
      1800,
      'Bring receipts, not rumors.',
    ),
    ProfileCollectible(
      'trophy',
      'Truth Champion',
      '🏆',
      3200,
      'A badge for dedicated investigators.',
    ),
  ];

  static const List<ProfileCollectible> frames = [
    ProfileCollectible(
      'classic',
      'Classic Navy',
      '◈',
      0,
      'The original Bantay Tambayan frame.',
    ),
    ProfileCollectible(
      'sunny',
      'Sunshine Signal',
      '☀️',
      300,
      'Warm and lively.',
    ),
    ProfileCollectible(
      'bubblegum',
      'Pink Press',
      '💗',
      700,
      'A playful reporter look.',
    ),
    ProfileCollectible(
      'mint',
      'Mint Defender',
      '🌱',
      1300,
      'Cool and collected.',
    ),
    ProfileCollectible(
      'violet',
      'Violet Vision',
      '💜',
      2600,
      'Stand out from the crowd.',
    ),
    ProfileCollectible(
      'gold',
      'Goldianna Extravaganza!',
      '✨',
      9500,
      'A radiant metallic gold frame for your investigator profile.',
    ),
  ];

  /// Unlockable names for ChameLeo. Names and colors are cosmetics, not spending.
  static const List<ProfileCollectible> mascotNames = [
    ProfileCollectible(
      'chameleo',
      'ChameLeo',
      '🦎',
      0,
      'A detective with an eye for the truth.',
    ),
    ProfileCollectible(
      'checks',
      'Sir Checks-a-Lot',
      '🔍',
      150,
      'Always checking, never guessing.',
    ),
    ProfileCollectible(
      'linky',
      'Linky McBlink',
      '🔗',
      400,
      'That link looks oddly familiar.',
    ),
    ProfileCollectible(
      'factgecko',
      'Fact Gecko',
      '📰',
      850,
      'Gecko on the record!',
    ),
    ProfileCollectible(
      'receipts',
      'Professor Receipts',
      '🧾',
      1400,
      'Where are the receipts?',
    ),
    ProfileCollectible(
      'pixel',
      'Pixel Poirot',
      '🎩',
      2300,
      'A tiny detective with big deductions.',
    ),
    ProfileCollectible(
      'nootp',
      'Agent No-TP',
      '🛡️',
      3600,
      'Never share the secret code.',
    ),
    ProfileCollectible(
      'clicklock',
      'Captain Click-Lock',
      '🔐',
      5200,
      'One safe click at a time.',
    ),
    ProfileCollectible(
      'hiss',
      'The Hiss-torian',
      '📚',
      7400,
      'Tracing rumors to their roots.',
    ),
    ProfileCollectible(
      'truth',
      'The Unphishable',
      '🏆',
      10000,
      'A legendary internet sleuth.',
    ),
  ];

  static const List<ProfileCollectible> mascotColors = [
    ProfileCollectible(
      'mint',
      'Classic Mint',
      '🌿',
      0,
      'The original cheerful chameleon.',
    ),
    ProfileCollectible(
      'sky',
      'Sky Sleuth',
      '💠',
      150,
      'A cool blue investigator.',
    ),
    ProfileCollectible('rose', 'Coral Caper', '🌺', 400, 'A rosy disguise.'),
    ProfileCollectible(
      'sunny',
      'Golden Gecko',
      '☀️',
      700,
      'Bright-eyed and curious.',
    ),
    ProfileCollectible(
      'violet',
      'Violet Verdict',
      '💜',
      1000,
      'A mysterious purple shade.',
    ),
    ProfileCollectible(
      'pink',
      'Bubblegum Bluff',
      '🩷',
      1600,
      'Never underestimate pink.',
    ),
    ProfileCollectible(
      'teal',
      'Deep-Sea Detective',
      '🫧',
      2600,
      'Calm under pressure.',
    ),
    ProfileCollectible(
      'ice',
      'Icy Investigator',
      '❄️',
      3800,
      'Cool-headed fact checks.',
    ),
    ProfileCollectible(
      'ember',
      'Ember Evidence',
      '🔥',
      6000,
      'A fiery pursuit of facts.',
    ),
    ProfileCollectible(
      'gold',
      'Legendary Gold',
      '👑',
      9500,
      'The final glowing disguise.',
    ),
  ];

  static ProfileCollectible? mascotNameById(String id) {
    for (final item in mascotNames) {
      if (item.id == id) return item;
    }
    return null;
  }

  static ProfileCollectible? mascotColorById(String id) {
    for (final item in mascotColors) {
      if (item.id == id) return item;
    }
    return null;
  }

  static CareerRank rankAt(int xp) {
    var current = ranks.first;
    for (final rank in ranks) {
      if (xp < rank.xp) break;
      current = rank;
    }
    return current;
  }

  static CareerRank? nextRank(int xp) {
    for (final rank in ranks) {
      if (xp < rank.xp) return rank;
    }
    return null;
  }

  static double levelProgress(int xp) {
    final current = rankAt(xp);
    final next = nextRank(xp);
    if (next == null) return 1;
    return ((xp - current.xp) / (next.xp - current.xp))
        .clamp(0.0, 1.0)
        .toDouble();
  }

  static CareerRank? rankById(String id) {
    for (final rank in ranks) {
      if (rank.id == id) return rank;
    }
    return null;
  }

  static ProfileCollectible? badgeById(String id) {
    for (final item in badges) {
      if (item.id == id) return item;
    }
    return null;
  }

  static ProfileCollectible? frameById(String id) {
    for (final item in frames) {
      if (item.id == id) return item;
    }
    return null;
  }
}
