import 'arcade_common.dart';
import '../models/arcade_models.dart';

/// Impostor Hunt. Each story writes a small independent "directory" plus two
/// profiles. Age, followers, verified badges and polish are rolled apart from
/// the truth. The truth comes from one rule: an account is a problem only if
/// it claims authority it was never given, or if an authorized account has
/// been taken over.
class _Org {
  final String name, base, kind;
  const _Org(this.name, this.base, this.kind);
}

const _orgs = <_Org>[
  _Org('Sulit Shop', 'sulitshop', 'shop'),
  _Org('Pag-asa Science High', 'pagasashs', 'school'),
  _Org('Barangay Liwayway Hall', 'brgyliwayway', 'barangay'),
  _Org('Office of Mayor Del Rosario', 'mayordelrosario', 'politician'),
  _Org('BAHAGHARI Official', 'bahaghariofficial', 'group'),
  _Org('PesoGo', 'pesogo', 'wallet'),
  _Org('Kargo Express PH', 'kargoexpressph', 'courier'),
  _Org('Northridge Falcons', 'northridgefalcons', 'sports'),
  _Org('Tambayan Daily', 'tambayandaily', 'news'),
  _Org('LUNARIS Official', 'lunarisofficial', 'group'),
  _Org('Bili-Bili Hub', 'bilibilihub', 'shop'),
  _Org('Kalikasan College', 'kalikasancollege', 'school'),
];

const _benign = <String, List<String>>{
  'shop': ['New stocks tomorrow, order in the app!', 'Salamat sa lahat ng 5-star reviews!', 'Shipping update: orders ship Mon-Sat.'],
  'school': ['Enrollment extended until Friday.', 'Reminder: ID validation sa Room 12.', 'Foundation week schedule is out.'],
  'barangay': ['Clean-up drive sa Sabado, 7AM.', 'Schedule ng bakuna: Martes sa health center.', 'Paalala: ihanda ang ID para sa payout.'],
  'politician': ['Nag-inspect kami ng drainage project ngayong umaga.', 'Salamat sa mga volunteer ng clean-up drive.', 'Public hearing sa Huwebes, bukas sa lahat.'],
  'group': ['Comeback teaser drops tonight!', 'Salamat sa 1M views, mga fans!', 'Fan meeting details sa official website.'],
  'wallet': ['Reminder: never share your OTP with anyone.', 'App update available, download from the store.', 'Our hotline is listed in the app only.'],
  'courier': ['Tracking tip: use the app, not links from texts.', 'Holiday delivery schedule posted.', 'Hubs are closed this Sunday.'],
  'sports': ['Game day Sabado, 3PM!', 'Practice moved to 5PM.', 'Ticket info is on the school page.'],
  'news': ['Weather update, 5PM bulletin.', 'City council session recap.', 'Correction: earlier post misspelled a name.'],
  'person': ['Happy birthday sa ate ko! 🎂', 'Miss ko na ang barkada', 'Exam week na naman 😭'],
};

const _scams = <String>[
  'Libreng P{amt}! Mag-register dito: {dom}-promo.example',
  'Nanalo ka! I-DM ang OTP mo para ma-claim ang prize.',
  'Para ma-refund, i-send ang card details sa DM.',
  'Magbayad ng P500 para ma-reserve ang slot mo.',
];

class _Spec {
  final List<String> dir;
  final ProfileView a, b;
  final int flagged; // 0 = a, 1 = b, -1 = neither
  final String lesson, hint;
  const _Spec(this.dir, this.a, this.b, this.flagged, this.lesson, this.hint);
}

const _stories = <String>[
  'lookalike', 'hijacked', 'rebrand', 'fan_label', 'parody_label',
  'parody_hidden', 'same_name', 'fake_support', 'two_branches', 'renamed',
  'paid_badge', 'supporters', 'fake_reseller', 'real_reseller', 
  'cloned_friend', 'archive_page',
];

int impostorScenarioCount() => _stories.length;
String impostorScenarioId(int i) => _stories[i];

/// Stories where exactly one account must be flagged.
const _flaggedStories = {'lookalike', 'hijacked', 'parody_hidden',
  'fake_support', 'renamed', 'paid_badge', 'fake_reseller', 'cloned_friend'};
