import 'arcade_common.dart';
import '../models/arcade_models.dart';

/// Rumor Radar. Five puzzles, five controls:
///  0 order       drag cards to rebuild who reposted whom
///  1 spotDiff    tap the version that disagrees with the official notice
///  2 outdated    tap the post that would mislead *today* (dates, not age)
///  3 independent tap the one item that confirms the claim on its own
///  4 wordEdit    tap the words that were changed in a viral caption
int rumorScenarioCount() => RumorTask.values.length;
String rumorScenarioId(int i) => RumorTask.values[i].name;

const _escalations = <String, List<String>>{
  'fire': [
    "May sunog sa Brgy. {town}. Dalawang bahay ang apektado, wala pong nasaktan.",
    "Sunog sa Brgy. {town}! Mga 10 bahay na raw ang nasusunog.",
    "SUNOG SA {town}! Halos buong barangay na, may mga patay daw!",
    "Walang lumalabas na balita pero sunog na ang buong lungsod! Magtago na kayo!",
    "BREAKING: Sunog sa buong probinsya, itinatago ng gobyerno!",
  ],
  'flood': [
    "Hanggang bukung-bukong ang baha sa kanto ng Brgy. {town}, passable pa rin.",
    "Hanggang tuhod na ang baha sa Brgy. {town}, mag-ingat po.",
    "Hanggang bewang na ang baha sa buong {town}! Hindi na madaanan!",
    "Lubog na ang buong lungsod, rescue na ang kailangan!",
    "WALANG TUMUTULONG! Lubog ang buong probinsya, nawawala na ang mga tao!",
  ],
  'dengue': [
    "Limang kaso ng dengue ang naitala sa isang paaralan sa Brgy. {town}.",
    "Dengue sa school ng Brgy. {town}, marami na raw ang naospital.",
    "Outbreak ng dengue sa buong {town}, sarado na raw ang mga paaralan!",
    "Dengue emergency sa lungsod, daan-daang patay na daw!",
    "Lockdown na ang buong probinsya dahil sa dengue, itinatago ng gobyerno!",
  ],
  'fare': [
    "Panukala: ₱2 na dagdag-pasahe sa jeep, pag-uusapan pa sa hearing sa Huwebes.",
    "Tataas na raw ang pamasahe ng ₱2 simula Lunes.",
    "Doble na ang pamasahe simula bukas!!",
    "Hindi na makakasakay ang mga estudyante dahil sa taas ng pamasahe, kanselado na ang klase!",
    "Walang jeep na bibiyahe simula Lunes, hindi na raw babalik!",
  ],
  'road': [
    "Isang lane sa highway ang sarado ngayong gabi para sa pag-aayos.",
    "Sarado ang highway ng 3 oras ngayong gabi, humanap ng ibang daan.",
    "SARADO ang highway buong linggo! Wag na kayong dumaan!",
    "Sarado na ang buong NCR at probinsya, lahat ng tulay bagsak na!",
    "Bagsak ang tulay at sarado ang bansa, magtago na!",
  ],
};

const _eyewitness = [
  "Nandito ako mismo sa lugar. Ito ang kuha ko kanina.",
  "Personal kong nakita. Kuha ko ang larawan na ito.",
  "Residente ako dito, ako ang nag-video.",
];

String _h(Gen g) => '@${g.pick(Pools.handlesFirst)}${g.id()}';

ArcadeCase buildRumor(Gen g, ArcadeDifficulty d, int index) {
  switch (RumorTask.values[index]) {
    case RumorTask.order: return _order(g, d);
    case RumorTask.spotDiff: return _spot(g, d);
    case RumorTask.outdated: return _outdated(g, d);
    case RumorTask.independent: return _independent(g, d);
    case RumorTask.wordEdit: return _word(g, d);
  }
}

