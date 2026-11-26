import 'arcade_common.dart';
import '../models/arcade_models.dart';

/// Comment Chaos. The rule has three parts: criticism is allowed (even harsh),
/// but threats, coordinated harassment / doxxing, scams and hate toward a
/// group of people are not. Zero, one or two comments may break the rules.
enum _ThreadCategory { entertainment, education, transport, utilities, health, civic, financial }

class _C {
  final String text, reason, context;
  final String primary, secondary;
  final Set<_ThreadCategory> categories;
  final bool bad;
  const _C(this.bad, this.text, {this.reason = '', this.context = '', this.primary = '', this.secondary = '', this.categories = const {}});
}

class _BadAction {
  final String text;
  final Set<_ThreadCategory> categories;
  const _BadAction(this.text, {this.categories = const {}});
}

const _allowedBase = <_C>[
  _C(false, "I'm disappointed by the result on {issue}. Why is there still no clear explanation?"),
  _C(false, "Hindi ko bet {target} sa usapin ng {issue}, ang weird nung paliwanag."),
  _C(false, "Pwede bang magpaliwanag {target} tungkol sa usapin ng {issue}? Marami pa kong tanong."),
  _C(false, "I waited weeks for an update on {issue}. Is there an official timeline?"),
  _C(false, "Mas maayos sana kung inasikaso agad yung usapin ng {issue}, seryoso 😂"),
  _C(false, "May nagbanta sa akin matapos akong magtanong tungkol sa {issue}. Sinave ko yung message. Saan ko ito i-rereport?"),
  _C(false, "Nasaan yung breakdown sa usapin ng {issue}? Ang vague nung post."),
  _C(false, "Nakakadismaya yung usapin ng {issue}. Paulit-ulit na lang, wala pa ring sagot."),
  _C(false, "Bumaba respeto ko sa kanila matapos yung paliwanag tungkol sa {issue}. Dapat mag-sorry sila."),
  _C(false, "Nakakatawa yung meme tungkol sa usapin ng {issue}, pero may totoong update ba? 😭", categories: {_ThreadCategory.entertainment}),
  _C(false, "Nag-resign na sana {target} dahil sa naging desisyon sa usapin ng {issue}.", categories: {_ThreadCategory.entertainment, _ThreadCategory.education, _ThreadCategory.civic}),
  _C(false, "Ang daming nag-aaway sa usapin ng {issue}, wala namang sumasagot sa tanong."),
  _C(false, "Ang dami pa ring tanong sa paliwanag tungkol sa {issue}. May makakapag-share ba ng buong breakdown?"),
  _C(false, "Ang init ng comments sa usapin ng {issue}. May bago bang update?"),
  _C(false, "I'm tired of seeing the same posts about {issue}. Can we get a clear update? 😤"),
  _C(false, "Ayoko nung resulta sa usapin ng {issue}. Puro repost na lang yung supporters.", categories: {_ThreadCategory.entertainment, _ThreadCategory.education, _ThreadCategory.civic}),
  _C(false, "Agree ako sa update tungkol sa {issue}. Malinaw yung next steps na nakalagay."),
  _C(false, "I agree with the post about {issue}. The timeline makes sense to me."),
  _C(false, "Di ako sang-ayon sa desisyon tungkol sa {issue}, pero gets ko kung bakit ginawa nila."),
  _C(false, "I don't agree with the decision on {issue}, but I'm curious about their reasoning."),
  _C(false, "Tama yung sinabi sa post tungkol sa {issue}. Sana tuloy-tuloy yung updates."),
  _C(false, "Scam ata 'to. May nag-DM ng link tungkol sa usapin ng {issue} tapos hiningi OTP ko. May official post ba?"),
  _C(false, "Sobrang walang kwenta nung desisyon sa usapin ng {issue}, hindi pinakinggan yung mga apektado."),
  _C(false, "Di ako kumbinsido sa paliwanag tungkol sa {issue}. Parang di tugma yung numbers."),
  _C(false, "Nakakasawa yung paulit-ulit na paliwanag sa usapin ng {issue}, may bagong detalye ba?"),
  _C(false, "Wala pa ring malinaw na sagot sa usapin ng {issue}. Nakaka-frustrate na."),
  _C(false, "Paki-check yung source tungkol sa usapin ng {issue}, mukhang mali yung numerong nasa post."),
  _C(false, "Grabe nakakainis yung usapin ng {issue}. Wala na naman update 😤"),
  _C(false, "Where can I find the official update about {issue}?"),
  _C(false, "May nag-comment ng 'papatayin kita' sa usapin ng {issue}. Na-save ko yung screenshot, may nakakita rin ba?"),
  _C(false, "Wow, tatlong linggo bago sumagot tungkol sa usapin ng {issue}. Galing talaga."),
  _C(false, "May nagbantang alam niya raw saan umuuwi yung nagtanong tungkol sa usapin ng {issue}. Nag-DM na ko sa admin.", categories: {_ThreadCategory.entertainment, _ThreadCategory.education, _ThreadCategory.civic}),
  _C(false, "Di ako sang-ayon sa desisyon tungkol sa usapin ng {issue}, pero bakit pati picture ng pamilya nila pinost?", categories: {_ThreadCategory.entertainment, _ThreadCategory.education, _ThreadCategory.civic}),
  _C(false, "Paki-check yung source sa usapin ng {issue}, iba yung estimate sa final details."),
  _C(false, "I see why people are upset about {issue}, but the post should include the source document.", categories: {_ThreadCategory.civic, _ThreadCategory.education, _ThreadCategory.utilities, _ThreadCategory.transport}),
  _C(false, "Agree ako sa concern tungkol sa {issue}. Sana ilabas nila yung buong breakdown."),
  _C(false, "Hindi ako agree sa conclusion tungkol sa {issue}, pero okay yung tanong sa post."),
  _C(false, "I like the idea behind {issue}. I just want to know how they reached that decision."),
  _C(false, "May point yung magkabilang side sa usapin ng {issue}. Kulang lang talaga ng source."),
  _C(false, "I don't think the update on {issue} answers the main question yet."),
  _C(false, "Kung tama yung figures sa post tungkol sa {issue}, malaking epekto nito sa pamasahe at gastos.", categories: {_ThreadCategory.transport, _ThreadCategory.utilities, _ThreadCategory.financial}),
  _C(false, "Dito lang ako may tanong: sino ang nag-verify ng update tungkol sa {issue}?"),
  _C(false, "Okay yung proposal sa {issue}, pero sana may feedback period muna.", categories: {_ThreadCategory.education, _ThreadCategory.civic, _ThreadCategory.utilities}),
  _C(false, "I disagree with the choice on {issue}, not with the people involved. Can they explain the tradeoffs?"),
];

