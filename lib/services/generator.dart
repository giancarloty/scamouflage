import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';

/// All output is fictional and offline. Rules create the ground truth BEFORE
/// text and visible evidence, so a payment, new account or typo is never a
/// standalone automatic reason to reject content.
class Pattern {
  final CaseKind kind;
  final Verdict verdict;
  final String topic, title, body, artifact, secondary;
  final String source, context, identity, lesson;
  const Pattern(
    this.kind,
    this.verdict,
    this.topic,
    this.title,
    this.body,
    this.artifact,
    this.secondary,
    this.source,
    this.context,
    this.identity,
    this.lesson,
  );
}

const patterns = <Pattern>[
  // Philippine civic issues: fictional organizations, no allegations about real individuals.
  Pattern(
    CaseKind.post,
    Verdict.approve,
    'Government',
    'Mga tanong sa delayed {area} project',
    'Bakit ang tagal ng repair sa {area}? Public funds deserve public answers. May nakakaalam ng latest update?',
    '🛣️ COMMUNITY DISCUSSION',
    'Civic feedback',
    'This is an opinion/question, not a fabricated factual announcement.',
    'Criticizing a public project is permitted political discussion.',
    'Personal community account; no impersonation observed.',
    'A critical government post is not automatically misinformation.',
  ),
  Pattern(
    CaseKind.post,
    Verdict.reject,
    'Government',
    'LEAKED: All benefits cancelled!',
    'BREAKING: lahat ng government assistance cancelled na raw {day}! This old screenshot is proof. SHARE ASAP!!',
    '📄 CROPPED NOTICE',
    'Old document',
    'The image originated from an unrelated notice from a previous year.',
    'No current official cancellation matches the sweeping claim.',
    'An unverified repost uses official-looking branding.',
    'An outdated document is presented as a current nationwide policy.',
  ),
  Pattern(
    CaseKind.post,
    Verdict.approve,
    'Government',
    'Bayanihan fair this weekend',
    'FYI! The fictional Barangay {area} volunteer fair opens {day}. Free admission—details on the official board.',
    '📆 LOCAL EVENT',
    'Published notice',
    'The original bulletin confirms the dates and free admission.',
    'The details match the currently posted announcement.',
    'This community page accurately quotes the bulletin.',
    'Reliable sources can confirm an announcement even when it spreads widely.',
  ),
  Pattern(
    CaseKind.post,
    Verdict.reject,
    'Government',
    'Official relief payout?',
    'ALL residents automatically get ₱{amount} today. Click {link} to “claim” before midnight.',
    '💸 EASY MONEY',
    'A fabricated claim',
    'The real fictional barangay bulletin has no such payout.',
    'An urgent reward claim is paired with an impersonating link.',
    'The account has no affiliation with the named agency.',
    'Treat false government-benefit claims as deceptive, not as genuine assistance.',
  ),
  Pattern(
    CaseKind.post,
    Verdict.approve,
    'Drag Race',
    'Unpopular opinion on the runway',
    'Not gonna lie, {queen} looked so shady this episode 😭 but that made amazing TV. Still a talented queen.',
    '👑 RUNWAY RECAP',
    'Fan commentary',
    'The author openly describes their own reaction, not a fabricated quote.',
    'This is non-threatening criticism of a fictional TV persona.',
    'An ordinary fan account sharing an opinion.',
    'Unpopular opinions and entertainment criticism are not automatically abuse.',
  ),
  Pattern(
    CaseKind.post,
    Verdict.reject,
    'Drag Race',
    '“Leaked quote” about a queen',
    'EXPOSED! {queen} supposedly said this about fans. Here is a suspicious screenshot—cancel them NOW!',
    '📸 FAKE QUOTE',
    'Manipulated screenshot',
    'A comparison with the original clip shows the quote was added later.',
    'The caption presents a fabricated statement as genuine.',
    'Repost account has no direct source for the quote.',
    'A manipulated quotation is deceptive even if many users are angry.',
  ),
  Pattern(
    CaseKind.post,
    Verdict.approve,
    'Basketball memorial',
    'A respectful sports tribute',
    'Remembering a young basketball talent. Please give the family privacy and verify photos before sharing. 🕊️',
    '🏀 FAN TRIBUTE',
    'Community remembrance',
    'The post clearly expresses sympathy and does not invent facts.',
    'It asks for privacy, not money or viral speculation.',
    'A memorial fan page is not automatically impersonation.',
    'Respectful tributes are different from deceptive memorial content.',
  ),
  Pattern(
    CaseKind.post,
    Verdict.reject,
    'Basketball memorial',
    'Sensational edited memorial image',
    'SHOCKING NEW PHOTO! Someone edited this old basketball image and claims it is new evidence. Share this everywhere!',
    '🖼️ ALTERED PHOTO',
    'Fictional athlete',
    'The image matches an older photo but has been digitally modified.',
    'The sensational claim is unsupported and misrepresents a tragedy.',
    'The uploader does not provide a verifiable original source.',
    'Do not spread manipulated imagery about real-world tragedies.',
  ),
  Pattern(
    CaseKind.post,
    Verdict.approve,
    'Campus',
    'Class suspension confirmed',
    'Confirmed: Classes in fictional North Campus pause {day} due to scheduled maintenance. Link to the campus portal is in the notice.',
    '🏫 ADVISORY',
    'School bulletin',
    'The notice exists in the campus’s fictional verified archive.',
    'Date, scope and reason match the original announcement.',
    'The bulletin account is linked on the campus portal.',
    'A real announcement should be approved even if commenters doubt it.',
  ),
  Pattern(
    CaseKind.post,
    Verdict.approve,
    'Campus',
    'Pahabol na annoucement!',
    'Pahabol lang sa annoucement: open ang library {day}! Sorry sa typo 😅 Official campus notice is linked below.',
    '📚 LIBRARY HOURS',
    'Minor typo in real notice',
    'The original verified school calendar confirms the library hours.',
    'The author misspells a word but correctly quotes the real notice.',
    'The account was linked on the campus community directory.',
    'Typos and informal Filipino are not reliable proof of misinformation.',
  ),
  Pattern(
    CaseKind.post,
    Verdict.reject,
    'Campus',
    'WALANG PASOK EVERYWHERE!',
    'OMG nationwide no classes {day}!! Screenshot from an old campus advisory—forward to all GCs!',
    '📣 VIRAL SCREENSHOT',
    'Incorrect scope',
    'The old screenshot concerns one campus only, not every school.',
    'The new caption changes the scope and date.',
    'The uploader copied an old advisory.',
    'Missing context can mislead as much as an entirely false image.',
  ),
  Pattern(
    CaseKind.profile,
    Verdict.approve,
    'Government',
    'New community bulletin account',
    'This official community page was launched recently to post neighborhood announcements.',
    '🏘️ BARANGAY BULLETIN',
    'About • Created 2 days ago',
    'The fictional barangay’s existing verified website links to this exact new account.',
    'Its first posts match the public notices.',
    'It is newly created but independently listed as official.',
    'An account being two days old is not enough to prove impersonation.',
  ),
  Pattern(
    CaseKind.profile,
    Verdict.reject,
    'Government',
    'Benefits Desk • verified?',
    'Claims to be an official government benefits page. It asks for citizens’ wallet PINs via private messages.',
    '🏛️ BENEFITS DESK',
    'About • Created 3 years ago',
    'The original agency directory lists a different official account.',
    'The account asks for sensitive wallet credentials.',
    'Its long history and high follower count do not establish legitimacy.',
    'Older accounts can be compromised or used to impersonate organizations.',
  ),
  Pattern(
    CaseKind.profile,
    Verdict.approve,
    'Drag Race',
    '{queen} Fan Vault',
    'A clearly labeled fan page posting memes, fancams, and episode reactions.',
    '👑 FAN ACCOUNT',
    'Bio • Unofficial fan page',
    'The bio explicitly says this is an unofficial fan account.',
    'No attempt to collect sensitive data or pretend to be the queen.',
    'A newer account with an ordinary fan purpose.',
    'A fan account may be legitimate if it does not deceive users.',
  ),
  Pattern(
    CaseKind.profile,
    Verdict.reject,
    'Drag Race',
    'Official {queen} Giveaways',
    'Uses a performer’s photo and claims to be their official manager, asking for verification codes to claim prizes.',
    '🎁 VIP REWARD',
    'Bio • Official manager?',
    'The performer’s official profile identifies no such manager account.',
    'The profile directs people to a fake claim form.',
    'A matching photo is not proof of identity.',
    'Impersonation relies on copied identities, not just suspicious account age.',
  ),
  Pattern(
    CaseKind.profile,
    Verdict.approve,
    'Campus',
    'Campus Photography Club',
    'Small student organization page sharing photos and event reminders.',
    '📷 STUDENT CLUB',
    'About • 2-day-old page',
    'A school activity roster independently confirms the club.',
    'There are no fabricated official claims or hidden payment requests.',
    'A new profile can be legitimate even with few followers.',
    'Treat age and follower count as clues, not verdicts.',
  ),
  Pattern(
    CaseKind.profile,
    Verdict.reject,
    'Campus',
    'Registrar Help Center 24/7',
    'An account claims to unlock grades for a fee and requests student logins.',
    '📄 STUDENT SERVICES',
    'About • 2-year-old page',
    'No registrar office lists this account as an approved contact.',
    'The account collects passwords through an unsolicited form.',
    'A polished profile and old creation date can still conceal a fraud.',
    'Identity verification should come from an independent trusted source.',
  ),
  Pattern(
    CaseKind.sms,
    Verdict.approve,
    'Shopping',
    'Your bookstore pickup is ready',
    'Hi {who}, your prepaid textbook order #482 is ready for pickup at the shop counter. No action required.',
    '📦 BOOKSTORE',
    'From saved store contact',
    'The purchase appears in the user’s own order history.',
    'Message contains no new link, payment request or OTP request.',
    'This is the saved store number from a prior purchase.',
    'A legitimate notification may arrive by SMS.',
  ),
  Pattern(
    CaseKind.sms,
    Verdict.approve,
    'Shopping',
    'Order payment confirmed',
    'Payment of ₱{amount} to the bookshop is confirmed in your *own* shopping app. Thank you!',
    '🧾 RECEIPT',
    'From an expected order',
    'The transaction matches a purchase the user made independently in the official app.',
    'A payment amount in a text is not by itself a scam.',
    'The sender matches the saved merchant conversation.',
    'Do not reject every message that mentions money.',
  ),
  Pattern(
    CaseKind.sms,
    Verdict.reject,
    'Delivery',
    'URGENT parcel reschedule',
    'Delivery failed! Pay ₱{amount} to avoid return: {link}. Your parcel expires in 8 minutes.',
    '🚚 DELIVERY',
    'Unknown sender',
    'The link is not affiliated with the courier’s verified service.',
    'The official courier app shows no failed delivery.',
    'Urgency and an unexpected outside payment channel combine into a strong warning.',
    'Fake delivery fees lure users to imitation sites.',
  ),
  Pattern(
    CaseKind.sms,
    Verdict.reject,
    'Rewards',
    'WINNER KA!',
    'Congrats {who}! You won a mobile-load prize. Reply with your one-time code to release your reward.',
    '🎉 PRIZE',
    'Unknown promo contact',
    'The provider has no matching promotion on its official channel.',
    'The text requests an OTP, which should never be disclosed.',
    'This promotional sender is not verified by the provider.',
    'An OTP request makes this offer unsafe—not the spelling or punctuation.',
  ),
  Pattern(
    CaseKind.sms,
    Verdict.approve,
    'Campus',
    'Contribution reminder',
    'Club meeting {day}: optional ₱{amount} printing contribution. Details on the official club board; no payment link in this text.',
    '🎨 SCHOOL CLUB',
    'Saved club GC',
    'The original club announcement confirms the voluntary contribution.',
    'It does not demand a code or urgent outside payment.',
    'Sender is a known club representative in the existing GC.',
    'A genuine contribution request is not automatically a scam.',
  ),
  Pattern(
    CaseKind.sms,
    Verdict.reject,
    'Family',
    'Unexpected “Tito” message',
    'New phone. It is your Tito. Transfer ₱{amount} NOW to my new account and do not call me back.',
    '☎️ FAMILY',
    'Unknown number',
    'A previously saved number was not used, and the identity cannot be confirmed.',
    'The sender refuses independent verification and demands money.',
    'Pressure, secrecy and unfamiliar account details are red flags.',
    'Confirm urgent requests through a known contact channel.',
  ),
  Pattern(
    CaseKind.email,
    Verdict.approve,
    'Scholarships',
    'Your application receipt',
    'Hello {who}, your scholarship application was received. View your status in the portal you already used; no action required by email.',
    '📩 RECEIPT',
    'Institutional mailbox',
    'The same reference number appears in the applicant’s already-open official portal.',
    'It does not request a password or an unexpected fee.',
    'The message belongs to an existing, verified correspondence.',
    'Not every scholarship email is phishing.',
  ),
  Pattern(
    CaseKind.email,
    Verdict.reject,
    'Scholarships',
    'You are GUARANTEED ₱{amount}!',
    'Congrats! Everyone qualifies! Open {link} and provide your school password to claim by midnight.',
    '🎓 GRANT OFFER',
    'Imitation scholarship address',
    'The address is not affiliated with the real school portal.',
    'The email asks for a password via an unexpected link.',
    'The sender mimics a school office but fails independent verification.',
    'Phishing can target people using legitimate benefit themes.',
  ),
  Pattern(
    CaseKind.email,
    Verdict.approve,
    'Shopping',
    'Digital receipt • ₱{amount}',
    'Thank you for buying tickets to a fictional local arts show. Attached is the receipt for your existing booking.',
    '🎫 E-TICKET',
    'Saved merchant thread',
    'Booking details match the order purchased through the official box office.',
    'This is a receipt, not a request to pay again.',
    'The message is in an existing conversation with the vendor.',
    'Money, receipts and attachments are not automatically malicious.',
  ),
  Pattern(
    CaseKind.email,
    Verdict.reject,
    'Government',
    'URGENT account suspension',
    'Government support access expires tonight. Confirm wallet password at {link} or the benefit will be cancelled.',
    '🔒 SUSPENSION',
    'Unrecognized agency sender',
    'The fictional agency site lists no suspension and no such address.',
    'It demands secret credentials outside the verified government portal.',
    'Sender uses an imitation identity.',
    'Urgency plus credential capture supports a phishing determination.',
  ),
  Pattern(
    CaseKind.email,
    Verdict.approve,
    'Work',
    'Volunteer schedule update',
    'Hi {who}, you are assigned to the barangay volunteer orientation {day}. Reply only if your availability changed.',
    '📆 ORIENTATION',
    'Existing thread',
    'The volunteer roster confirms the invitation and schedule.',
    'No unusual requests or new links appear.',
    'Message comes from the established organizer conversation.',
    'Some ordinary messages are boring—and that is fine.',
  ),
  Pattern(
    CaseKind.email,
    Verdict.reject,
    'Drag Race',
    'Exclusive queen meet-and-greet',
    'Get backstage access to {queen}! Send ID photos and account password to reserve your slot at {link}.',
    '💌 VIP ACCESS',
    'Spoofed fan-club address',
    'The fictional performer’s official venue listing has no such promotion.',
    'It requests passwords and sensitive documents unrelated to tickets.',
    'The sender is not an approved venue or fan club.',
    'A convincing fandom theme can be used to impersonate an organizer.',
  ),
  Pattern(
    CaseKind.report,
    Verdict.approve,
    'Drag Race',
    '“Her attitude is good TV!”',
    'Reported: A fan writes “{queen} is so dramatic this week. I hated that runway but love the chaos 😂.”',
    '👑 REPORTED RANT',
    'Complaint: “Hate speech!”',
    'The full thread contains critical opinion about a fictional performance, not threats.',
    'The report reflects disagreement with the opinion.',
    'The content does not encourage harassment or disclosure of personal information.',
    'Dislike and criticism are not the same as harassment.',
  ),
  Pattern(
    CaseKind.report,
    Verdict.reject,
    'Drag Race',
    'Dogpile an account',
    'Reported: “Everyone mass-tag {queen} all day until they delete their page. Send threats in every comment!”',
    '🚩 TARGETED HARASSMENT',
    'Complaint: “Coordinated targeting”',
    'The original comment explicitly encourages targeted harassment.',
    'The call to harass is not necessary to express criticism.',
    'It mobilizes an online pile-on rather than discussing the episode.',
    'Criticism is allowed; coordinated harassment is not.',
  ),
  Pattern(
    CaseKind.report,
    Verdict.approve,
    'Government',
    'Public spending rant',
    'Reported: “Bakit walang repair sa kalsada natin? We deserve an itemized accounting of the barangay budget!”',
    '🏛️ CIVIC DISCUSSION',
    'Complaint: “Against officials”',
    'The post requests accountability rather than inventing an event.',
    'Strong criticism of public services is legitimate civic speech.',
    'No private information or harassment is shared.',
    'Political disagreement alone is not a reason for removal.',
  ),
  Pattern(
    CaseKind.report,
    Verdict.reject,
    'Government',
    'Fabricated official quote',
    'Reported: Viral graphic attributes a made-up corruption confession to a fictional mayor. No original recording exists.',
    '📰 FALSE QUOTE',
    'Complaint: “Misleading image”',
    'The alleged original quote is absent from the unedited record.',
    'The image is altered to present a fabricated admission as fact.',
    'The report includes a comparison with the unedited public statement.',
    'Fabricated evidence differs from expressing a political opinion.',
  ),
  Pattern(
    CaseKind.report,
    Verdict.approve,
    'Basketball memorial',
    'Respectful tribute reported',
    'Reported: “Please stop posting altered photos of young athletes. Let families grieve privately.”',
    '🏀 RESPECTFUL MESSAGE',
    'Complaint: “Too emotional”',
    'The complete post expresses concern without targeting anyone.',
    'Disagreement with a memorial message is not itself a policy violation.',
    'It discourages spreading manipulated imagery.',
    'Moderate behavior and verifiable claims, not emotional tone.',
  ),
  Pattern(
    CaseKind.report,
    Verdict.reject,
    'Basketball memorial',
    'Fake memorial fundraiser',
    'Reported: A page impersonates a fictional athlete’s family and claims an unauthorized memorial donation account.',
    '🕊️ FALSE FUNDRAISER',
    'Complaint: “Impersonation”',
    'The family’s public notice says this fundraising account is not theirs.',
    'Donation requests use the impersonated identity.',
    'The account is not linked by any family representative.',
    'Impersonating a grieving family to solicit money is deceptive.',
  ),
  Pattern(
    CaseKind.video,
    Verdict.approve,
    'Drag Race',
    'Reaction is staged for comedy',
    'Clip: A fictional drag queen performs an exaggerated side-eye during a comedy challenge. Clearly labelled TV commentary.',
    '🎥 REACTION CLIP',
    'Caption: “Good TV!”',
    'The clip is from a public performance with the same context.',
    'No invented event or claim is presented as fact.',
    'The uploader openly labels the clip as an edited reaction.',
    'Stylized editing and drag performance are not automatically deception.',
  ),
  Pattern(
    CaseKind.video,
    Verdict.reject,
    'Drag Race',
    'Fake apology clip',
    'Viral clip claims {queen} admitted cheating. A voiceover was added to the original interview without disclosure.',
    '🎞️ ADDED AUDIO',
    'Claim: “Real confession!”',
    'The unaltered interview has different audio.',
    'The clip presents edited dialogue as genuine confession.',
    'The source is a repost with no matching original quote.',
    'Manipulated audio misrepresents what a person said.',
  ),
  Pattern(
    CaseKind.video,
    Verdict.approve,
    'AI satire',
    'Clearly labelled AI parody',
    'Video labelled “AI-generated parody” shows fictional robots running a barangay talent contest. No real person impersonated.',
    '🤖 AI COMEDY',
    'Visible label: AI PARODY',
    'The uploader consistently discloses synthetic content.',
    'The scene is obviously fictional and makes no false factual claim.',
    'The creator is identified as a comedy page.',
    'AI-generated media is not automatically prohibited when transparently presented.',
  ),
  Pattern(
    CaseKind.video,
    Verdict.reject,
    'Government',
    'Fake government endorsement',
    'Video uses synthesized speech to imitate a fictional city official and urge viewers to visit {link} for cash payouts.',
    '🗣️ FAKE ENDORSEMENT',
    'Claim: “Official announcement”',
    'The actual fictional city channel has no matching statement.',
    'A reconstructed voice promotes an unauthorized payout site.',
    'The uploader cannot substantiate the official endorsement.',
    'False official endorsements can deceive viewers regardless of visual quality.',
  ),
  Pattern(
    CaseKind.video,
    Verdict.approve,
    'Government',
    'Real community safety notice',
    'Original clip from the fictional Barangay {area} channel explains updated traffic detours for {day}.',
    '🚧 COMMUNITY VIDEO',
    'Published full recording',
    'The unedited recording matches the public advisory.',
    'The timing and details align with the official notice.',
    'The uploader is linked in the barangay directory.',
    'A legitimate video can be verified using source and context.',
  ),
  Pattern(
    CaseKind.video,
    Verdict.reject,
    'Basketball memorial',
    'Out-of-context sports clip',
    'A recycled sports training clip is captioned as “new shocking footage.” The date and location were removed.',
    '🏀 OLD FOOTAGE',
    'Wrong caption',
    'The original recording is from an unrelated practice season.',
    'The caption invents a connection to a recent memorial conversation.',
    'No credible outlet confirms the claimed relationship.',
    'Out-of-context footage can deceive without being AI-generated.',
  ),

  // ---- v11: timely Philippine scenarios (all fictional) ----
  Pattern(
    CaseKind.post,
    Verdict.approve,
    'Government',
    'FOI request for the flood wall',
    'Thread: nag-file kami ng FOI request para sa itemized costs ng flood wall sa {area}. Nasa baba ang public project list at ang request receipt. Mag-uupdate kami kapag may sagot.',
    '📑 FOI REQUEST',
    'Civic accountability',
    'The project list and the request receipt both match what the post says.',
    'The post asks for documents; it accuses no one of a crime it cannot support.',
    'A local watchdog page that posts its sources.',
    'Asking for accountability with receipts is legitimate civic speech.',
  ),
  Pattern(
    CaseKind.post,
    Verdict.reject,
    'Government',
    'GHOST PROJECT sa {area}?!',
    'GHOST PROJECT! Walang flood wall, puro damo lang!! Saan napunta ang pera?? Share para mabisto!',
    '🌾 EMPTY LOT PHOTO',
    'Wrong location',
    'The photo was taken in a different barangay two weeks ago; the public inspection report shows the wall in {area} is complete.',
    'Corruption is a real concern, but this picture does not show the place it names.',
    'The uploader cites no document for the claim.',
    'Valid anger needs accurate evidence. A photo of the wrong place is not proof.',
  ),
  Pattern(
    CaseKind.post,
    Verdict.reject,
    'Weather',
    'LIVE: baha sa {area} NGAYON',
    'Hanggang bubong na ang baha sa {area} ngayon!! Pa-share para makita ng lahat.',
    '🌊 FLOOD PHOTO',
    'Recycled disaster photo',
    'The photo first appeared years ago during a different storm in another city.',
    'The weather bureau lists no flood warning for {area} today.',
    'The page re-posts dramatic disaster photos often.',
    'Old disaster photos return every storm season and cause needless panic.',
  ),
  Pattern(
    CaseKind.post,
    Verdict.approve,
    'Weather',
    'Weather bulletin summary',
    'Ayon sa weather bureau, Signal No. 2 sa ilang lugar ngayong gabi. Link sa mismong bulletin sa baba.',
    '⛈️ WEATHER BULLETIN',
    'Matches the bureau',
    'The bulletin lists the same signal and areas.',
    'The post links the original bulletin and adds no extra claims.',
    'A local news page with a record of corrections.',
    'A report that matches the official bulletin is solid, whoever posts it.',
  ),
  Pattern(
    CaseKind.video,
    Verdict.reject,
    'Health',
    'Doctor “testimonial” for a capsule',
    'A well-known fictional physician seems to say a herbal capsule cures every lung illness. The lip movement and voice do not match.',
    '💊 AI TESTIMONIAL',
    'Claim: “Doc says so”',
    'The physician’s own page says this is an AI edit and the original talk was about handwashing.',
    'A trusted face is used to sell a product with no disclosure.',
    'The seller page was created last week.',
    'AI can copy a face and voice. A trusted face selling a cure needs a check with the person’s own page.',
  ),
  Pattern(
    CaseKind.video,
    Verdict.approve,
    'AI satire',
    'Labeled AI art reel',
    'A reel of AI-generated jeepneys flying over a city, labeled “AI art” by the creator, with the prompt in the caption.',
    '🎨 AI ART',
    'Visible label',
    'The creator labels the work and does not present it as news.',
    'Nobody real is imitated and no event is claimed.',
    'An art account with a clear bio.',
    'AI art is fine when it is clearly presented as art.',
  ),
  Pattern(
    CaseKind.sms,
    Verdict.reject,
    'Jobs',
    'Part-time “like and earn” job',
    'Hi {who}! ₱{amount}/day lang sa pag-like ng videos. Magdeposito muna ng ₱1,000 para ma-activate ang account.',
    '💼 ONLINE JOB',
    'Unknown number',
    'No employer lists this offer, and legitimate jobs do not charge you to start.',
    'Easy money plus an upfront deposit is a classic task scam.',
    'The number found you without any application.',
    'Never pay to start a job. Report and block.',
  ),
  Pattern(
    CaseKind.sms,
    Verdict.approve,
    'Shopping',
    'Login code you just requested',
    'Your login code is 482 910. Never share it with anyone, not even staff. If you did not request this, ignore it.',
    '🔐 LOGIN CODE',
    'Saved wallet sender',
    'You tapped “Log in” in the app a minute ago and the sender is the saved wallet name.',
    'The code is not requested from you; it is only delivered.',
    'The message warns you not to share the code.',
    'Getting a code you asked for is normal. The danger is giving it to someone else.',
  ),
  Pattern(
    CaseKind.sms,
    Verdict.reject,
    'Entertainment',
    'Concert tickets via DM',
    'Last 2 VIP tickets, 50% off! Bayad muna sa e-wallet para ma-reserve, ipapadala ko ang QR.',
    '🎟️ TICKET RESALE',
    'Unknown seller',
    'The official ticketing site says tickets are sold only on its own page.',
    'Several buyers report paying and being blocked.',
    'The seller account is new and reuses the same QR image.',
    'Sold-out concerts attract scammers. Buy only from the official seller.',
  ),
  Pattern(
    CaseKind.profile,
    Verdict.reject,
    'Shopping',
    'Support • verified ✔',
    'A newly created page with a paid badge claims to be customer care and asks people to DM their OTP.',
    '🎧 FAKE SUPPORT',
    'About • Created 4 days ago',
    'The company says support is handled only inside its app and its listed account.',
    'The page asks for a one-time code, which real support never needs.',
    'A badge can be bought. It does not prove identity.',
    'A badge is not a directory. Check the company’s own list of accounts.',
  ),
  Pattern(
    CaseKind.profile,
    Verdict.approve,
    'Government',
    'New handle announced by the old page',
    'A new account for a barangay office says it replaced the old handle. The old account’s pinned post announces the move.',
    '🏘️ NEW HANDLE',
    'About • Created 5 days ago',
    'The old official page and the city website both link to the new account.',
    'Both accounts point to each other and nothing asks for money.',
    'New does not mean fake when the old official page vouches for it.',
    'A brand-new account can be the real one when trusted sources confirm it.',
  ),
  Pattern(
    CaseKind.report,
    Verdict.approve,
    'Entertainment',
    'Fandom roast, not harassment',
    'Reported: “Overrated ang comeback nila at bagsak ang choreo. Pero mahal ko pa rin ang fans, mababait sila.”',
    '🎤 FANDOM OPINION',
    'Complaint: “Hate speech!”',
    'The comment criticizes a music video and nobody’s identity.',
    'There are no threats, slurs or personal details.',
    'An ordinary fan account sharing an opinion.',
    'Disliking a comeback is not harassment, however loud the fandom reacts.',
  ),
  Pattern(
    CaseKind.report,
    Verdict.reject,
    'Campus',
    'Doxxing a student',
    'Reported: A comment posts a student’s home address and says “puntahan natin siya ngayong gabi.”',
    '📍 DOXXING',
    'Complaint: “Private info”',
    'The comment shares a private address and urges people to go there.',
    'This exposes a person to physical harm and is not criticism.',
    'The poster organizes others to target one student.',
    'Sharing private details to target someone is never allowed.',
  ),
  Pattern(
    CaseKind.email,
    Verdict.reject,
    'Campus',
    'New bank details for tuition',
    'The accounting office says its old bank account is closed and asks you to send tuition to a new account number. Reply-to is a different address.',
    '🏦 PAYMENT CHANGE',
    'Sender looks right, reply-to differs',
    'The school’s portal lists only the original payment channels.',
    'The reply-to address does not match the school domain.',
    'The sender name copies the accounting office.',
    'Changes to payment details by email are a classic scam. Confirm through the school directly.',
  ),
  Pattern(
    CaseKind.email,
    Verdict.approve,
    'Campus',
    'Enrollment closes Friday',
    'Reminder from the registrar: enrollment closes this Friday, 5PM. Finish on the school portal you already use. We never ask for your password by email.',
    '⏰ DEADLINE',
    'Registrar address',
    'The school portal lists the same deadline and the link points to the school’s own domain.',
    'It is urgent, but the deadline is real and it asks for no password.',
    'The sender is the registrar’s official address.',
    'Urgent does not mean fake. Check whether the deadline and domain are real.',
  ),
  Pattern(
    CaseKind.video,
    Verdict.approve,
    'Government',
    'Short cut, full video linked',
    'A 20-second clip of a council answer, cut from a livestream. The caption links the full video and the question is included.',
    '✂️ SHORT CUT',
    'Full video linked',
    'The full recording says the same thing, with the question and answer intact.',
    'Trimming did not change the meaning and the source is linked.',
    'A local news page that links full recordings.',
    'Short clips are normal. What matters is whether the cut changes the meaning.',
  ),
  Pattern(
    CaseKind.video,
    Verdict.reject,
    'Government',
    '“Wala akong pakialam” clip',
    'A clip cuts a mayor’s answer so he seems to say he does not care about flood victims. The reporter’s question and his denial are removed.',
    '✂️ CUT CONTEXT',
    'Caption: “Heto ang tunay na ugali”',
    'The full interview shows he was repeating a rumor and then denying it.',
    'The kept words are real but the meaning is reversed.',
    'The page posts only angry edits about officials.',
    'Trimming away the question can reverse a meaning. Look for the full recording.',
  ),
  Pattern(
    CaseKind.post,
    Verdict.reject,
    'Election',
    '“Partial count” screenshot',
    'Kap. Reyes lamang daw ng 90%! Dinaya ang kalaban. Screenshot ng bilangan ang nakalakip.',
    '🗳️ RESULTS SCREENSHOT',
    'Old practice run',
    'The screenshot header shows a test run from an earlier election; the election office says no results are out.',
    'Fake results spread fast because people are emotional.',
    'The uploader cites no official release.',
    'Only the election office’s own release counts as results.',
  ),
  Pattern(
    CaseKind.post,
    Verdict.reject,
    'Campus',
    'Dengue: ALL schools closed',
    'BREAKING: lahat ng paaralan sa probinsya, sarado next week dahil sa dengue! Share sa GC!',
    '🦟 DENGUE NOTICE',
    'Wrong scope',
    'The real notice covers one school for two days of cleaning.',
    'Parents of other schools say classes continue.',
    'The caption stretches one notice into a province-wide claim.',
    'Misleading posts often start with something real and stretch its scope.',
  ),
];

