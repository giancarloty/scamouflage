import 'arcade_common.dart';
import '../models/arcade_models.dart';

/// Scam Slam. The player sees what they actually did recently ("your phone"),
/// an incoming chat, and the link's real domain. A message is legitimate only
/// when it matches the player's own activity AND asks for nothing the real
/// service would never ask (OTP, PIN, advance fees, off-app payment).
///
/// The correct reply is NOT always "verify": real messages are answered by
/// carrying on normally, so the answer depends on the facts, not the phrasing.
class _Chat {
  final String id, sender, number;
  final bool scam;
  final List<String> incoming;
  final List<String> activity;
  final String link; // domain shown in the link preview, '' if none
  final String official; // what the real service uses
  final String senderNote;
  final String best; // correct reply
  final List<String> wrong; // plausible wrong replies (2 used)
  final List<String> afterBest, afterWrong;
  final String lesson, hint;
  const _Chat(
    this.id,
    this.scam,
    this.sender,
    this.number,
    this.incoming,
    this.activity,
    this.link,
    this.official,
    this.senderNote,
    this.best,
    this.wrong,
    this.afterBest,
    this.afterWrong,
    this.lesson,
    this.hint,
  );
}

const _chats = <_Chat>[
  // ------------------------------------------------------------- LEGIT
  _Chat(
    'cod_real',
    false,
    'Kargo Express',
    '+63 917 ••• 2210',
    [
      "Hi! Rider ng Kargo Express po ito. Today ang delivery ng parcel mo from {store}. COD amount: ₱{amt}. Pakihanda po ang eksaktong bayad 🙏",
    ],
    [
      "Yesterday: you ordered a phone case from {store} (Cash on Delivery, ₱{amt}).",
      "Your order page says: Out for delivery today.",
    ],
    '',
    '',
    'Number saved from your earlier deliveries.',
    "Wait for the rider and pay the COD amount shown in your order page",
    [
      "Block the number and report it as a scam",
      "Reply with your home address and birthday \"to confirm\"",
    ],
    ["Rider arrives. The amount matches your order page. Parcel received ✅"],
    [
      "The rider can't reach you. Your parcel goes back to the hub.",
      "Reporting a real rider doesn't protect anyone, and your order is delayed.",
    ],
    "Not every text about money is a scam. This one matched an order you made, asked for no OTP, and used cash on delivery.",
    "Does the message match something you actually did?",
  ),
  _Chat(
    'otp_real',
    false,
    '{wallet}',
    'PesoGo',
    [
      "{wallet}: Your login code is 483 920. Never share this with anyone, even {wallet} staff. Valid for 5 minutes.",
    ],
    ["A minute ago: you tapped \"Log in\" in the {wallet} app."],
    '',
    '',
    'Sent from the wallet\'s official sender name.',
    "Type the code only into the app you just opened",
    [
      "Send the code to the number that \"called to verify\" you",
      "Post the code in the group chat to ask if it's normal",
    ],
    ["You're in. Nobody else ever saw the code ✅"],
    ["Anyone with that code can log in as you."],
    "A code you asked for is normal. The danger is giving it to someone else, no matter who they say they are.",
    "Did you just request this code yourself?",
  ),
  _Chat(
    'class_gc_real',
    false,
    'Class GC • Ate Mika',
    '+63 998 ••• 0412',
    [
      "Guys, contribution para sa class shirt: ₱{amt}, hanggang Friday lang. Pay ka sa class treasurer sa school, hindi online ha 🙏",
    ],
    [
      "Your class GC voted for class shirts last week.",
      "Ate Mika is your class treasurer (saved contact).",
    ],
    '',
    '',
    'Saved contact in your class group.',
    "Pay the class treasurer in person like the group agreed",
    [
      "Ask her to send her wallet PIN so you can \"pay faster\"",
      "Report the chat as a scam",
    ],
    ["You pay on Friday and get a signed receipt ✅"],
    ["Awkward. Your classmates ask why you reported a normal class activity."],
    "Money requests from people you know can be real. This one matched a class decision and used the agreed in-person payment.",
    "Do you know this person, and did the class agree to this?",
  ),
  _Chat(
    'refund_real',
    false,
    '{store} Support',
    '+63 920 ••• 8841',
    [
      "Hi! Natanggap na namin ang return request #R{id} mo. Ang refund ay mapupunta sa original payment method within 5-7 days. Wala nang kailangang gawin 🙂",
    ],
    [
      "Two days ago: you filed a return request in the {store} app.",
      "Your app shows: Return approved. Refund pending.",
    ],
    '',
    '',
    'Matches the number shown in your app\'s help page.',
    "Wait for the refund; do nothing else",
    [
      "Send your wallet PIN so they can \"speed up\" the refund",
      "Click a link to \"track\" the refund (none was sent)",
    ],
    ["The refund arrives a few days later ✅"],
    [
      "Nothing good comes from sharing a PIN for a refund. Real refunds never need it.",
    ],
    "A real refund message asks nothing from you. Notice what it did NOT ask for.",
    "What, if anything, is the message asking you to do?",
  ),
  _Chat(
    'concert_real',
    false,
    '{group} Tickets',
    'GROUP-TIX',
    [
      "Your e-ticket for the {group} fan meeting is ready. Open the official app and tap My Tickets. Do not share your QR code with anyone.",
    ],
    [
      "Last month: you bought a fan meeting ticket on the official ticketing app.",
    ],
    'tix.{groupDomain}.example',
    'tix.{groupDomain}.example',
    'Same sender name as your purchase receipt.',
    "Open the ticket in the official app that you bought it from",
    [
      "Forward the QR code to a friend who \"wants to check\"",
      "Ignore it, because tickets are always scams",
    ],
    ["Your ticket is in the app, ready for the event ✅"],
    [
      "A QR code can be used once. If someone else scans it first, the door says \"already used\".",
    ],
    "The message matched a purchase you made and pointed you back to the official app.",
    "Did you buy a ticket, and where did you buy it?",
  ),
  _Chat(
    'portal_real',
    false,
    'Registrar',
    'REGISTRAR',
    [
      "Reminder: enrollment closes this Friday. Log in at {schoolDomain}.example. Please type it yourself. We will never ask for your password by text.",
    ],
    [
      "Last week: you started your enrollment on the school portal.",
      "Your portal shows: 2 steps left before Friday.",
    ],
    '{schoolDomain}.example',
    '{schoolDomain}.example',
    'The same sender name as your earlier school reminders.',
    "Open the portal yourself and finish the last 2 steps",
    [
      "Ignore it, since urgent texts are always scams",
      "Reply with your student number and password to confirm",
    ],
    ["You finish enrollment with a day to spare ✅"],
    [
      "You miss the deadline, and late enrollment costs extra.",
      "Never send a password by text, even to a real office.",
    ],
    "Urgent does not mean fake. The deadline matched your own progress, the domain was the school's, and it asked for no password.",
    "Does it match what you are already doing?",
  ),
  _Chat(
    'rider_gate',
    false,
    'Kuya Rider',
    '+63 933 ••• 6205',
    ["Ma'am/Sir, rider po ito ng {store}. Nasa gate na po ako. COD po ₱{amt}."],
    [
      "10 minutes ago: you ordered from {store}, Cash on Delivery ₱{amt}.",
      "The app shows: Rider arriving.",
    ],
    '',
    '',
    'The app showed this rider\'s number on your order.',
    "Go to the gate and pay the amount shown in the app",
    [
      "Send your wallet PIN for \"faster payment\"",
      "Block the number because it's unknown",
    ],
    ["The amount matches your order. You get your food ✅"],
    [
      "Never share a PIN. A rider only needs the cash or the order code.",
      "The rider can't reach you, and your food goes cold.",
    ],
    "The message matched an order you made minutes ago, the number matched the app, and the amount matched.",
    "Does the number and amount match your own order?",
  ),
  _Chat(
    'card_alert_real',
    false,
    '{wallet}',
    'PesoGo',
    [
      "{wallet}: A ₱{amt} payment to {store} was made from your account. If this was you, no action is needed. We will never ask for your OTP.",
    ],
    ["5 minutes ago: you paid ₱{amt} to {store} in the {wallet} app."],
    '',
    '',
    'The wallet\'s official sender name.',
    "Do nothing: it's your own payment",
    ["Reply with your OTP to \"cancel\" it", "Report the message as a scam"],
    ["It was your payment. Nothing else to do ✅"],
    [
      "Nobody asked for an OTP. Never give one out.",
      "Reporting a true alert only wastes your time.",
    ],
    "Alerts about your own purchases are normal. This one asked for nothing.",
    "Did you just make this payment?",
  ),
  _Chat(
    'scholar_fee',
    true,
    'Scholarship Admin',
    '+63 955 ••• 1824',
    [
      "Hi scholar! Admin ng scholarship GC. Para ma-release ang allowance mo ngayon, mag-send ng ₱500 verification fee sa {wallet} namin.",
    ],
    [
      "The scholarship office announced allowances on the official portal. No fees mentioned.",
      "This number is not in your scholarship group.",
    ],
    '',
    '',
    'An unknown number using the word "admin".',
    "Check the official portal or office; don't send anything",
    [
      "Send ₱500 now so you don't lose your allowance",
      "Ask them to send a photo of their ID first",
    ],
    ["The portal says allowances are released free. You report the number ✅"],
    [
      "The allowance never comes, and they ask for more fees.",
      "Fake IDs are easy to make.",
    ],
    "Real scholarships don't charge fees to release money. The official portal said so.",
    "Where did the scholarship office say allowances are released?",
  ),
  _Chat(
    'parcel_hub_pay',
    true,
    '{courier}',
    '+63 949 ••• 5509',
    [
      "{courier}: May parcel kang naka-hold sa hub. Magbayad ng ₱{amt} shipping sa {wallet} namin bago mag-deliver.",
    ],
    [
      "You haven't ordered anything this week.",
      "Your orders list: nothing on the way.",
    ],
    '',
    '',
    'A number that is not on any of your orders.',
    "Check your orders in the shopping app, and don't pay",
    ["Pay the ₱{amt} to be safe", "Reply and ask what the parcel is"],
    ["No orders on the way. You delete the text and report it ✅"],
    [
      "The money is gone and no parcel ever arrives.",
      "Replying tells them the number is live.",
    ],
    "No order, a number you don't know, and an outside payment are the classic parcel-scam signs.",
    "Did you order anything?",
  ),
  // ------------------------------------------------------------- SCAM
  _Chat(
    'parcel_fee',
    true,
    'Kargo Express',
    '+63 905 ••• 7712',
    [
      "KARGO EXPRESS: Failed delivery. Your parcel is on hold. Pay ₱{amt} redelivery fee within 2 hours or it will be returned: {link}",
    ],
    [
      "You haven't ordered anything this week.",
      "Your order list: no pending deliveries.",
    ],
    'kargo-redeliver-fee.example',
    'kargoexpress.example',
    'A new number you have never saved.',
    "Check your orders in the shopping app yourself, and ignore the link",
    [
      "Tap the link to see how much the fee really is",
      "Reply \"STOP\" to unsubscribe from the messages",
    ],
    [
      "You open the app. No orders and no failed deliveries. You delete the text and report the number ✅",
    ],
    [
      "The link opens a page asking for card details.",
      "Replying also tells the sender your number is active.",
    ],
    "There was no order, the link domain wasn't the courier's, and the fee was urgent. Check your own app, not the link.",
    "Did you order anything? Who owns that link domain?",
  ),
  _Chat(
    'otp_call',
    true,
    'Unknown',
    '+63 917 ••• 3009',
    [
      "Hi, ako si Rico from {wallet} Security. May nag-login sa account mo sa Cebu. Para ma-block, paki-send ang 6-digit code na ipapadala namin sa'yo ngayon.",
    ],
    [
      "You haven't tried to log in anywhere right now.",
      "No security alert in the {wallet} app.",
    ],
    '',
    '',
    'A mobile number, not the wallet\'s sender name.',
    "Hang up or stop replying. Check the alert inside the app yourself",
    [
      "Send the code so the \"security team\" can block the login",
      "Ask for his employee ID and keep chatting",
    ],
    ["The app shows no alert. You block the number and report it ✅"],
    [
      "That code is the key to your wallet. The scammer logs in and empties it.",
      "Chatting longer gives them time to pressure you.",
    ],
    "Real security teams never ask you to read out a code. The code is what lets them in.",
    "Would a real company ask for your code?",
  ),
  _Chat(
    'relative_new_number',
    true,
    '"Ate Joy"',
    '+63 936 ••• 5502',
    [
      "Hi, si Ate Joy 'to! Nasira phone ko kaya bagong number. Pwede mo ba muna akong utangan ng ₱{amt}? Bayaran ko mamaya. Huwag ka na tumawag, mahina ang signal.",
    ],
    [
      "Ate Joy's saved number is different from this one.",
      "Her last post in the family group was 2 hours ago.",
    ],
    '',
    '',
    'Unsaved number using your cousin\'s first name.',
    "Call Ate Joy's saved number or ask in the family group first",
    [
      "Send the money now, since family comes first",
      "Ask \"Ano apelyido mo?\" and send if she answers",
    ],
    [
      "Ate Joy answers her usual number: \"Ha? Hindi ako 'yan!\" You warn the family group ✅",
    ],
    [
      "The money is gone and the number stops replying.",
      "Scammers often know the family's surnames already.",
    ],
    "A new number plus pressure not to call is a classic. Confirm through a contact channel you already trust.",
    "Is there a way to reach the real person on a number you already have?",
  ),
  _Chat(
    'task_job',
    true,
    'Job Offer',
    '+63 947 ••• 6618',
    [
      "Hello! Part-time online job, ₱{amt}/day lang sa pag-like ng videos. Walang experience needed. Magdeposito muna ng ₱1,000 para ma-activate ang account mo, ibabalik din.",
    ],
    [
      "You didn't apply for any online job.",
      "Your student email has no applications pending.",
    ],
    'quickjobs-ph.example',
    '',
    'A number that found you out of nowhere.',
    "Don't pay anything. Report and block",
    [
      "Pay the ₱1,000 first, since it's refundable",
      "Ask for a screenshot of their \"company\" first",
    ],
    ["You report the number and your classmates thank you for the heads-up ✅"],
    [
      "The first \"task\" pays ₱50. Then they ask for a bigger deposit, and the account is frozen.",
      "Fake screenshots are easy to make.",
    ],
    "Jobs that charge you to start, or pay a lot for liking videos, are a common scam pattern.",
    "Who asks a worker to pay money first?",
  ),
  _Chat(
    'raffle_prize',
    true,
    '{wallet} Promo',
    '+63 915 ••• 4120',
    [
      "CONGRATULATIONS! Nanalo ka ng ₱{amt} sa {wallet} Anniversary Raffle! I-claim ngayon: {link}. Ilagay ang MPIN para ma-verify.",
    ],
    ["You didn't join any raffle.", "The {wallet} app has no promo like this."],
    'pesogo-claim-prize.example',
    'pesogo.example',
    'A mobile number, not the wallet\'s sender name.',
    "Ignore the link and delete the message. Report it as phishing",
    [
      "Tap the link, but just look without typing anything",
      "Reply to ask if it's real",
    ],
    ["The app has no such promo. You delete the text ✅"],
    [
      "Even opening an unknown link can load a fake login page.",
      "Replying tells them your number is live.",
    ],
    "You can't win a raffle you never joined, and no real raffle asks for your MPIN.",
    "Did you enter this raffle?",
  ),
  _Chat(
    'lto_fine',
    true,
    'Traffic Fine',
    '+63 927 ••• 9984',
    [
      "FINAL NOTICE: May unpaid traffic violation ka na ₱{amt}. Bayaran within 24 hrs o lalaki ang penalty: {link}",
    ],
    [
      "You don't drive and have no registered vehicle.",
      "No traffic ticket was ever issued to you.",
    ],
    'traffic-fines-pay.example',
    'bltservices.example',
    'An unsaved mobile number.',
    "Check the official traffic website by typing it yourself",
    [
      "Pay through the link just to be safe",
      "Send a screenshot to the GC and ask if you should pay",
    ],
    ["The official site shows no violation under your name ✅"],
    [
      "Paying through the link sends the money straight to the scammer.",
      "Your GC may reply with advice, but the money is still gone if you paid.",
    ],
    "A fine for something you never did, with a short deadline and an outside link, is a red flag.",
    "Did you actually get a ticket?",
  ),
  _Chat(
    'bank_known_details',
    true,
    'Order Update',
    '+63 918 ••• 7731',
    [
      "Hi Ms./Mr. {name}, order #R{id} sa {store} ay na-hold dahil kulang ang address. Pakiverify ang card details dito: {link}",
    ],
    [
      "Yesterday: you did place an order on {store} (₱{amt}).",
      "Your app shows: Order confirmed, address complete.",
    ],
    'store-verify-order.example',
    '',
    'Knows your name and a real order, but it is an unsaved number.',
    "Check the order in the {store} app yourself, and don't use the link",
    [
      "Verify through the link, since they know your order",
      "Reply with the first 6 digits of your card to prove it's you",
    ],
    ["The app says your order is fine and the address is complete ✅"],
    [
      "Scammers can buy leaked order data. Knowing your name doesn't make them the store.",
      "Even partial card numbers help them.",
    ],
    "A real order doesn't make a message real. The app shows no problem, and the link isn't the store's.",
    "What does your own order page say?",
  ),
  _Chat(
    'sim_register',
    true,
    'SIM Notice',
    '+63 960 ••• 3317',
    [
      "NOTICE: Your SIM will be deactivated in 24 hours. To keep your number, reply with a photo of your ID and your birthday.",
    ],
    [
      "Your SIM was registered when you bought it.",
      "Your network app shows: SIM registered ✓.",
    ],
    '',
    '',
    'A mobile number, not your network\'s sender name.',
    "Check your SIM status in your network's app yourself",
    [
      "Send a photo of your ID so you do not lose your number",
      "Ask them to confirm your name first",
    ],
    ["The app says your SIM is registered. You delete the text ✅"],
    [
      "A photo of your ID and birthday is enough for someone to open accounts in your name.",
      "Scammers can fake any confirmation.",
    ],
    "Your own app says the SIM is registered. A text that asks for an ID photo by reply is collecting your identity.",
    "What does your own network app say?",
  ),
  _Chat(
    'school_refund_real',
    false,
    'Kalikasan College Registrar',
    'REGISTRAR',
    [
      "Nabalik na sa student account mo ang ?{amt} lab fee. Makikita ang detalye sa school portal; huwag magpadala ng password o OTP sa text.",
    ],
    [
      "Last week: you dropped a lab class and filed the refund form in the student portal.",
      "Your portal status says: Refund approved.",
    ],
    '',
    '',
    'The notice matches a request you submitted and directs you back to the portal.',
    "Check the student portal yourself; do not send any code",
    [
      "Reply with your password so the registrar can release it",
      "Report the message because all refund texts are scams",
    ],
    ["The portal shows the refund is pending and no extra action is needed ?"],
    [
      "A real office will never need your password by text.",
      "You report a genuine update and miss useful information.",
    ],
    "A refund message can be real when it matches your request and points back to the portal without asking for secrets.",
    "Does it match a request you actually made?",
  ),
  _Chat(
    'fake_delivery_address',
    true,
    'Delivery Helpdesk',
    '+63 945 ??? 7308',
    [
      "Hindi makita ang bahay mo. Ipadala ang live location at picture ng ID dito ngayon para maihatid ang parcel.",
    ],
    [
      "You have one parcel on the way, but the courier app already has your saved address.",
      "The courier never asked for a new delivery instruction.",
    ],
    '',
    '',
    'An unknown number asks for your location and identity documents outside the courier app.',
    "Open the courier app and contact support there; do not send your ID",
    [
      "Send your live location and ID to avoid a failed delivery",
      "Reply with your full address and birthday",
    ],
    [
      "The app shows the correct address. You report the number without sharing personal details ?",
    ],
    [
      "Your location and ID are now exposed to an unknown sender.",
      "The extra details can be used to impersonate you.",
    ],
    "A real delivery problem should be handled in the courier's official app, not by sending an ID photo to an unknown number.",
    "Can you verify the delivery request inside the courier app?",
  ),
  _Chat(
    'storm_alert_real',
    false,
    'Brgy. Sinag DRRMO',
    'BRGY-ALERTS',
    [
      "Flood advisory for Riverside Zone: move to the covered court if water reaches the blue marker. Updates are on the barangay page.",
    ],
    [
      "The barangay website lists BRGY-ALERTS for emergency notices.",
      "The city weather bulletin says the river is rising, but has not ordered a citywide evacuation.",
    ],
    '',
    '',
    'The sender and the limited evacuation condition match the official directory.',
    "Follow the Riverside Zone instruction and check the barangay page for updates",
    [
      "Ignore it because the city has not ordered everyone to evacuate",
      "Forward it as a citywide evacuation order",
    ],
    [
      "The notice is limited to the riverside zone and tells residents where to verify updates.",
    ],
    [
      "Residents in the marked zone miss a real precaution.",
      "A wider claim can cause unnecessary panic and hide the actual boundary.",
    ],
    "A genuine alert can be conditional and local. Keep its exact scope instead of dismissing it or broadening it.",
    "Who is covered by the instruction, and what condition triggers it?",
  ),
  _Chat(
    'family_phone_stolen',
    true,
    'Ate Joy',
    '+63 936 ••• 5502',
    [
      "Nasa biyahe ako at nawalan ng phone. Paki-send muna ng ₱{amt} sa bagong wallet na ito. Huwag mo munang tawagan, babawi ako mamaya.",
    ],
    [
      "This is Ate Joy's saved number, but the family group says her phone was stolen this morning.",
      "Her usual wallet details are pinned in the family group; this message gives a different account.",
    ],
    '',
    '',
    'A familiar number can still be controlled by someone else.',
    "Call Ate Joy using another trusted contact or ask the family group to confirm",
    [
      "Send the money because the number is saved",
      "Ask a question only Ate Joy would know, then pay if the reply sounds right",
    ],
    [
      "The family reaches Ate Joy through her usual contact and confirms the request is false.",
    ],
    [
      "The thief receives the money.",
      "A convincing answer may come from someone who has read her messages.",
    ],
    "A known number is not enough when there is a credible compromise warning and changed payment details. Verify through a separate channel.",
    "What changed, and can you verify without using this conversation?",
  ),
];