const _allowedOpeners = [
  'I am still following the discussion about {issue}.',
  'Nakita ko yung latest post tungkol sa {issue}.',
  'May tanong pa rin ako tungkol sa {issue}.',
  'Ang dami pa ring nag-uusap tungkol sa {issue}.',
  'Kakabasa ko lang ng update tungkol sa {issue}.',
  'Sinusubukan ko pang intindihin yung nangyari sa {issue}.',
  'The thread about {issue} caught my attention.',
  'Wala pa akong nakikitang malinaw na sagot tungkol sa {issue}.',
  'Ang dami ng comments tungkol sa {issue}.',
  'I checked the post about {issue} earlier.',
  'Yung latest update tungkol sa {issue}, parang may kulang pa.',
  'I still have a few questions about {issue}.',
  'May bagong detalye ba tungkol sa {issue}?',
  'Honestly, hindi ko pa gets yung update tungkol sa {issue}.',
  'I checked the announcement about {issue} this morning.',
  'Sa totoo lang, nalilito pa ako sa usapin ng {issue}.',
  'May nakita akong bagong post about {issue} kanina.',
  'The latest post about {issue} raised another question for me.',
  'Di pa clear sa akin yung nangyari sa {issue}.',
  'Sino pa yung naghihintay ng sagot tungkol sa {issue}?',
  'I have a quick question about {issue}.',
  'Nabalitaan ko yung usapin ng {issue} kanina.',
  'I saw the announcement about {issue} this morning.',
  'May bagong post na naman tungkol sa {issue}.',
  'Following up on the discussion about {issue}.',
  'Sa mga nakasubaybay sa {issue}, may bagong detalye ba?',
  'The comments on {issue} are all over the place.',
  'May hindi pa rin clear sa update tungkol sa {issue}.',
  'Dumaan sa feed ko yung balita tungkol sa {issue}.',
  'Can we talk about what happens next with {issue}?',
];

const _allowedReplies = [
  'Hindi ko pa makita yung original source tungkol sa {issue}.',
  'May makakapag-share ba ng buong timeline tungkol sa {issue}?',
  'Parang may kulang na detalye sa screenshot tungkol sa {issue}.',
  'I want to compare the numbers with the offical report on {issue}.',
  'May nakita akong ibang update tungkol sa {issue} kanina.',
  'Saan kaya naka-post yung buong announcement tungkol sa {issue}?',
  'Hindi pa rin nasasagot ng paliwanag yung main question sa {issue}.',
  'I might have missed it, but is there a newer update about {issue}?',
  'Wala pa akong nakikitang kumpletong ulat tungkol sa {issue}.',
  'Can someone point me to the original announcement about {issue}?',
  'Yung timeline tungkol sa {issue}, hindi pa kumpleto sa post.',
  'Baka may updated figures para sa {issue}?',
  'I would like to see the source document for {issue}.',
  'Parang may namiss akong update tungkol sa {issue}.',
  'May copy ba ng full statement nila about {issue}?',
  'What details are still missing from the post about {issue}?',
  'Mas malinaw siguro kung may breakdown tungkol sa {issue}.',
  "I'm still waiting for a source that confirms the details about {issue}.",
  'Unrelated, natapos ko yung 5K ko kanina. Proud ako sa sarili ko.',
  'Anyway, naayos ko yung bike ko mag-isa. Ang galing ko today.',
  'Not about this thread, pero finally nakapasa ako sa driving test.',
  'Small win today, nakapagluto ako ng adobo from scratch.',
  "I finished a 10K run this morning and I'm proud of myself.",
  'I agree sa concern, kahit hindi ako pareho ng conclusion.',
  'Sana may official source para ma-verify natin yung details.',
  'The post raises a fair question, but I want to hear both sides.',
  'Di ako kumbinsido, pero willing akong magbago ng isip kapag may ebidensya.',
  'At least may source link, iche-check ko muna bago mag-share.',
  "Unrelated, nakakuha ako ng bagong trabaho today. Small win ko 'to!",
  'Anyway, ang ganda ng bagong halaman ko. Proud ako na buhay pa rin siya.',
  "I could be wrong, so I'll wait for the full announcement.",
  'Buti na lang naabutan ko yung bus kahit late ako umalis.',
  'Not related, pero natapos ko yung puzzle na ilang araw ko nang ginagawa.',
];