class ShiftBundle {
  final int seed;
  final List<PlayCase> cases;
  final String modifier;
  final List<String> signatures;
  const ShiftBundle(this.seed, this.cases, this.modifier, this.signatures);
}

/// Truth-first, offline generator. The Pattern verdict is decided before
/// formatting the content and revealing evidence.
class CaseGenerator {
  final Random rng;
  CaseGenerator(int seed) : rng = Random(seed);

  static const names = [
    'Mika',
    'Nica',
    'Jules',
    'Rafi',
    'Sam',
    'Kai',
    'Ate Chai',
    'Kuya Eli',
    'Paolo',
    'Iya',
    'Tita Cora',
  ];
  static const groups = [
    'Tambayan Updates',
    'Barkada Bulletin',
    'Campus Chika',
    'Kanto Herald',
    'Community Circle',
    'Bayanihan Board',
  ];
  static const queens = [
    'Miss Talahib',
    'Queen Mariposa',
    'Madam Sarsa',
    'Diva Pinya',
    'Misis Halo-Halo',
  ];
  static const places = [
    'Malaya',
    'Liwayway',
    'Gumamela',
    'Masigla',
    'Maharlika',
  ];
  static const dates = [
    'tomorrow',
    'next Monday',
    'this weekend',
    'on Friday',
    'later today',
  ];
  static const modifiers = [
    'SOURCE SWAP',
    'FANDOM FINALE',
    'CAMPUS WEEK',
    'COMMUNITY BULLETIN',
  ];

