import 'arcade_common.dart';
import '../models/arcade_models.dart';

/// Post Autopsy. Each scenario fixes the truth first, then writes five
/// inspection results. Account details, tone and engagement are rolled
/// independently of the truth, so they never predict the verdict.
class _Post {
  final String id, topic, caption, q, lesson;
  final bool bad;
  final List<String> bodies;
  final String photo, date, source, replies, photoLabel;
  final Relevance rPhoto, rDate, rSource, rReplies;
  final String? account;
  final Relevance rAccount;
  const _Post(this.id, this.bad, this.topic, this.caption, this.bodies, {
    required this.q, required this.lesson,
    required this.photo, required this.date, required this.source,
    required this.replies,
    this.rPhoto = Relevance.support, this.rDate = Relevance.decoy,
    this.rSource = Relevance.decisive, this.rReplies = Relevance.support,
    this.account, this.rAccount = Relevance.decoy,
    this.photoLabel = 'MEDIA TRACE',
  });
}

const _posts = <_Post>[
  // ---------------------------------------------------------------- KEEP
  _Post('class_real', false, 'Weather', 'Class suspension advisory', [
    "Walang pasok bukas sa lahat ng antas sa {city}. Sabi ng City Hall, dahil sa bagyo. Ingat po!",
    "Class suspension bukas, elementary to SHS, {city}. Naka-post na sa page ng City Hall: cityhall.example/advisories",
  ],
    q: 'Does City Hall say the same thing?',
    photo: "The advisory graphic uses the same layout City Hall used in earlier suspensions.",
    date: "Advisory posted today, 5:12 AM.",
    source: "City Hall's own page posted the same advisory: all levels suspended tomorrow.",
    replies: "Students say their school group chats got the same notice.",
    rDate: Relevance.support,
    lesson: "Even a small or brand-new page can share a real advisory. The City Hall's own page matched it."),
  _Post('flood_critic', false, 'Government', 'Flooded street photo', [
    "P{amt}M daw ang flood wall sa Brgy. {town}, pero lubog pa rin kami kahapon. Nasaan ang liquidation report? Public funds po 'to.",
    "Ang tagal na ng flood wall project sa Brgy. {town}. Bakit hanggang tuhod pa rin ang baha? Gusto naming makita ang accounting.",
  ],
    q: 'Do the numbers it quotes match public records?',
    photo: "The flooded-street photo is new: taken yesterday, and a street sign shows Brgy. {town}.",
    date: "Posted the evening after the rain.",
    source: "The city's public project list shows a P{amt}M flood wall for Brgy. {town}. The post quotes it correctly.",
    replies: "Residents argue about whether the wall or the drainage is the problem. Heated, but no threats.",
    rPhoto: Relevance.support,
    lesson: "Strong criticism of a public project is allowed when the facts it cites are accurate. Asking for accountability is not misinformation."),
  _Post('satire_page', false, 'Government', 'Meme image', [
    "BREAKING: Aso sa Brgy. {town}, nahalal na Kapitan; nangakong libreng buto para sa lahat 🐶🏆",
    "LATEST: Traffic enforcer sa {city}, ginawaran ng 'Pinakamapagpasensyang Tao ng Taon' matapos ang 3 oras na traffic.",
  ],
    q: 'Who runs this page, and what do they say they post?',
    photo: "An edited meme image carrying the same page's watermark.",
    date: "Posted this morning, like the page's other jokes.",
    source: "No news outlet reports this, and the page posts jokes like it every day.",
    replies: "Everyone is laughing and tagging friends.",
    account: "Page bio: \"Satire at memes lang. Walang totoo dito 😂\". Active for 3 years.",
    rAccount: Relevance.decisive, rSource: Relevance.support,
    lesson: "Labeled satire is allowed. The page's bio tells you it's a joke, so context matters."),
  _Post('ai_art', false, 'AI', 'Digital artwork', [
    "Jeepney na lumilipad sa ibabaw ng Maynila 🚌✨ Ang ganda ng gawa ko!",
    "Binuo ko 'to gamit AI: sampaguita garden sa gitna ng EDSA. Ano sa tingin n'yo?",
  ],
    q: 'Does the creator say how it was made?',
    photo: "Creator tagged the image \"AI-generated\" and posted the prompt in the first comment.",
    date: "Posted today with the artist's other digital art.",
    source: "The creator's portfolio lists it under AI art, not news.",
    replies: "People ask for the prompt. Nobody thinks it's a real photo.",
    rPhoto: Relevance.decisive, rSource: Relevance.support,
    photoLabel: 'MEDIA TRACE',
    lesson: "AI images are fine when presented as art. The problem is passing them off as real events."),
  _Post('old_valid', false, 'Campus', 'Scholarship poster', [
    "Reminder: Bukas pa ang {school} scholarship applications, ayon sa school portal. Check the current deadline there.",
    "Pa-share po! Sa latest {school} scholarship portal, ongoing pa ang applications. I-check ang updated deadline sa portal.",
  ],
    q: 'Is the date still current on the official page?',
    photo: "The poster is the school's own design from this term.",
    date: "The post is 3 weeks old.",
    source: "In this fictional case, the school's current portal confirms applications are still open this term.",
    replies: "Applicants confirm that the portal is still accepting applications.",
    rDate: Relevance.decoy,
    lesson: "An older post isn't automatically outdated. Check whether the information is still current."),
  _Post('review_receipts', false, 'Shopping', 'Order screenshot', [
    "{store} seller: 11 days late ang parcel ko, tapos seen-zone pa. Hindi ko inirerekomenda 😤 Resibo ko sa comments.",
    "Warning sa mga bibili sa {store}: 2 weeks na, wala pa rin ang order ko at walang sagot. Screenshots ko po.",
  ],
    q: 'Do the receipts back up the complaint?',
    photo: "The order screenshot shows an order placed 11 days ago, matching the post.",
    date: "Posted after the delivery window passed.",
    source: "The order number in the screenshot matches the shop's own order page.",
    replies: "A few buyers had good experiences; others had the same delay.",
    rPhoto: Relevance.decisive, rSource: Relevance.support,
    lesson: "A negative review with receipts is customer feedback. Disliking a business is not misinformation."),
  _Post('flood_real', false, 'Weather', 'Flooded street', [
    "Baha na sa kanto namin sa Brgy. {town}, hanggang tuhod na. Mag-ingat po sa mga dadaan.",
    "Update from Brgy. {town}: umaapaw na ang estero. Iwasan muna ang Rizal St.",
  ],
    q: 'Is the photo new, and does the location match?',
    photo: "Photo is new: first seen today at 3:40 PM, and the street sign matches Brgy. {town}.",
    date: "Posted 20 minutes ago.",
    source: "The weather bureau's bulletin has a heavy-rain warning for the area today.",
    replies: "Neighbors confirm and add their own photos.",
    rPhoto: Relevance.decisive, rSource: Relevance.support, rReplies: Relevance.support, rDate: Relevance.support,
    lesson: "A fresh, local photo with matching details can be trusted. Check where and when it was taken."),
  _Post('fan_hot_take', false, 'Music', 'MV screenshot', [
    "Hot take: mid ang bagong MV ng {group}, pero stan pa rin ako 😭 Sana mas maganda ang choreo next time.",
    "Unpopular opinion: overrated ang comeback ng {group}. Pero mahal ko pa rin sila, huwag n'yo akong i-cancel 😅",
  ],
    q: 'Is there a factual claim to check at all?',
    photo: "The screenshot is from the group's official MV.",
    date: "Posted the day of the MV release.",
    source: "Nothing to fact-check: it's a personal opinion about a music video.",
    replies: "Fans disagree politely. A few jokes.",
    lesson: "Disliking a music video is not misinformation or harassment. Opinions are allowed."),
  _Post('ayuda_real', false, 'Government', 'Payout poster', [
    "Ayuda payout para sa registered seniors sa Brgy. {town}: bukas 8AM sa covered court. Dalhin ang valid ID at pension slip.",
    "Reminder sa mga senior ng Brgy. {town}: payout bukas 8AM, covered court. Valid ID lang ang kailangan. Detalye: brgy-{town}.example/payout",
  ],
    q: 'Do the barangay and the welfare office both list it?',
    photo: "The poster matches the one used in the barangay's earlier payouts.",
    date: "Posted the day before the payout.",
    source: "The barangay's page and the city welfare office both list this payout with the same time and place.",
    replies: "Seniors say they got text reminders from the barangay.",
    lesson: "Not every ayuda post is a scam. The agency's own pages confirmed the details, and no link or fee was involved."),
  _Post('weather_news', false, 'Weather', 'Weather map', [
    "{outlet}: Signal No. 2 sa 4 na lalawigan habang papalapit ang Bagyong Ligaya.",
    "Ayon sa {outlet}, Signal No. 2 na sa apat na lalawigan dahil sa Bagyong Ligaya. Bulletin: weatherbureau.example/bulletin",
  ],
    q: 'What does the weather bureau bulletin say?',
    photo: "A standard bulletin map, with the bureau's usual colors.",
    date: "Published within the hour of the 5 PM bulletin.",
    source: "The weather bureau's 5 PM bulletin lists Signal No. 2 for those same provinces.",
    replies: "People tag relatives in the affected areas.",
    rDate: Relevance.support,
    lesson: "A news report that matches the official bulletin is solid. Reputation matters less than whether it checks out."),
  _Post('nepo_question', false, 'Government', 'Vacation photo', [
    "Nag-post ang anak ni Cong. Villareal ng luxury trip habang lubog ang distrito. Hindi ko sinasabing may ninakaw, pero pwede bang ilabas ang statement of assets para malinaw?",
    "Tanong lang po: ang laki ng gastos sa bakasyon ng anak ni Cong. Villareal. Public official po siya, may karapatan tayong humingi ng transparency.",
  ],
    q: 'Does the post claim a crime, or does it ask for documents?',
    photo: "The vacation photo comes from the relative's own public account, posted this week.",
    date: "Posted two days after the floods, same week as the travel photos.",
    source: "The post makes no claim of theft. It asks for the official's published asset statement, which is a public document.",
    replies: "Supporters and critics argue; nobody posts threats.",
    rSource: Relevance.decisive, rPhoto: Relevance.support,
    lesson: "Asking an official for transparency is allowed. The post claims no crime and shows nothing doctored. Heated politics is not misinformation."),
  _Post('celeb_donation', true, 'Music', 'Donation graphic', [
    "{group} leader nag-donate ng ₱5M sa mga biktima ng bagyo! I-share ang post na ito at makakatanggap ka ng ₱1,000 sa {wallet}!",
    "Biyaya! Sa bawat share ng post na ito, may ₱1,000 ka mula sa donation ng {group}. Comment 'SHARE' para ma-register.",
  ],
    q: 'Did the group or its agency announce a donation?',
    photo: "The donation graphic copies the group's logo but not its usual font; the same graphic appears on other pages.",
    date: "Posted during the typhoon news cycle.",
    source: "The group's agency page says it has announced no such donation or giveaway.",
    replies: "Many comment 'SHARE' hoping for money; nobody reports receiving any.",
    rSource: Relevance.decisive, rPhoto: Relevance.support, rReplies: Relevance.support,
    lesson: "A donation that pays you for sharing is bait to spread a scam. Check what the person or agency has actually said."),
  _Post('sk_event', false, 'Campus', 'Event poster', [
    "SK Youth Day sa Brgy. {town} ngayong Sabado! Libre ang sports clinic at career talk. Walang registration fee. Mag-sign up sa mismong SK table.",
    "Mga kabataan ng Brgy. {town}: SK Youth Day this Saturday, 9AM. Libre lahat. Dalhin lang ang school ID.",
  ],
    q: 'Does the barangay page confirm the event?',
    photo: "The poster matches the design the SK page used for earlier events.",
    date: "Posted four days before the event.",
    source: "The barangay's page lists the same event, date and 'free' note. No payment link anywhere.",
    replies: "Residents ask about parking; the SK chair answers.",
    rSource: Relevance.decisive,
    lesson: "Not every event post is a scam. The barangay's own page matched it and nothing asked for money."),
  _Post('fake_queen_quote', true, 'Drag Race', 'Edited screenshot', [
    "{queen} said it herself: 'Mga fans ko, pabigat lang kayo.' Eto ang screenshot, huwag n'yo na siyang suportahan!!",
    "EXPOSED! Eto ang tunay na sinabi ni {queen} tungkol sa fans niya. Screenshot, i-share para mabisto!",
  ],
    q: 'Does the queen\'s own page show that post?',
    photo: "The font in the screenshot is slightly different from the platform's, and the time stamp has an edit artifact.",
    date: "The original post time doesn't appear on {queen}'s page.",
    source: "{queen}'s own page has a post from that hour: 'Mahal ko ang fans ko, salamat sa 1M!'",
    replies: "Fans are split; one asks for the link to the original post and gets no answer.",
    rPhoto: Relevance.decisive, rSource: Relevance.decisive,
    lesson: "Fandom drama makes edited screenshots spread. The real page says the opposite."),
  // -------------------------------------------------------------- REMOVE
  _Post('recycled_flood', true, 'Weather', 'Flood photo', [
    "NGAYON LANG! Baha sa {city} dahil sa Bagyong Ligaya, grabe na! 😭 Pa-share para makita ng lahat.",
    "Ito na ang sitwasyon sa {city} ngayon. Hanggang bubong na ang tubig!! Ingat po lahat.",
  ],
    q: 'When did this photo first appear?',
    photo: "This photo first appeared in {y1}, during a different storm in another city.",
    date: "The image file dates to {y1}; the post says it's happening now.",
    source: "The weather bureau lists no flood warning for {city} today.",
    replies: "One user says: \"Taong {y1} 'yan ah, hindi 'to ngayon.\"",
    rPhoto: Relevance.decisive, rDate: Relevance.support, rSource: Relevance.support,
    lesson: "Old disaster photos return every storm season. A real photo can still mislead when it is shown with the wrong date and place."),
  _Post('fake_quote', true, 'Government', 'News card', [
    "SINABI NI {who}: \"Wala akong pakialam sa mga nabaha, bayaran na lang nila ang utang nila.\" Grabe 'tong taong 'to!!",
    "Eto ang tunay na ugali ni {who}. Basahin n'yo ang sinabi niya sa mga biktima 😡 SHARE!",
  ],
    q: 'Did the outlet on the card actually publish it?',
    photo: "The card's font and logo don't match {outlet}'s real news cards.",
    date: "Posted at 1 AM, with no link to a full story.",
    source: "{outlet} says it never published this card. Its website has no such quote.",
    replies: "People are furious, but nobody can link the original interview.",
    rSource: Relevance.decisive, rPhoto: Relevance.support,
    lesson: "Anger is not evidence. A fake news card can put words in someone's mouth, whether you like that person or not."),
  _Post('fake_ayuda_link', true, 'Government', 'Cash graphic', [
    "LIBRE P{amt} PARA SA LAHAT! Walang requirements, mag-register lang sa ayuda-ph-now.example bago mag-12 midnight!",
    "ATTENTION: P{amt} cash aid, first 1,000 lang. I-click ang ayuda-ph-now.example at ilagay ang mobile number.",
  ],
    q: 'Does the city or barangay announce this program?',
    photo: "The picture of cash is a stock photo used on other scam posts.",
    date: "Posted late at night, with a deadline of midnight.",
    source: "City Hall posted: \"We have no such program. Don't click links.\"",
    replies: "Some ask for the link, others say they never received anything.",
    rPhoto: Relevance.support,
    lesson: "Free cash with a link and a deadline is a classic scam pattern. Check the official page, not the post's own link."),
  _Post('fake_recruitment', true, 'Government', 'Hiring poster', [
    "HIRING na ang Maritime Service PH! Sahod ₱43,800, walang experience needed. Magbayad lang ng ₱1,500 processing fee sa {wallet}.",
    "Job openings sa Maritime Service PH! Sahod ₱43,800/buwan. Reserve your slot, bayad ₱1,500 sa {wallet}.",
  ],
    q: 'Does the agency charge application fees?',
    photo: "The poster logo is a low-resolution copy of the agency's logo.",
    date: "Posted by a page created last week.",
    source: "The agency's official page says it never charges application fees and lists no such hiring.",
    replies: "Applicants say they paid and were then blocked.",
    rPhoto: Relevance.support, rSource: Relevance.decisive,
    lesson: "Legit agencies don't charge a fee to apply. A high salary with no requirements is bait."),
  _Post('deepfake_doc', true, 'Health', 'Video thumbnail', [
    "Si Doc Ramon Alcantara mismo ang nagsabi: itong herbal capsule ang lunas sa ubo at pulmonya. Order na bago maubos! 🎥",
    "Doc Ramon, inamin na! Gamot daw sa lahat ng sakit sa baga ang capsule na ito. Panoorin ang buong video.",
  ],
    q: 'Does the doctor say this in the original video?',
    photo: "The doctor's lips and voice don't line up. The original video, from {y1}, is about handwashing.",
    date: "The audio was added to an older video.",
    source: "The doctor's official page says: \"I never promoted this product. This video is an AI edit.\"",
    replies: "Many glowing testimonials, all from new accounts using the same wording.",
    rPhoto: Relevance.decisive, rSource: Relevance.decisive, rDate: Relevance.support,
    lesson: "AI can copy a real person's face and voice. A trusted face selling a cure is a reason to check the person's own page."),
  _Post('doctored_screenshot', true, 'Weather', 'Advisory screenshot', [
    "WALANG PASOK BUKAS sa LAHAT ng level sa buong {city}! Galing sa City Hall ang advisory. Share na!",
    "CLASS SUSPENSION: lahat ng paaralan sa {city}, bukas. Screenshot mula sa City Hall. Pakisabi sa mga GC!",
  ],
    q: 'Look at the date on the advisory itself.',
    photo: "A {y1} date is visible in the corner of the advisory graphic.",
    date: "That advisory was from {y1} and covered one school only.",
    source: "City Hall's current page has no suspension notice today.",
    replies: "Students say their schools haven't announced anything.",
    rPhoto: Relevance.decisive, rDate: Relevance.decisive, rSource: Relevance.decisive,
    lesson: "Old advisories get reposted as new. Check the date on the graphic and the official page."),
  _Post('false_scope', true, 'Campus', 'School news photo', [
    "BREAKING: Lahat ng paaralan sa probinsya, SARADO sa susunod na linggo dahil sa dengue!!",
    "Dengue outbreak! Walang klase ang buong probinsya next week. Pakisabi sa pamilya n'yo!",
  ],
    q: 'What does the real notice actually cover?',
    photo: "The photo is real, but its caption says \"one school\".",
    date: "The news item is from this week.",
    source: "The real notice is from one school in Brgy. {town}: two days of cleaning after dengue cases.",
    replies: "Parents from other schools say their classes are still on.",
    rPhoto: Relevance.support, rDate: Relevance.decoy, rSource: Relevance.decisive,
    lesson: "Misleading posts often start with something real and then stretch the scope. Compare the claim with the original notice."),
  _Post('ghost_wrong_site', true, 'Government', 'Empty lot photo', [
    "GHOST PROJECT! Eto ang \"flood wall\" sa Brgy. {town}, wala naman pala!! Saan napunta ang P{amt}M?? 😡",
    "Walang flood wall sa Brgy. {town}! Puro damo lang. Ninakaw ang P{amt}M, ipakulong sila!",
  ],
    q: 'Is the photo really from Brgy. {town}?',
    photo: "The empty lot was photographed two weeks ago in Brgy. {town2}, a different barangay.",
    date: "The photo is real but is two weeks old.",
    source: "The city's inspection report shows the Brgy. {town} wall as finished, with dated photos.",
    replies: "Residents say the wall exists, but the old drainage still floods.",
    rPhoto: Relevance.decisive, rSource: Relevance.decisive, rReplies: Relevance.support,
    lesson: "Corruption is a real issue and worth asking about. But a photo of the wrong place is not proof. Accountability needs accurate evidence."),
  _Post('ticket_resale', true, 'Music', 'Ticket image', [
    "LAST 2 PCS na VIP ticket ng {group} concert! 50% OFF, bayad agad sa {wallet} para ma-reserve. DM lang.",
    "{group} concert tickets, SOLD OUT na sa website pero may stock pa ako. Bayad muna sa {wallet}, ipapadala ang QR.",
  ],
    q: 'Where does the official ticketing site say tickets are sold?',
    photo: "The QR code on the ticket image also appears on other sellers' posts.",
    date: "Posted minutes after the official sale sold out.",
    source: "The official ticketing site says tickets are sold only on its own page, with no resale or DM sales.",
    replies: "Several people say they paid and were blocked.",
    rPhoto: Relevance.support, rSource: Relevance.decisive, rReplies: Relevance.support,
    lesson: "Sold-out concert tickets attract scammers. Check the official seller's rules before paying anyone."),
  _Post('election_count', true, 'Election', 'Results screenshot', [
    "PARTIAL UNOFFICIAL COUNT: Kap. Reyes lamang ng 90%! Dinaya daw ang kalaban, share para mabisto!",
    "BREAKING: Lamang na si Kap. Reyes sa bilangan, 90% ng presinto na! Itinatago ito ng media.",
  ],
    q: 'Has the election office released any results yet?',
    photo: "The screenshot header shows a practice run from {y1}.",
    date: "The results page was created during {y1}'s test.",
    source: "The election office says no results have been released yet.",
    replies: "People argue about cheating without linking any official numbers.",
    rPhoto: Relevance.decisive, rDate: Relevance.support, rSource: Relevance.decisive, rReplies: Relevance.decoy,
    lesson: "Fake election results spread fast because people are emotional. Only the election office's own release counts."),
  _Post('ai_disaster', true, 'AI', 'Dramatic photo', [
    "TSUNAMI sa Manila Bay?! Nakuha ng drone kanina. Pa-share para makapaghanda ang lahat 🌊😱",
    "Grabeng alon sa Manila Bay ngayon lang. Lumikas na kayo!! Kuha ng kaibigan ko.",
  ],
    q: 'Where did the picture first appear, and what do official warnings say?',
    photo: "No camera data. The image first appeared on an AI art page two days ago.",
    date: "The scene doesn't match today's weather.",
    source: "The weather bureau and major outlets report no tsunami warning.",
    replies: "Others point out melted text on signs and odd building shapes.",
    rPhoto: Relevance.decisive, rSource: Relevance.decisive, rDate: Relevance.support,
    lesson: "AI images can look dramatic and real. When there's no official warning, don't spread panic."),
];