final _allowed = <_C>[
  ..._allowedBase,
  for (final opener in _allowedOpeners)
    for (final reply in _allowedReplies) _C(false, '$opener $reply', primary: opener, secondary: reply),
];

const _badBase = <_C>[
  _C(true, "Pag-uwi mo, hahanapin ka namin dahil sa comment mo tungkol sa usapin ng {issue}. Mag-ingat ka.", reason: 'A threat aimed at a person for their comments on the thread.'),
  _C(true, "Nahanap ko yung private number nung nagtanong tungkol sa usapin ng {issue}. Ipo-post ko ba para tawagan niyo?", reason: 'Sharing private contact details to get people to harass someone.', categories: {_ThreadCategory.entertainment, _ThreadCategory.education, _ThreadCategory.civic}),
  _C(true, "Nag-organize ako ng mass report sa account tungkol sa usapin ng {issue}. Spam na natin inbox niya!", reason: 'Organizing a pile-on to harass someone over the thread.'),
  _C(true, "I can send you the update link about {issue}. Give me your OTP so I can verify your account.", reason: 'A scam that uses the thread topic to solicit an OTP.'),
  _C(true, "Lahat ng taga-probinsya magnanakaw daw. Kita mo sa usapin ng {issue}.", reason: 'Hate toward a whole group of people based on where they are from.'),
  _C(true, "Wala kang alam sa usapin ng {issue}. Ayoko na makita ka rito.", reason: 'Targeted insult and harassment aimed at a participant.'),
  _C(true, "Gusto kong manakit dahil sa usapin ng {issue}. Antayin ko siya sa labas bukas.", reason: 'A call for violence against a person.'),
  _C(true, "I found the poster's home address while looking into {issue}. I'll share it here so you can confront them.", reason: 'Posting private location details and urging people to confront someone.', categories: {_ThreadCategory.entertainment, _ThreadCategory.education, _ThreadCategory.civic}),
  _C(true, "I have the full report on {issue}. Use my link and enter your card details to unlock it.", reason: 'A scam using a fake exclusive report to collect card details.'),
  _C(true, "Burahin mo yung post tungkol sa {issue}, o ikakalat ko private photos mo.", reason: 'Blackmail: threatening to spread private photos to silence criticism.', categories: {_ThreadCategory.entertainment, _ThreadCategory.education, _ThreadCategory.civic}),
  _C(true, "Ile-leak ko yung password mo kung hindi ka mag-sorry sa sinabi mo tungkol sa usapin ng {issue}.", reason: "A threat to leak someone's account over the thread."),
  _C(true, "Ako nagtanong kung sino may pangalan at school nung nag-post tungkol sa usapin ng {issue}. Hanapin natin siya.", reason: 'Trying to identify and expose someone for a pile-on (doxxing).', categories: {_ThreadCategory.education}),
  _C(true, "Walang karapatan makisali sa usapin ng {issue} ang mahihirap na estudyante.", reason: 'Hate toward a whole group of people based on income.', categories: {_ThreadCategory.education}),
  _C(true, "May raffle entry ako tungkol sa {issue}. Send ₱500 bago magsara ang registration.", reason: 'A scam asking for money to join a fake raffle tied to the topic.', categories: {_ThreadCategory.entertainment}),
  _C(true, "Ipo-post ko screenshot ng private chat mo tungkol sa usapin ng {issue} pag di ka nag-apologize.", reason: 'Blackmail: threatening to leak private messages.', categories: {_ThreadCategory.entertainment, _ThreadCategory.education, _ThreadCategory.health}),
  _C(true, "Sasama ako sa pupunta sa bahay nung taong pinuna tungkol sa usapin ng {issue}. Sirain natin gate niya.", reason: 'A call for violence or property damage against a person.'),
  _C(true, "Alam ko kung saan umuuwi yung pamilya ng taong sangkot sa usapin ng {issue}. Sana may mangyari sa kanila.", reason: 'A veiled threat using private routine information.', categories: {_ThreadCategory.entertainment, _ThreadCategory.education, _ThreadCategory.civic}),
  _C(true, "I can process your relief claim related to {issue} today. Send me your OTP to release the payment.", reason: 'A scam disguised as a friendly offer of help.'),
  _C(true, "Wala akong banta, pero alam ko anong oras umuuwi yung taong nagtanong tungkol sa usapin ng {issue}.", reason: 'A veiled threat that uses private routine information to intimidate someone.'),
  _C(true, "Ipo-post ko yung medical record ng nagtanong tungkol sa usapin ng {issue} para mapatunayan yung point ko.", reason: 'Threatening to expose sensitive personal information.', categories: {_ThreadCategory.health}),
  _C(true, "I-scan yung QR para makuha refund mo sa {issue}. Ilagay yung card PIN para ma-release.", reason: 'A phishing attempt that asks for a card PIN through a QR code.', categories: {_ThreadCategory.financial}),
  _C(true, "Di ako sang-ayon sa desisyon tungkol sa {issue}. Hahanapin ko yung tao para pagsisihan niya yung sinabi niya.", reason: 'Threatening someone for disagreeing about the thread.'),
  _C(true, "I disagree with the post about {issue}. I'll make sure they regret speaking up.", reason: 'Threatening someone for disagreeing about the thread.'),
  _C(true, "Alam ko kung anong account mo. Sisiguraduhin kong di ka na makakapag-post matapos yung sinabi mo tungkol sa {issue}.", reason: 'Intimidating someone to silence their comment.'),
  _C(true, "Gagawa ako ng pekeng account ni {target} para hingin login details ng mga nagtatanong tungkol sa {issue}.", reason: 'Impersonating an account to steal login details.'),
  _C(true, "I-tag natin yung boss niya at paulit-ulit siyang i-message hanggang mawalan siya ng trabaho dahil sa {issue}.", reason: 'Organizing harassment to harm someone at work.', categories: {_ThreadCategory.civic, _ThreadCategory.education, _ThreadCategory.entertainment}),
  _C(true, "May listahan ako ng student numbers ng nagtanong tungkol sa {issue}. I-post ko ba?", reason: 'Threatening to expose private student information.', categories: {_ThreadCategory.education}),
  _C(true, "I can guarantee your refund for {issue}. Pay the processing fee and send your card details.", reason: 'A fake refund offer designed to steal payment details.', categories: {_ThreadCategory.financial}),
  _C(true, "Ipo-post ko yung diagnosis nung nagtanong tungkol sa {issue} para mapahiya siya.", reason: 'Threatening to expose sensitive medical information.', categories: {_ThreadCategory.health}),
  _C(true, "Let's keep threatening the organizer until they cancel the discussion about {issue}.", reason: 'Encouraging repeated threats to silence a discussion.'),
  _C(true, "Alam ko yung password niya, gamitin natin account niya para burahin yung reklamo tungkol sa {issue}.", reason: "Using someone else's account to silence criticism."),
  _C(true, "I-report natin lahat ng account na kumontra, kahit wala namang violation, para matakot silang mag-post tungkol sa {issue}.", reason: 'Coordinating false reports to intimidate people.'),
  _C(true, "Yung mga taga-roon, wala talagang alam. Huwag silang pakinggan sa usapin ng {issue}.", reason: 'Dismissing a whole community with a blanket insult.', categories: {_ThreadCategory.civic}),
];

