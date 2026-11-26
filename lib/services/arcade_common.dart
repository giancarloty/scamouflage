import 'dart:math';

/// Thin wrapper around [Random] with the helpers every mode generator uses.
class Gen {
  final Random r;
  Gen(this.r);

  T pick<T>(List<T> items) => items[r.nextInt(items.length)];
  bool chance(double p) => r.nextDouble() < p;
  int between(int low, int high) => low + r.nextInt(high - low + 1);
  int id() => 100 + r.nextInt(900);
  List<T> shuffled<T>(Iterable<T> items) => items.toList()..shuffle(r);

  /// Picks [n] distinct items.
  List<T> sample<T>(List<T> items, int n) =>
      shuffled(items).take(n).toList();
}

/// Fictional content pools. No real people, parties or live websites.
class Pools {
  Pools._();

  static const towns = [
    'Liwayway', 'Gumamela', 'Masigla', 'Maharlika', 'Sinag', 'Dalisay',
    'Bagong Tala', 'Kalayaan Norte', 'Mapayapa', 'Maligaya', 'Bukang-Liwayway',
    'Luntian', 'Payapa', 'Sampaguita', 'Silangan', 'Pulang Lupa',
  ];
  static const cities = [
    'Hiraya', 'Tala', 'Bagumbayan', 'Santa Rosalia', 'San Isidro del Sol',
    'Lungsod Amihan', 'Nueva Liwayway', 'Porto Maharlika', 'Sierra Verde',
    'Villa Dalisay', 'Lakan City', 'San Teodoro',
  ];
  static const officials = ['Mayor Del Rosario', 'Mayor Santillan',
    'Cong. Villareal', 'Gov. Ocampo', 'Kap. Dimaculangan', 'Sen. Magtanggol',
    'Mayor Balagtas', 'Gov. Mapili', 'Cong. Alon', 'Kap. Luntian',
    'Sen. Marikit', 'Mayor Silayan', 'Gov. Dayao', 'Cong. Hiraya'];
  static const outlets = [
    'Balitang Bayan PH', 'TeleBalita 24', 'Sulyap News', 'Tambayan Daily',
    'Kanto Courier', 'Bayanihan Bulletin', 'Hiraya Today', 'Agila Updates',
    'Pintig Newsroom', 'The Barangay Ledger', 'Tala Tribune', 'Sinag Reports',
  ];
  static const queens = [
    'Miss Talahib', 'Diva Pinya', 'Queen Sarsa', 'Madam Sinigang',
    'Lola Halo-Halo', 'Reyna Sampaguita', 'Miss Kalamansi', 'Diva Bituin',
    'Queen Mais', 'Madam Ube', 'Lola Sampalok', 'Reyna Liwayway',
  ];
  static const groups = [
    'BAHAGHARI', 'LUNARIS', 'Sampaguita 5', 'ASTRALA', 'AMIHAN',
    'TALA NOVA', 'KALAYAAN', 'MABUHAY7', 'SINAG CREW', 'Hiraya',
    'Bituin Avenue', 'MAYA MUSE',
  ];
  static const schools = [
    'Northridge University', 'Pag-asa Science High', 'Kalikasan College',
    'St. Gabriel Academy', 'Hiraya Polytechnic', 'Amihan State University',
    'San Isidro Learning Center', 'Liwayway Technical Institute',
    'Luntian National High', 'Maharlika Arts College',
    'Dalisay Community School', 'Sampaguita Science Academy',
  ];
  static const stores = [
    'Sulit Shop', 'Pabili.ph', 'Tipid Mart', 'Bili-Bili Hub', 'Tindahan 24',
    'Mura Market', 'Hiraya Finds', 'Suki Central', 'Pitik Picks',
    'Luntian Living', 'Kahon Corner', 'Ginhawa Goods',
  ];
  static const couriers = [
    'Kargo Express', 'RushJet', 'Lakad Logistics', 'BilisBox',
    'Hatid Bayan', 'Agila Parcel', 'Sulong Delivery', 'Tala Transit',
    'Kahon Ko', 'Pinto-to-Pinto',
  ];
  static const wallets = [
    'PesoGo', 'Bayad Wallet', 'TapPay', 'SukiPay', 'Hiraya Cash',
    'BilisPeso', 'Bayan Wallet', 'TalaPay', 'KitaKita', 'Luntian Money',
  ];
  static const handlesFirst = ['mika', 'jules', 'nica', 'kai', 'paolo', 'iya',
    'rafi', 'lian', 'migs', 'bea', 'tonton', 'ate_sam', 'tala', 'enzo',
    'yumi', 'omar', 'rhea', 'basti', 'javi', 'luz', 'cleo', 'nori', 'cielo',
    'toni', 'mavi', 'santi', 'aya', 'renzo', 'dani', 'zeph', 'kiko',
    'sela', 'ari', 'noel', 'mira'];
  static const intros = ['Uy!', 'Mga besh,', 'FYI lang,', 'Hello po!',
    'Grabe,', 'Pa-share po,', 'Update:', 'Quick heads-up,', 'Kamusta!',
    'Team,', 'May nakita ako:', 'Share ko lang:', 'Good day po,'];

  static String handle(Gen g) => '@${g.pick(handlesFirst)}${g.id()}';
}

/// Replaces `{slot}` markers.
String fillSlots(String s, Map<String, String> slots) {
  var out = s;
  slots.forEach((k, v) => out = out.replaceAll('{$k}', v));
  return out;
}