  T choose<T>(List<T> list) => list[rng.nextInt(list.length)];
  int between(int low, int high) => low + rng.nextInt(high - low + 1);

  String _fill(String s, Map<String, String> fields) {
    var result = s;
    for (final e in fields.entries) {
      result = result.replaceAll('{${e.key}}', e.value);
    }
    return result;
  }

  String _neutralHeadline(Pattern p, Map<String, String> fields) {
    final location = fields['area']!;
    final queen = fields['queen']!;
    return switch (p.kind) {
      CaseKind.profile =>
        p.topic == 'Drag Race'
            ? 'About $queen'
            : p.topic == 'Government'
            ? '$location Community Desk'
            : 'Campus community page',
      CaseKind.sms => choose([
        'New message received',
        'A message for you',
        'Inbox notification',
      ]),
      CaseKind.email => choose([
        'A message about your account',
        'New mail received',
        'An update for you',
      ]),
      CaseKind.report => choose([
        'User report submitted',
        'Community report',
        'Reported content',
      ]),
      CaseKind.video => choose([
        'A clip is circulating',
        'Trending video',
        'Recent upload',
      ]),
      CaseKind.post => switch (p.topic) {
        'Drag Race' => '$queen: tonight\'s episode',
        'Government' => 'News from $location?',
        'Campus' => 'Campus update in the group chat',
        'Basketball memorial' => 'Courtside discussion',
        'Weather' => 'Weather talk in the barangay',
        'Election' => 'Election chatter',
        'Health' => 'Health tips going around',
        _ => 'A community post is trending',
      },
    };
  }