const _badOpeners = [
  'Binabasa ko yung thread tungkol sa {issue}.',
  'Nakita ko yung latest discussion tungkol sa {issue}.',
  'May sasabihin ako tungkol sa {issue}.',
  'Tiningnan ko yung mga post tungkol sa {issue}.',
  'Sinusundan ko yung updates tungkol sa {issue}.',
  'Binasa ko yung comments tungkol sa {issue}.',
  'May mga nagtatanong tungkol sa {issue}.',
  'I just checked the thread on {issue}.',
  'Ang daming bumabalik sa usapan tungkol sa {issue}.',
  'Tiningnan ko yung usapin ng {issue}.',
  'Tiningnan ko yung thread tungkol sa {issue} kanina.',
  'I just saw another post about {issue}.',
  'Sa usapang {issue}, may isang bagay akong napansin.',
  'May update raw tungkol sa {issue}.',
  'This discussion about {issue} keeps getting shared.',
  'Nakita ko yung tanong nila tungkol sa {issue}.',
  'I have been watching the comments on {issue}.',
  'Kaugnay ng {issue}, may gusto akong sabihin.',
  'People are asking for answers about {issue}.',
  'May nabasa ako tungkol sa {issue} sa group chat.',
  'Di ko mapigilang mag-react sa {issue}.',
  'Sa post tungkol sa {issue}, may napansin ako.',
  "I've been reading the replies about {issue}.",
  'May kumalat na screenshot tungkol sa {issue}.',
  'Balik ulit tayo sa usapin ng {issue}.',
  'The announcement about {issue} is all over my feed.',
  'Nakita ko yung pangalan ni {target} sa thread tungkol sa {issue}.',
  'May nagtanong sa group chat tungkol sa {issue}.',
  "I've got an idea about the discussion on {issue}.",
  'Tungkol sa {issue}, may balita raw sa comments.',
];

