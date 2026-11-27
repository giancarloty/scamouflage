import 'arcade_common.dart';
import '../models/arcade_models.dart';

/// Inbox Sprint. One case is a batch of emails the player sorts quickly.
/// Spam always has an objective tell in the sender/link/ask details; legit
/// mail may still look urgent, informal or full of money talk.
class _E {
  final String family, fromName, from, subject, body, why;
  final String reply, linkLabel, link, attach;
  final bool spam;
  const _E(
    this.family,
    this.spam,
    this.fromName,
    this.from,
    this.subject,
    this.body,
    this.why, {
    this.reply = '',
    this.linkLabel = '',
    this.link = '',
    this.attach = '',
  });
}

const _legit = <_E>[
  _E(
    'scholar_status',
    false,
    'Student Services',
    'scholarships@{schoolDom}.example',
    'Application received',
    "Hi {name}, we received your scholarship application on Monday. The status and review timeline are now on the student portal.",
    "The school domain matches the application portal, which shows the same received date and review timeline.",
  ),
  _E(
    'receipt_store',
    false,
    '{store}',
    'receipts@{storeDom}.example',
    'Your receipt: order #R{id}',
    "Salamat sa order mo! Total: ₱{amt}. Naka-attach ang receipt. Makikita rin ito sa Orders ng app.",
    "The order number and total match your recent purchase, and the sender uses the store's domain.",
    attach: 'receipt-R{id}.pdf',
  ),
  _E(
    'enroll_urgent',
    false,
    'Registrar',
    'registrar@{schoolDom}.example',
    'Enrollment closes this Friday',
    "Reminder: enrollment closes this Friday, 5PM. Finish the last step on the portal at {schoolDom}.example.",
    "The deadline matches the registrar calendar, and the link uses the school's portal domain.",
    linkLabel: 'Open the portal',
    link: '{schoolDom}.example/portal',
  ),
  _E(
    'teacher_gmail',
    false,
    'Sir Dennis (Math)',
    'sir.dennis.math@mail.example',
    'Quiz moved to Thursday',
    "Hi class, na-move ang quiz sa Thursday dahil sa class suspension. Same coverage. Reply here if may tanong.",
    "The teacher's personal address matches the one in your class group, which has the same schedule change.",
    reply: 'sir.dennis.math@mail.example',
  ),
  _E(
    'wallet_statement',
    false,
    '{wallet}',
    'no-reply@{walletDom}.example',
    'Your monthly statement is ready',
    "Your {wallet} statement for last month is ready. Open the {wallet} app and go to Statements to view the same billing period.",
    "The statement period and sender domain match the account page in your {wallet} app.",
  ),
  _E(
    'event_ticket',
    false,
    '{group} Tickets',
    'tickets@{groupDom}-tix.example',
    'Your e-ticket for Saturday',
    "Your ticket to the {group} fan meeting is attached. The QR code is scanned at the gate.",
    "You bought this ticket, and the order record and sender domain match the ticketing app.",
    attach: 'eticket.pdf',
  ),
  _E(
    'club_meet',
    false,
    'Photography Club',
    'club@{schoolDom}.example',
    'Meeting on Thursday, 4PM',
    "Hi {name}! Club meeting sa Thursday, 4PM, Room 12. Dalhin ang camera kung meron; puwede ring maki-share sa group.",
    "The sender is the school's club address, and the meeting details match the club calendar.",
  ),
  _E(
    'refund_done',
    false,
    '{store}',
    'support@{storeDom}.example',
    'Refund approved: R{id}',
    "Your refund of ₱{amt} was approved and is scheduled to arrive in 5-7 days. The return status is in your account.",
    "The return number and refund amount match the request shown in your store account.",
    linkLabel: 'View your return',
    link: '{storeDom}.example/returns',
  ),
  _E(
    'city_notice',
    false,
    'City Hall',
    'notices@city-{cityDom}.example',
    'Brgy. payout schedule',
    "Ang payout para sa registered seniors ay sa Sabado, 8AM sa covered court. Dalhin ang appointment slip.",
    "It comes from the city's domain and matches the barangay's own posted schedule.",
  ),
  _E(
    'pw_changed',
    false,
    '{wallet}',
    'security@{walletDom}.example',
    'You changed your password',
    "Your {wallet} password was changed a minute ago. Review the security activity in the app.",
    "The timestamp matches the password change you just made, and the sender domain matches the wallet.",
  ),
  _E(
    'library_due',
    false,
    'Library',
    'library@{schoolDom}.example',
    'Book due on Friday',
    "Hi {name}, your borrowed book is due this Friday. Renew it through the library portal before the due date.",
    "The library sender and due date match the loan listed in your portal.",
  ),
  _E(
    'order_shipped',
    false,
    '{store}',
    'orders@{storeDom}.example',
    'Your order #{id} has shipped',
    "Good news! Your order shipped today. Track it in the {store} app under Orders.",
    "The order number and dispatch date match the order history in the {store} app.",
  ),
  _E(
    'council_survey',
    false,
    'Student Council',
    'council@{schoolDom}.example',
    'Survey: Foundation week ideas',
    "Hi {name}! Gusto naming marinig ang ideas mo para sa foundation week. Sagutan ang survey sa school portal bago Biyernes.",
    "The council address and survey link are both listed on the school's foundation-week page.",
    linkLabel: 'Open the survey',
    link: '{schoolDom}.example/survey',
  ),
  _E(
    'new_device',
    false,
    '{wallet}',
    'security@{walletDom}.example',
    'New device login',
    "A login to your {wallet} account was recorded from a new phone at 8:42 PM. Review the device list in the app.",
    "The time matches your new-device sign-in, and the sender is the wallet's listed security address.",
  ),
  _E(
    'class_schedule',
    false,
    'Kalikasan College Registrar',
    'registrar@{schoolDom}.example',
    'Updated laboratory schedule',
    "Your lab section meets in Room 204 this Thursday. The registrar calendar has the updated room assignment.",
    "The school domain and room number match the current registrar calendar.",
  ),
  _E(
    'survey_vendor',
    false,
    'Student Council',
    'noreply@formsmail.example',
    'Foundation week survey',
    "Hi {name}! Sagutan ang survey ng Student Council sa survey app. The school portal has the same survey link and closing date.",
    "The external survey service is named on the school portal, which lists the same URL and deadline.",
    linkLabel: 'Open survey',
    link: 'formsmail.example/s/foundation',
  ),
  _E(
    'deadline_real',
    false,
    'Scholarship Office',
    'scholarships@{schoolDom}.example',
    'FINAL REMINDER: documents due tomorrow',
    "FINAL REMINDER, {name}: your scholarship documents are due tomorrow, 5PM. Submit them through the student portal.",
    "The reminder matches your open application and the deadline shown on the scholarship portal.",
  ),
  _E(
    'library_hold',
    false,
    'Kalikasan College Library',
    'notices@library-services.example',
    'Your reserved book is ready',
    "Hi {name}, the book you reserved is ready at the campus desk until Friday. Check the hold in the library portal.",
    "The library portal shows the same hold and pickup deadline; the outside mail service is listed as the library's notification provider.",
    reply: 'library@{schoolDom}.example',
  ),
  _E(
    'payroll_summary',
    false,
    'Campus Payroll',
    'statements@payroll-partner.example',
    'Weekly pay summary: ₱{amt}',
    "Your shift pay for the week ending Friday is posted. The staff portal shows the same hours and summary.",
    "The staff portal lists this payroll provider and shows the matching pay period.",
    attach: 'pay-summary-{id}.pdf',
  ),
  _E(
    'event_vendor_update',
    false,
    'Campus Events',
    'events@calendar-notify.example',
    'Art workshop moved to 2:30PM',
    "The Saturday art workshop now starts at 2:30PM in Studio 4. The campus events page has the updated schedule.",
    "The campus events page lists this calendar provider and the same room and time.",
    linkLabel: 'View event details',
    link: 'calendar-notify.example/events/{id}',
  ),
  _E(
    'volunteer_shift',
    false,
    'Mara - Eco Club',
    'mara.ecoclub@mail.example',
    'Saturday cleanup starts at 8:30',
    "Hi {name}, the cleanup starts at 8:30 instead of 9 this week. Please check the pinned Eco Club group post for the supply list.",
    "The coordinator's address matches the club roster, and the same time change is pinned in the club group.",
    reply: 'mara.ecoclub@mail.example',
  ),
  _E(
    'clinic_appointment',
    false,
    'Community Clinic',
    'appointments@{cityDom}-clinic.example',
    'Appointment moved to Wednesday',
    "Your checkup is now Wednesday at 10:30AM. The clinic calendar shows the updated appointment time.",
    "The booking reference and revised time match the appointment in the clinic portal.",
  ),
];