int chatScenarioCount() => _chats.length;
String chatScenarioId(int i) => _chats[i].id;
bool chatScenarioScam(int i) => _chats[i].scam;

ArcadeCase buildChat(Gen g, ArcadeDifficulty d, int index) {
  final c = _chats[index];
  final group = g.pick(Pools.groups);
  final slots = <String, String>{
    'store': g.pick(Pools.stores),
    'wallet': g.pick(Pools.wallets),
    'amt': g.pick(['89', '149', '250', '399', '1,200']),
    'group': group,
    'id': '${g.id()}',
    'groupDomain': group.toLowerCase().replaceAll(RegExp(r'[^a-z]'), ''),
    'name': g.pick(['Santos', 'Reyes', 'Cruz', 'Bautista']),
    'courier': g.pick(Pools.couriers),
    'schoolDomain': g.pick(['northridge', 'kalikasan', 'pagasa']),
  };
  slots['link'] = fillSlots(c.link, slots);
  String f(String s) => fillSlots(s, slots);
  final activity = d == ArcadeDifficulty.hard && c.id == 'parcel_fee'
      ? [
          "Yesterday: you ordered a small item from Kargo Express for ₱{amt}.",
          "The courier app shows the parcel at the local hub; no extra redelivery fee is listed.",
        ]
      : c.activity;
  final wrongOrder = g
      .shuffled([for (var i = 0; i < c.wrong.length; i++) i])
      .take(2)
      .toList();
  final texts = [f(c.best), ...wrongOrder.map((i) => f(c.wrong[i]))];
  final order = g.shuffled([0, 1, 2]);
  final choices = [for (final i in order) ArcadeOption(texts[i])];
  final correctChoice = order.indexOf(0);
  // Each wrong choice has its own follow-up; the right one has a good ending.
  final follow = <int, List<String>>{};
  for (var pos = 0; pos < 3; pos++) {
    final original = order[pos];
    if (original == 0) {
      follow[pos] = c.afterBest.map(f).toList();
    } else {
      final w = wrongOrder[original - 1];
      follow[pos] = [f(c.afterWrong[w.clamp(0, c.afterWrong.length - 1)])];
    }
  }
  final sender = f(c.sender);
  final number = c.number == 'PesoGo' || c.number == 'GROUP-TIX'
      ? (c.number == 'PesoGo' ? slots['wallet']! : '${group.toUpperCase()}-TIX')
      : c.number;
  return ArcadeCase(
    signature: 'chat:${c.id}',
    scenario: c.id,
    mode: ArcadeMode.scamSlam,
    title: 'New message',
    author: sender,
    handle: number,
    text: 'What do you do?',
    subtext: f(c.senderNote),
    chatIn: c.incoming.map(f).toList(),
    activity: activity.map(f).toList(),
    linkDomain: slots['link']!,
    deceptive: c.scam,
    correct: [correctChoice],
    choices: choices,
    followUps: follow,
    lesson: f(c.lesson),
    hint: d.profile.requiresCrossChecking
        ? 'Check whether your own recent activity supports the request, then verify through a channel you already trust.'
        : f(c.hint),
  );
}