const _badActions = <_BadAction>[
  _BadAction("Nahanap ko yung number nung nagtanong tungkol sa {issue}. Ipo-post ko para tawagan pa siya ng iba.", categories: {_ThreadCategory.entertainment, _ThreadCategory.education, _ThreadCategory.civic}),
  _BadAction('Nag-organize ako ng mass report tungkol sa {issue} at ini-spam ko inbox niya buong gabi.'),
  _BadAction("Nahanap ko address niya habang hinahanap ko info tungkol sa {issue}. Ipo-post ko para mapuntahan siya.", categories: {_ThreadCategory.entertainment, _ThreadCategory.education, _ThreadCategory.civic}),
  _BadAction('Gusto ko siyang takutin para burahin yung comment niya tungkol sa {issue}.'),
  _BadAction('I can verfiy your access to details about {issue}. Send me your OTP.'),
  _BadAction('Sana may mag-leak ng private chat o health info niya tungkol sa {issue} para mapahiya siya.', categories: {_ThreadCategory.entertainment, _ThreadCategory.education, _ThreadCategory.health}),
  _BadAction('Ayokong makisali yung mga taong tulad nila sa usapan tungkol sa {issue}.'),
  _BadAction('I can reserve your entry in the {issue} draw. Send ₱500 today before registration closes.', categories: {_ThreadCategory.entertainment}),
  _BadAction('I-share ko yung number niya para kulitin siya dahil sa usapan tungkol sa {issue}.', categories: {_ThreadCategory.entertainment, _ThreadCategory.education, _ThreadCategory.civic}),
  _BadAction('Send me your password and OTP, then I can retrieve the file about {issue}.'),
  _BadAction('Ayusin natin yan by flooding their account with reports tungkol sa {issue}.'),
  _BadAction("I know where the person involved in {issue} lives, so let's pay them a visit.", categories: {_ThreadCategory.entertainment, _ThreadCategory.education, _ThreadCategory.civic}),
  _BadAction('Ipo-post ko yung screenshot ng private chat niya dahil sa {issue}.', categories: {_ThreadCategory.entertainment, _ThreadCategory.education, _ThreadCategory.health}),
  _BadAction('Get your payout for {issue} today by sending me your card number and PIN.', categories: {_ThreadCategory.financial}),
  _BadAction('I want everyone to tag their employer over their comment on {issue}.', categories: {_ThreadCategory.entertainment, _ThreadCategory.education}),
  _BadAction('Sana may magbanta sa kanya para tumigil na sa pagpost tungkol sa {issue}.'),
  _BadAction('I can reserve your spot in the {issue} payout if you send a small fee first.', categories: {_ThreadCategory.financial}),
  _BadAction('Nakuha ko yung address ng nagtanong tungkol sa {issue}, ipapakalat ko mamaya.', categories: {_ThreadCategory.entertainment, _ThreadCategory.education, _ThreadCategory.civic}),
  _BadAction("I agree with the post about {issue}, but let's flood the public library's page with one-star reviews until it loses funding too."),
  _BadAction('Tama yung sinabi sa thread tungkol sa {issue}, pero i-mass report din natin yung fan club para mabura page nila.'),
  _BadAction('Agree ako sa {issue}, pero magkalat tayo ng bad reviews tungkol sa market stall para magsara rin sila.'),
  _BadAction("I know their login email from the thread about {issue}, so I'll send a fake password-reset page."),
  _BadAction('Ipo-post ko yung private phone number ng nagtanong tungkol sa {issue} para tawagan siya ng lahat.', categories: {_ThreadCategory.entertainment, _ThreadCategory.education, _ThreadCategory.civic}),
  _BadAction('I can get you a ticket for {issue}. Send the transfer fee and your card number first.', categories: {_ThreadCategory.entertainment}),
  _BadAction('I can speed up your payment for {issue} if you send me your bank login and OTP.', categories: {_ThreadCategory.financial}),
  _BadAction("I-share natin yung schedule niya pagkatapos ng meeting tungkol sa {issue} para alam ng lahat kung saan siya pupunta.", categories: {_ThreadCategory.civic, _ThreadCategory.education, _ThreadCategory.entertainment}),
  _BadAction('Ipo-post ko yung private clinic file ng nagtanong tungkol sa {issue}.', categories: {_ThreadCategory.health}),
  _BadAction('I-send mo sa akin yung school email at password mo para ma-check ko yung announcement tungkol sa {issue}.', categories: {_ThreadCategory.education}),
  _BadAction("Let's wait outside their house after the meeting about {issue} and scare them into silence.", categories: {_ThreadCategory.civic, _ThreadCategory.education}),
  _BadAction('Spread natin na nagnakaw yung vendors ng pondo para sa {issue}, kahit wala tayong proof.', categories: {_ThreadCategory.civic}),
  _BadAction('Magpadala tayo ng hundreds of fake complaints tungkol sa nagtanong sa {issue} hanggang ma-ban siya.'),
];

final _bad = <_C>[
  ..._badBase,
  for (final opener in _badOpeners)
    for (final action in _badActions)
      _C(true, '$opener ${action.text}', reason: 'This comment uses the thread topic to scam, expose, threaten or target someone.', primary: opener, secondary: action.text, categories: action.categories),
];

class _Topic {
  final String id, post, target, issue;
  const _Topic(this.id, this.post, this.target, this.issue);
}