const _spam = <_E>[
  _E(
    'scholar_cash',
    true,
    'Scholarship Office',
    'award@scholar-grants-ph.example',
    'You are guaranteed ₱{amt}!',
    "Congratulations {name}! Everyone qualifies. Click below and enter your school password to claim before midnight.",
    "The sender's domain isn't the school's, and it asks for your password.",
    linkLabel: 'CLAIM NOW',
    link: 'scholar-grants-ph.example/claim',
  ),
  _E(
    'parcel_fee',
    true,
    'Kargo Express',
    'delivery@kargo-redelivery.example',
    'Failed delivery: pay fee',
    "Your parcel is on hold. Pay ₱{amt} within 2 hours or it will be returned.",
    "The sender's domain isn't the courier's, there's no order you made, and it demands an urgent outside payment.",
    linkLabel: 'Pay redelivery fee',
    link: 'kargo-redelivery.example/pay',
  ),
  _E(
    'wallet_lock',
    true,
    '{wallet} Security',
    'verify@{walletDom}-secure-login.example',
    'Account locked, act now',
    "Your account will be closed in 24 hours. Verify your MPIN and OTP to keep it.",
    "The sender's domain is a lookalike, and it asks for your MPIN and OTP, which a real wallet never asks for.",
    linkLabel: 'Verify account',
    link: '{walletDom}-secure-login.example',
  ),
  _E(
    'job_fee',
    true,
    'HR Recruitment',
    'jobs@fast-hire-ph.example',
    'Online job: ₱{amt}/day',
    "No interview, no experience. Pay a ₱1,000 activation fee first to start. Fee is refundable.",
    "A real employer never charges you to start working.",
    linkLabel: 'Activate account',
    link: 'fast-hire-ph.example/activate',
  ),
  _E(
    'tuition_change',
    true,
    'Accounting Office',
    'accounting@{schoolDom}.example',
    'New bank details for tuition',
    "Please send your tuition payment to our new account number 0099-1121-33. Our old account is closed.",
    "The sender looks right, but the reply-to address is a different one. Changing bank details by email is a classic scam.",
    reply: 'accounting.office@mail-support.example',
  ),
  _E(
    'gift_cards',
    true,
    'Prof. Villanueva',
    'prof.villanueva@{schoolDom}-staff.example',
    'Quick favor',
    "Are you available? I need 5 gift cards for a surprise for the class. I'll reimburse you. Reply ASAP, I can't take calls.",
    "The domain isn't the school's, and it asks for gift cards with urgency and no phone calls.",
    reply: 'villanueva.prof@mail-reply.example',
  ),
  _E(
    'invoice_zip',
    true,
    'Accounts',
    'billing@invoices-ph.example',
    'Unpaid invoice #{id}',
    "Attached is your overdue invoice. Please open it and enable macros to view.",
    "You don't recognize this invoice, the sender is unknown, and a .zip file asking to enable macros is dangerous.",
    attach: 'invoice-{id}.zip',
  ),
  _E(
    'ayuda_link',
    true,
    'Ayuda Program',
    'ayuda@gov-ayuda-registry.example',
    'Register for ₱{amt} ayuda',
    "Rehistro na para sa ayuda. Ilagay ang buong pangalan, birthday at ID number sa link.",
    "The domain isn't the government's, and it asks for personal details.",
    linkLabel: 'Register here',
    link: 'gov-ayuda-registry.example/form',
  ),
  _E(
    'streambox',
    true,
    'StreamBox Billing',
    'billing@streambox-payments.example',
    'Payment failed',
    "We couldn't charge your card. Call 0917 555 0188 to update your details or your plan will end.",
    "It sends you to a phone number it provides, and the sender isn't the real service.",
  ),
  _E(
    'deepfake_doc',
    true,
    'Wellness Deals',
    'deals@herbal-cure-ph.example',
    'Doc says this cures everything',
    "Doc Ramon recommends this capsule for every illness. Only 20 left. Pay now with {wallet}.",
    "A doctor's name used on an unknown seller's email, with cure claims and urgency, is a scam.",
    linkLabel: 'Order now',
    link: 'herbal-cure-ph.example/order',
  ),
  _E(
    'prize_survey',
    true,
    'Customer Rewards',
    'rewards@survey-prizes-ph.example',
    'Answer 3 questions, win ₱{amt}',
    "Take our quick survey and win ₱{amt} instantly. Enter your card number to receive your prize.",
    "A survey that pays you if you enter your card number is a card-theft trick.",
    linkLabel: 'Start survey',
    link: 'survey-prizes-ph.example/start',
  ),
  _E(
    'boss_codes',
    true,
    'Dean Reyes',
    'dean.reyes@{schoolDom}-office.example',
    'Urgent: confidential',
    "I'm in a meeting and can't talk. Please buy ₱{amt} in {wallet} credits and send me the codes. Keep this confidential.",
    "The sender's domain isn't the school's, and it asks for wallet codes with secrecy and urgency.",
    reply: 'reyes.dean@mail-reply.example',
  ),
  _E(
    'password_expire',
    true,
    'IT Helpdesk',
    'it-helpdesk@{schoolDom}-support.example',
    'Your password expires today',
    "Your school email password expires in 1 hour. Click below and type your current password to keep it.",
    "The sender's domain isn't the school's, and a real helpdesk never asks you to type your current password.",
    linkLabel: 'Keep my password',
    link: '{schoolDom}-support.example/keep',
  ),
  _E(
    'inheritance',
    true,
    'Legal Desk',
    'claims@global-estates.example',
    'You inherited ₱{amt}',
    "A distant relative left you money. Reply with your full name, an ID photo and a ₱2,000 processing fee to release it.",
    "Unexpected money that needs a fee and your ID is an advance-fee scam.",
    reply: 'claims.desk@mail-reply.example',
  ),
  _E(
    'campus_parking',
    true,
    'Campus Parking Office',
    'parking@{schoolDom}-tickets.example',
    'Unpaid parking fine: R{id}',
    "Pay ₱{amt} by 6PM to avoid a hold on your student account. Open the attachment to see your plate number and payment instructions.",
    "The sender uses a lookalike school domain, creates urgency, and asks you to open an unexpected attachment.",
    attach: 'parking-fine-{id}.zip',
  ),
  _E(
    'compromised_staff',
    true,
    'Registrar Office',
    'registrar@{schoolDom}.example',
    'Update your records today',
    "Please re-enter your student portal password at the link below to avoid losing your enrolment.",
    "The address looks right, but real offices never ask for your password, and the link goes to a different site.",
    linkLabel: 'Student portal',
    link: 'portal-update-ph.example/login',
  ),
  _E(
    'polite_advance',
    true,
    'Ms. Dela Cruz',
    'mdelacruz.hr@careers-desk.example',
    'Interview invitation',
    "Good day {name}, we reviewed your profile and would like to invite you for a remote role. Kindly reply with your ID photo and a ₱1,500 onboarding fee to schedule.",
    "Polite and professional, but you never applied, and real employers don't charge an onboarding fee.",
    reply: 'dela.cruz@mail-reply.example',
  ),
  _E(
    'shared_class_notes',
    true,
    'Sir Dennis (Math)',
    'sir.dennis.math@mail.example',
    'Notes from today',
    "Hi {name}, here's the worksheet we discussed. Open the attached HTML file and sign in again to view the notes.",
    "The class portal has no new worksheet, and the attachment is a sign-in page rather than a document. Confirm with the teacher through the class portal before opening it.",
    reply: 'sir.dennis.math@mail.example',
    attach: 'math-notes.html',
  ),
  _E(
    'grant_documents',
    true,
    'Scholarship Review Team',
    'review@{schoolDom}-awards.example',
    'Your application is shortlisted',
    "Your scholarship file is shortlisted. Upload a photo of your student ID and bank details by 6PM to reserve the stipend.",
    "The sender domain differs from the school's, and the form requests identity and financial details.",
    linkLabel: 'Reserve stipend',
    link: '{schoolDom}-awards.example/shortlist',
  ),
  _E(
    'class_file_share',
    true,
    'Sir Dennis (Math)',
    'sir.dennis.math@school-sharebox.example',
    'Shared: exam review sheet',
    "I added the exam review sheet. Sign in with your school account at the link before it expires tonight.",
    "The address is not the teacher's known school or class address, and the file link opens an unrelated sign-in site.",
    linkLabel: 'Open shared sheet',
    link: 'school-files-share.example/login',
  ),
  _E(
    'payroll_change',
    true,
    'Campus Payroll',
    'payroll@campus-payroll-update.example',
    'Confirm direct deposit before payday',
    "We couldn't process this week's pay. Submit your account number and a photo of your ID in the form so we can release it today.",
    "The sender uses a lookalike payroll domain and requests bank and identity details through an unlisted form.",
    reply: 'payroll-help@fast-mail.example',
    linkLabel: 'Fix deposit details',
    link: 'campus-payroll-update.example/confirm',
  ),
  _E(
    'wallet_refund',
    true,
    '{store} Refund Desk',
    'refunds@{storeDom}-claims.example',
    'Refund for order #{id}',
    "Your ₱{amt} refund is ready. Sign in with your wallet account and enter the one-time code to transfer it now.",
    "The sender is outside the store's domain, and the refund page asks for a wallet sign-in and one-time code.",
    linkLabel: 'Receive refund',
    link: '{storeDom}-claims.example/refund',
  ),
  _E(
    'voicemail_attachment',
    true,
    'Campus Office',
    'audio@campus-messagebox.example',
    'Voice message from the Dean',
    "The dean left a private voice note about your application. Open the attached player and sign in to listen before it is deleted.",
    "The sender is not the campus office, and an unexpected attachment asks you to sign in to play audio.",
    attach: 'dean-voice-player.html',
  ),
];