// ----------------------------------------------------------------- order
ArcadeCase _order(Gen g, ArcadeDifficulty d) {
  final topic = g.pick(_escalations.keys.toList());
  final levels = _escalations[topic]!;
  final n = switch (d) {
    ArcadeDifficulty.easy => 3,
    ArcadeDifficulty.medium => 4,
    ArcadeDifficulty.hard => 5,
  };
  final town = g.pick(Pools.towns);
  final handles = List.generate(n, (_) => _h(g));
  // Chain position 0 is the first-hand post.
  final chain = <RumorCard>[];
  for (var i = 0; i < n; i++) {
    final body = fillSlots(levels[i], {'town': town});
    final String meta;
    if (i == 0) {
      meta = g.pick(_eyewitness);
    } else if (g.chance(.5)) {
      meta = 'Shared from ${handles[i - 1]}';
    } else {
      meta = "Screenshot of ${handles[i - 1]}'s post";
    }
    chain.add(RumorCard(handles[i], body, meta));
  }
  // Shuffle for display; make sure it isn't already solved.
  var perm = g.shuffled([for (var i = 0; i < n; i++) i]);
  var tries = 0;
  while (_isIdentity(perm) && tries++ < 8) {
    perm = g.shuffled([for (var i = 0; i < n; i++) i]);
  }
  final cards = [for (final i in perm) chain[i]];
  // correct: display indexes in chain order (origin first).
  final correct = [for (var i = 0; i < n; i++) perm.indexOf(i)];
  return ArcadeCase(
    signature: 'rumor:order:$topic:$n', scenario: 'order', mode: ArcadeMode.rumor,
    title: 'Who started it?', rumorTask: RumorTask.order,
    text: 'Use the arrows: first-hand post at the top, newest repost last.',
    subtext: 'Each card says who it copied from.',
    cards: cards, correct: correct, deceptive: true,
    lesson: "Each repost copies the one before it, and the story grows. The post at the top is first-hand, and the later ones add details nobody there confirmed.",
    hint: 'Start with the card that says it saw it personally. Then follow each "Shared from".',
  );
}

bool _isIdentity(List<int> p) {
  for (var i = 0; i < p.length; i++) {
    if (p[i] != i) return false;
  }
  return true;
}

// ---------------------------------------------------------------- spotDiff
ArcadeCase _spot(Gen g, ArcadeDifficulty d) {
  final days = ['Sabado', 'Linggo', 'Biyernes', 'Huwebes'];
  final times = ['8:00 AM', '9:30 AM', '1:00 PM', '3:00 PM'];
  final venues = ['covered court ng Brgy. {town}', 'Health Center ng Brgy. {town}',
    'gym ng {school}', 'plaza ng {city}'];
  final fees = ['Libre', 'Libre', 'Libre'];
  final town = g.pick(Pools.towns);
  final slots = {
    'town': town, 'school': g.pick(Pools.schools), 'city': g.pick(Pools.cities),
  };
  final day = g.pick(days), time = g.pick(times);
  final venue = fillSlots(g.pick(venues), slots);
  final fee = g.pick(fees);
  final phone = '0917 ${g.between(100, 999)} ${g.between(1000, 9999)}';
  final event = g.pick(['Libreng medical mission', 'Libreng bakuna',
    'Scholarship briefing', 'Job fair', 'Blood donation drive']);
  final attrs = ['day', 'time', 'venue', 'fee', 'phone'];
  final changed = g.pick(attrs);
  String render(String Function(String a, String real) tweak) {
    String v(String a, String real) => tweak(a, real);
    return '$event: ${v('day', day)}, ${v('time', time)}, ${v('venue', venue)}. '
        '${v('fee', fee)}. Hotline: ${v('phone', phone)}';
  }
  String altered(String a, String real) {
    if (a != changed) return real;
    return switch (a) {
      'day' => g.pick(days.where((x) => x != day).toList()),
      'time' => g.pick(times.where((x) => x != time).toList()),
      'venue' => fillSlots(g.pick(venues.where((x) => fillSlots(x, slots) != venue).toList()), slots),
      'fee' => '₱${g.pick(['50', '150', '300'])} registration',
      _ => '0917 ${g.between(100, 999)} ${g.between(1000, 9999)}',
    };
  }
  final official = render((a, real) => real);
  final faithful = render((a, real) => real);
  final n = d == ArcadeDifficulty.hard ? 4 : 3;
  final wrongOne = render(altered);
  final texts = <String>[wrongOne];
  while (texts.length < n) {
    // Hard mode requires semantic comparison, not simply finding the lone
    // string that isn't byte-for-byte identical to its neighbours.
    texts.add(d == ArcadeDifficulty.hard
        ? g.pick(['Reposted notice: $faithful', 'Forwarded: $faithful',
            'Shared community announcement: $faithful'])
        : faithful);
  }
  final sources = g.shuffled(['Group chat forward', 'Page repost',
    'Screenshot in a story', 'Fan page', 'Barangay board repost']).take(n).toList();
  final perm = g.shuffled([for (var i = 0; i < n; i++) i]);
  final cards = [for (final i in perm) RumorCard('Version ${perm.indexOf(i) + 1}', texts[i], sources[i])];
  final correct = perm.indexOf(0);
  final label = switch (changed) {
    'day' => 'day', 'time' => 'time', 'venue' => 'place',
    'fee' => 'fee', _ => 'hotline',
  };
  return ArcadeCase(
    signature: 'rumor:spot:$changed:$n', scenario: 'spotDiff', mode: ArcadeMode.rumor,
    title: 'Which one was changed?', rumorTask: RumorTask.spotDiff,
    text: 'Which version changes a fact from the official notice? Ignore forwarding labels.',
    subtext: 'OFFICIAL NOTICE: $official',
    cards: cards, correct: [correct], deceptive: true,
    lesson: "Only the $label changed in one version. Small edits to a date, fee or hotline are how scammers redirect people, so compare each detail line by line.",
    hint: 'Read each version line by line against the official notice. What detail is different?',
  );
}

