import 'arcade_common.dart';
import '../models/arcade_models.dart';

/// Comment Chaos. The rule has three parts: criticism is allowed (even harsh),
/// but threats, coordinated harassment / doxxing, scams and hate toward a
/// group of people are not. Zero, one or two comments may break the rules.
class _C {
  final String text, reason, context;
  final bool bad;
  const _C(this.bad, this.text, {this.reason = '', this.context = ''});
}

const _allowed = <_C>[
  _C(false, "Ang pangit ng ending, sayang ang oras ko. Walang kwenta ang writing."),
  _C(false, "Hindi ko bet si {t} dito, bakit ba siya laging ganito 😭 pero okay lang, opinion ko lang."),
  _C(false, "Pwede bang magpaliwanag si {t}? Maraming tanong, kailangan ng sagot."),
  _C(false, "Ang tagal ng sagot ng admin. Nakakainis na, sana may update man lang."),
  _C(false, "Mas magaling pa sa kanila ang kapatid ko, seryoso 😂"),
  _C(false, "May nag-DM sa akin ng \"hahanapin ka namin\". Report n'yo po ang account na 'yon, hindi ako okay.",
      context: 'Quoting a threat in order to report it.'),
  _C(false, "Hindi dapat tinatago ang detalye. Public funds po 'to, maghintay tayo ng sagot."),
  _C(false, "Nakakadismaya, pero mas okay kung pag-usapan natin ang isyu, hindi ang tao."),
  _C(false, "Bumaba ang respeto ko kay {t} after nito. Sana mag-sorry."),
  _C(false, "LOL, ang bastos ng edit pero hindi naman nakakasakit. Funny 😭"),
  _C(false, "Nag-resign na sana si {t} kung may delikadesa. Opinion ko 'yan."),
  _C(false, "Tama na ang hate, mga besh. Okay lang mag-disagree pero respeto naman."),
  _C(false, "Hindi ko sinasabing kasalanan niya, pero responsibilidad niya 'to bilang opisyal."),
  _C(false, "Ang init ng ulo ng lahat dito, pero wala namang threat kaya hayaan na natin."),
  _C(false, "Nakakaasar yung ads sa gitna ng video, sobrang dami 😤"),
  _C(false, "Ayoko sa takbo ng palabas, pero mahal ko pa rin ang mga fans, mababait naman."),
  _C(false, "Scam ata 'to: may nag-DM na kailangan daw ng OTP ko. Huwag kayong maniwala!",
      context: 'Warning others about a scam message.'),
  _C(false, "Sobrang walang katuturan ng desisyong 'to, hindi inisip ang mga estudyante."),
  _C(false, "Hindi ako boboto kay {t} sa susunod. Ang daming pangako, kulang sa resulta."),
  _C(false, "Unfollow na ako. Paulit-ulit na lang ang content, nakakasawa."),
  _C(false, "Sana may refund o paliwanag man lang. Dalawang beses na akong na-charge!"),
  _C(false, "Mali ang numero sa post, 5,000 hindi 50,000. Pa-edit po."),
  _C(false, "Ang init ng ulo ko dito pero hindi ko naman sasaktan ang kahit sino, vent lang 😤"),
  _C(false, "Kung may nakakita ng nawawalang ID ko sa Brgy. Sinag, paki-message po ako. Salamat!"),
];

const _bad = <_C>[
  _C(true, "Hahanapin ka namin pag-uwi mo, {t}. Mag-ingat ka na lang.",
      reason: 'A threat aimed at a person.'),
  _C(true, "Eto number niya: 0917 000 {n}. Tawagan n'yo hanggang magsorry!",
      reason: 'Sharing private contact details to get people to harass someone.'),
  _C(true, "Mass report natin si {t} hanggang ma-ban. Spam natin ang inbox niya 24/7!",
      reason: 'Organizing a pile-on to harass someone.'),
  _C(true, "DM me para sa ₱5,000 ayuda. I-send lang ang OTP mo para ma-verify.",
      reason: 'A scam: no real program asks for your OTP.'),
  _C(true, "Mga taga-probinsya talaga, lahat magnanakaw. Dapat hindi na pinapapasok dito.",
      reason: 'Hate toward a whole group of people based on where they are from.'),
  _C(true, "Ang taba mo, huwag ka nang magpakita sa school. Walang may gusto sa'yo.",
      reason: 'Targeted body-shaming and harassment.'),
  _C(true, "Dapat saktan na ang mga ganyan. Antayin natin sa labas ng school bukas.",
      reason: 'A call for violence against people.'),
  _C(true, "Eto address ni {t}: Blk 4 Lot 9. Puntahan natin sila ngayong gabi.",
      reason: 'Posting a home address and urging people to go there.'),
  _C(true, "Libre ticket sa concert! I-click ang link sa bio ko at ilagay ang card details.",
      reason: 'A scam trying to collect card details.'),
  _C(true, "Burahin mo na ang post mo o ipapakalat namin ang private photos mo.",
      reason: 'Blackmail: threatening to spread private photos.'),
  _C(true, "Ibibigay ko ang password mo sa lahat kapag hindi ka nag-sorry ngayon.",
      reason: "A threat to leak someone's account."),
  _C(true, "Sino may pangalan at school ng nag-post nito? Hanapin natin siya at i-expose.",
      reason: 'Trying to identify and expose someone for a pile-on (doxxing).'),
  _C(true, "Mga mahihirap na estudyante, huwag na silang pasukin sa school natin. Wala silang karapatan dito.",
      reason: 'Hate toward a whole group of people based on income.'),
  _C(true, "Sumali sa group chat namin at mag-send ng ₱500 para sa 'VIP raffle'. Maraming nanalo na!",
      reason: 'A scam asking for money to join a raffle.'),
  _C(true, "Ipo-post ko ang screenshot ng private chat mo kapag hindi ka nag-apologize.",
      reason: 'Blackmail: threatening to leak private messages.'),
  _C(true, "Pumunta tayo sa bahay ni {t} at sirain ang gate. Sino sasama?",
      reason: 'A call for violence or damage against a person.'),
];