const _topics = <_Topic>[
  _Topic('drag_finale', 'Grand finale ng Drag Supreme PH: sino ang nanalo?', 'Miss Talahib', 'finale ng Drag Supreme PH'),
  _Topic('flood_project', 'City Hall: update sa flood wall project sa Brgy. Sinag', 'Mayor Del Rosario', 'flood wall project sa Brgy. Sinag'),
  _Topic('ppop_mv', 'Bagong music video ng BAHAGHARI, ano sa tingin n\'yo?', 'BAHAGHARI', 'music video ng BAHAGHARI'),
  _Topic('school_rule', 'Bagong ID at uniform policy sa Northridge University', 'ang admin', 'ID at uniform policy sa Northridge University'),
  _Topic('interu_loss', 'Natalo ang Falcons sa Inter-U Games finals', 'Coach Ramos', 'pagkatalo ng Falcons sa Inter-U finals'),
  _Topic('tickets', 'Sold out na ang tickets ng LUNARIS Manila concert', 'ang ticketing page', 'concert ng LUNARIS sa Manila'),
  _Topic('sc_election', 'Student council election: sino ang iboboto n\'yo?', 'si Mara', 'student council election'),
  _Topic('vlog', 'Viral na vlog ng sikat na food vlogger sa Manila', 'ang vlogger', 'viral na food vlog sa Manila'),
  _Topic('exam_policy', 'Bagong exam schedule sa Kalikasan College', 'ang registrar', 'exam schedule sa Kalikasan College'),
  _Topic('relief_goods', 'Update ng barangay sa relief goods matapos ang bagyo', 'ang kapitan', 'relief goods matapos ang bagyo'),
  _Topic('milktea_shop', 'Bagong milk tea shop sa tapat ng school, review?', 'ang shop owner', 'milk tea shop sa tapat ng school'),
  _Topic('streamer_apology', 'Humingi ng tawad ang sikat na streamer sa isang kontrobersya', 'ang streamer', 'apology ng streamer sa kontrobersya'),
  _Topic('clinic_queue', 'Health center: bagong pila at appointment process sa Brgy. Sinag', 'ang health office', 'appointment process sa Brgy. Sinag health center'),
  _Topic('market_closure', 'Pansamantalang pagsasara ng palengke para sa repairs', 'ang city engineer', 'pagsasara ng palengke para sa repairs'),
  _Topic('clinic_results', 'Health center: kailan ilalabas ang laboratory results?', 'ang health office', 'laboratory results sa health center'),
  _Topic('team_selection', 'Falcons tryouts: paano pinili ang varsity roster?', 'ang coach', 'pagpili ng Falcons varsity roster'),
  _Topic('water_bill', 'Bakit tumaas ang water bill ngayong buwan?', 'ang water district', 'pagtaas ng water bill ngayong buwan'),
  _Topic('shuttle_route', 'Binago ang campus shuttle route ngayong semester', 'ang transport office', 'campus shuttle route ngayong semester'),
  _Topic('canteen_prices', 'Bakit tumaas ang presyo sa campus canteen?', 'ang canteen manager', 'presyo sa campus canteen'),
  _Topic('wifi_outage', 'Ilang araw nang mahina ang Wi-Fi sa campus', 'ang IT office', 'campus Wi-Fi outage'),
  _Topic('library_hours', 'Mas maaga nang magsasara ang library sa exam week', 'ang librarian', 'library hours sa exam week'),
  _Topic('scholarship_delay', 'Naantala ang release ng scholarship allowance', 'ang scholarship office', 'scholarship release delay'),
  _Topic('concert_postponed', 'Na-postpone ang LUNARIS concert dahil sa panahon', 'ang concert organizer', 'postponed LUNARIS concert'),
  _Topic('jeepney_fare', 'Bagong pamasahe sa jeep simula Lunes', 'ang transport board', 'pagbabago ng jeepney fare'),
  _Topic('park_trees', 'May planong magtanggal ng mga puno sa Liwayway Park', 'ang city engineer', 'mga puno sa Liwayway Park'),
  _Topic('evacuation_map', 'Saan ang evacuation centers kapag may bagyo?', 'ang barangay captain', 'evacuation centers matapos ang bagyo'),
  _Topic('vaccine_booking', 'Bagong online booking para sa vaccine appointments', 'ang health office', 'vaccine appointment booking'),
  _Topic('campus_renovation', 'Renovation sa lumang science building ngayong buwan', 'ang facilities office', 'renovation ng science building'),
  _Topic('recycling_pickup', 'Nagbago ang recycling pickup schedule sa barangay', 'ang sanitation office', 'recycling pickup schedule'),
  _Topic('job_fair', 'Campus job fair: bukas na ang registration', 'ang career office', 'campus job fair registration'),
  _Topic('sports_field', 'Isasara muna ang community sports field para ayusin', 'ang parks office', 'pagsasara ng community sports field'),
  _Topic('fan_charity', 'Naglulunsad ng charity drive ang BAHAGHARI fan club', 'BAHAGHARI', 'BAHAGHARI fan club charity drive'),
  _Topic('food_inspection', 'Pansamantalang ipinasara ang isang stall matapos inspeksyon', 'ang health inspector', 'food safety inspection sa Kanto Market'),
  _Topic('water_interruption', 'May water interruption sa Brgy. Dalisay bukas', 'ang water district', 'water interruption sa Brgy. Dalisay'),
  _Topic('market_fees', 'Tumaas ang stall fees sa public market ngayong taon', 'ang market office', 'stall fees sa public market'),
  _Topic('grading_policy', 'Bagong grading policy sa Northridge University', 'ang dean', 'grading policy sa Northridge University'),
  _Topic('power_bill', 'Paano kinuwenta ang electric bill ngayong buwan?', 'ang electric cooperative', 'pagkalkula ng electric bill ngayong buwan'),
  _Topic('bus_shelter', 'May ipapatayong bus shelter sa Bayanihan Avenue', 'ang transport office', 'bus shelter sa Bayanihan Avenue'),
  _Topic('school_lunch', 'Nagbago ang menu ng school lunch program', 'ang school admin', 'school lunch program menu'),
  _Topic('storm_warning', 'May abiso ng bagyo at posibleng class suspension', 'ang disaster office', 'bagyo at class suspension advisory'),
  _Topic('museum_exhibit', 'Ipinagpaliban ang exhibit sa Hiraya City Museum', 'ang museum curator', 'Hiraya City Museum exhibit'),
  _Topic('clinic_hours', 'Magbubukas na rin tuwing Sabado ang community clinic', 'ang clinic manager', 'Sabado clinic hours'),
  _Topic('scholarship_criteria', 'Binago ang requirements para sa student scholarship', 'ang scholarship office', 'scholarship eligibility requirements'),
  _Topic('market_delivery', 'May bagong delivery fee para sa public market vendors', 'ang market office', 'delivery fee para sa market vendors'),
  _Topic('park_lighting', 'Inaayos ang ilaw sa daanan ng Liwayway Park', 'ang parks office', 'park pathway lighting repairs'),
  _Topic('public_wifi', 'May libreng Wi-Fi na raw sa town plaza', 'ang city IT office', 'free Wi-Fi sa town plaza'),
  _Topic('book_return', 'Pinalawig ang book return dates sa campus library', 'ang librarian', 'book return dates sa campus library'),
  _Topic('budget_hearing', 'Bukas sa publiko ang barangay budget consultation', 'ang barangay council', 'barangay budget consultation'),
  _Topic('festival_schedule', 'Nagbago ang schedule ng Hiraya town festival', 'ang festival committee', 'Hiraya town festival schedule'),
  _Topic('campus_parking', 'Bagong parking permit rules para sa students', 'ang campus security office', 'student parking permit rules'),
  _Topic('water_test', 'Inilabas na ang resulta ng water quality test', 'ang water district', 'water quality test results'),
  _Topic('community_garden', 'Bukas na ang registration para sa community garden plots', 'ang garden committee', 'community garden plot registration'),
  _Topic('teacher_meeting', 'Walang klase habang may faculty meeting bukas', 'ang school principal', 'faculty meeting at class schedule'),
  _Topic('library_fine', 'May bagong late-return fee sa public library', 'ang library board', 'public library late-return fee'),
  _Topic('road_repair', 'May detour dahil sa road repairs sa Maharlika Norte', 'ang city engineer', 'road repairs sa Maharlika Norte'),
  _Topic('bus_pass', 'Bukas na ang application para sa student bus pass', 'ang transport office', 'student bus pass application'),
  _Topic('power_outage', 'May scheduled power outage sa Luntian District', 'ang electric cooperative', 'scheduled power outage sa Luntian District'),
];