// -------------------------------------------------------------- outdated
ArcadeCase _outdated(Gen g, ArcadeDifficulty d) {
  final months = ['Oct', 'Nov'];
  final todayDay = g.between(10, 22);
  final todayMonth = months.first;
  String dateAt(int offset) {
    var day = todayDay + offset;
    var month = todayMonth;
    if (day > 31) { day -= 31; month = 'Nov'; }
    if (day < 1) { day += 30; month = 'Sep'; }
    return '$month $day';
  }
  final what = g.pick([
    ('Enrollment deadline', 'Enrollment sa {school} hanggang'),
    ('Promo end', 'Libreng sakay promo hanggang'),
    ('Registration', 'Registration para sa scholarship hanggang'),
    ('Payout', 'Payout para sa registered seniors sa'),
  ]);
  final school = g.pick(Pools.schools);
  String line(int deadlineOffset) =>
      '${fillSlots(what.$2, {'school': school})} ${dateAt(deadlineOffset)}.';
  final n = d == ArcadeDifficulty.easy ? 3 : 4;
  // Stale post can be an old post OR a freshly re-shared old poster.
  final recycled = d == ArcadeDifficulty.easy ? false : g.chance(.6);
  final items = <(RumorCard, bool)>[];
  items.add((RumorCard('Page A', line(-g.between(4, 9)),
      recycled ? 'Posted yesterday' : 'Posted ${g.between(18, 30)} days ago'), true));
  items.add((RumorCard('Page B', line(g.between(6, 14)),
      'Posted ${g.between(20, 35)} days ago'), false)); // old but still valid
  items.add((RumorCard('Page C', line(g.between(10, 20)),
      'Posted ${g.between(1, 3)} days ago'), false));
  if (n == 4) {
    items.add((RumorCard('Page D', line(g.between(3, 9)), 'Posted today'), false));
  }
  final perm = g.shuffled([for (var i = 0; i < n; i++) i]);
  final cards = [for (final i in perm) items[i].$1];
  final correct = perm.indexWhere((i) => items[i].$2);
  return ArcadeCase(
    signature: 'rumor:outdated:${what.$1}:${recycled ? 1 : 0}:$n',
    scenario: 'outdated', mode: ArcadeMode.rumor,
    title: 'What is stale?', rumorTask: RumorTask.outdated,
    text: 'Today is ${dateAt(0)}. Which post would mislead people if you shared it now?',
    subtext: 'Look at the deadline, not just when it was posted.',
    cards: cards, correct: [correct], deceptive: true,
    lesson: "The stale post has a deadline that's already passed. The post date can fool you: an old post can still be valid, and a brand-new post can recycle an old deadline.",
    hint: 'Compare each deadline to today. Ignore how old each post is.',
  );
}