const _accounts = <String>[
  "Established page, 7 yrs, 120K followers. Mostly news and memes.",
  "New page, 9 days old, 340 followers. Posts only this week.",
  "Personal account, 3 yrs, 800 followers. Real name, school and photos.",
  "Fan page, 2 yrs, 15K followers. Bio: unofficial fan account.",
  "Community page, 11 months, 6.2K followers. Admins not named.",
  "Local page, 4 yrs, 52K followers. Has posted corrections before.",
];

const _hypeHead = ['🚨 ALERT: ', 'BREAKING: ', '📢 PAKI-SHARE: ', 'UPDATE: '];
const _hypeTail = [' SHARE NA!! 🚨', ' Pa-viral naman 🙏', ' Basahin hanggang dulo!!'];
const _calmTail = [' Salamat po.', ' Fyi lang.', ' Ingat tayo lahat.'];

String _titleCase(String w) => w[0] + w.substring(1).toLowerCase();

/// Toned-down version: no shouting, one calm sentence ender.
String _calm(String text) {
  var t = text.replaceAllMapped(RegExp(r'\b[A-Z]{4,}\b'), (m) => _titleCase(m[0]!));
  t = t.replaceAll(RegExp(r'!{2,}'), '.').replaceAll('?!', '?');
  return t.replaceAll(' 😡', '').replaceAll(' 😱', '');
}

