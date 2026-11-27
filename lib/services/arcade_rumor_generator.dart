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
    "Lumikas na raw ang buong bansa dahil sa sunog; huwag nang maghintay ng kumpirmasyon!",
  ],
  'flood': [
    "Hanggang bukung-bukong ang baha sa kanto ng Brgy. {town}, passable pa rin.",
    "Hanggang tuhod na ang baha sa Brgy. {town}, mag-ingat po.",
    "Hanggang bewang na ang baha sa buong {town}! Hindi na madaanan!",
    "Lubog na ang buong lungsod, rescue na ang kailangan!",
    "WALANG TUMUTULONG! Lubog ang buong probinsya, nawawala na ang mga tao!",
    "Aabot na raw sa kabisera ang baha; walang ligtas kahit saan!",
  ],
  'dengue': [
    "Limang kaso ng dengue ang naitala sa isang paaralan sa Brgy. {town}.",
    "Dengue sa school ng Brgy. {town}, marami na raw ang naospital.",
    "Outbreak ng dengue sa buong {town}, sarado na raw ang mga paaralan!",
    "Dengue emergency sa lungsod, daan-daang patay na daw!",
    "Lockdown na ang buong probinsya dahil sa dengue, itinatago ng gobyerno!",
    "Kumakalat na raw sa buong bansa at wala nang ospital na tumatanggap ng pasyente!",
  ],
  'fare': [
    "Panukala: ₱2 na dagdag-pasahe sa jeep, pag-uusapan pa sa hearing sa Huwebes.",
    "Tataas na raw ang pamasahe ng ₱2 simula Lunes.",
    "Doble na ang pamasahe simula bukas!!",
    "Hindi na makakasakay ang mga estudyante dahil sa taas ng pamasahe, kanselado na ang klase!",
    "Walang jeep na bibiyahe simula Lunes, hindi na raw babalik!",
    "Wala nang pampublikong sasakyan sa buong bansa simula bukas, maglakad na lang daw!",
  ],
  'road': [
    "Isang lane sa highway ang sarado ngayong gabi para sa pag-aayos.",
    "Sarado ang highway ng 3 oras ngayong gabi, humanap ng ibang daan.",
    "SARADO ang highway buong linggo! Wag na kayong dumaan!",
    "Sarado na ang buong NCR at probinsya, lahat ng tulay bagsak na!",
    "Bagsak ang tulay at sarado ang bansa, magtago na!",
    "Lahat ng daan at tulay ay gumuho raw; walang makakapasok o makakalabas!",
  ],
  'water': [
    "Walang tubig sa ilang bahay sa Brgy. {town} mula 8PM hanggang 4AM para sa pag-aayos ng tubo.",
    "Mawawalan ng tubig sa buong Brgy. {town} bukas ng gabi, mag-ipon na.",
    "Walang tubig sa buong {town} ng tatlong araw! Mag-ipon na ngayon!",
    "Wala nang tubig ang buong lungsod, kontaminado raw ang supply!",
    "Nilalason daw ang tubig ng buong probinsya, huwag uminom!",
    "Lason na raw ang lahat ng gripo sa bansa; huwag nang gumamit ng tubig!",
  ],
  'power': [
    "May brownout sa Brgy. {town} bukas, 9AM hanggang 3PM, para sa maintenance ng linya.",
    "Brownout sa buong Brgy. {town} bukas ng buong araw.",
    "Tatlong araw na brownout sa {town}, wala raw kuryente hanggang Linggo!",
    "Blackout na sa buong lungsod, sabotahe raw ito!",
    "Wala nang kuryente sa buong bansa, itinatago ng gobyerno ang totoo!",
    "Hindi na raw maibabalik ang kuryente sa buong bansa; maghanda sa maraming taon!",
  ],
  'exam': [
    "Ang quiz sa Math sa {town} High ay inilipat sa Huwebes dahil sa suspensyon.",
    "Lahat ng exam sa {town} High ay inilipat sa susunod na linggo.",
    "Kanselado na ang lahat ng exam sa buong {town} hanggang next month!",
    "Walang pasok ang buong lungsod hanggang next month, kanselado na ang school year!",
    "Tapos na ang school year sa buong bansa, wala nang exam at walang diploma!",
    "Isinara na raw ang lahat ng paaralan sa bansa nang permanente!",
  ],
  'library': [
    "Paalala: ₱5 kada araw ang late return ng libro pagkatapos ng due date.",
    "May ₱5 late fee na raw lahat ng humiram ng libro, kahit hindi pa due.",
    "Kailangan na raw magbayad ng ₱500 ang bawat estudyante bago makapasok sa library.",
    "Isasara na raw ang library bukas kapag walang nagbayad ng bagong fee.",
    "Wala nang libreng library access sa buong paaralan simula ngayon!",
    "Isinara na raw ang lahat ng library sa buong lungsod dahil sa utang ng estudyante!",
  ],
  'bridge': [
    "Isang lane lang ng tulay sa Brgy. {town} ang isasara sa inspeksyon bukas, 9AM-12NN.",
    "Sarado na raw ang buong tulay sa Brgy. {town} bukas habang may inspeksyon.",
    "Bawal na raw dumaan sa lahat ng tulay sa {town} hanggang matapos ang inspeksyon.",
    "Delikado raw ang mga tulay sa buong lungsod; huwag nang bumiyahe.",
    "May bumagsak na raw na tulay kahit walang opisyal na ulat.",
    "Gumuho na raw ang lahat ng tulay sa probinsya at walang ligtas na ruta!",
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
    case RumorTask.order:
      return _order(g, d);
    case RumorTask.spotDiff:
      return _spot(g, d);
    case RumorTask.outdated:
      return _outdated(g, d);
    case RumorTask.independent:
      return _independent(g, d);
    case RumorTask.wordEdit:
      return _word(g, d);
  }
}

