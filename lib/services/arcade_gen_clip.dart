import 'arcade_common.dart';
import '../models/arcade_models.dart';

/// Clip Check. A clip is a few beats on a timeline. The viral cut keeps some
/// beats; the full video has all of them. Five info chips (upload info, audio,
/// creator, label, full video) give neutral facts; the truth follows from the
/// facts, so an honest trim and a deceptive trim can look alike on the surface.
class _Clip {
  final String id, topic, title, caption, lesson, hint;
  final bool bad;
  final List<ClipBeat> beats;
  final String upload, audio, creator, label;
  final Relevance rUpload, rAudio, rCreator, rLabel, rFull;
  final String full;
  const _Clip(this.id, this.bad, this.topic, this.title, this.caption,
      this.beats, {
    required this.upload, required this.audio, required this.creator,
    required this.label, required this.full,
    required this.lesson, required this.hint,
    this.rUpload = Relevance.support, this.rAudio = Relevance.support,
    this.rCreator = Relevance.decoy, this.rLabel = Relevance.decoy,
    this.rFull = Relevance.decisive,
  });
}

const _clips = <_Clip>[
  // ----------------------------------------------------------- KEEP
  _Clip('honest_trim', false, 'Government', 'Budget hearing, short cut',
    'Mayor Santillan explains the flood wall delay.',
    [
      ClipBeat(0, 'Question from a councilor', 'Councilor: "Bakit na-delay?"', 'Councilor: "Bakit na-delay?"'),
      ClipBeat(12, 'Mayor answers', 'Mayor: "Dahil sa tatlong linggong ulan."', 'Mayor: "Dahil sa tatlong linggong ulan."'),
      ClipBeat(30, 'Mayor adds', 'Mayor: "Matatapos ito sa Enero."', 'Mayor: "Matatapos ito sa Enero."'),
      ClipBeat(55, 'Next agenda', '(cut)', 'Councilor moves to the next item.', inViral: false),
    ],
    upload: 'The short clip is cut from the livestream, and the page links the full video.',
    audio: 'Audio is continuous, with no cuts in the middle of the answer.',
    creator: 'A local news page that usually links to full recordings.',
    label: 'Caption says: "Short cut. Full video in the comments."',
    full: 'The full video says the same thing; the short cut only trims the end.',
    rFull: Relevance.decisive, rAudio: Relevance.support, rLabel: Relevance.support,
    lesson: 'Short clips are normal. This cut kept the question, the answer and the context, and the page links the full video.',
    hint: 'Does cutting the video change what the speaker meant?'),
  _Clip('labeled_ai', false, 'AI', 'AI parody: barangay robot',
    'A robot barangay captain announces free pandesal for all (AI parody).',
    [
      ClipBeat(0, 'A robot at a podium', 'Robot: "Mga kababayan!"', 'Robot: "Mga kababayan!"'),
      ClipBeat(8, 'Crowd cheering', 'Robot: "Libreng pandesal para sa lahat!"', 'Robot: "Libreng pandesal para sa lahat!"'),
      ClipBeat(20, 'Credits', 'Label: "AI-generated parody"', 'Label: "AI-generated parody"'),
    ],
    upload: 'First uploaded by a comedy page that posts only AI parodies.',
    audio: 'The voice is synthetic, and the page says so in its description.',
    creator: 'A comedy page; the bio says "All videos are AI-made".',
    label: 'An on-screen "AI-generated parody" label appears throughout.',
    full: 'The full video is the same parody with the same label.',
    rLabel: Relevance.decisive, rFull: Relevance.support, rCreator: Relevance.support,
    lesson: 'AI is fine when it is clearly labeled and nobody real is being impersonated. The label is the deciding fact.',
    hint: 'Is the AI use disclosed and obvious?'),
  _Clip('real_news', false, 'Weather', 'Rescue boat clip',
    'Rescue team brings residents out of a flooded street in Brgy. Sinag.',
    [
      ClipBeat(0, 'Rescue boat arrives', 'Narrator: "Sa Brgy. Sinag ngayon."', 'Narrator: "Sa Brgy. Sinag ngayon."'),
      ClipBeat(15, 'Residents board', 'Narrator: "Ligtas ang lahat."', 'Narrator: "Ligtas ang lahat."'),
      ClipBeat(40, 'Hotline', '(cut)', 'Narrator: "Hotline: ang numero ay nasa page."', inViral: false),
    ],
    upload: 'Uploaded today by the city rescue unit; the location and time are in the description.',
    audio: 'Audio matches the footage: the same water sounds and voices.',
    creator: 'The city\'s official rescue page.',
    label: 'No special label. It is plain footage.',
    full: 'The full version is the same footage with the hotline at the end.',
    rUpload: Relevance.decisive, rFull: Relevance.support, rCreator: Relevance.support,
    lesson: 'This footage is new and local, and it comes from the group that was there. Nothing was added or reversed.',
    hint: 'Where and when was this uploaded, and by whom?'),
  _Clip('fan_edit', false, 'Music', 'Fancam edit',
    'A fan edit that cuts together the best moments of the {group} concert.',
    [
      ClipBeat(0, 'Intro', 'Caption: "Best moments 🔥"', 'Caption: "Best moments 🔥"'),
      ClipBeat(10, 'Dance break', 'Caption: "Dance break!"', 'Caption: "Dance break!"'),
      ClipBeat(25, 'Closing', 'Caption: "Thanks for the night"', 'Caption: "Thanks for the night"'),
    ],
    upload: 'Uploaded by a fan page after the concert, labeled as a fan edit.',
    audio: 'Music is the group\'s song; there is no added speech.',
    creator: 'A fan account that says "Unofficial fan edit".',
    label: 'The description says: "Fan edit, not official footage."',
    full: 'Longer fan video showing the same songs in order.',
    rLabel: Relevance.decisive, rFull: Relevance.support,
    lesson: 'Edits that don\'t claim to be something else aren\'t misleading. A fan edit doesn\'t need to be removed.',
    hint: 'Does the video claim to be anything other than what it is?'),
  _Clip('sports_highlight', false, 'Basketball memorial', 'Inter-U finals highlight',
    'Northridge Falcons\' game-winning shot, short highlight from the school channel.',
    [
      ClipBeat(0, 'Inbound pass', 'Score: 78-78, 3.2s left', 'Score: 78-78, 3.2s left'),
      ClipBeat(9, 'The shot', 'Shot goes in!', 'Shot goes in!'),
      ClipBeat(15, 'Buzzer', 'Final: 80-78', 'Final: 80-78'),
      ClipBeat(40, 'Handshakes', '(cut)', 'Both teams shake hands.', inViral: false),
    ],
    upload: 'Uploaded by the school\'s official sports channel an hour after the game.',
    audio: 'The crowd noise is continuous and matches the footage.',
    creator: 'The school\'s sports channel, which also posts full games.',
    label: 'Caption says "Short highlight. Full game in playlist."',
    full: 'The full game shows the same shot and the same 80-78 score.',
    rFull: Relevance.decisive, rUpload: Relevance.support, rCreator: Relevance.support,
    lesson: 'A highlight reel is not misleading when the score and sequence match the full game and the source links it.',
    hint: 'Does the full game show the same score and play?'),
  _Clip('parody_labeled', false, 'Drag Race', 'Lip-sync parody',
    'Fans lip-sync a famous {queen} runway moment, labeled parody.',
    [
      ClipBeat(0, 'Costume reveal', 'On-screen: "FAN PARODY"', 'On-screen: "FAN PARODY"'),
      ClipBeat(10, 'Lip-sync', 'Fans lip-sync the old line', 'Fans lip-sync the old line'),
      ClipBeat(22, 'Bow', 'Credits: "Not affiliated"', 'Credits: "Not affiliated"'),
    ],
    upload: 'Posted by a fan theater group that makes parodies every month.',
    audio: 'The audio is the original show clip, credited in the description.',
    creator: 'A fan theater group with a public bio.',
    label: 'A "FAN PARODY" label stays on screen the whole time.',
    full: 'The full video is the same performance with credits.',
    rLabel: Relevance.decisive, rFull: Relevance.support,
    lesson: 'A clearly labeled parody isn\'t fooling anyone. It can stay up.',
    hint: 'Does it say what it is?'),
  _Clip('old_rally', true, 'Government', 'Street protest clip',
    'LIVE NGAYON: libu-libong tao sa kalsada sa {city}!',
    [
      ClipBeat(0, 'Crowd on a street', 'Caption: "LIVE ngayon sa {city}"', 'Caption: "Rally, {y1}, ibang lungsod"'),
      ClipBeat(12, 'Banners', 'Caption: "Libo-libo!"', 'Caption: "Rally, {y1}"'),
      ClipBeat(30, 'Marchers', 'Caption: "Naglalakad na sila!"', 'Caption: "Rally, {y1}"'),
    ],
    upload: 'The earliest upload was in {y1}, from a different city and a different event.',
    audio: 'The chants mention an issue that has nothing to do with today.',
    creator: 'A page that reposts old rally footage as news.',
    label: 'No date or location shown in the video.',
    full: 'The original video is labeled with the {y1} event.',
    rUpload: Relevance.decisive, rFull: Relevance.decisive, rAudio: Relevance.support,
    lesson: 'Real footage from another event, shown as "live now", misleads even though nothing was edited.',
    hint: 'When and where was the earliest version posted?'),
  _Clip('subtitle_swap', true, 'Government', 'Council clip with subtitles',
    'Council member says: "We oppose the new bus lane."',
    [
      ClipBeat(0, 'Speaker at the council', 'Subtitle: "We oppose the new bus lane."', 'Audio (Filipino): "Hindi po kami tutol sa bus lane."'),
      ClipBeat(8, 'Speaker continues', 'Subtitle: "It is a waste of money."', 'Audio (Filipino): "Gusto lang naming makita ang gastos."'),
      ClipBeat(20, 'Close', 'Subtitle: "Thank you."', 'Audio (Filipino): "Salamat po."'),
    ],
    upload: 'The video is a re-upload with burned-in English subtitles.',
    audio: 'The spoken words are Filipino and do not match the subtitles.',
    creator: 'A page that adds subtitles to political clips.',
    label: 'No note that the subtitles were added by the page.',
    full: 'The council\'s own video has no subtitles; the speaker says they do NOT oppose the lane and only want the costs.',
    rAudio: Relevance.decisive, rFull: Relevance.decisive, rCreator: Relevance.support,
    lesson: 'The video is real but the subtitles reverse what was said. Always check the spoken words against the captions.',
    hint: 'Do the spoken words match the subtitles?'),
  // ----------------------------------------------------------- REMOVE
  _Clip('context_trim', true, 'Government', 'Mayor interview, short cut',
    'Mayor Santillan: "Wala akong pakialam sa mga biktima ng baha."',
    [
      ClipBeat(0, 'Reporter asks', '(cut)', 'Reporter: "Totoo bang wala kang pakialam sa mga biktima?"', inViral: false),
      ClipBeat(6, 'Mayor reacts', 'Mayor: "Wala akong pakialam sa mga biktima ng baha."', 'Mayor: "Sinasabi ng iba na wala akong pakialam sa mga biktima ng baha."'),
      ClipBeat(14, 'Mayor continues', '(cut)', 'Mayor: "Pero hindi iyon totoo. Nandito kami para tumulong."', inViral: false),
    ],
    upload: 'The short clip starts at 0:06 of a longer interview.',
    audio: 'The cut falls in the middle of the mayor\'s sentence.',
    creator: 'A page that posts only angry captions about politicians.',
    label: 'No source link is given for the full interview.',
    full: 'In the full interview, the mayor was repeating a rumor the reporter asked about, and then denying it.',
    rFull: Relevance.decisive, rAudio: Relevance.support, rUpload: Relevance.support,
    lesson: 'Trimming away the question and the answer reversed the meaning. The kept words are real, but the clip misleads.',
    hint: 'What came right before and right after the part in the viral clip?'),
  _Clip('recycled_footage', true, 'Weather', 'Flood footage',
    'LIVE NGAYON: baha sa {city}, hanggang bubong na!',
    [
      ClipBeat(0, 'Flooded street', 'Caption: "LIVE ngayon sa {city}"', 'Caption: "Bagyong Ulan, {y1}. Lungsod ng Tala."'),
      ClipBeat(10, 'Roofs submerged', 'Caption: "Hanggang bubong na!"', 'Caption: "Bagyong Ulan, {y1}."'),
      ClipBeat(25, 'Rescue boat', 'Caption: "Rescue na!"', 'Caption: "Bagyong Ulan, {y1}."'),
    ],
    upload: 'The earliest version of this video was uploaded in {y1}, by a different page in a different city.',
    audio: 'The audio names a storm that has nothing to do with today\'s weather.',
    creator: 'A page that posts "live" disaster videos.',
    label: 'No date or location is shown in the video.',
    full: 'The original video is labeled with the {y1} storm and the city of Tala.',
    rUpload: Relevance.decisive, rFull: Relevance.decisive, rAudio: Relevance.support,
    lesson: 'Real disaster footage from an earlier storm is being shown as breaking news. Nothing was edited, but the context is false.',
    hint: 'When was the earliest upload of this video?'),
  _Clip('ai_voice_swap', true, 'AI', 'Senator announcement',
    'Sen. Magtanggol: "Ayuda para sa lahat, mag-register sa link."',
    [
      ClipBeat(0, 'Senator at a podium', 'Voice: "Mga kababayan, may ayuda ako!"', 'Voice: "Mga kababayan, mag-ingat po sa baha."'),
      ClipBeat(9, 'Senator gestures', 'Voice: "Mag-register sa link sa ibaba."', 'Voice: "Sundin ang payo ng mga lokal na opisyal."'),
      ClipBeat(20, 'Senator waves', 'Voice: "Salamat po!"', 'Voice: "Salamat po!"'),
    ],
    upload: 'The video is a re-upload of the senator\'s press statement from last week.',
    audio: 'In the viral version, the lip movements don\'t match the words.',
    creator: 'A new page with no other posts.',
    label: 'No label. Nothing says AI or edited.',
    full: 'The senator\'s own page has the original video: it never mentions ayuda or a link.',
    rAudio: Relevance.decisive, rFull: Relevance.decisive, rCreator: Relevance.support,
    lesson: 'The face is real but the voice was swapped. A real person never said these lines, and the link is a trap.',
    hint: 'Do the mouth and the words match? What does the original say?'),
  _Clip('fake_apology', true, 'Music', 'Idol apology clip',
    '{group} leader finally admits she lip-synced the whole concert.',
    [
      ClipBeat(0, 'Leader at a press room', 'Leader: "Aaminin ko na."', 'Leader: "Gusto kong linawin ang usapin."'),
      ClipBeat(7, 'Leader speaks', 'Leader: "Lip sync lahat."', 'Leader: "May isang kanta na pre-recorded. Hindi lahat."'),
      ClipBeat(18, 'Leader bows', 'Leader: "Pasensya na."', 'Leader: "Pasensya sa kalituhan."'),
    ],
    upload: 'The clip is a short piece of a longer press conference.',
    audio: 'The viral version\'s audio skips between sentences.',
    creator: 'A page that posts only drama about idols.',
    label: 'No label.',
    full: 'In the full video, the leader says one song was pre-recorded and the rest was live.',
    rFull: Relevance.decisive, rAudio: Relevance.support,
    lesson: 'Cutting between sentences made a small clarification sound like a confession. Always look for the full statement.',
    hint: 'Are the words in the viral clip in the same order in the full video?'),
  _Clip('unlabeled_ai_ad', true, 'Health', 'Doctor testimonial',
    'Doc Ramon says this pill cures every lung problem. Buy now.',
    [
      ClipBeat(0, 'Doctor in a clinic', 'Doc: "Ito ang lunas sa lahat ng sakit sa baga."', 'Doc: "Maghugas ng kamay para makaiwas sa sakit."'),
      ClipBeat(10, 'Product shot', 'Doc: "Bumili na bago maubos."', 'Doc: "Magpatingin sa doktor kapag may sintomas."'),
      ClipBeat(20, 'Hotline', 'Doc: "Mag-order sa link."', 'Doc: "Salamat sa panonood."'),
    ],
    upload: 'The video uses footage from a {y1} public health talk by the real doctor.',
    audio: 'The voice is smooth but cuts out whenever the camera moves.',
    creator: 'A seller page created last week.',
    label: 'No AI disclosure.',
    full: 'The doctor\'s original video is about hygiene and never mentions any product.',
    rFull: Relevance.decisive, rAudio: Relevance.support, rUpload: Relevance.support,
    lesson: 'A trusted face and voice were used to sell a product the doctor never mentioned. This is an AI-edited endorsement without disclosure.',
    hint: 'What does the doctor\'s own original video talk about?'),
];