  /// The displayed artifact never contains verdict-spoiling labels.
  String _artwork(Pattern p) => switch (p.topic) {
    'Drag Race' => '👑 EPISODE DISCUSSION',
    'Government' => '🏛️ COMMUNITY BULLETIN',
    'Campus' => '🎓 CAMPUS BOARD',
    'Basketball memorial' => '🏀 COURTSIDE',
    'Shopping' => '🛍️ SHOPPING',
    'Delivery' => '📦 DELIVERY',
    'AI satire' => '🎬 NEW UPLOAD',
    'Weather' => '⛈️ WEATHER WATCH',
    'Health' => '🩺 HEALTH TALK',
    'Jobs' => '💼 OPPORTUNITIES',
    'Entertainment' => '🎤 FANDOM FEED',
    'Election' => '🗳️ ELECTION WATCH',
    _ => '📲 RECENT ACTIVITY',
  };

  int _ageDays(Pattern p) {
    final source = p.secondary.toLowerCase();
    if (RegExp(r'2[- ]day').hasMatch(source)) return 2;
    if (RegExp(r'3[- ]year').hasMatch(source)) return 1095;
    if (RegExp(r'2[- ]year').hasMatch(source)) return 730;
    return choose([2, 18, 130, 530, 1200, 1900]);
  }