bool impostorScenarioFlagged(int i) => _flaggedStories.contains(_stories[i]);

String _lookalike(Gen g, String base) {
  if (base.contains('m')) return base.replaceFirst('m', 'rn');
  if (base.contains('l')) return base.replaceFirst('l', '1');
  return g.pick(['${base}_', '${base}ph', '${base}official']);
}

ArcadeCase buildImpostor(Gen g, ArcadeDifficulty d, int index) {
  final story = _stories[index];
  final hard = d.profile.requiresCrossChecking;
  final easy = d == ArcadeDifficulty.easy;

  List<_Org> fit(List<String> kinds) =>
      _orgs.where((o) => kinds.contains(o.kind)).toList();
  final org = switch (story) {
    'fake_reseller' || 'real_reseller' => g.pick(fit(['shop'])),
    'archive_page' => g.pick(fit(['news'])),
    'cloned_friend' => const _Org('Joy Villanueva', 'joyvillanueva', 'person'),
    'parody_label' || 'parody_hidden' || 'supporters' =>
      g.pick(fit(['politician'])),
    'fan_label' || 'paid_badge' => g.pick(fit(['group'])),
    'fake_support' => g.pick(fit(['wallet', 'courier', 'shop'])),
    'two_branches' => g.pick(fit(['school', 'sports'])),
    _ => g.pick(_orgs),
  };
  final dom = org.base;
  final benign = _benign[org.kind]!;
  int followers() => g.between(120, 48000);
  int oldAge() => g.between(400, 2600);
  int newAge() => g.between(1, 25);
  final amt = g.pick(['500', '1,000', '5,000']);
  String scam() => fillSlots(g.pick(_scams), {'amt': amt, 'dom': dom});

  ProfileView real({int? age, String? bio, List<String>? recent}) => ProfileView(
    name: org.name, handle: '@${org.base}',
    bio: bio ?? 'Official page of ${org.name}.',
    link: '$dom.example', ageDays: age ?? oldAge(), followers: followers(),
    recent: recent ?? g.sample(benign, 2));

  final _Spec spec = switch (story) {
    'lookalike' => (() {
      final fake = ProfileView(
        name: org.name, handle: '@${_lookalike(g, org.base)}',
        bio: 'Official page. Verified ✔ Fast support!',
        link: '$dom-help.example', ageDays: g.chance(.5) ? newAge() : oldAge(),
        followers: followers(), badge: g.chance(.5),
        recent: easy || g.chance(.5) ? [scam(), benign.first] : [benign.last, benign.first]);
      return _Spec(
        ['${org.name} website lists its only account as @${org.base}.'],
        real(), fake, 1,
        "The handle is one character off from the listed account and isn't linked from the official website. Age, badge and polish don't prove identity.",
        'Compare each handle letter by letter with the directory.');
    })(),
    'hijacked' => (() {
      final hacked = ProfileView(
        name: org.name, handle: '@${org.base}',
        bio: 'Official page. Big giveaway sa pinned post!',
        link: '$dom-winners.example', ageDays: oldAge(), followers: followers(),
        badge: true, recent: [scam(), 'Last month: ${benign.first}']);
      final backup = ProfileView(
        name: '${org.name} (Backup)', handle: '@${org.base}_backup',
        bio: 'Backup page while our main account is recovered.',
        link: '$dom.example', ageDays: g.between(30, 900), followers: g.between(200, 4000),
        recent: ['Our main page was hacked. Ignore links it posts this week.', benign.first]);
      return _Spec(
        ['${org.name} website lists @${org.base} as its main page and @${org.base}_backup as its backup.'],
        hacked, backup, 0,
        "@${org.base} is the real listed account, but it was taken over: a new link, a giveaway, and the owner's backup page warns about it. The right move is to flag the hacked page, not the backup.",
        'Which account is listed, and which one is behaving differently?');
    })(),
    'rebrand' => (() {
      final old = ProfileView(
        name: org.name, handle: '@${org.base}',
        bio: 'We moved! Follow our new handle.', link: '$dom.example',
        ageDays: oldAge(), followers: followers(),
        recent: ['Pinned: "Lumipat na kami sa @${org.base}ph. Same team, same page!"', benign.first]);
      final fresh = ProfileView(
        name: org.name, handle: '@${org.base}ph',
        bio: 'New official handle of ${org.name}.', link: '$dom.example',
        ageDays: newAge(), followers: g.between(80, 1800),
        recent: [benign.first, 'Salamat sa mga sumunod sa amin dito!']);
      return _Spec(
        ['The ${org.name} website lists @${org.base}ph as its new account.'],
        old, fresh, -1,
        "A brand-new account can be the real one. The old page's pinned post and the website both point to the new handle.",
        'Is the new account announced by the old one?');
    })(),
    'fan_label' => (() {
      final fan = ProfileView(
        name: '${org.name.replaceAll(' Official', '')} Fans PH',
        handle: '@${org.base.replaceAll('official', '')}fansph',
        bio: 'Unofficial fan account. Not affiliated.', label: 'Fan account',
        link: 'no link', ageDays: g.between(30, 2000), followers: g.between(2000, 90000),
        recent: ['Fancam compilation 🎥', 'Ranking our favorite MV looks!']);
      return _Spec(
        ['${org.name} agency page lists @${org.base} as its only official account.'],
        real(), fan, -1,
        "A fan account that says it's unofficial isn't impersonating anyone, even with a bigger following.",
        'Does the second account claim to be official?');
    })(),
    'parody_label' => (() {
      final parody = ProfileView(
        name: 'Mayor Del Rosaryo (Parody)',
        handle: '@mayor_delrosaryo', label: 'Parody',
        bio: 'Parody account. Hindi totoong alkalde. Joke lang po.',
        ageDays: g.between(60, 1400), followers: g.between(1000, 30000),
        recent: ['Utos ko: libreng kape tuwing Lunes ☕ (joke)', 'Mga dalubhasa sa traffic: mga pusa.']);
      return _Spec(
        ['The city website lists @${org.base} as the mayor\'s office account.'],
        real(), parody, -1,
        "A clearly labeled parody account isn't pretending to be the real mayor. Mocking officials with a label is allowed.",
        'Does the parody account label itself?');
    })(),
    'parody_hidden' => (() {
      final fake = ProfileView(
        name: org.name, handle: '@${org.base}_pr',
        bio: 'Opisyal na page ng alkalde. Para sa mga balita at anunsyo.',
        ageDays: newAge(), followers: g.between(300, 9000),
        recent: ['Wala akong pakialam kung mamatay kayo sa baha.', 'Libreng ayuda sa mga mag-share ng post na ito!']);
      return _Spec(
        ['The city website lists @${org.base} as the mayor\'s office account.'],
        fake, real(), 0,
        "This account uses the mayor's name and claims to be official, with no parody label. It is not listed anywhere, and it posts offensive claims in the mayor's name.",
        'Does it say "parody" anywhere, or does it claim to be the real office?');
    })(),
    'same_name' => (() {
      final cityA = g.pick(Pools.cities);
      final cityB = g.pick(Pools.cities.where((c) => c != cityA).toList());
      final a = ProfileView(
        name: 'Kapitbahay Bakery', handle: '@kapitbahaybakery_${cityA.replaceAll(' ', '')}'.toLowerCase(),
        bio: 'Pandesal at kape sa $cityA.', link: 'no link',
        ageDays: oldAge(), followers: followers(),
        recent: ['Mainit na pandesal 6AM!', 'Sold out na ang ensaymada 😋']);
      final b = ProfileView(
        name: 'Kapitbahay Bakery', handle: '@kapitbahaybakery_${cityB.replaceAll(' ', '')}'.toLowerCase(),
        bio: 'Small bakery sa $cityB.', link: 'no link',
        ageDays: oldAge(), followers: followers(),
        recent: ['New flavor: ube cheese pandesal.', 'Bukas kami kahit holiday.']);
      return _Spec(
        ['Local shop listings: Kapitbahay Bakery ($cityA) @${a.handle.substring(1)}; Kapitbahay Bakery ($cityB) @${b.handle.substring(1)}.'],
        a, b, -1,
        "Two businesses can share a name in different cities. Neither claims to be the other, and both are listed separately.",
        'Do either of them claim to be the other shop?');
    })(),
    'fake_support' => (() {
      final fake = ProfileView(
        name: '${org.name} Customer Care', handle: '@${org.base}_care_ph',
        bio: '24/7 support. DM us for account fix!',
        ageDays: newAge(), followers: g.between(40, 900),
        recent: ['Replying to a complaint: "Send your OTP in DM so we can fix it."', scam()]);
      return _Spec(
        ['${org.name} says support is handled only inside its app and by @${org.base}.'],
        real(recent: [benign.first, 'We never ask for your OTP.']), fake, 1,
        "This account isn't listed, offers \"support\" in DMs, and asks for an OTP. Genuine support never asks for your OTP.",
        'Where does the company say support happens?');
    })(),
    'two_branches' => (() {
      final main = ProfileView(
        name: '${org.name} (Main)', handle: '@${org.base}_main',
        bio: 'Main campus announcements.', link: '$dom.example',
        ageDays: oldAge(), followers: followers(), recent: g.sample(benign, 2));
      final south = ProfileView(
        name: '${org.name} (Southfield)', handle: '@${org.base}_south',
        bio: 'Southfield branch announcements.', link: '$dom.example/south',
        ageDays: g.between(90, 1800), followers: followers(), recent: g.sample(benign, 2));
      return _Spec(
        ['${org.name} website lists two official pages: @${org.base}_main and @${org.base}_south.'],
        main, south, -1,
        "Both accounts are acknowledged by the organization as official branches. Similar names don't automatically mean one is fake.",
        'Does the directory list more than one official page?');
    })(),
    'renamed' => (() {
      final reused = ProfileView(
        name: org.name, handle: '@${org.base}_deals',
        bio: 'Official ${org.name}. Message us for slots!',
        link: 'no link', ageDays: oldAge(), followers: g.between(3000, 40000),
        recent: ['Name changed 3 days ago from "Mura Gadgets Resell".', scam()]);
      return _Spec(
        ['${org.name} website lists @${org.base} as its page. No other page is mentioned.'],
        reused, real(), 0,
        "An old account with lots of followers was renamed to look official. It isn't listed, and its history shows it was a different business days ago.",
        'Look at the recent activity: what did this page used to be?');
    })(),
    'paid_badge' => (() {
      final badged = ProfileView(
        name: org.name, handle: '@${org.base}_ph',
        bio: 'Official fan club. Join our VIP raffle!',
        link: '$dom-vip.example', badge: true,
        ageDays: newAge(), followers: followers(),
        recent: ['VIP raffle! Send P500 to reserve your slot.', 'Giveaway ends tonight.']);
      return _Spec(
        ['${org.name} agency page lists @${org.base} as its official account. Badges can be bought by anyone.'],
        badged, real(), 0,
        "A paid badge isn't proof. This account isn't listed by the agency, and it asks for money for a raffle slot. The real page has no badge.",
        'Is a badge the same thing as being listed in the directory?');
    })(),
    'fake_reseller' => (() {
      final fake = ProfileView(
        name: '${org.name} Authorized Dealer', handle: '@${org.base}_dealer_ph',
        bio: 'Authorized dealer! Wholesale prices, pay first before shipping.',
        link: 'no link', ageDays: g.between(10, 200), followers: followers(),
        recent: ['Slots open! Send P500 deposit to reserve.', 'Walang refund, final sale.']);
      return _Spec(
        ['${org.name} website lists its authorized dealers by name. @${org.base}_dealer_ph is not on the list.'],
        real(), fake, 1,
        "Claiming to be an authorized dealer is claiming authority. The brand's own dealer list doesn't include this page, and it asks for money up front.",
        "Is the page on the brand's own dealer list?");
    })(),
    'real_reseller' => (() {
      final partner = ProfileView(
        name: '${org.name} Partner Store (Cavite)', handle: '@${org.base}_cavite',
        bio: 'Authorized reseller of ${org.name}. See the dealer list on their website.',
        link: '$dom.example/dealers', ageDays: g.between(90, 1500), followers: followers(),
        recent: ['New stocks arrived, order in the ${org.name} app!', 'Pickup hours: Mon-Sat.']);
      return _Spec(
        ['${org.name} website lists @${org.base} as its main page and @${org.base}_cavite as an authorized partner store.'],
        real(), partner, -1,
        "A reseller can be real when the brand's own site lists it. This partner page points to the dealer list and asks for nothing outside the brand's usual checkout.",
        "Does the brand's own directory list the partner?");
    })(),
    'cloned_friend' => (() {
      final friend = ProfileView(
        name: 'Joy Villanueva', handle: '@joy.villanueva',
        bio: 'BS Nursing • Quezon City', link: 'no link',
        ageDays: g.between(500, 2500), followers: g.between(150, 900),
        recent: [g.pick(benign), 'Reminder: exam sa Lunes!']);
      final clone = ProfileView(
        name: 'Joy Villanueva', handle: '@joy.villanueva.2',
        bio: 'New account! Add me po 😊', link: 'no link',
        ageDays: newAge(), followers: g.between(20, 120),
        recent: ['Emergency! Pa-send muna ng P$amt sa wallet ko, ibabalik ko bukas.',
          'Huwag mo munang tawagan ako, ang ingay dito.']);
      return _Spec(
        ['Your contacts: Joy Villanueva is saved as @joy.villanueva (your friend for 3 years).'],
        friend, clone, 1,
        "Copying a name and photo is easy. The account that just appeared and immediately asks for money isn't your friend. The one in your contacts is.",
        'Which account is the one you already have in your contacts?');
    })(),
    'archive_page' => (() {
      final archive = ProfileView(
        name: '${org.name} Archive', handle: '@${org.base}_archive',
        bio: 'Fan-run archive of old ${org.name} posts. Not affiliated.',
        label: 'Archive account', link: 'no link',
        ageDays: g.between(200, 2000), followers: g.between(500, 15000),
        recent: ['Throwback: our favorite old weather bulletin.',
          'Archive note: this is an old post, not today\'s news.']);
      return _Spec(
        ['${org.name} lists @${org.base} as its only official account.'],
        real(), archive, -1,
        "An archive page that says it is unofficial isn't pretending to be the outlet, even when it shares the outlet's old posts.",
        'Does the account claim to be the outlet itself?');
    })(),
    _ => (() {
      final fans = ProfileView(
        name: 'Kap. Reyes Supporters', handle: '@kapreyes_supporters',
        bio: 'Supporters page, hindi opisyal na account ng kapitan.',
        label: 'Supporters page', ageDays: g.between(30, 900),
        followers: g.between(500, 20000),
        recent: ['Salamat sa lahat ng dumalo sa clean-up drive!', 'Memes tungkol sa traffic 😂']);
      return _Spec(
        ['The barangay site lists @${org.base} as the official page.'],
        fans, real(), -1,
        "A supporters page is allowed to cheer for someone as long as it doesn't claim to be their official account.",
        'Does the supporters page say it is unofficial?');
    })(),
  };

  final flip = g.chance(.5);
  final left = flip ? spec.b : spec.a;
  final right = flip ? spec.a : spec.b;
  final flagged = spec.flagged == -1 ? -1 : (flip ? 1 - spec.flagged : spec.flagged);
  return ArcadeCase(
    signature: 'impostor:$story:${org.base}', scenario: story,
    mode: ArcadeMode.impostor, title: org.name,
    author: 'Tambayan Identity Desk', handle: '@identitychecks',
    text: 'Two accounts use a similar name. Does either one fake an identity?',
    subtext: hard
        ? 'Cross-check the directory, links, account history and recent behavior.'
        : 'Open both profiles, then compare.',
    directory: spec.dir,
    leftProfile: left, rightProfile: right,
    deceptive: flagged != -1,
    correct: [flagged == -1 ? 2 : flagged],
    choices: const [ArcadeOption('FLAG A'), ArcadeOption('FLAG B'), ArcadeOption('BOTH OK')],
    lesson: spec.lesson, hint: spec.hint,
  );
}