// ----------------------------------------------------------------- order
ArcadeCase _order(Gen g, ArcadeDifficulty d) {
  final topic = g.pick(_escalations.keys.toList());
  final levels = _escalations[topic]!;
  final n = switch (d.profile.reasoningLevel) {
    1 => 3,
    2 => 4,
    _ => 6,
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
    signature: 'rumor:order:$topic:$n',
    scenario: 'order',
    mode: ArcadeMode.rumor,
    title: 'Who started it?',
    rumorTask: RumorTask.order,
    text: 'Use the arrows: first-hand post at the top, newest repost last.',
    subtext: d.profile.requiresCrossChecking
        ? 'Trace the source chain; reposts may add unsupported details.'
        : 'Each card says who it copied from.',
    cards: cards,
    correct: correct,
    deceptive: true,
    lesson:
        "Each repost copies the one before it, and the story grows. The post at the top is first-hand, and the later ones add details nobody there confirmed.",
    hint:
        'Start with the card that says it saw it personally. Then follow each "Shared from".',
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
  final venues = [
    'covered court ng Brgy. {town}',
    'Health Center ng Brgy. {town}',
    'gym ng {school}',
    'plaza ng {city}',
  ];
  final fees = ['Libre', 'Libre', 'Libre'];
  final town = g.pick(Pools.towns);
  final slots = {
    'town': town,
    'school': g.pick(Pools.schools),
    'city': g.pick(Pools.cities),
  };
  final day = g.pick(days), time = g.pick(times);
  final venue = fillSlots(g.pick(venues), slots);
  final fee = g.pick(fees);
  final phone = '0917 ${g.between(100, 999)} ${g.between(1000, 9999)}';
  final event = g.pick([
    'Libreng medical mission',
    'Libreng bakuna',
    'Scholarship briefing',
    'Job fair',
    'Blood donation drive',
    'Libreng eye check-up',
    'Tree planting',
    'Livelihood training',
    'Libreng legal consultation',
    'Farmers market',
    'Disaster-preparedness seminar',
    'Community legal-aid clinic',
    'Free school-supplies distribution',
    'Bridge inspection and traffic reroute',
    'Public library book-return drive',
  ]);
  final attrs = ['day', 'time', 'venue', 'fee', 'phone'];
  final changed = g.pick(attrs);
  String render(String Function(String a, String real) tweak, {int style = 0}) {
    String v(String a, String real) => tweak(a, real);
    final values = {
      'day': v('day', day),
      'time': v('time', time),
      'venue': v('venue', venue),
      'fee': v('fee', fee),
      'phone': v('phone', phone),
    };
    return switch (style) {
      1 =>
        'Schedule for $event at ${values['venue']} — ${values['day']}, ${values['time']}. '
            'Entry: ${values['fee']}. Hotline: ${values['phone']}.',
      2 =>
        'Notice for residents: $event will be held on ${values['day']} at ${values['time']} '
            '(${values['venue']}). ${values['fee']}. For questions, call ${values['phone']}.',
      3 =>
        'Announcement: ${values['venue']}, ${values['time']} on ${values['day']} — $event. '
            '${values['fee']}. Hotline for details: ${values['phone']}.',
      4 =>
        '$event bulletin | Date: ${values['day']} | Time: ${values['time']} | '
            'Place: ${values['venue']} | Cost: ${values['fee']} | Contact: ${values['phone']}',
      _ =>
        '$event: ${values['day']}, ${values['time']}, ${values['venue']}. '
            '${values['fee']}. Hotline: ${values['phone']}',
    };
  }

  String altered(String a, String real) {
    if (a != changed) return real;
    return switch (a) {
      'day' => g.pick(days.where((x) => x != day).toList()),
      'time' => g.pick(times.where((x) => x != time).toList()),
      'venue' => fillSlots(
        g.pick(venues.where((x) => fillSlots(x, slots) != venue).toList()),
        slots,
      ),
      'fee' => '₱${g.pick(['50', '150', '300'])} registration',
      _ => '0917 ${g.between(100, 999)} ${g.between(1000, 9999)}',
    };
  }

  final official = render((a, real) => real);
  final faithful = render((a, real) => real);
  final n = d.profile.reasoningLevel >= 3 ? 5 : 3;
  final wrongOne = render(
    altered,
    style: d == ArcadeDifficulty.hard ? g.between(0, 4) : 0,
  );
  final texts = <String>[wrongOne];
  while (texts.length < n) {
    texts.add(
      d == ArcadeDifficulty.hard
          ? render((a, real) => real, style: texts.length)
          : faithful,
    );
  }
  final sources = g
      .shuffled([
        'Group chat forward',
        'Page repost',
        'Screenshot in a story',
        'Fan page',
        'Barangay board repost',
      ])
      .take(n)
      .toList();
  final perm = g.shuffled([for (var i = 0; i < n; i++) i]);
  final cards = [
    for (final i in perm)
      RumorCard('Version ${perm.indexOf(i) + 1}', texts[i], sources[i]),
  ];
  final correct = perm.indexOf(0);
  final label = switch (changed) {
    'day' => 'day',
    'time' => 'time',
    'venue' => 'place',
    'fee' => 'fee',
    _ => 'hotline',
  };
  return ArcadeCase(
    signature: 'rumor:spot:$changed:$n',
    scenario: 'spotDiff',
    mode: ArcadeMode.rumor,
    title: 'Which one was changed?',
    rumorTask: RumorTask.spotDiff,
    text:
        'Which version changes a fact from the official notice? Ignore forwarding labels.',
    subtext: 'OFFICIAL NOTICE: $official',
    cards: cards,
    correct: [correct],
    deceptive: true,
    lesson:
        "Only the $label changed in one version. Small edits to a date, fee or hotline are how scammers redirect people, so compare each detail line by line.",
    hint:
        'Read each version line by line against the official notice. What detail is different?',
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
    if (day > 31) {
      day -= 31;
      month = 'Nov';
    }
    if (day < 1) {
      day += 30;
      month = 'Sep';
    }
    return '$month $day';
  }

  // Stale information is not always an expired deadline. Rotate the kind of
  // change players must notice: expired, cancelled, moved, superseded, or
  // eligibility changed. This prevents the puzzle from being "pick oldest".
  final kind = g.pick([
    'deadline',
    'cancelled',
    'location',
    'superseded',
    'eligibility',
    'promo',
  ]);
  final school = g.pick(Pools.schools);
  final town = g.pick(Pools.towns);
  final today = dateAt(0);
  final past = dateAt(-g.between(2, 8));
  final future = dateAt(g.between(4, 12));
  final oldPost = g.pick([
    'Posted 3 weeks ago',
    'Posted 2 months ago',
    'Posted yesterday',
    'Re-shared today',
  ]);
  final stale = switch (kind) {
    'deadline' =>
      'Scholarship application deadline: $past. Submit at the registrar.',
    'cancelled' =>
      'Announcement: the free medical mission on $past is cancelled due to weather.',
    'location' =>
      'Free vaccination today at the old venue: $school covered court.',
    'superseded' => 'Road advisory: $town bridge is CLOSED today, $today.',
    'eligibility' =>
      'Ayuda registration: all residents may claim until $future.',
    _ => 'Student fare promo: 50% discount valid until $past.',
  };
  final currentInfo = switch (kind) {
    'deadline' => [
      'Scholarship application deadline: $future. Submit at the registrar.',
      'Scholarship forms are accepted until ${dateAt(g.between(8, 16))}.',
      'Registrar reminder: applications remain open; check the official desk for requirements.',
      'Scholarship deadline extended to $future by the registrar.',
    ],
    'cancelled' => [
      'Medical mission moved to $future; the organizer confirms it will proceed.',
      'Free medical mission is rescheduled to $future, weather permitting.',
      'Organizer update: the medical mission is ON for $future at the health center.',
      'New notice: the mission will proceed on $future, not the earlier date.',
    ],
    'location' => [
      'Free vaccination today at the health center, not the covered court.',
      'Venue update: vaccination moved to the barangay health center.',
      'The vaccination team is at the health center today. Bring your ID.',
      'Official update: new venue is the health center for today’s vaccination.',
    ],
    'superseded' => [
      'Road advisory: one lane of $town bridge is OPEN today, $today.',
      'Updated traffic notice: bridge is passable with alternating lanes.',
      'Engineer update: the bridge inspection is complete; traffic resumes today.',
      'Latest advisory: only the sidewalk remains closed; vehicles may pass.',
    ],
    'eligibility' => [
      'Ayuda registration is only for residents listed in the barangay registry.',
      'Updated eligibility: registered households only; no walk-in claims.',
      'The barangay says applicants must have a valid resident ID.',
      'Official reminder: only pre-registered recipients may claim.',
    ],
    _ => [
      'Student fare promo ended last week; regular fare applies today.',
      'Promo is valid only on weekdays, and today is a weekend.',
      'Updated notice: discount applies only to enrolled students with a valid ID.',
      'The fare promo has been extended to $future for verified students.',
    ],
  };
  final n = d.profile.reasoningLevel == 1
      ? 3
      : d.profile.reasoningLevel >= 3
      ? 5
      : 4;
  final cards = <(RumorCard, bool)>[
    (
      RumorCard(
        'Page A',
        stale,
        g.pick([oldPost, 'Posted today', 'Posted 1 day ago']),
      ),
      true,
    ),
    for (var i = 0; i < n - 1; i++)
      (
        RumorCard(
          'Page ${String.fromCharCode(66 + i)}',
          g.pick(currentInfo),
          g.pick([
            'Official update',
            'Posted today',
            'Posted 2 days ago',
            'Verified notice',
          ]),
        ),
        false,
      ),
  ];
  // Ensure the current alternatives are text-distinct even when random picks collide.
  final used = <String>{cards.first.$1.body};
  for (var i = 1; i < cards.length; i++) {
    var body = cards[i].$1.body;
    while (!used.add(body)) {
      body = g.pick(currentInfo);
    }
    cards[i] = (RumorCard(cards[i].$1.title, body, cards[i].$1.meta), false);
  }
  final perm = g.shuffled([for (var i = 0; i < n; i++) i]);
  final displayed = [for (final i in perm) cards[i].$1];
  final correct = perm.indexOf(0);
  final label = switch (kind) {
    'deadline' => 'expired deadline',
    'cancelled' => 'cancellation notice',
    'location' => 'old venue',
    'superseded' => 'outdated road status',
    'eligibility' => 'old eligibility rule',
    _ => 'expired promo',
  };
  return ArcadeCase(
    signature: 'rumor:outdated:$kind:$n',
    scenario: 'outdated',
    mode: ArcadeMode.rumor,
    title: 'What is stale?',
    rumorTask: RumorTask.outdated,
    text:
        'Today is $today. Which post has information that has been replaced or is no longer valid?',
    subtext:
        'Check the actual status, venue, conditions, and deadline—not post age alone.',
    cards: displayed,
    correct: [correct],
    deceptive: true,
    lesson:
        'The stale item is the $label. Stale information can be an expired date, a cancelled event, an old venue, a superseded advisory, changed eligibility, or an ended promotion. A recent repost can still be wrong.',
    hint:
        'Look for the detail that is no longer true. Posting time is only a clue, not the answer.',
  );
}

// ----------------------------------------------------------- independent
ArcadeCase _independent(Gen g, ArcadeDifficulty d) {
  final claim = g.pick([
    'Libreng sakay para sa mga estudyante sa Lunes',
    'Bagong bayad sa e-wallet para sa ayuda',
    'Sarado ang tulay sa Brgy. {town} sa Sabado',
    'Nag-apruba ang konseho ng ordinansa sa single-use plastic',
    'Libreng bakuna sa Health Center sa Martes',
    'Inilipat sa Huwebes ang pagsusulit sa {town}',
    'Walang pasok sa Lunes sa lahat ng antas',
    'Bukas na ulit ang tulay sa Brgy. {town}',
    'May libreng konsultasyon sa City Hall sa Miyerkules',
    'Naglabas ng bagong evacuation route ang disaster office',
    'Maaaring mag-apply online para sa student ID replacement',
    'Ipinagpaliban ng konseho ang botohan sa bagong parke',
    'Isang lane ng tulay ang bubuksan matapos ang inspeksyon',
    'May libreng blood-pressure check sa health center sa Sabado',
    'Pinalawig ng registrar ang deadline ng scholarship application',
  ]);
  final town = g.pick(Pools.towns);
  final c = fillSlots(claim, {'town': town});
  final outlet = g.pick(Pools.outlets);
  final real = <RumorCard>[
    RumorCard(
      "City Hall's own notice",
      'Signed, dated notice on the official page: "$c".',
      'Basis: its own decision',
    ),
    RumorCard(
      'Council meeting record',
      'The council secretary\'s posted minutes include: "$c".',
      'Basis: the meeting itself',
    ),
    RumorCard(
      'On-scene video',
      'Reporter\'s own video with a time stamp and a visible street sign: "$c".',
      'Basis: filmed on location',
    ),
  ];
  final fake = <RumorCard>[
    RumorCard(
      'Viral repost',
      '"$c" with 3.2K shares.',
      'Basis: same screenshot as the first post',
    ),
    RumorCard(
      '$outlet article',
      'Headline: "$c, netizens say".',
      'Basis: cites "a viral post"',
    ),
    const RumorCard(
      'Comment thread',
      '"Totoo \'yan! Sabi ng kapitbahay ko."',
      'Basis: heard from a neighbor',
    ),
    const RumorCard(
      'Fan page copy',
      'Same wording as the viral post, posted 2 hours later.',
      'Basis: copied the viral post',
    ),
    const RumorCard(
      '"Insider" screenshot',
      'A blurry screenshot of a chat, no names visible.',
      'Basis: unnamed source',
    ),
  ];
  final n = d.profile.reasoningLevel == 1
      ? 3
      : d.profile.reasoningLevel >= 3
      ? 5
      : 4;
  final good = g.pick(real);
  final all = [good, ...g.sample(fake, n - 1)];
  final perm = g.shuffled([for (var i = 0; i < n; i++) i]);
  final cards = [for (final i in perm) all[i]];
  return ArcadeCase(
    signature:
        'rumor:independent:${real.indexOf(good)}:${all.skip(1).map((e) => e.title).join('|')}',
    scenario: 'independent',
    mode: ArcadeMode.rumor,
    title: 'Where is the proof?',
    rumorTask: RumorTask.independent,
    text: d.profile.requiresCrossChecking
        ? 'Cross-check the claim. Find independent evidence, not repeated copies.'
        : 'Tap the one item that confirms the claim by itself, without copying the viral post.',
    subtext: 'Claim: $c',
    cards: cards,
    correct: [perm.indexOf(0)],
    deceptive: true,
    lesson:
        "Independent proof comes from the people or place that made the decision, or from someone who was physically there. A big outlet that just cites a viral post isn't proof, and neither is the 3.2K shares.",
    hint:
        'Read each "Basis" line. Which one does not depend on the viral post?',
  );
}

// -------------------------------------------------------------- wordEdit
class _Quote {
  final String speaker, orig, edit;
  const _Quote(this.speaker, this.orig, this.edit);
}

const _quotes = <_Quote>[
  _Quote(
    'Mayor Santillan',
    "Hindi pa final ang desisyon, pag-aaralan pa namin sa Lunes.",
    "[[Final na]] ang desisyon, pag-aaralan pa namin sa Lunes.",
  ),
  _Quote(
    'Registrar',
    "Ang bayad sa enrollment ay ₱500 lang para sa mga scholar.",
    "Ang bayad sa enrollment ay [[₱5,000]] lang para sa mga scholar.",
  ),
  _Quote(
    'Education officer',
    "Sinuspinde ang klase sa elementarya lamang.",
    "Sinuspinde ang klase sa [[lahat ng antas]] lamang.",
  ),
  _Quote(
    'Organizer',
    "Kung walang pila, tapos na ang pamimigay bago mag-tanghali.",
    "[[Dahil]] walang pila, tapos na ang pamimigay bago mag-tanghali.",
  ),
  _Quote(
    'Singer',
    "Hindi ko sinabing pangit ang kanta, kailangan lang ng practice.",
    "[[Pangit]] ang kanta, kailangan lang ng practice.",
  ),
  _Quote(
    'Coach',
    "Natalo kami ng 2 puntos, pero maganda ang laro ng team.",
    "Natalo kami ng [[20]] puntos, pero maganda ang laro ng team.",
  ),
  _Quote(
    'Event host',
    "Tuloy ang concert sa Sabado kung walang bagyo.",
    "Tuloy ang concert sa Sabado [[kahit may]] bagyo.",
  ),
  _Quote(
    'Engineer',
    "Ang proyekto ay 80% tapos na at matatapos sa Enero.",
    "Ang proyekto ay [[100%]] tapos na at matatapos sa Enero.",
  ),
  _Quote(
    'Kapitan',
    "Humihingi ako ng paumanhin sa mga naabala.",
    "[[Wala akong pakialam]] sa mga naabala.",
  ),
  _Quote(
    'Nurse',
    "Isa lang ang nasaktan at ligtas na siya ngayon.",
    "[[Sampu]] ang nasaktan at ligtas na siya ngayon.",
  ),
  _Quote(
    'Utility spokesperson',
    "Ang brownout ay tatagal ng anim na oras mula 9AM hanggang 3PM.",
    "Ang brownout ay tatagal ng [[tatlong araw]] mula 9AM hanggang 3PM.",
  ),
  _Quote(
    'Registrar',
    "Ang enrollment ay hanggang Biyernes lamang.",
    "Ang enrollment ay [[hanggang katapusan ng buwan]] lamang.",
  ),
  _Quote(
    'Barangay captain',
    "Walang kumpirmadong kaso ng dengue sa aming barangay ngayong linggo.",
    "[[May sampung]] kumpirmadong kaso ng dengue sa aming barangay ngayong linggo.",
  ),
  _Quote(
    'Teacher',
    "Mag-submit ng proyekto bago ang Biyernes, walang late penalty hanggang Sabado.",
    "Mag-submit ng proyekto bago ang Biyernes, [[bagsak agad kapag late.]]",
  ),
  _Quote(
    'Forecaster',
    "Posibleng lumakas ang bagyo pero hindi pa tiyak ang landas nito.",
    "[[Tiyak na tatama ang bagyo]] pero hindi pa tiyak ang landas nito.",
  ),
  _Quote(
    'Social worker',
    "Mamimigay kami ng ayuda sa mga nakarehistro lamang, walang bayad.",
    "Mamimigay kami ng ayuda sa [[lahat, magbayad lang ng ₱200 sa registration.]]",
  ),
  _Quote(
    'City engineer',
    "Isang lane lang ang isasara habang ginagawa ang drainage.",
    "[[Lahat ng lane]] ang isasara habang ginagawa ang drainage.",
  ),
  _Quote(
    'School principal',
    "May klase bukas para sa senior high; suspended ang elementarya.",
    "May klase bukas para sa [[lahat ng antas]]; suspended ang elementarya.",
  ),
  _Quote(
    'Health officer',
    "Walang kumpirmadong kaso sa barangay; patuloy ang pagsusuri.",
    "[[May kumpirmadong outbreak]] sa barangay; patuloy ang pagsusuri.",
  ),
  _Quote(
    'Council secretary',
    "Pinag-uusapan pa ang panukala; wala pang botohan.",
    "[[Naaprubahan na]] ang panukala; wala pang botohan.",
  ),
  _Quote(
    'Weather officer',
    "Lumikas kung umabot sa orange alert ang tubig sa inyong lugar.",
    "[[Lumikas na ang buong lungsod]] kung umabot sa orange alert ang tubig sa inyong lugar.",
  ),
  _Quote(
    'School principal',
    "Maaaring gamitin ang gym kung sarado ang covered court.",
    "[[Dapat gamitin]] ang gym kung sarado ang covered court.",
  ),
  _Quote(
    'Water district',
    "Walang nakitang kontaminasyon sa unang sample; susuriin pa ang iba.",
    "[[May nakitang kontaminasyon]] sa unang sample; susuriin pa ang iba.",
  ),
];

ArcadeCase _word(Gen g, ArcadeDifficulty d) {
  final q = g.pick(_quotes);

  // The [[...]] markup is retained in the quote data for readability, but it
  // is NOT the source of truth for the answer. Compare the edited caption
  // against the original so unchanged words inside a marked phrase aren't
  // accidentally counted as edits.
  final original = q.orig.split(RegExp(r'\s+'));
  final edited = q.edit
      .replaceAll('[[', '')
      .replaceAll(']]', '')
      .split(RegExp(r'\s+'));

  // Longest common subsequence. These quotes are short, so O(n*m) is trivial.
  // Matching is exact (including punctuation/case) to flag meaningful edits.
  final dp = List.generate(
    original.length + 1,
    (_) => List<int>.filled(edited.length + 1, 0),
  );
  for (var i = original.length - 1; i >= 0; i--) {
    for (var j = edited.length - 1; j >= 0; j--) {
      dp[i][j] = original[i] == edited[j]
          ? dp[i + 1][j + 1] + 1
          : (dp[i + 1][j] >= dp[i][j + 1] ? dp[i + 1][j] : dp[i][j + 1]);
    }
  }

  // Recover which edited-caption tokens are unchanged. Every edited token
  // outside the LCS is an insertion/replacement and should be selectable.
  final unchangedEdited = <int>{};
  var i = 0;
  var j = 0;
  while (i < original.length && j < edited.length) {
    if (original[i] == edited[j]) {
      unchangedEdited.add(j);
      i++;
      j++;
    } else if (dp[i + 1][j] >= dp[i][j + 1]) {
      i++;
    } else {
      j++;
    }
  }

  final changed = <int>[
    for (var index = 0; index < edited.length; index++)
      if (!unchangedEdited.contains(index)) index,
  ];

  return ArcadeCase(
    signature: 'rumor:words:${q.speaker}:${q.orig.length}',
    scenario: 'wordEdit',
    mode: ArcadeMode.rumor,
    title: 'Spot the edit',
    rumorTask: RumorTask.wordEdit,
    text: 'Tap the words in the viral caption that were changed.',
    subtext: 'FULL RECORDING (${q.speaker}): "${q.orig}"',
    tokens: edited,
    correct: changed,
    deceptive: true,
    lesson:
        "Changing a single word can flip a statement. Always compare a viral quote with the full recording.",
    hint: 'Read the full recording first, then compare it word by word.',
  );
}