class _Topic {
  final String id, post, target;
  const _Topic(this.id, this.post, this.target);
}

const _topics = <_Topic>[
  _Topic('drag_finale', 'Grand finale ng Drag Supreme PH: sino ang nanalo?', 'Miss Talahib'),
  _Topic('flood_project', 'City Hall: update sa flood wall project sa Brgy. Sinag', 'Mayor Del Rosario'),
  _Topic('ppop_mv', 'Bagong music video ng BAHAGHARI, ano sa tingin n\'yo?', 'BAHAGHARI'),
  _Topic('school_rule', 'Bagong ID at uniform policy sa Northridge University', 'ang admin'),
  _Topic('interu_loss', 'Natalo ang Falcons sa Inter-U Games finals', 'Coach Ramos'),
  _Topic('tickets', 'Sold out na ang tickets ng LUNARIS Manila concert', 'ang ticketing page'),
  _Topic('sc_election', 'Student council election: sino ang iboboto n\'yo?', 'si Mara'),
  _Topic('vlog', 'Viral na vlog ng sikat na food vlogger sa Manila', 'ang vlogger'),
  _Topic('exam_policy', 'Bagong exam schedule sa Kalikasan College', 'ang registrar'),
  _Topic('relief_goods', 'Update ng barangay sa relief goods matapos ang bagyo', 'ang kapitan'),
  _Topic('milktea_shop', 'Bagong milk tea shop sa tapat ng school, review?', 'ang shop owner'),
  _Topic('streamer_apology', 'Humingi ng tawad ang sikat na streamer sa isang kontrobersya', 'ang streamer'),
];

int threadScenarioCount() => _topics.length;
String threadScenarioId(int i) => _topics[i].id;

ArcadeCase buildThread(Gen g, ArcadeDifficulty d, int index, {int? forceBad}) {
  final t = _topics[index];
  final n = switch (d) {
    ArcadeDifficulty.easy => 4,
    ArcadeDifficulty.medium => 5,
    ArcadeDifficulty.hard => 6,
  };
  final roll = g.r.nextInt(10);
  var badCount = forceBad ?? (roll < 2 ? 0 : roll < 7 ? 1 : 2);
  // Zero-violation threads are possible at every difficulty: don't reward
  // the habit of always flagging someone. Tutorial still forces one.
  final slots = <String, String>{'t': t.target, 'n': '${g.between(100, 999)}'};
  final pickedBad = g.sample(_bad, badCount);
  // Harsh-but-allowed comments are the point: always include some.
  final pickedGood = g.sample(_allowed, n - badCount);
  final all = g.shuffled([...pickedBad, ...pickedGood]);
  final views = <CommentView>[];
  final flagged = <int>[];
  for (var i = 0; i < all.length; i++) {
    final c = all[i];
    if (c.bad) flagged.add(i);
    views.add(CommentView(
      '@${g.pick(Pools.handlesFirst)}${g.id()}', fillSlots(c.text, slots),
      context: c.context.isNotEmpty ? c.context
          : g.chance(.3) ? 'Replying to ${t.target}' : '',
      violates: c.bad, reason: c.reason,
    ));
  }
  return ArcadeCase(
    signature: 'thread:${t.id}:${all.map((e) => e.text.hashCode % 997).join('.')}',
    scenario: t.id, mode: ArcadeMode.comments,
    title: t.post, author: 'Tambayan Thread',
    handle: '${g.between(12, 80)} reported comments',
    text: 'Which comments break the rules? Maybe none.',
    subtext: 'Criticism is allowed. Threats, doxxing, scams and hate are not.',
    comments: views, correct: flagged, deceptive: badCount > 0,
    lesson: badCount == 0
        ? 'No comment here breaks the rules. Some are rude or angry, but criticism and strong opinions are allowed, and reporting a threat is not making one.'
        : 'Strong opinions are allowed. What gets removed: threats, sharing private details, organized harassment, scams and hate toward whole groups.',
    hint: 'Ask of each comment: is it an opinion, or is it threatening, exposing, scamming or targeting someone?',
  );
}