  PlayCase build(Pattern p, String id) {
    final fields = <String, String>{
      'who': choose(names),
      'queen': choose(queens),
      'area': choose(places),
      'day': choose(dates),
      'amount': choose(['75', '250', '399', '1,200', '2,500']),
      'link':
          '${choose(['parcel-check', 'cash-help', 'verify-account', 'claim-now', 'campus-awards'])}.example',
    };
    final age = _ageDays(p);
    final followers = age <= 5
        ? between(30, 1800)
        : age < 200
        ? between(120, 7000)
        : age < 1000
        ? between(400, 22000)
        : between(1000, 85000);
    final author = p.kind == CaseKind.profile
        ? _fill(p.title, fields)
        : p.kind == CaseKind.sms
        ? choose([
            'Delivery Desk',
            'Bookshop Service',
            'Text Updates',
            'Class GC',
            'Unknown Number',
          ])
        : p.kind == CaseKind.email
        ? choose([
            'Campus Mail',
            'Event Services',
            'Helpdesk',
            'Community Mail',
          ])
        : p.topic == 'Drag Race'
        ? choose(['Runway Tea PH', 'Untucked Tambayan', 'Barkada Feed'])
        : p.topic == 'Basketball memorial'
        ? choose(['Courtside Community', 'Hoops and Heart'])
        : choose(groups);
    final normalized = author.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
    final handle =
        '@${normalized.substring(0, min(16, normalized.length))}${choose(['ph', 'daily', 'hq', ''])}';
    final sourceText = _fill(p.source, fields);
    // Free hints create questions, not answers. A lookup must be purchased
    // to reveal the decisive independent source.
    final clues = <Hotspot>[
      Hotspot(
        'identity',
        'ACCOUNT DETAILS',
        p.kind == CaseKind.profile
            ? 'This page is $age days old with $followers followers. Who confirms its identity?'
            : 'Sender: $author. Display names can be copied; independently verify their identity.',
        Icons.account_circle_outlined,
        signal: EvidenceSignal.ambiguous,
        principle: 'identity_needs_corrob',
      ),
      Hotspot(
        'context',
        'READ THE CONTEXT',
        p.kind == CaseKind.report
            ? 'The queue shows reported content, but the report count cannot establish a violation.'
            : p.kind == CaseKind.sms || p.kind == CaseKind.email
            ? 'The message claims: ${_fill(p.title, fields)}. Can you corroborate it through a known account?'
            : p.kind == CaseKind.post
            ? 'The claim concerns ${p.topic.toLowerCase()} and mentions ${fields['day']}. Compare the full original.'
            : p.kind == CaseKind.profile
            ? 'Look at the account description and history: ${_fill(p.title, fields)}.'
            : 'What does the uncropped original clip actually show?',
        Icons.content_paste_search_outlined,
        signal: EvidenceSignal.neutral,
        principle: 'surface_cues_not_truth',
      ),
      Hotspot(
        'source',
        'VERIFY INDEPENDENTLY',
        sourceText,
        Icons.fact_check_outlined,
        signal: p.verdict == Verdict.reject
            ? EvidenceSignal.suspicious
            : EvidenceSignal.supporting,
        strength: 3,
        verification: true,
        principle: 'independent_source',
      ),
    ];
    final isNew = age <= 7;
    final verified = p.kind == CaseKind.profile
        ? (p.verdict == Verdict.approve && !isNew && rng.nextBool())
        : rng.nextInt(5) == 0;
    var message = _fill(p.body, fields);
    // The original audit found verdicts leaked through narration.
    // Remove explicit adjudication labels; keep user-visible suspicious *claims*.
    message = message
        .replaceAll('fake claim form', 'claim form')
        .replaceAll('fake payout', 'payout')
        .replaceAll('fake screenshot', 'shared screenshot')
        .replaceAll('A page impersonates', 'A page claims to represent')
        .replaceAll(
          'A voiceover was added to the original interview without disclosure.',
          'People disagree about what the clip says.',
        )
        .replaceAll('fabricated', 'shared')
        .replaceAll(
          'This old screenshot is proof.',
          'A screenshot is being shared.',
        )
        .replaceAll(
          'No action required.',
          'You can check your order if needed.',
        );
    final secondary = p.kind == CaseKind.profile
        ? 'Joined ${age <= 7
              ? '$age days'
              : age < 365
              ? '${(age / 30).round()} months'
              : '${(age / 365).round()} years'} ago'
        : _fill(p.secondary, fields)
              .replaceAll('FAKE', 'RECENT')
              .replaceAll('FALSE', 'REPORTED')
              .replaceAll('Manipulated screenshot', 'Shared screenshot');
    final archetypeId = '${p.kind.index}:${patterns.indexOf(p)}';
    final variant =
        '$archetypeId|${fields['queen']}|${fields['area']}|${fields['day']}|${fields['amount']}';
    return PlayCase(
      id: id,
      archetypeId: archetypeId,
      kind: p.kind,
      correct: p.verdict,
      topic: p.topic,
      author: author,
      handle: handle,
      headline: _neutralHeadline(p, fields),
      body: message,
      artifact: _artwork(p),
      secondary: secondary,
      timestamp: choose(['now', '8m', '21m', '1h']),
      accountAge: '$age days ago',
      ageDays: age,
      followers: followers,
      likes: between(3, 12000),
      reports: between(0, 100),
      verified: verified,
      clues: clues,
      rationale: _fill(p.lesson, fields),
      variant: variant,
      tier: p.kind == CaseKind.post ? 1 : 2,
    );
  }

  ShiftBundle generate(
    int shift, {
    required int seed,
    bool endless = false,
    int count = 7,
    Set<String> recent = const {},
    List<PlayCase> callbacks = const [],
    int safety = 80,
    int fairness = 80,
  }) {
    final allowedKinds = endless
        ? CaseKind.values
        : shifts[(shift - 1).clamp(0, 5).toInt()].kinds;
    final allowed = patterns
        .where((p) => allowedKinds.contains(p.kind))
        .toList();
    final chosen = <PlayCase>[];
    final picked = <String>{};
    final signatures = <String>[];
    final modifier = choose(modifiers);
    // The source archetype (not cosmetic text) is deduplicated per shift.
    for (final callback in callbacks.take(1)) {
      chosen.add(callback);
      picked.add(callback.archetypeId);
      signatures.add(callback.archetypeId);
    }
    final firstGenerated = chosen.length;
    for (int i = chosen.length; i < count; i++) {
      final need = i == firstGenerated
          ? Verdict.approve
          : i == firstGenerated + 1
          ? Verdict.reject
          : null;
      final options = allowed.where((p) {
        final sig = '${p.kind.index}:${patterns.indexOf(p)}';
        return !picked.contains(sig) && (need == null || p.verdict == need);
      }).toList();
      if (options.isEmpty) break;
      // A low Safety meter brings more deception reports next shift;
      // low Fairness brings more legitimate posts and appeals to review.
      final biased = safety < 55
          ? options.where((p) => p.verdict == Verdict.reject).toList()
          : fairness < 55
          ? options.where((p) => p.verdict == Verdict.approve).toList()
          : <Pattern>[];
      final categoryPool = biased.isNotEmpty && rng.nextInt(100) < 50
          ? biased
          : options;
      final themed = switch (modifier) {
        'FANDOM FINALE' =>
          categoryPool.where((p) => p.topic == 'Drag Race').toList(),
        'CAMPUS WEEK' =>
          categoryPool.where((p) => p.topic == 'Campus').toList(),
        'COMMUNITY BULLETIN' =>
          categoryPool.where((p) => p.topic == 'Government').toList(),
        _ => <Pattern>[],
      };
      final weighted = themed.isNotEmpty && rng.nextInt(100) < 60
          ? themed
          : categoryPool;
      final fresh = weighted
          .where(
            (p) => !recent.contains('${p.kind.index}:${patterns.indexOf(p)}'),
          )
          .toList();
      final pool = fresh.isNotEmpty ? fresh : weighted;
      final p = choose(pool);
      final candidate = build(p, '$seed:$i');
      chosen.add(candidate);
      picked.add(candidate.archetypeId);
      signatures.add(candidate.archetypeId);
    }
    chosen.shuffle(rng);
    return ShiftBundle(seed, chosen, modifier, signatures);
  }
}