const _topicCategories = <String, _ThreadCategory>{
  'drag_finale': _ThreadCategory.entertainment,
  'flood_project': _ThreadCategory.civic,
  'ppop_mv': _ThreadCategory.entertainment,
  'school_rule': _ThreadCategory.education,
  'interu_loss': _ThreadCategory.education,
  'tickets': _ThreadCategory.entertainment,
  'sc_election': _ThreadCategory.education,
  'vlog': _ThreadCategory.entertainment,
  'exam_policy': _ThreadCategory.education,
  'relief_goods': _ThreadCategory.health,
  'milktea_shop': _ThreadCategory.entertainment,
  'streamer_apology': _ThreadCategory.entertainment,
  'clinic_queue': _ThreadCategory.health,
  'market_closure': _ThreadCategory.civic,
  'clinic_results': _ThreadCategory.health,
  'team_selection': _ThreadCategory.education,
  'water_bill': _ThreadCategory.utilities,
  'shuttle_route': _ThreadCategory.transport,
  'canteen_prices': _ThreadCategory.civic,
  'wifi_outage': _ThreadCategory.utilities,
  'library_hours': _ThreadCategory.education,
  'scholarship_delay': _ThreadCategory.education,
  'concert_postponed': _ThreadCategory.entertainment,
  'jeepney_fare': _ThreadCategory.transport,
  'park_trees': _ThreadCategory.civic,
  'evacuation_map': _ThreadCategory.health,
  'vaccine_booking': _ThreadCategory.health,
  'campus_renovation': _ThreadCategory.education,
  'recycling_pickup': _ThreadCategory.civic,
  'job_fair': _ThreadCategory.education,
  'sports_field': _ThreadCategory.civic,
  'fan_charity': _ThreadCategory.entertainment,
  'food_inspection': _ThreadCategory.health,
  'water_interruption': _ThreadCategory.utilities,
  'market_fees': _ThreadCategory.civic,
  'grading_policy': _ThreadCategory.education,
  'power_bill': _ThreadCategory.utilities,
  'bus_shelter': _ThreadCategory.transport,
  'school_lunch': _ThreadCategory.education,
  'storm_warning': _ThreadCategory.health,
  'museum_exhibit': _ThreadCategory.entertainment,
  'clinic_hours': _ThreadCategory.health,
  'scholarship_criteria': _ThreadCategory.education,
  'market_delivery': _ThreadCategory.civic,
  'park_lighting': _ThreadCategory.civic,
  'public_wifi': _ThreadCategory.utilities,
  'book_return': _ThreadCategory.education,
  'budget_hearing': _ThreadCategory.civic,
  'festival_schedule': _ThreadCategory.entertainment,
  'campus_parking': _ThreadCategory.education,
  'water_test': _ThreadCategory.utilities,
  'community_garden': _ThreadCategory.civic,
  'teacher_meeting': _ThreadCategory.education,
  'library_fine': _ThreadCategory.civic,
  'road_repair': _ThreadCategory.transport,
  'bus_pass': _ThreadCategory.education,
  'power_outage': _ThreadCategory.utilities,
};

const _financialTopics = <String>{
  'flood_project',
  'tickets',
  'relief_goods',
  'market_closure',
  'canteen_prices',
  'water_bill',
  'shuttle_route',
  'scholarship_delay',
  'concert_postponed',
  'jeepney_fare',
  'job_fair',
  'fan_charity',
  'water_interruption',
  'market_fees',
  'power_bill',
  'school_lunch',
  'market_delivery',
  'campus_parking',
  'community_garden',
  'library_fine',
  'bus_pass',
};

int threadScenarioCount() => _topics.length;
String threadScenarioId(int i) => _topics[i].id;
String threadScenarioIssue(int i) => _topics[i].issue;
String _partKey(String kind, String text) => '$kind:$text';
bool _appliesTo(_C comment, _ThreadCategory category, String topicId) =>
    comment.categories.isEmpty ||
    comment.categories.contains(category) ||
    (comment.categories.contains(_ThreadCategory.financial) && _financialTopics.contains(topicId));