String _applyRegister(Gen g, String body) {
  final roll = g.r.nextDouble();
  if (roll < .34) {
    final head = g.chance(.6) ? g.pick(_hypeHead) : '';
    return head + body + g.pick(_hypeTail);
  }
  if (roll < .84) return _calm(body) + g.pick(_calmTail);
  return body;
}

int trustScenarioCount() => _posts.length;
String trustScenarioId(int i) => _posts[i].id;
bool trustScenarioBad(int i) => _posts[i].bad;

ArcadeCase buildTrust(Gen g, ArcadeDifficulty d, int index) {
  final p = _posts[index];
  final town = g.pick(Pools.towns);
  final town2 = g.pick(Pools.towns.where((t) => t != town).toList());
  final slots = <String, String>{
    'town': town, 'town2': town2, 'city': g.pick(Pools.cities),
    'who': g.pick(Pools.officials), 'amt': g.pick(['85', '120', '250', '5,000']),
    'outlet': g.pick(Pools.outlets), 'group': g.pick(Pools.groups),
    'school': g.pick(Pools.schools), 'store': g.pick(Pools.stores),
    'wallet': g.pick(Pools.wallets), 'y1': '${g.between(2019, 2023)}',
    'queen': g.pick(Pools.queens),
  };
  // Register (shouting, plain or calm) is rolled independently of the truth:
  // honest posts can shout, and false ones can sound perfectly calm.
  final body = _applyRegister(g, fillSlots(g.pick(p.bodies), slots));
  // In hard mode, social proof is UNRELIABLE rather than always reversed.
  // Its popularity, confidence and opinion are unrelated to the truth;
  // otherwise players could learn to invert the top comment for easy XP.
  var replies = fillSlots(p.replies, slots);
  if (d.profile.requiresCrossChecking) {
    // Hard mode deliberately presents conflicting social proof. Comments are
    // opinions, not evidence, and neither one is tied to the case's truth.
    final opposingOpinions = [
      "Legit 'to, nakita ko rin sa GC.",
      "Fake 'to sabi ng pinsan ko.",
    ];
    for (final opinion in opposingOpinions.take(d.profile.conflictingEvidence)) {
      replies += ' Comment (${g.between(18, 950)} likes): "$opinion"';
    }
    if (d.profile.decoyClues > 0) {
      final decoyOpinion = g.pick([
        'May nagsabi lang, better check the source first.',
        'Mukhang tunay, pero wala pa akong makita na official source.',
        'Hindi enough ang dami ng shares para malaman kung totoo.',
      ]);
      replies += ' Comment (${g.between(18, 950)} likes): "$decoyOpinion"';
    }
  }
  final author = p.id == 'satire_page' ? 'Kalokohan PH'
      : g.pick(['Balita Ngayon', 'Kanto Updates', 'Tambayan Feed', 'Sikat PH',
        'Barkada Bulletin', 'Mika R.', 'Paolo D.']);
  final tools = <Finding>[
    Finding('photo', p.photoLabel, '🖼️', fillSlots(p.photo, slots), p.rPhoto),
    Finding('account', 'ACCOUNT', '👤', p.account ?? g.pick(_accounts), p.rAccount),
    Finding('date', 'DATE CHECK', '🕒', fillSlots(p.date, slots), p.rDate),
    Finding('source', 'ORIGINAL SOURCE', '🔎', fillSlots(p.source, slots), p.rSource),
    Finding('replies', 'REPLIES', '💬', replies, p.rReplies),
  ];
  final decisive = tools.firstWhere((t) => t.relevance == Relevance.decisive);
  return ArcadeCase(
    signature: 'trust:${p.id}', scenario: p.id, mode: ArcadeMode.trust,
    title: 'Trending in Tambayan', author: author,
    handle: '@${author.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '')}${g.id()}',
    text: body, subtext: 'Open up to ${d.scanBudget} checks',
    imageTopic: p.topic, imageCaption: p.caption,
    reactions: '${g.between(1, 49)}K views · ${g.between(80, 4000)} shares',
    tools: tools, deceptive: p.bad, correct: [p.bad ? 1 : 0],
    choices: const [ArcadeOption('KEEP'), ArcadeOption('REMOVE')],
    lesson: fillSlots(p.lesson, slots),
    hint: 'Try ${decisive.emoji} ${decisive.label}. Ask: ${fillSlots(p.q, slots)}',
  );
}
