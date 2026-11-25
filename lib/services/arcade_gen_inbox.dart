import 'arcade_common.dart';
import '../models/arcade_models.dart';

/// Inbox Sprint. One case is a batch of emails the player sorts quickly.
/// Spam always has an objective tell in the sender/link/ask details; legit
/// mail may still look urgent, informal or full of money talk.
class _E {
  final String family, fromName, from, subject, body, why;
  final String reply, linkLabel, link, attach;
  final bool spam;
  const _E(this.family, this.spam, this.fromName, this.from, this.subject,
      this.body, this.why,
      {this.reply = '', this.linkLabel = '', this.link = '', this.attach = ''});
}

const _legit = <_E>[
  _E('scholar_status', false, 'Student Services', 'scholarships@{schoolDom}.example', 'Application received',
    "Hi {name}, we got your scholarship application. You can check the status in the student portal you already use. No action needed by email.",
    "The sender domain is the school's own, and it only points you to the portal you already use."),
  _E('receipt_store', false, '{store}', 'receipts@{storeDom}.example', 'Your receipt: order #R{id}',
    "Salamat sa order mo! Total: ₱{amt}. Naka-attach ang receipt. Makikita rin ito sa Orders ng app.",
    "It matches an order you made, comes from the store's domain, and asks you for nothing.",
    attach: 'receipt-R{id}.pdf'),
  _E('enroll_urgent', false, 'Registrar', 'registrar@{schoolDom}.example', 'Enrollment closes this Friday',
    "Reminder: enrollment closes this Friday, 5PM. Please finish on the portal at {schoolDom}.example. The registrar never asks for your password by email.",
    "It's urgent, but the deadline is real, the link goes to the school's own domain, and it asks for no password.",
    linkLabel: 'Open the portal', link: '{schoolDom}.example/portal'),
  _E('teacher_gmail', false, 'Sir Dennis (Math)', 'sir.dennis.math@mail.example', 'Quiz moved to Thursday',
    "Hi class, na-move ang quiz sa Thursday dahil sa class suspension. Same coverage. Reply here if may tanong.",
    "A teacher you know can use a personal address. It asks for nothing, and the news matches your class group.",
    reply: 'sir.dennis.math@mail.example'),
  _E('wallet_statement', false, '{wallet}', 'no-reply@{walletDom}.example', 'Your monthly statement is ready',
    "Your {wallet} statement for last month is ready. Open the {wallet} app and go to Statements. We will never ask for your PIN or OTP.",
    "It points you to the app instead of a link and warns against sharing your PIN or OTP."),
  _E('event_ticket', false, '{group} Tickets', 'tickets@{groupDom}-tix.example', 'Your e-ticket for Saturday',
    "Your ticket to the {group} fan meeting is attached. Show the QR code at the gate. Don't share it with anyone.",
    "You bought this ticket, it comes from the ticket seller's domain, and it warns you not to share the QR.",
    attach: 'eticket.pdf'),
  _E('club_meet', false, 'Photography Club', 'club@{schoolDom}.example', 'Meeting on Thursday, 4PM',
    "Hi {name}! Club meeting sa Thursday, 4PM, Room 12. Dalhin ang camera kung meron. Walang bayad.",
    "It comes from the school's club address and is free, with no link or code request."),
  _E('refund_done', false, '{store}', 'support@{storeDom}.example', 'Refund approved: R{id}',
    "Your refund of ₱{amt} was approved and will arrive in 5-7 days. You don't need to do anything.",
    "It matches a return you filed, and it asks you for nothing.",
    linkLabel: 'View your return', link: '{storeDom}.example/returns'),
  _E('city_notice', false, 'City Hall', 'notices@city-{cityDom}.example', 'Brgy. payout schedule',
    "Ang payout para sa registered seniors ay sa Sabado, 8AM sa covered court. Valid ID lang ang kailangan.",
    "It comes from the city's domain, matches the barangay's own post, and asks for no link or money."),
  _E('pw_changed', false, '{wallet}', 'security@{walletDom}.example', 'You changed your password',
    "You changed your {wallet} password a minute ago. If this wasn't you, open the app and use Help. We won't ask for your password by email.",
    "You just did this, it has no link, and it tells you to use the app if you didn't."),
];