// ----------------------------------------------------------- independent
ArcadeCase _independent(Gen g, ArcadeDifficulty d) {
  final claim = g.pick([
    'Libreng sakay para sa mga estudyante sa Lunes',
    'Bagong bayad sa e-wallet para sa ayuda',
    'Sarado ang tulay sa Brgy. {town} sa Sabado',
    'Nag-apruba ang konseho ng ordinansa sa single-use plastic',
  ]);
  final town = g.pick(Pools.towns);
  final c = fillSlots(claim, {'town': town});
  final outlet = g.pick(Pools.outlets);
  final real = <RumorCard>[
    RumorCard("City Hall's own notice", 'Signed, dated notice on the official page: "$c".', 'Basis: its own decision'),
    RumorCard('Council meeting record', 'The council secretary\'s posted minutes include: "$c".', 'Basis: the meeting itself'),
    RumorCard('On-scene video', 'Reporter\'s own video with a time stamp and a visible street sign: "$c".', 'Basis: filmed on location'),
  ];
  final fake = <RumorCard>[
    RumorCard('Viral repost', '"$c" with 3.2K shares.', 'Basis: same screenshot as the first post'),
    RumorCard('$outlet article', 'Headline: "$c, netizens say".', 'Basis: cites "a viral post"'),
    const RumorCard('Comment thread', '"Totoo \'yan! Sabi ng kapitbahay ko."', 'Basis: heard from a neighbor'),
    const RumorCard('Fan page copy', 'Same wording as the viral post, posted 2 hours later.', 'Basis: copied the viral post'),
    const RumorCard('"Insider" screenshot', 'A blurry screenshot of a chat, no names visible.', 'Basis: unnamed source'),
  ];
  final n = d == ArcadeDifficulty.easy ? 3 : 4;
  final good = g.pick(real);
  final all = [good, ...g.sample(fake, n - 1)];
  final perm = g.shuffled([for (var i = 0; i < n; i++) i]);
  final cards = [for (final i in perm) all[i]];
  return ArcadeCase(
    signature: 'rumor:independent:${real.indexOf(good)}:${all.skip(1).map((e) => e.title).join('|')}',
    scenario: 'independent', mode: ArcadeMode.rumor,
    title: 'Where is the proof?', rumorTask: RumorTask.independent,
    text: 'Tap the one item that confirms the claim by itself, without copying the viral post.',
    subtext: 'Claim: $c',
    cards: cards, correct: [perm.indexOf(0)], deceptive: true,
    lesson: "Independent proof comes from the people or place that made the decision, or from someone who was physically there. A big outlet that just cites a viral post isn't proof, and neither is the 3.2K shares.",
    hint: 'Read each "Basis" line. Which one does not depend on the viral post?',
  );
}

// -------------------------------------------------------------- wordEdit
class _Quote {
  final String speaker, orig, edit;
  const _Quote(this.speaker, this.orig, this.edit);
}

const _quotes = <_Quote>[
  _Quote('Mayor Santillan', "Hindi pa final ang desisyon, pag-aaralan pa namin sa Lunes.", "[[Final na]] ang desisyon, pag-aaralan pa namin sa Lunes."),
  _Quote('Registrar', "Ang bayad sa enrollment ay ₱500 lang para sa mga scholar.", "Ang bayad sa enrollment ay [[₱5,000]] lang para sa mga scholar."),
  _Quote('Education officer', "Sinuspinde ang klase sa elementarya lamang.", "Sinuspinde ang klase sa [[lahat ng antas]] lamang."),
  _Quote('Organizer', "Kung walang pila, tapos na ang pamimigay bago mag-tanghali.", "[[Dahil]] walang pila, tapos na ang pamimigay bago mag-tanghali."),
  _Quote('Singer', "Hindi ko sinabing pangit ang kanta, kailangan lang ng practice.", "[[Pangit]] ang kanta, kailangan lang ng practice."),
  _Quote('Coach', "Natalo kami ng 2 puntos, pero maganda ang laro ng team.", "Natalo kami ng [[20]] puntos, pero maganda ang laro ng team."),
  _Quote('Event host', "Tuloy ang concert sa Sabado kung walang bagyo.", "Tuloy ang concert sa Sabado [[kahit may]] bagyo."),
  _Quote('Engineer', "Ang proyekto ay 80% tapos na at matatapos sa Enero.", "Ang proyekto ay [[100%]] tapos na at matatapos sa Enero."),
  _Quote('Kapitan', "Humihingi ako ng paumanhin sa mga naabala.", "[[Wala akong pakialam]] sa mga naabala."),
  _Quote('Nurse', "Isa lang ang nasaktan at ligtas na siya ngayon.", "[[Sampu]] ang nasaktan at ligtas na siya ngayon."),
];

ArcadeCase _word(Gen g, ArcadeDifficulty d) {
  final q = g.pick(_quotes);
  final tokens = <String>[];
  final changed = <int>[];
  var inMark = false;
  for (final raw in q.edit.split(' ')) {
    var t = raw;
    if (t.startsWith('[[')) { inMark = true; t = t.substring(2); }
    final ends = t.endsWith(']]');
    if (ends) t = t.substring(0, t.length - 2);
    if (inMark) changed.add(tokens.length);
    tokens.add(t);
    if (ends) inMark = false;
  }
  return ArcadeCase(
    signature: 'rumor:words:${q.speaker}:${q.orig.length}', scenario: 'wordEdit',
    mode: ArcadeMode.rumor, title: 'Spot the edit', rumorTask: RumorTask.wordEdit,
    text: 'Tap the words in the viral caption that were changed.',
    subtext: 'FULL RECORDING (${q.speaker}): "${q.orig}"',
    tokens: tokens, correct: changed, deceptive: true,
    lesson: "Changing a single word can flip a statement. Always compare a viral quote with the full recording.",
    hint: 'Read the full recording first, then compare it word by word.',
  );
}