int clipScenarioCount() => _clips.length;
String clipScenarioId(int i) => _clips[i].id;
bool clipScenarioBad(int i) => _clips[i].bad;

ArcadeCase buildClip(Gen g, ArcadeDifficulty d, int index) {
  final c = _clips[index];
  final group = g.pick(Pools.groups);
  final slots = {
    'group': group, 'city': g.pick(Pools.cities), 'queen': g.pick(Pools.queens),
    'y1': '${g.between(2019, 2023)}',
  };
  String f(String s) => fillSlots(s, slots);
  final tools = <Finding>[
    Finding('upload', 'UPLOAD INFO', '📅', f(c.upload), c.rUpload),
    Finding('audio', 'AUDIO', '🎧', f(c.audio), c.rAudio),
    Finding('creator', 'CREATOR', '👤', f(c.creator), c.rCreator),
    Finding('label', 'LABEL', '🏷️', f(c.label), c.rLabel),
    Finding('full', 'FULL VIDEO', '🎬', f(c.full), c.rFull),
  ];
  final beats = [
    for (final b in c.beats)
      ClipBeat(b.second, f(b.scene), f(b.viralLine), f(b.fullLine),
          inViral: b.inViral),
  ];
  final decisive = tools.firstWhere((t) => t.relevance == Relevance.decisive);
  return ArcadeCase(
    signature: 'clip:${c.id}', scenario: c.id, mode: ArcadeMode.clip,
    title: c.title, author: 'Tambayan Reels', handle: '@reels${g.id()}',
    text: f(c.caption), subtext: 'Scrub the timeline and compare both cuts.',
    imageTopic: c.topic, imageCaption: c.title, tools: tools, beats: beats,
    deceptive: c.bad, correct: [c.bad ? 1 : 0],
    choices: const [ArcadeOption('KEEP'), ArcadeOption('REMOVE')],
    lesson: f(c.lesson),
    hint: 'Open ${decisive.emoji} ${decisive.label}. Ask: ${f(c.hint)}',
  );
}