const _spam = <_E>[
  _E('scholar_cash', true, 'Scholarship Office', 'award@scholar-grants-ph.example', 'You are guaranteed ₱{amt}!',
    "Congratulations {name}! Everyone qualifies. Click below and enter your school password to claim before midnight.",
    "The sender's domain isn't the school's, and it asks for your password.",
    linkLabel: 'CLAIM NOW', link: 'scholar-grants-ph.example/claim'),
  _E('parcel_fee', true, 'Kargo Express', 'delivery@kargo-redelivery.example', 'Failed delivery: pay fee',
    "Your parcel is on hold. Pay ₱{amt} within 2 hours or it will be returned.",
    "The sender's domain isn't the courier's, there's no order you made, and it demands an urgent outside payment.",
    linkLabel: 'Pay redelivery fee', link: 'kargo-redelivery.example/pay'),
  _E('wallet_lock', true, '{wallet} Security', 'verify@{walletDom}-secure-login.example', 'Account locked, act now',
    "Your account will be closed in 24 hours. Verify your MPIN and OTP to keep it.",
    "The sender's domain is a lookalike, and it asks for your MPIN and OTP, which a real wallet never asks for.",
    linkLabel: 'Verify account', link: '{walletDom}-secure-login.example'),
  _E('job_fee', true, 'HR Recruitment', 'jobs@fast-hire-ph.example', 'Online job: ₱{amt}/day',
    "No interview, no experience. Pay a ₱1,000 activation fee first to start. Fee is refundable.",
    "A real employer never charges you to start working.",
    linkLabel: 'Activate account', link: 'fast-hire-ph.example/activate'),
  _E('tuition_change', true, 'Accounting Office', 'accounting@{schoolDom}.example', 'New bank details for tuition',
    "Please send your tuition payment to our new account number 0099-1121-33. Our old account is closed.",
    "The sender looks right, but the reply-to address is a different one. Changing bank details by email is a classic scam.",
    reply: 'accounting.office@mail-support.example'),
  _E('gift_cards', true, 'Prof. Villanueva', 'prof.villanueva@{schoolDom}-staff.example', 'Quick favor',
    "Are you available? I need 5 gift cards for a surprise for the class. I'll reimburse you. Reply ASAP, I can't take calls.",
    "The domain isn't the school's, and it asks for gift cards with urgency and no phone calls.",
    reply: 'villanueva.prof@mail-reply.example'),
  _E('invoice_zip', true, 'Accounts', 'billing@invoices-ph.example', 'Unpaid invoice #{id}',
    "Attached is your overdue invoice. Please open it and enable macros to view.",
    "You don't recognize this invoice, the sender is unknown, and a .zip file asking to enable macros is dangerous.",
    attach: 'invoice-{id}.zip'),
  _E('ayuda_link', true, 'Ayuda Program', 'ayuda@gov-ayuda-registry.example', 'Register for ₱{amt} ayuda',
    "Rehistro na para sa ayuda. Ilagay ang buong pangalan, birthday at ID number sa link.",
    "The domain isn't the government's, and it asks for personal details.",
    linkLabel: 'Register here', link: 'gov-ayuda-registry.example/form'),
  _E('streambox', true, 'StreamBox Billing', 'billing@streambox-payments.example', 'Payment failed',
    "We couldn't charge your card. Call 0917 555 0188 to update your details or your plan will end.",
    "It sends you to a phone number it provides, and the sender isn't the real service."),
  _E('deepfake_doc', true, 'Wellness Deals', 'deals@herbal-cure-ph.example', 'Doc says this cures everything',
    "Doc Ramon recommends this capsule for every illness. Only 20 left. Pay now with {wallet}.",
    "A doctor's name used on an unknown seller's email, with cure claims and urgency, is a scam.",
    linkLabel: 'Order now', link: 'herbal-cure-ph.example/order'),
];

int inboxScenarioCount() => _legit.length + _spam.length;

EmailItem _make(Gen g, _E e, Map<String, String> s) {
  String f(String x) => fillSlots(x, s);
  return EmailItem(
    fromName: f(e.fromName), fromAddress: f(e.from), subject: f(e.subject),
    body: f(e.body), spam: e.spam, why: f(e.why),
    replyTo: f(e.reply), linkLabel: f(e.linkLabel), linkTarget: f(e.link),
    attachment: f(e.attach),
  );
}

ArcadeCase buildInbox(Gen g, ArcadeDifficulty d, int index, {int? count}) {
  final n = count ?? switch (d.profile.reasoningLevel) {
    1 => 3,
    2 => 4,
    _ => 6,
  };
  final store = g.pick(Pools.stores);
  final wallet = g.pick(Pools.wallets);
  final group = g.pick(Pools.groups);
  String dom(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  final slots = <String, String>{
    'name': g.pick(['Mika', 'Jules', 'Nica', 'Paolo']),
    'store': store, 'storeDom': dom(store), 'wallet': wallet,
    'walletDom': dom(wallet), 'group': group, 'groupDom': dom(group),
    'schoolDom': dom(g.pick(Pools.schools)), 'cityDom': dom(g.pick(Pools.cities)),
    'amt': g.pick(['250', '1,500', '5,000']), 'id': '${g.id()}',
  };
  // Beyond the tutorial, a batch may be all genuine or all spam.
  // This prevents players from using "there must be one of each" to win.
  final mixedTutorial = count != null;
  final extremeChance = d == ArcadeDifficulty.easy ? .12 : .25;
  final spamCount = !mixedTutorial && g.chance(extremeChance)
      ? g.pick([0, n])
      : g.between(1, n - 1);
  final chosenSpam = g.sample(_spam, spamCount);
  final chosenLegit = g.sample(_legit, n - spamCount);
  final mix = g.shuffled([...chosenSpam, ...chosenLegit]);
  final emails = [for (final e in mix) _make(g, e, slots)];
  return ArcadeCase(
    signature: 'inbox:${mix.map((e) => e.family).toList().join(',')}',
    scenario: 'batch', mode: ArcadeMode.inbox,
    title: 'Inbox', author: 'Tambayan Mail',
    text: 'Swipe each email: left = SPAM, right = KEEP.',
    subtext: d.profile.requiresCrossChecking
        ? 'Inspect the sender, reply-to, link destination and request before deciding.'
        : 'Tap an email to see who really sent it.',
    emails: emails, deceptive: spamCount > 0,
    correct: [for (final e in emails) e.spam ? 0 : 1],
    lesson: 'Spam can look polished and real mail can look rushed. The sender address, where a link really goes, and what the email asks you for are what count.',
    hint: 'Tap the card to flip it. Compare the sender and link with the real service, and ask what it wants from you.',
  );
}
