import 'arcade_common.dart';
import '../models/arcade_models.dart';

/// An alternative way to prove the same verdict. Anything left null falls
/// back to the post's own value. Each variant must keep at least one
/// decisive check, and must not change the truth.
class _Variant {
  final String? q, photo, date, source, account;
  final Relevance? rPhoto, rDate, rSource, rAccount;
  const _Variant({
    this.q,
    this.photo,
    this.date,
    this.source,
    this.account,
    this.rPhoto,
    this.rDate,
    this.rSource,
    this.rAccount,
  });
}

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
  final List<Concept> concepts;
  final String ruleOfThumb;
  final List<_Variant> variants;
  const _Post(
    this.id,
    this.bad,
    this.topic,
    this.caption,
    this.bodies, {
    required this.q,
    required this.lesson,
    required this.photo,
    required this.date,
    required this.source,
    required this.replies,
    this.rPhoto = Relevance.support,
    this.rDate = Relevance.decoy,
    this.rSource = Relevance.decisive,
    this.rReplies = Relevance.support,
    this.account,
    this.rAccount = Relevance.decoy,
    this.photoLabel = 'MEDIA TRACE',
    this.concepts = const [],
    this.ruleOfThumb = '',
    this.variants = const [],
  });
}

const _posts = <_Post>[
  // ---------------------------------------------------------------- KEEP
  _Post(
    'class_real',
    false,
    'Weather',
    'Class suspension advisory',
    [
      "Walang pasok bukas sa lahat ng antas sa {city}. Sabi ng City Hall, dahil sa bagyo. Ingat po!",
      "Class suspension bukas, elementary to SHS, {city}. Naka-post na sa page ng City Hall: cityhall.example/advisories",
    ],
    q: 'Does City Hall say the same thing?',
    photo:
        "The advisory graphic uses the same layout City Hall used in earlier suspensions.",
    date: "Advisory posted today, 5:12 AM.",
    source:
        "City Hall's own page posted the same advisory: all levels suspended tomorrow.",
    replies: "Students say their school group chats got the same notice.",
    concepts: [Concept.officialSource],
    variants: [
      _Variant(
        q: 'Is this the page City Hall itself lists for advisories?',
        account:
            "Page is linked from City Hall's official website as its advisory account. Active for 8 years.",
        rAccount: Relevance.decisive,
        rSource: Relevance.support,
      ),
      _Variant(
        q: 'Do City Hall and the disaster office both list it?',
        source:
            "City Hall's page and the city disaster office both list the same advisory number and time.",
      ),
    ],
    ruleOfThumb:
        "Check the official page for advisories. A real advisory is not misinformation.",
    rDate: Relevance.support,
    lesson:
        "Even a small or brand-new page can share a real advisory. The City Hall's own page matched it.",
  ),
  _Post(
    'flood_critic',
    false,
    'Government',
    'Flooded street photo',
    [
      "P{amt}M daw ang flood wall sa Brgy. {town}, pero lubog pa rin kami kahapon. Nasaan ang liquidation report? Public funds po 'to.",
      "Ang tagal na ng flood wall project sa Brgy. {town}. Bakit hanggang tuhod pa rin ang baha? Gusto naming makita ang accounting.",
    ],
    q: 'Do the numbers it quotes match public records?',
    photo:
        "The flooded-street photo is new: taken yesterday, and a street sign shows Brgy. {town}.",
    date: "Posted the evening after the rain.",
    source:
        "The city's public project list shows a P{amt}M flood wall for Brgy. {town}. The post quotes it correctly.",
    replies:
        "Residents argue about whether the wall or the drainage is the problem. Heated, but no threats.",
    concepts: [Concept.opinionVsHarassment],
    ruleOfThumb:
        "Strong criticism is allowed when the facts it cites match public records.",
    rPhoto: Relevance.support,
    lesson:
        "Strong criticism of a public project is allowed when the facts it cites are accurate. Asking for accountability is not misinformation.",
  ),
  _Post(
    'satire_page',
    false,
    'Government',
    'Meme image',
    [
      "BREAKING: Aso sa Brgy. {town}, nahalal na Kapitan; nangakong libreng buto para sa lahat 🐶🏆",
      "LATEST: Traffic enforcer sa {city}, ginawaran ng 'Pinakamapagpasensyang Tao ng Taon' matapos ang 3 oras na traffic.",
    ],
    q: 'Who runs this page, and what do they say they post?',
    photo: "An edited meme image carrying the same page's watermark.",
    date: "Posted this morning, like the page's other jokes.",
    source:
        "No news outlet reports this, and the page posts jokes like it every day.",
    replies: "Everyone is laughing and tagging friends.",
    concepts: [Concept.satireLabel],
    ruleOfThumb: "Check the page's bio for context. Labeled satire is allowed.",
    account:
        "Page bio: \"Satire at memes lang. Walang totoo dito 😂\". Active for 3 years.",
    rAccount: Relevance.decisive,
    rSource: Relevance.support,
    lesson:
        "Labeled satire is allowed. The page's bio tells you it's a joke, so context matters.",
  ),
  _Post(
    'ai_art',
    false,
    'AI',
    'Digital artwork',
    [
      "Jeepney na lumilipad sa ibabaw ng Maynila 🚌✨ Ang ganda ng gawa ko!",
      "Binuo ko 'to gamit AI: sampaguita garden sa gitna ng EDSA. Ano sa tingin n'yo?",
    ],
    q: 'Does the creator say how it was made?',
    photo:
        "Creator tagged the image \"AI-generated\" and posted the prompt in the first comment.",
    date: "Posted today with the artist's other digital art.",
    source: "The creator's portfolio lists it under AI art, not news.",
    replies: "People ask for the prompt. Nobody thinks it's a real photo.",
    concepts: [Concept.aiGenerated],
    ruleOfThumb:
        "Look for labels indicating AI generation. AI art is acceptable when properly disclosed.",
    rPhoto: Relevance.decisive,
    rSource: Relevance.support,
    photoLabel: 'MEDIA TRACE',
    lesson:
        "AI images are fine when presented as art. The problem is passing them off as real events.",
  ),
  _Post(
    'old_valid',
    false,
    'Campus',
    'Scholarship poster',
    [
      "Reminder: Bukas pa ang {school} scholarship applications, ayon sa school portal. Check the current deadline there.",
      "Pa-share po! Sa latest {school} scholarship portal, ongoing pa ang applications. I-check ang updated deadline sa portal.",
    ],
    q: 'Is the date still current on the official page?',
    photo: "The poster is the school's own design from this term.",
    date: "The post is 3 weeks old.",
    source:
        "In this fictional case, the school's current portal confirms applications are still open this term.",
    replies:
        "Applicants confirm that the portal is still accepting applications.",
    concepts: [Concept.oldValid],
    ruleOfThumb:
        "An older post isn't automatically outdated. Check whether the information is still current.",
    rDate: Relevance.decoy,
    lesson:
        "An older post isn't automatically outdated. Check whether the information is still current.",
  ),
  _Post(
    'review_receipts',
    false,
    'Shopping',
    'Order screenshot',
    [
      "{store} seller: 11 days late ang parcel ko, tapos seen-zone pa. Hindi ko inirerekomenda 😤 Resibo ko sa comments.",
      "Warning sa mga bibili sa {store}: 2 weeks na, wala pa rin ang order ko at walang sagot. Screenshots ko po.",
    ],
    q: 'Do the receipts back up the complaint?',
    photo:
        "The order screenshot shows an order placed 11 days ago, matching the post.",
    date: "Posted after the delivery window passed.",
    source:
        "The order number in the screenshot matches the shop's own order page.",
    replies: "A few buyers had good experiences; others had the same delay.",
    concepts: [Concept.editedScreenshot],
    ruleOfThumb:
        "Check the receipts or screenshots provided. A negative review with receipts is customer feedback, not misinformation.",
    rPhoto: Relevance.decisive,
    rSource: Relevance.support,
    lesson:
        "A negative review with receipts is customer feedback. Disliking a business is not misinformation.",
  ),
  _Post(
    'flood_real',
    false,
    'Weather',
    'Flooded street',
    [
      "Baha na sa kanto namin sa Brgy. {town}, hanggang tuhod na. Mag-ingat po sa mga dadaan.",
      "Update from Brgy. {town}: umaapaw na ang estero. Iwasan muna ang Rizal St.",
    ],
    q: 'Is the photo new, and does the location match?',
    photo:
        "Photo is new: first seen today at 3:40 PM, and the street sign matches Brgy. {town}.",
    date: "Posted 20 minutes ago.",
    source:
        "The weather bureau's bulletin has a heavy-rain warning for the area today.",
    replies: "Neighbors confirm and add their own photos.",
    concepts: [Concept.recycledMedia],
    ruleOfThumb:
        "A fresh photo with a matching place and a matching official warning can be trusted.",
    rPhoto: Relevance.decisive,
    rSource: Relevance.support,
    rReplies: Relevance.support,
    rDate: Relevance.support,
    lesson:
        "A fresh, local photo with matching details can be trusted. Check where and when it was taken.",
    variants: [
      _Variant(
        q: 'Do the authorities confirm flooding there today?',
        photo:
            "No readable street sign, but nothing in the photo looks edited.",
        source:
            "The weather bureau and the city disaster office both report flooding in Brgy. {town} this afternoon.",
        rPhoto: Relevance.decisive,
        rSource: Relevance.support,
      ),
      _Variant(
        q: 'Does the photo\'s capture time match the rain?',
        photo: "Nothing looks edited, and the street looks like Brgy. {town}.",
        date:
            "The photo's capture time is 3:40 PM today, the same hour the heavy rain started.",
        rPhoto: Relevance.support,
        rDate: Relevance.decisive,
      ),
    ],
  ),
  _Post(
    'fan_hot_take',
    false,
    'Music',
    'MV screenshot',
    [
      "Hot take: mid ang bagong MV ng {group}, pero stan pa rin ako 😭 Sana mas maganda ang choreo next time.",
      "Unpopular opinion: overrated ang comeback ng {group}. Pero mahal ko pa rin sila, huwag n'yo akong i-cancel 😅",
    ],
    q: 'Is there a factual claim to check at all?',
    photo: "The screenshot is from the group's official MV.",
    date: "Posted the day of the MV release.",
    source:
        "Nothing to fact-check: it's a personal opinion about a music video.",
    replies: "Fans disagree politely. A few jokes.",
    concepts: [Concept.opinionVsHarassment],
    ruleOfThumb:
        "Distinguish between personal opinions and harassment. Constructive criticism is allowed.",
    lesson:
        "Disliking a music video is not misinformation or harassment. Opinions are allowed.",
  ),
  _Post(
    'ayuda_real',
    false,
    'Government',
    'Payout poster',
    [
      "Ayuda payout para sa registered seniors sa Brgy. {town}: bukas 8AM sa covered court. Dalhin ang valid ID at pension slip.",
      "Reminder sa mga senior ng Brgy. {town}: payout bukas 8AM, covered court. Valid ID lang ang kailangan. Detalye: brgy-{town}.example/payout",
    ],
    q: 'Do the barangay and the welfare office both list it?',
    photo: "The poster matches the one used in the barangay's earlier payouts.",
    date: "Posted the day before the payout.",
    source:
        "The barangay's page and the city welfare office both list this payout with the same time and place.",
    replies: "Seniors say they got text reminders from the barangay.",
    concepts: [Concept.linkMismatch],
    ruleOfThumb:
        "A payout post is safe when its details match the barangay's own pages and nothing asks for a fee.",
    lesson:
        "Not every ayuda post is a scam. The agency's own pages confirmed the details, and no link or fee was involved.",
  ),
  _Post(
    'weather_news',
    false,
    'Weather',
    'Weather map',
    [
      "{outlet}: Signal No. 2 sa 4 na lalawigan habang papalapit ang Bagyong Ligaya.",
      "Ayon sa {outlet}, Signal No. 2 na sa apat na lalawigan dahil sa Bagyong Ligaya. Bulletin: weatherbureau.example/bulletin",
    ],
    q: 'What does the weather bureau bulletin say?',
    photo: "A standard bulletin map, with the bureau's usual colors.",
    date: "Published within the hour of the 5 PM bulletin.",
    source:
        "The weather bureau's 5 PM bulletin lists Signal No. 2 for those same provinces.",
    replies: "People tag relatives in the affected areas.",
    concepts: [Concept.officialSource],
    ruleOfThumb:
        "Check the official bulletin for weather warnings. A news report that matches the bulletin is solid.",
    rDate: Relevance.support,
    lesson:
        "A news report that matches the official bulletin is solid. Reputation matters less than whether it checks out.",
  ),
  _Post(
    'nepo_question',
    false,
    'Government',
    'Vacation photo',
    [
      "Nag-post ang anak ni Cong. Villareal ng luxury trip habang lubog ang distrito. Hindi ko sinasabing may ninakaw, pero pwede bang ilabas ang statement of assets para malinaw?",
      "Tanong lang po: ang laki ng gastos sa bakasyon ng anak ni Cong. Villareal. Public official po siya, may karapatan tayong humingi ng transparency.",
    ],
    q: 'Does the post claim a crime, or does it ask for documents?',
    photo:
        "The vacation photo comes from the relative's own public account, posted this week.",
    date: "Posted two days after the floods, same week as the travel photos.",
    source:
        "The post makes no claim of theft. It asks for the official's published asset statement, which is a public document.",
    replies: "Supporters and critics argue; nobody posts threats.",
    concepts: [Concept.opinionVsHarassment],
    ruleOfThumb:
        "Distinguish between personal opinions and harassment. Constructive criticism is allowed.",
    rSource: Relevance.decisive,
    rPhoto: Relevance.support,
    lesson:
        "Asking an official for transparency is allowed. The post claims no crime and shows nothing doctored. Heated politics is not misinformation.",
  ),
  _Post(
    'celeb_donation',
    true,
    'Music',
    'Donation graphic',
    [
      "{group} leader nag-donate ng ₱5M sa mga biktima ng bagyo! I-share ang post na ito at makakatanggap ka ng ₱1,000 sa {wallet}!",
      "Biyaya! Sa bawat share ng post na ito, may ₱1,000 ka mula sa donation ng {group}. Comment 'SHARE' para ma-register.",
    ],
    q: 'Did the group or its agency announce a donation?',
    photo:
        "The donation graphic copies the group's logo but not its usual font; the same graphic appears on other pages.",
    date: "Posted during the typhoon news cycle.",
    source:
        "The group's agency page says it has announced no such donation or giveaway.",
    replies:
        "Many comment 'SHARE' hoping for money; nobody reports receiving any.",
    concepts: [Concept.payToReceive],
    ruleOfThumb:
        "A giveaway that pays you for sharing is bait. Check what the agency really announced.",
    rSource: Relevance.decisive,
    rPhoto: Relevance.support,
    rReplies: Relevance.support,
    lesson:
        "A donation that pays you for sharing is bait to spread a scam. Check what the person or agency has actually said.",
  ),
  _Post(
    'sk_event',
    false,
    'Campus',
    'Event poster',
    [
      "SK Youth Day sa Brgy. {town} ngayong Sabado! Libre ang sports clinic at career talk. Walang registration fee. Mag-sign up sa mismong SK table.",
      "Mga kabataan ng Brgy. {town}: SK Youth Day this Saturday, 9AM. Libre lahat. Dalhin lang ang school ID.",
    ],
    q: 'Does the barangay page confirm the event?',
    photo: "The poster matches the design the SK page used for earlier events.",
    date: "Posted four days before the event.",
    source:
        "The barangay's page lists the same event, date and 'free' note. No payment link anywhere.",
    replies: "Residents ask about parking; the SK chair answers.",
    concepts: [Concept.officialSource],
    ruleOfThumb:
        "Check the official page for event confirmations. A real event is not misinformation.",
    rSource: Relevance.decisive,
    lesson:
        "Not every event post is a scam. The barangay's own page matched it and nothing asked for money.",
  ),
  _Post(
    'fake_queen_quote',
    true,
    'Drag Race',
    'Edited screenshot',
    [
      "{queen} said it herself: 'Mga fans ko, pabigat lang kayo.' Eto ang screenshot, huwag n'yo na siyang suportahan!!",
      "EXPOSED! Eto ang tunay na sinabi ni {queen} tungkol sa fans niya. Screenshot, i-share para mabisto!",
    ],
    q: 'Does the queen\'s own page show that post?',
    photo:
        "The font in the screenshot is slightly different from the platform's, and the time stamp has an edit artifact.",
    date: "The original post time doesn't appear on {queen}'s page.",
    source:
        "{queen}'s own page has a post from that hour: 'Mahal ko ang fans ko, salamat sa 1M!'",
    replies:
        "Fans are split; one asks for the link to the original post and gets no answer.",
    concepts: [Concept.fakeQuote, Concept.editedScreenshot],
    ruleOfThumb:
        "Check the person's own page for quotes. A screenshot can be edited to misrepresent what someone said.",
    rPhoto: Relevance.decisive,
    rSource: Relevance.decisive,
    lesson:
        "Fandom drama makes edited screenshots spread. The real page says the opposite.",
  ),
  // -------------------------------------------------------------- REMOVE
  _Post(
    'recycled_flood',
    true,
    'Weather',
    'Flood photo',
    [
      "NGAYON LANG! Baha sa {city} dahil sa Bagyong Ligaya, grabe na! 😭 Pa-share para makita ng lahat.",
      "Ito na ang sitwasyon sa {city} ngayon. Hanggang bubong na ang tubig!! Ingat po lahat.",
    ],
    q: 'When did this photo first appear?',
    photo:
        "This photo first appeared in {y1}, during a different storm in another city.",
    date: "The image file dates to {y1}; the post says it's happening now.",
    source: "The weather bureau lists no flood warning for {city} today.",
    replies: "One user says: \"Taong {y1} 'yan ah, hindi 'to ngayon.\"",
    concepts: [Concept.recycledMedia],
    ruleOfThumb:
        "Check the date and location of the photo against official sources.",
    rPhoto: Relevance.decisive,
    rDate: Relevance.support,
    rSource: Relevance.support,
    lesson:
        "Old disaster photos return every storm season. A real photo can still mislead when it is shown with the wrong date and place.",
    variants: [
      _Variant(
        q: 'Does the photo itself say when it was taken?',
        photo:
            "The location is hard to tell from the photo. No readable signs or landmarks.",
        date:
            "The file's original upload date is {y1}, years before this storm. The post says it's happening now.",
        rPhoto: Relevance.decoy,
        rDate: Relevance.decisive,
      ),
      _Variant(
        q: 'Do the authorities report any flooding in {city} today?',
        photo: "The photo is too blurry to tell where it was taken.",
        date: "The post doesn't say when the photo was taken.",
        source:
            "The weather bureau shows no warning for {city} today, and the city disaster office reports no flooding.",
        rPhoto: Relevance.support,
        rDate: Relevance.decoy,
        rSource: Relevance.decisive,
      ),
    ],
  ),
  _Post(
    'fake_quote',
    true,
    'Government',
    'News card',
    [
      "SINABI NI {who}: \"Wala akong pakialam sa mga nabaha, bayaran na lang nila ang utang nila.\" Grabe 'tong taong 'to!!",
      "Eto ang tunay na ugali ni {who}. Basahin n'yo ang sinabi niya sa mga biktima 😡 SHARE!",
    ],
    q: 'Did the outlet on the card actually publish it?',
    photo: "The card's font and logo don't match {outlet}'s real news cards.",
    date: "Posted at 1 AM, with no link to a full story.",
    source:
        "{outlet} says it never published this card. Its website has no such quote.",
    replies: "People are furious, but nobody can link the original interview.",
    concepts: [Concept.fakeQuote, Concept.editedScreenshot],
    ruleOfThumb:
        "Check the source of any quote before sharing. A fake news card can put words in someone's mouth, whether you like that person or not.",
    rSource: Relevance.decisive,
    rPhoto: Relevance.support,
    lesson:
        "Anger is not evidence. A fake news card can put words in someone's mouth, whether you like that person or not.",
  ),
  _Post(
    'fake_ayuda_link',
    true,
    'Government',
    'Cash graphic',
    [
      "LIBRE P{amt} PARA SA LAHAT! Walang requirements, mag-register lang sa ayuda-ph-now.example bago mag-12 midnight!",
      "ATTENTION: P{amt} cash aid, first 1,000 lang. I-click ang ayuda-ph-now.example at ilagay ang mobile number.",
    ],
    q: 'Does the city or barangay announce this program?',
    photo: "The picture of cash is a stock photo used on other scam posts.",
    date: "Posted late at night, with a deadline of midnight.",
    source: "City Hall posted: \"We have no such program. Don't click links.\"",
    replies: "Some ask for the link, others say they never received anything.",
    concepts: [Concept.urgencyPressure, Concept.linkMismatch],
    variants: [
      _Variant(
        q: 'Is this the page the city website lists?',
        account:
            "Page created 3 days ago. Its name copies the city's, but its handle isn't the one listed on the city website.",
        rAccount: Relevance.decisive,
        rSource: Relevance.support,
      ),
      _Variant(
        q: 'Has this exact wording been posted before?',
        date:
            "The same 'midnight deadline' wording has appeared on other pages every week since {y1}, each with a new link.",
        rDate: Relevance.decisive,
        rSource: Relevance.support,
      ),
    ],
    ruleOfThumb:
        "Free cash with a deadline and a link is pressure. Check the agency's own page, not the post's link.",
    rPhoto: Relevance.support,
    lesson:
        "Free cash with a link and a deadline is a classic scam pattern. Check the official page, not the post's own link.",
  ),
  _Post(
    'fake_recruitment',
    true,
    'Government',
    'Hiring poster',
    [
      "HIRING na ang Maritime Service PH! Sahod ₱43,800, walang experience needed. Magbayad lang ng ₱1,500 processing fee sa {wallet}.",
      "Job openings sa Maritime Service PH! Sahod ₱43,800/buwan. Reserve your slot, bayad ₱1,500 sa {wallet}.",
    ],
    q: 'Does the agency charge application fees?',
    photo: "The poster logo is a low-resolution copy of the agency's logo.",
    date: "Posted by a page created last week.",
    source:
        "The agency's official page says it never charges application fees and lists no such hiring.",
    replies: "Applicants say they paid and were then blocked.",
    concepts: [Concept.payToReceive],
    ruleOfThumb:
        "A real job never asks you to pay to apply. Check the agency's own page.",
    rPhoto: Relevance.decisive,
    rSource: Relevance.support,
    lesson:
        "Legit agencies don't charge a fee to apply. A high salary with no requirements is bait.",
  ),
  _Post(
    'deepfake_doc',
    true,
    'Health',
    'Video thumbnail',
    [
      "Si Doc Ramon Alcantara mismo ang nagsabi: itong herbal capsule ang lunas sa ubo at pulmonya. Order na bago maubos! 🎥",
      "Doc Ramon, inamin na! Gamot daw sa lahat ng sakit sa baga ang capsule na ito. Panoorin ang buong video.",
    ],
    q: 'Does the doctor say this in the original video?',
    photo:
        "The doctor's lips and voice don't line up. The original video, from {y1}, is about handwashing.",
    date: "The audio was added to an older video.",
    source:
        "The doctor's official page says: \"I never promoted this product. This video is an AI edit.\"",
    replies:
        "Many glowing testimonials, all from new accounts using the same wording.",
    concepts: [Concept.aiGenerated, Concept.editedScreenshot],
    ruleOfThumb:
        "Check the person's own page for statements. AI can copy a real person's face and voice, but that doesn't mean they said it.",
    rPhoto: Relevance.decisive,
    rSource: Relevance.decisive,
    rDate: Relevance.support,
    lesson:
        "AI can copy a real person's face and voice. A trusted face selling a cure is a reason to check the person's own page.",
  ),
  _Post(
    'doctored_screenshot',
    true,
    'Weather',
    'Advisory screenshot',
    [
      "WALANG PASOK BUKAS sa LAHAT ng level sa buong {city}! Galing sa City Hall ang advisory. Share na!",
      "CLASS SUSPENSION: lahat ng paaralan sa {city}, bukas. Screenshot mula sa City Hall. Pakisabi sa mga GC!",
    ],
    q: 'Look at the date on the advisory itself.',
    photo: "A {y1} date is visible in the corner of the advisory graphic.",
    date: "That advisory was from {y1} and covered one school only.",
    source: "City Hall's current page has no suspension notice today.",
    replies: "Students say their schools haven't announced anything.",
    concepts: [Concept.editedScreenshot],
    ruleOfThumb:
        "Check the date on the advisory itself. Old advisories get reposted as new.",
    rPhoto: Relevance.decisive,
    rDate: Relevance.decisive,
    rSource: Relevance.decisive,
    lesson:
        "Old advisories get reposted as new. Check the date on the graphic and the official page.",
  ),
  _Post(
    'false_scope',
    true,
    'Campus',
    'School news photo',
    [
      "BREAKING: Lahat ng paaralan sa probinsya, SARADO sa susunod na linggo dahil sa dengue!!",
      "Dengue outbreak! Walang klase ang buong probinsya next week. Pakisabi sa pamilya n'yo!",
    ],
    q: 'What does the real notice actually cover?',
    photo: "The photo is real, but its caption says \"one school\".",
    date: "The news item is from this week.",
    source:
        "The real notice is from one school in Brgy. {town}: two days of cleaning after dengue cases.",
    replies: "Parents from other schools say their classes are still on.",
    concepts: [Concept.editedScreenshot, Concept.recycledMedia],
    ruleOfThumb:
        "Misleading posts often start with something real and then stretch the scope. Compare the claim with the original notice.",
    rPhoto: Relevance.support,
    rDate: Relevance.decoy,
    rSource: Relevance.decisive,
    lesson:
        "Misleading posts often start with something real and then stretch the scope. Compare the claim with the original notice.",
  ),
  _Post(
    'ghost_wrong_site',
    true,
    'Government',
    'Empty lot photo',
    [
      "GHOST PROJECT! Eto ang \"flood wall\" sa Brgy. {town}, wala naman pala!! Saan napunta ang P{amt}M?? 😡",
      "Walang flood wall sa Brgy. {town}! Puro damo lang. Ninakaw ang P{amt}M, ipakulong sila!",
    ],
    q: 'Is the photo really from Brgy. {town}?',
    photo:
        "The empty lot was photographed two weeks ago in Brgy. {town2}, a different barangay.",
    date: "The photo is real but is two weeks old.",
    source:
        "The city's inspection report shows the Brgy. {town} wall as finished, with dated photos.",
    replies:
        "Residents say the wall exists, but the old drainage still floods.",
    concepts: [Concept.missingContext],
    variants: [
      _Variant(rSource: Relevance.support),
      _Variant(
        q: "What does the city's inspection report show for Brgy. {town}?",
        rPhoto: Relevance.support,
        rSource: Relevance.decisive,
      ),
    ],
    ruleOfThumb:
        "A real photo from the wrong place is not proof. Check where it was taken.",
    rPhoto: Relevance.decisive,
    rSource: Relevance.support,
    rReplies: Relevance.support,
    lesson:
        "Corruption is a real issue and worth asking about. But a photo of the wrong place is not proof. Accountability needs accurate evidence.",
  ),
  _Post(
    'ticket_resale',
    true,
    'Music',
    'Ticket image',
    [
      "LAST 2 PCS na VIP ticket ng {group} concert! 50% OFF, bayad agad sa {wallet} para ma-reserve. DM lang.",
      "{group} concert tickets, SOLD OUT na sa website pero may stock pa ako. Bayad muna sa {wallet}, ipapadala ang QR.",
    ],
    q: 'Where does the official ticketing site say tickets are sold?',
    photo:
        "The QR code on the ticket image also appears on other sellers' posts.",
    date: "Posted minutes after the official sale sold out.",
    source:
        "The official ticketing site says tickets are sold only on its own page, with no resale or DM sales.",
    replies: "Several people say they paid and were blocked.",
    concepts: [Concept.payToReceive, Concept.urgencyPressure],
    ruleOfThumb:
        "Check the official seller's rules before paying anyone. Sold-out tickets are often used to scam buyers.",
    rPhoto: Relevance.support,
    rSource: Relevance.decisive,
    rReplies: Relevance.support,
    lesson:
        "Sold-out concert tickets attract scammers. Check the official seller's rules before paying anyone.",
  ),
  _Post(
    'election_count',
    true,
    'Election',
    'Results screenshot',
    [
      "PARTIAL UNOFFICIAL COUNT: Kap. Reyes lamang ng 90%! Dinaya daw ang kalaban, share para mabisto!",
      "BREAKING: Lamang na si Kap. Reyes sa bilangan, 90% ng presinto na! Itinatago ito ng media.",
    ],
    q: 'Has the election office released any results yet?',
    photo: "The screenshot header shows a practice run from {y1}.",
    date: "The results page was created during {y1}'s test.",
    source: "The election office says no results have been released yet.",
    replies:
        "People argue about cheating without linking any official numbers.",
    concepts: [Concept.missingContext],
    ruleOfThumb:
        "A partial or practice count isn't a result. Only the election office's release counts.",
    rPhoto: Relevance.decisive,
    rDate: Relevance.support,
    rSource: Relevance.support,
    rReplies: Relevance.decoy,
    lesson:
        "Fake election results spread fast because people are emotional. Only the election office's own release counts.",
  ),
  _Post(
    'ai_disaster',
    true,
    'AI',
    'Dramatic photo',
    [
      "TSUNAMI sa Manila Bay?! Nakuha ng drone kanina. Pa-share para makapaghanda ang lahat 🌊😱",
      "Grabeng alon sa Manila Bay ngayon lang. Lumikas na kayo!! Kuha ng kaibigan ko.",
    ],
    q: 'Where did the picture first appear, and what do official warnings say?',
    photo:
        "No camera data. The image first appeared on an AI art page two days ago.",
    date: "The scene doesn't match today's weather.",
    source: "The weather bureau and major outlets report no tsunami warning.",
    replies: "Others point out melted text on signs and odd building shapes.",
    concepts: [Concept.aiGenerated, Concept.editedScreenshot],
    ruleOfThumb:
        "AI images can look dramatic and real. When there's no official warning, don't spread panic.",
    rPhoto: Relevance.decisive,
    rSource: Relevance.support,
    rDate: Relevance.support,
    lesson:
        "AI images can look dramatic and real. When there's no official warning, don't spread panic.",
  ),
  _Post(
    'satire_stripped',
    true,
    'Government',
    'Cropped news card',
    [
      "Rice cooker, bawal na sa buong {city} simula Lunes! Basahin ang screenshot, galing sa news site!",
      "Grabe 'to: bawal na ang rice cooker sa {city} para tipid-kuryente. Share para malaman ng lahat!",
    ],
    q: 'Was this published as news, or as a joke?',
    photo:
        "The screenshot is cropped. The original has a 'SATIRE' banner and the humor site's joke logo at the bottom.",
    date:
        "The original article is two days old and was posted by the humor site itself.",
    source:
        "No news outlet or city office reports a rice cooker ban. The humor site files the story under satire.",
    replies:
        "Some laugh and tag friends; others panic and ask where to buy a backup stove.",
    concepts: [Concept.satireLabel],
    ruleOfThumb:
        "A joke with its label cropped off becomes misinformation. Look for the original.",
    rPhoto: Relevance.decisive,
    rSource: Relevance.support,
    lesson:
        "Satire is fine with its label. Once the label is cropped, readers can mistake a joke for news.",
  ),
  _Post(
    'outdated_deadline',
    true,
    'Campus',
    'Scholarship reminder',
    [
      "LAST CALL! Hanggang bukas na lang ang {school} scholarship applications. Mag-apply na bago maubos ang slots!",
      "Pa-share po: deadline na bukas ng {school} scholarship. Huwag nang palampasin!",
    ],
    q: 'Is this deadline for this term, or an old one?',
    photo:
        "The poster is the school's own design, but its small print names the {y1} school year.",
    date: "This is a re-share of a poster first published in {y1}.",
    source:
        "The school's current portal says that term's applications closed long ago and lists a new schedule.",
    replies:
        "Some commenters say they were told the deadline had passed; others share it without checking.",
    concepts: [Concept.oldValid],
    ruleOfThumb:
        "Check the school year on the poster, then confirm on the current portal.",
    rDate: Relevance.decisive,
    rSource: Relevance.support,
    lesson:
        "Old posts can be harmless or outdated. Here the poster is from a past term, so the deadline no longer applies.",
  ),
  _Post(
    'fake_agency_page',
    true,
    'Weather',
    'Bulletin graphic',
    [
      "OFFICIAL ADVISORY: Signal No. 4 na sa {city}! Lumikas na ngayon din, huwag nang maghintay ng update.",
      "Weather Bureau PH Official: Signal No. 4 sa {city} simula ngayong gabi. Pakisabi sa pamilya n'yo.",
    ],
    q: "Is this the handle the weather bureau really uses?",
    photo:
        "The graphic copies the bureau's colors, but the logo is stretched and the map has no legend.",
    date: "Posted at 11 PM, ahead of the bureau's next scheduled bulletin.",
    source:
        "The weather bureau's real page has posted no Signal No. 4. Its last bulletin lists Signal No. 1.",
    replies:
        "Some residents start packing. One points out the page name has a zero in place of an O.",
    account:
        "Page created 6 days ago, 410 followers. Handle: @weatherbureau_ph0fficial. The real bureau uses @weatherbureau, with years of posts.",
    concepts: [Concept.lookalikeHandle],
    ruleOfThumb:
        "Compare the exact handle with the agency's real page. One swapped letter means a different account.",
    rAccount: Relevance.decisive,
    rSource: Relevance.support,
    lesson:
        "A page can copy an agency's name and colors. Compare the handle with the real page before sharing a warning.",
  ),
  _Post(
    'agency_warning_real',
    false,
    'Government',
    'Impostor page warning',
    [
      "PAALALA mula sa City Hall ng {city}: may peking page na gumagamit ng pangalan namin para humingi ng bayad. Ang opisyal na site lang ay cityhall.example. I-report ang peke.",
      "Babala: may kumakalat na page na nagpapanggap na City Hall of {city}. Hindi kami nagpapadala ng mensahe para humingi ng pera. Opisyal: cityhall.example.",
    ],
    q: "Is this posted by the agency's own page?",
    photo:
        "The graphic matches City Hall's earlier notices and shows the fake page's handle circled.",
    date:
        "Posted this afternoon, an hour after residents reported the fake page.",
    source: "The warning also appears on City Hall's official website.",
    replies:
        "Residents thank the office and report the fake page. A few share it in barangay group chats.",
    account:
        "Page created 9 years ago, 210K followers. Handle matches the one listed on the city's official website.",
    concepts: [Concept.lookalikeHandle],
    ruleOfThumb:
        "Confirm the handle matches the official website. A warning from the real page is worth sharing.",
    rAccount: Relevance.decisive,
    rSource: Relevance.support,
    lesson:
        "Real agencies warn about impostors. This one comes from the page whose handle matches the official site, so it's safe to keep.",
  ),
  _Post(
    'otp_giveaway',
    true,
    'Shopping',
    'Giveaway announcement',
    [
      "{wallet} GIVEAWAY! P{amt} sa 50 winners. I-comment ang number mo, tapos ibigay ang 6-digit code na matatanggap mo para ma-verify ang panalo!",
      "Congrats sa mga mananalo! Para ma-claim ang P{amt} sa {wallet}, i-DM ang OTP na ite-text sa inyo. First 50 lang!",
    ],
    q: 'Would a real wallet app ever ask you for this code?',
    photo:
        "The graphic uses {wallet}'s colors but not its current logo, and the same image appears on other pages.",
    date: "Posted minutes ago, with a countdown for the 'first 50' winners.",
    source:
        "{wallet}'s official page says it never asks for your OTP, PIN or password, not even for prizes.",
    replies:
        "Several people say they sent the code and lost access to their account.",
    concepts: [Concept.otpRequest, Concept.urgencyPressure],
    ruleOfThumb:
        "An OTP is the key to your account. Nobody legitimate needs you to send it, even for a prize.",
    rSource: Relevance.decisive,
    lesson:
        "OTP codes prove it's you. Anyone who asks for one, even for a prize, is trying to take over your account.",
  ),
  _Post(
    'wallet_otp_warning',
    false,
    'Shopping',
    'Safety reminder',
    [
      "Paalala mula sa {wallet}: huwag ibigay kahit kanino ang OTP, PIN o password. Hindi hihingi nito ang staff namin sa chat, tawag, o comment.",
      "Reminder sa lahat ng users ng {wallet}: ang OTP ay para sa'yo lang. Kung may humingi nito, i-report agad sa app.",
    ],
    q: "Does this match the wallet's own help page?",
    photo: "The reminder graphic matches the wallet's earlier safety notices.",
    date: "Posted as part of the wallet's regular safety reminders.",
    source:
        "The wallet's app and help page carry the same reminder: staff never ask for OTPs.",
    replies: "Users share their own scam messages and thank the page.",
    concepts: [Concept.otpRequest],
    ruleOfThumb:
        "Real security notices tell you to protect your codes. They never ask you to send one.",
    rSource: Relevance.decisive,
    lesson:
        "A reminder not to share your OTP protects users. It asks for nothing and matches the wallet's own help page.",
  ),
  _Post(
    'fake_charity',
    true,
    'Government',
    'Donation drive poster',
    [
      "TULONG PARA SA MGA BIKTIMA NG BAGYO sa Brgy. {town}! I-send ang donasyon sa personal {wallet} ni Ate Cora: 0917 555 0142. Walang resibo pero aabot talaga!",
      "Magdonate para sa mga nasalanta ng baha sa {city}. Ipadala sa {wallet} ng admin namin at ibibigay agad sa mga pamilya.",
    ],
    q: 'Does the barangay list this donation drive?',
    photo:
        "The flooded-street photo was taken in another city in {y1}, not in {town}.",
    date: "Posted within hours of the typhoon by a page created the same day.",
    source:
        "The barangay's page lists its official drop-off at the barangay hall and says it doesn't accept wallet transfers to individuals.",
    replies:
        "Several commenters ask for a receipt; the page keeps deleting those comments.",
    concepts: [Concept.payToReceive, Concept.officialSource],
    ruleOfThumb:
        "Give through the official drop-off or a listed group, never to a stranger's personal wallet.",
    rPhoto: Relevance.support,
    lesson:
        "Disaster donation drives attract scams. A real drive is listed by the barangay or a registered group and gives receipts.",
  ),
  _Post(
    'clinic_vaccine_real',
    false,
    'Health',
    'Vaccine schedule poster',
    [
      "Libreng bakuna sa Health Center ng Brgy. {town} ngayong Martes, 8AM-12NN. Dalhin ang vaccination card. Walang bayad.",
      "Paalala: libreng flu vaccine para sa mga senior sa Health Center ng Brgy. {town} sa Martes. Walang registration fee.",
    ],
    q: 'Does the city health office list the same schedule?',
    photo:
        "The poster uses the health center's usual template and the same address as its page.",
    date: "Posted three days before the vaccination day.",
    source:
        "The city health office's page lists the same schedule, time and the 'free' note.",
    replies:
        "Residents ask about requirements and the health center answers with the same details.",
    concepts: [Concept.payToReceive],
    ruleOfThumb:
        "A free service is believable when the official health office lists it and nothing asks for payment.",
    lesson:
        "Not every health post is a scam. The city health office listed the same free schedule, and nothing asked for money or codes.",
  ),
  _Post(
    'voucher_link',
    true,
    'Shopping',
    'Voucher graphic',
    [
      "{store} ANNIVERSARY! Libreng ₱{amt} voucher para sa unang 500. I-click ang anniv-voucher-ph.example at ilagay ang mobile number at OTP.",
      "Namimigay ang {store} ng ₱{amt} voucher ngayon lang! Mag-register sa anniv-voucher-ph.example bago maubos.",
    ],
    q: "Is that link the store's own site?",
    photo:
        "The voucher graphic uses {store}'s logo, but the same graphic appears on other pages with different store names.",
    date: "Posted late at night with a 'first 500' countdown.",
    source:
        "{store}'s official page says its promos are only in its app and on its own site. The link in this post isn't either.",
    replies:
        "Some commenters say the site asked for an OTP and then charged their wallet.",
    concepts: [Concept.linkMismatch, Concept.otpRequest],
    ruleOfThumb:
        "A promo link that isn't the store's own site is a trap. Never type an OTP to claim a prize.",
    rPhoto: Relevance.support,
    lesson:
        "A voucher link that isn't on the store's own site is a classic trap. Real promos never ask for your OTP.",
  ),
  _Post(
    'full_statement_real',
    false,
    'Government',
    'Quote card',
    [
      "Sabi ni {who}: 'Hindi pa final ang budget.' Ito ang buong statement mula sa opisyal na page, basahin hanggang dulo: cityhall.example/statements",
      "Quote card mula sa budget hearing ni {who}. Nasa opisyal na page ng city council ang buong video at transcript.",
    ],
    q: 'Does the full statement say the same thing?',
    photo:
        "The quote card uses the council's template and shows the date and name of the hearing.",
    date: "Posted the same day as the hearing.",
    source:
        "The council's official transcript contains the quote, with the sentences before and after it, and the meaning is the same.",
    replies: "A few ask for the full video; others link the transcript.",
    concepts: [Concept.missingContext],
    ruleOfThumb:
        "A short quote is fine when the full statement says the same thing. Check what comes before and after it.",
    rPhoto: Relevance.support,
    lesson:
        "Short quotes aren't automatically misleading. This one matched the full transcript, so nothing that changes the meaning was left out.",
  ),
  _Post(
    'urgent_real_alert',
    false,
    'Weather',
    'Evacuation advisory',
    [
      "URGENT!! MANDATORY EVACUATION sa Brgy. {town}, ngayon din! Pumunta sa covered court. Dalhin ang valid ID at gamot.",
      "🚨 LUMIKAS NA! Tataas pa ang tubig sa Brgy. {town}. Sundin ang barangay at pumunta sa evacuation center ngayon.",
    ],
    q: 'Does the barangay itself announce the evacuation?',
    photo:
        "The graphic uses the barangay's usual template and lists the same evacuation center as its page.",
    date:
        "Posted 10 minutes after the weather bureau raised its warning for the area.",
    source:
        "The barangay's page and the city disaster office both announce the same evacuation point.",
    replies: "Neighbors confirm that officials are going door to door.",
    concepts: [Concept.officialSource, Concept.urgencyPressure],
    ruleOfThumb:
        "Urgent isn't the same as fake. Check whether the official page says the same thing.",
    lesson:
        "Real emergency alerts are loud and urgent. Don't dismiss a post just because it shouts. Check the official source.",
  ),
  _Post(
    'polite_scam',
    true,
    'Government',
    'Notice letter',
    [
      "Magandang araw po. Ito ay paalala mula sa Treasurer's Office ng {city}. Pakiupdate po ang inyong tax details sa link na ito kapag may oras kayo: treasurer-{town}-portal.example. Salamat po.",
      "Good day po. Para maiwasan ang abala sa susunod na billing, paki-verify ang inyong detalye sa treasurer-{town}-portal.example. Maraming salamat po.",
    ],
    q: "Is that link the city's official portal?",
    photo:
        "The letterhead is a pixel-perfect copy of the city's, with no seal metadata.",
    date: "Posted on a quiet weekend, with no deadline mentioned.",
    source:
        "The city's real page lists tax payments only through its own portal, and says it never sends update links.",
    replies: "Comments are turned off.",
    concepts: [Concept.linkMismatch, Concept.officialSource],
    ruleOfThumb:
        "A polite tone proves nothing. Check where the link really leads.",
    rPhoto: Relevance.support,
    lesson:
        "Scams don't always rush or shout. A calm, polite request with a lookalike link is just as dangerous.",
  ),
  _Post(
    'legit_fee',
    false,
    'Campus',
    'Fee notice',
    [
      "Paalala: ang replacement ng nawalang school ID ay ₱150. Bayaran sa cashier ng {school} o sa official payment portal ng school, hindi sa personal na account ng kahit sino.",
      "Nawala ang ID? ₱150 ang replacement fee sa {school}. Magbayad lang sa cashier o sa school portal.",
    ],
    q: "Does the school's own page list this fee and payment method?",
    photo: "The notice uses the school's official template.",
    date:
        "Posted at the start of the term, the same time as last year's notice.",
    source:
        "The school's registrar page lists the ₱150 fee and says to pay only at the cashier or on the school portal.",
    replies: "Students confirm they paid the same amount at the cashier.",
    concepts: [Concept.payToReceive, Concept.officialSource],
    ruleOfThumb:
        "Asking for money isn't always a scam. Check that the amount and the payment place match the official page.",
    lesson:
        "A real fee comes with an official page that lists the amount and the proper payment place.",
  ),
  _Post(
    'hijacked_trusted_page',
    true,
    'Shopping',
    'Giveaway post',
    [
      "SALAMAT SA 500K FOLLOWERS! Libreng P{amt} sa 100 lucky followers. I-DM ang inyong {wallet} number at OTP para ma-credit agad.",
      "GIVEAWAY ng page namin! Magpadala ng {wallet} number at OTP sa DM para ma-claim ang P{amt}.",
    ],
    q: 'Is this page still run by the people you remember?',
    photo: "The giveaway graphic is a template used on other hijacked pages.",
    date: "Posted in the middle of the night, unlike this page's usual posts.",
    source:
        "The page's original owner posted from a personal account: 'My page was hacked. Please ignore its giveaways.'",
    replies: "Longtime followers warn others in the comments.",
    account:
        "Established page, 12 yrs, 480K followers. But its name and handle were changed 2 days ago, and its earlier posts were about cooking.",
    concepts: [Concept.otpRequest, Concept.lookalikeHandle],
    ruleOfThumb:
        "A trusted page can be hijacked. Check what changed recently, and never share an OTP.",
    rAccount: Relevance.decisive,
    rSource: Relevance.support,
    lesson:
        "A long history and many followers don't guarantee safety. Hijacked pages keep their reputation but not their owner.",
  ),
  _Post(
    'correction_post',
    false,
    'Government',
    'Correction notice',
    [
      "PAGWAWASTO: Kahapon, nag-post kami na sarado ang tulay sa Brgy. {town}. Mali iyon. Bukas ito, at ang sarado ay ang kabilang daan. Paumanhin po.",
      "Correction: ang naunang post namin tungkol sa tulay sa Brgy. {town} ay hindi tama. Ang opisyal na advisory ng city engineer ay nasa page nila.",
    ],
    q: "Does the city engineer's advisory match the correction?",
    photo: "The photo shows the bridge open, with traffic moving.",
    date:
        "Posted the day after the original, and it links to the original post.",
    source:
        "The city engineer's advisory lists the bridge as open and the other road as closed.",
    replies: "Residents thank the page for fixing the mistake.",
    concepts: [Concept.officialSource],
    ruleOfThumb:
        "A post that corrects an earlier mistake can be the most reliable one. Check the official advisory.",
    rPhoto: Relevance.support,
    lesson:
        "A correction can look like a contradiction. Here the official advisory matches the correction, so it's worth keeping.",
  ),
  _Post(
    'clinic_hours_real',
    false,
    'Health',
    'Clinic hours notice',
    [
      "Paalala: bukas ang health center ng Brgy. {town} hanggang 6PM ngayong Huwebes para sa check-up. Walang dagdag na bayad.",
      "Extended clinic hours sa Brgy. {town} ngayong araw. I-check ang opisyal na schedule bago pumunta.",
    ],
    q: 'Does the health center list these hours?',
    photo:
        "The current schedule posted at the clinic entrance lists Thursday hours through 6PM.",
    date: "Posted this morning for today's extended hours.",
    source:
        "The city health office lists the same Thursday hours and confirms the service has no extra fee.",
    replies:
        "Residents ask what documents to bring; the health center answers with its regular requirements.",
    concepts: [Concept.officialSource],
    ruleOfThumb:
        "Confirm public-service changes through the office that provides the service.",
    rPhoto: Relevance.decisive,
    rSource: Relevance.support,
    lesson:
        "The official health office confirms the new hours. A changed schedule is worth checking, but the verified source makes this notice trustworthy.",
  ),
  _Post(
    'fake_aid_registration',
    true,
    'Government',
    'Ayuda registration post',
    [
      "May bagong ayuda para sa lahat ng residente ng {city}! Ipadala ang pangalan, birthday at ₱{amt} registration fee sa personal {wallet} namin.",
      "Huwag palampasin ang ayuda! Mag-register ngayon sa link at bayaran ang processing fee para ma-release agad.",
    ],
    q: 'Does the city list this program or fee?',
    photo:
        "The graphic copies the city's logo, but the contact number belongs to a personal account.",
    date: "Posted by a page created yesterday with a countdown to tonight.",
    source:
        "The city page says there is no new aid registration and warns residents not to pay a fee or share ID details.",
    replies:
        "Several comments asking for the official announcement are hidden; one says the link asked for an ID photo.",
    concepts: [Concept.payToReceive, Concept.officialSource],
    ruleOfThumb:
        "Check aid programs with the city directly; never pay a personal account to release benefits.",
    rSource: Relevance.decisive,
    lesson:
        "The city denied the program, and the post asks for both money and personal details. A copied logo and countdown don't make an aid offer real.",
  ),
  _Post(
    'proposal_called_approved',
    true,
    'Government',
    'Parking fee update',
    [
      "Approved na raw ang bagong ₱{amt} parking fee sa {city}. Maghanda na sa susunod na linggo.",
      "May bagong parking charge na sa {city}, sabi ng post na ito. I-share para malaman ng lahat.",
    ],
    q: 'Did the council approve it, or only discuss it?',
    photo:
        "The graphic is based on a real council slide, but crops out the word 'proposal'.",
    date: "Posted after the public hearing, before the next council vote.",
    source:
        "The council minutes say the fee is still a proposal and no vote has happened.",
    replies: "Some residents already argue about whether the charge is fair.",
    concepts: [Concept.missingContext, Concept.officialSource],
    ruleOfThumb:
        "A proposal is not an approved policy. Check the decision record and its status.",
    rPhoto: Relevance.decisive,
    rSource: Relevance.support,
    lesson:
        "The meeting happened, but the vote did not. A real document can mislead when it is presented as a final decision.",
  ),
  _Post(
    'small_sample_scoped',
    false,
    'Campus',
    'Class survey results',
    [
      "Sa survey ng 12 students sa section namin, 8 ang mas gusto ang Friday review session. Hindi ito buong-school poll.",
      "Eight out of 12 students in our class chose Friday for the review. Results are only for our section.",
    ],
    q: 'Does the post describe who was actually surveyed?',
    photo:
        "The chart shows 12 responses and labels the group as one class section.",
    date: "Posted after the class adviser closed the survey yesterday.",
    source:
        "The survey sheet has 12 responses from the named section; it makes no claim about the whole school.",
    replies: "Other sections say they prefer different days.",
    concepts: [Concept.officialSource],
    ruleOfThumb:
        "Small samples are limited, but an accurately scoped result is not a schoolwide claim.",
    rPhoto: Relevance.decisive,
    rSource: Relevance.support,
    lesson:
        "The result is only about one class, and the post says so. Don't mistake a limited, transparent poll for a claim about everyone.",
  ),
  _Post(
    'planning_map_mislabeled',
    true,
    'Weather',
    'Road closure map',
    [
      "SARADO NA ang buong Riverside District. Iwasan lahat ng tulay hanggang bukas!",
      "Citywide road closure ngayon, ayon sa mapang ito. Huwag bumiyahe.",
    ],
    q: 'Does the shaded area mean closed roads, or a planning zone?',
    photo:
        "The legend labels the shaded district as a flood-planning area; only one bridge is marked closed.",
    date: "Posted during a real flood advisory this afternoon.",
    source:
        "The city engineer confirms that one bridge is closed and the other routes remain open.",
    replies: "Commuters share different route suggestions.",
    concepts: [Concept.missingContext, Concept.officialSource],
    ruleOfThumb:
        "Read a map's legend before treating a highlighted area as a warning boundary.",
    rPhoto: Relevance.decisive,
    rSource: Relevance.support,
    lesson:
        "The map is real, but its shaded planning zone is not a closure order. The legend and the actual road markers say different things.",
  ),
  _Post(
    'labeled_satire_council',
    false,
    'Government',
    'Council parody post',
    [
      "BREAKING: Inaprubahan ng konseho ang libreng upuan sa session hall para sa lahat ng pusa. 🐈 (satire)",
      "Opisyal na: pusa na ang bagong traffic enforcers! Joke lang po — satire page ito.",
    ],
    q: 'What does the account say about the kind of content it posts?',
    photo:
        "The graphic is deliberately absurd and includes a visible 'SATIRE' label.",
    date: "Posted today alongside the page's other labeled jokes.",
    source:
        "No council record exists; the post is a joke, not a claim that a real vote happened.",
    replies: "Readers tag friends and joke about their cats.",
    account:
        "The account bio says 'Satire and parody. Not a government page.' It has used this label for three years.",
    concepts: [Concept.satireLabel],
    ruleOfThumb:
        "Clearly labeled satire is not a false claim pretending to be news.",
    rAccount: Relevance.decisive,
    rPhoto: Relevance.support,
    lesson:
        "The account openly identifies its posts as satire. Absurdity alone is not the evidence; the clear, consistent label is.",
  ),
  _Post(
    'voluntary_poll_overstated',
    true,
    'Government',
    'Road toll poll',
    [
      "70% ng mga residente ang pabor sa toll sa bagong tulay, ayon sa poll na ito.",
      "Karamihan daw ng taga-{city} gusto ang toll. Tingnan ang graph bago mag-share.",
    ],
    q: 'Who answered the poll, and does it represent the city?',
    photo:
        "The chart shows 7 of 10 votes from a voluntary page poll, not a citywide sample.",
    date: "Posted after ten followers answered an online question.",
    source:
        "The poll host confirms responses came only from users who chose to click the page poll.",
    replies: "Several commenters say they never saw the poll.",
    concepts: [Concept.missingContext],
    ruleOfThumb:
        "A percentage can be mathematically correct while being presented as more representative than it is.",
    rPhoto: Relevance.decisive,
    rSource: Relevance.support,
    lesson:
        "Seven of ten respondents chose the toll, but they were self-selected page users. That result cannot stand in for all city residents.",
  ),
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
const _hypeTail = [
  ' SHARE NA!! 🚨',
  ' Pa-viral naman 🙏',
  ' Basahin hanggang dulo!!',
];
const _calmTail = [' Salamat po.', ' Fyi lang.', ' Ingat tayo lahat.'];

String _titleCase(String w) => w[0] + w.substring(1).toLowerCase();

/// Toned-down version: no shouting, one calm sentence ender.
String _calm(String text) {
  var t = text.replaceAllMapped(
    RegExp(r'\b[A-Z]{4,}\b'),
    (m) => _titleCase(m[0]!),
  );
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
  final v = p.variants.isEmpty ? null : g.pick(p.variants);
  final town = g.pick(Pools.towns);
  final town2 = g.pick(Pools.towns.where((t) => t != town).toList());
  final slots = <String, String>{
    'town': town,
    'town2': town2,
    'city': g.pick(Pools.cities),
    'who': g.pick(Pools.officials),
    'amt': g.pick(['85', '120', '250', '5,000']),
    'outlet': g.pick(Pools.outlets),
    'group': g.pick(Pools.groups),
    'school': g.pick(Pools.schools),
    'store': g.pick(Pools.stores),
    'wallet': g.pick(Pools.wallets),
    'y1': '${g.between(2019, 2023)}',
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
    final shuffledOpinions = g.shuffled(opposingOpinions);
    for (
      var i = 0;
      i < d.profile.conflictingEvidence && i < shuffledOpinions.length;
      i++
    ) {
      final label = i == 0 ? 'Top comment' : 'Comment';
      replies +=
          ' $label (${g.between(18, 950)} likes): '
          '"${shuffledOpinions[i]}"';
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
  final author = p.id == 'satire_page'
      ? 'Kalokohan PH'
      : g.pick([
          'Balita Ngayon',
          'Kanto Updates',
          'Tambayan Feed',
          'Sikat PH',
          'Barkada Bulletin',
          'Mika R.',
          'Paolo D.',
        ]);
  final tools = <Finding>[
    Finding(
      'photo',
      p.photoLabel,
      '🖼️',
      fillSlots(v?.photo ?? p.photo, slots),
      v?.rPhoto ?? p.rPhoto,
    ),
    Finding(
      'account',
      'ACCOUNT',
      '👤',
      v?.account ?? p.account ?? g.pick(_accounts),
      v?.rAccount ?? p.rAccount,
    ),
    Finding(
      'date',
      'DATE CHECK',
      '🕒',
      fillSlots(v?.date ?? p.date, slots),
      v?.rDate ?? p.rDate,
    ),
    Finding(
      'source',
      'ORIGINAL SOURCE',
      '🔎',
      fillSlots(v?.source ?? p.source, slots),
      v?.rSource ?? p.rSource,
    ),
    Finding('replies', 'REPLIES', '💬', replies, p.rReplies),
  ];
  tools.shuffle(g.r);
  final decisive = tools.firstWhere(
    (t) => t.relevance == Relevance.decisive,
    orElse: () =>
        throw StateError('Trust case ${p.id} has no decisive finding.'),
  );
  return ArcadeCase(
    signature: 'trust:${p.id}',
    scenario: p.id,
    mode: ArcadeMode.trust,
    title: 'Trending in Tambayan',
    author: author,
    handle:
        '@${author.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '')}${g.id()}',
    text: body,
    subtext: 'Open up to ${d.scanBudget} checks',
    imageTopic: p.topic,
    imageCaption: p.caption,
    reactions: '${g.between(1, 49)}K views · ${g.between(80, 4000)} shares',
    tools: tools,
    deceptive: p.bad,
    correct: [p.bad ? 1 : 0],
    choices: const [ArcadeOption('KEEP'), ArcadeOption('REMOVE')],
    lesson: fillSlots(p.lesson, slots),
    concepts: p.concepts,
    ruleOfThumb: p.ruleOfThumb,
    hint: d.profile.requiresCrossChecking
        ? 'Try ${decisive.emoji} ${decisive.label}. Compare its evidence with the exact claim and the other details.'
        : 'Try ${decisive.emoji} ${decisive.label}. Ask: ${fillSlots(v?.q ?? p.q, slots)}',
  );
}