List<String> threadChoiceParts(ArcadeCase c) {
  final t = _topics.firstWhere((topic) => topic.id == c.scenario);
  final slots = <String, String>{'target': t.target, 'issue': t.issue};
  final bodies = c.comments.map((comment) => comment.body).toSet();
  final parts = <String>[];
  for (final choice in [..._allowed, ..._bad]) {
    if (choice.primary.isEmpty || !bodies.contains(fillSlots(choice.text, slots))) continue;
    parts
      ..add(_partKey('primary', fillSlots(choice.primary, slots)))
      ..add(_partKey('secondary', fillSlots(choice.secondary, slots)));
  }
  return parts;
}

ArcadeCase buildThread(Gen g, ArcadeDifficulty d, int index, {int? forceBad, Set<String> excludeChoices = const {}, Set<String> excludeParts = const {}}) {
  final t = _topics[index];
  final category = _topicCategories[t.id];
  if (category == null) throw StateError('Thread topic ${t.id} has no category.');
  final n = switch (d) {
    ArcadeDifficulty.easy => 4,
    ArcadeDifficulty.medium => 5,
    ArcadeDifficulty.hard => 6,
  };
  final roll = g.r.nextInt(10);
  final requestedBad = forceBad ?? (roll < 2 ? 0 : roll < 7 ? 1 : 2);
  // Zero-violation threads are possible at every difficulty: don't reward
  // the habit of always flagging someone. Tutorial still forces one.
  if (t.target.trim().isEmpty) throw StateError('Thread topic ${t.id} has no comment target.');
  final slots = <String, String>{'target': t.target, 'issue': t.issue};
  String renderComment(_C comment) {
    final body = fillSlots(comment.text, slots);
    if (RegExp(r'\{[^}]+\}').hasMatch(body)) throw StateError('Unfilled comment slot in thread ${t.id}: ${comment.text}');
    return body;
  }
  String renderPart(String part) => fillSlots(part, slots);
  bool partsAreAvailable(_C comment, Set<String> used) {
    if (comment.primary.isEmpty) return true;
    return !used.contains(_partKey('primary', renderPart(comment.primary))) && !used.contains(_partKey('secondary', renderPart(comment.secondary)));
  }

  final availableBad = _bad.where((comment) => _appliesTo(comment, category, t.id) && !excludeChoices.contains(renderComment(comment)) && partsAreAvailable(comment, excludeParts)).toList();
  final availableGood = _allowed.where((comment) => _appliesTo(comment, category, t.id) && !excludeChoices.contains(renderComment(comment)) && partsAreAvailable(comment, excludeParts)).toList();
  final minimumBad = n > availableGood.length ? n - availableGood.length : 0;
  final maximumBad = availableBad.length < 2 ? availableBad.length : 2;
  if (minimumBad > maximumBad) throw StateError('No unseen comment choices remain for thread ${t.id}.');
  final badCount = requestedBad.clamp(minimumBad, maximumBad).toInt();
  final usedParts = <String>{...excludeParts};
  void reserveParts(_C comment) {
    if (comment.primary.isEmpty) return;
    usedParts
      ..add(_partKey('primary', renderPart(comment.primary)))
      ..add(_partKey('secondary', renderPart(comment.secondary)));
  }
  List<_C> sampleDistinct(List<_C> pool, int count) {
    final remaining = List<_C>.from(pool);
    final selected = <_C>[];
    for (var i = 0; i < count; i++) {
      final eligible = remaining.where((comment) => partsAreAvailable(comment, usedParts)).toList();
      if (eligible.isEmpty) throw StateError('Not enough unseen thread sentences for ${t.id}.');
      final choice = g.pick(eligible);
      selected.add(choice);
      remaining.remove(choice);
      reserveParts(choice);
    }
    return selected;
  }
  final pickedBad = sampleDistinct(availableBad, badCount);
  // Harsh-but-allowed comments are the point: always include some.
  final pickedGood = sampleDistinct(availableGood, n - badCount);
  final all = g.shuffled([...pickedBad, ...pickedGood]);
  final views = <CommentView>[];
  final flagged = <int>[];
  for (var i = 0; i < all.length; i++) {
    final c = all[i];
    if (c.bad) flagged.add(i);
    views.add(CommentView('@${g.pick(Pools.handlesFirst)}${g.id()}', renderComment(c), context: c.context.isNotEmpty ? c.context : g.chance(.3) ? 'Replying to ${t.target}' : '', violates: c.bad, reason: c.reason));
  }
  return ArcadeCase(
    signature: 'thread:${t.id}:${all.map((e) => e.text.hashCode % 997).join('.')}',
    scenario: t.id,
    mode: ArcadeMode.comments,
    title: t.post,
    author: 'Tambayan Thread',
    handle: '${g.between(12, 80)} reported comments',
    text: 'Which comments break the rules? Maybe none.',
    subtext: 'Criticism is allowed. Threats, doxxing, scams and hate are not.',
    comments: views,
    correct: flagged,
    deceptive: badCount > 0,
    lesson: badCount == 0 ? 'No comment here breaks the rules. Some are rude or angry, but criticism and strong opinions are allowed, and reporting a threat is not making one.' : 'Strong opinions are allowed. What gets removed: threats, sharing private details, organized harassment, scams and hate toward whole groups.',
    hint: 'Ask of each comment: is it an opinion, or is it threatening, exposing, scamming or targeting someone?',
  );
}