const _hardLegitFamilies = {'teacher_gmail', 'survey_vendor'};
const _hardSpamFamilies = {
  'tuition_change',
  'compromised_staff',
  'polite_advance',
};

int inboxScenarioCount() => _legit.length + _spam.length;

EmailItem _make(Gen g, _E e, Map<String, String> s) {
  String f(String x) => fillSlots(x, s);
  return EmailItem(
    fromName: f(e.fromName),
    fromAddress: f(e.from),
    subject: f(e.subject),
    body: f(e.body),
    spam: e.spam,
    why: f(e.why),
    replyTo: f(e.reply),
    linkLabel: f(e.linkLabel),
    linkTarget: f(e.link),
    attachment: f(e.attach),
  );
}

ArcadeCase buildInbox(Gen g, ArcadeDifficulty d, int index, {int? count}) {
  final n =
      count ??
      switch (d.profile.reasoningLevel) {
        1 => 3,
        2 => 4,
        _ => 5,
      };
  final store = g.pick(Pools.stores);
  final wallet = g.pick(Pools.wallets);
  final group = g.pick(Pools.groups);
  String dom(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  final slots = <String, String>{
    'name': g.pick(['Mika', 'Jules', 'Nica', 'Paolo']),
    'store': store,
    'storeDom': dom(store),
    'wallet': wallet,
    'walletDom': dom(wallet),
    'group': group,
    'groupDom': dom(group),
    'schoolDom': dom(g.pick(Pools.schools)),
    'cityDom': dom(g.pick(Pools.cities)),
    'amt': g.pick(['250', '1,500', '5,000']),
    'id': '${g.id()}',
  };
  // Beyond the tutorial, a batch may be all genuine or all spam.
  // This prevents players from using "there must be one of each" to win.
  final mixedTutorial = count != null;
  final hard = d.profile.requiresCrossChecking && !mixedTutorial;
  final extremeChance = d == ArcadeDifficulty.easy ? .12 : .25;
  final spamCount = !mixedTutorial && g.chance(extremeChance)
      ? g.pick([0, n])
      : g.between(1, n - 1);
  List<_E> sample(List<_E> pool, int amount, Set<String> anchorFamilies) {
    if (!hard || amount == 0) return g.sample(pool, amount);
    final anchors = pool
        .where((e) => anchorFamilies.contains(e.family))
        .toList();
    final anchor = g.pick(anchors);
    final rest = pool.where((e) => e.family != anchor.family).toList();
    return [anchor, ...g.sample(rest, amount - 1)];
  }

  final chosenSpam = sample(_spam, spamCount, _hardSpamFamilies);
  final chosenLegit = sample(_legit, n - spamCount, _hardLegitFamilies);
  final mix = g.shuffled([...chosenSpam, ...chosenLegit]);
  final emails = [for (final e in mix) _make(g, e, slots)];
  return ArcadeCase(
    signature: 'inbox:${mix.map((e) => e.family).toList().join(',')}',
    scenario: 'batch',
    mode: ArcadeMode.inbox,
    title: 'Inbox',
    author: 'Tambayan Mail',
    text: 'Swipe each email: left = SPAM, right = KEEP.',
    subtext: d.profile.requiresCrossChecking
        ? 'Inspect the sender, reply-to, link destination and request before deciding.'
        : 'Tap an email to see who really sent it.',
    emails: emails,
    deceptive: spamCount > 0,
    correct: [for (final e in emails) e.spam ? 0 : 1],
    lesson:
        'Spam can look polished and real mail can look rushed. The sender address, where a link really goes, and what the email asks you for are what count.',
    hint:
        'Tap the card to flip it. Compare the sender and link with the real service, and ask what it wants from you.',
  );
}
