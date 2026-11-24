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

  static const towns = ['Liwayway', 'Gumamela', 'Masigla', 'Maharlika',
    'Sinag', 'Dalisay', 'Bagong Tala', 'Kalayaan Norte'];
  static const cities = ['Hiraya', 'Tala', 'Bagumbayan', 'Santa Rosalia'];
  static const officials = ['Mayor Del Rosario', 'Mayor Santillan',
    'Cong. Villareal', 'Gov. Ocampo', 'Kap. Dimaculangan', 'Sen. Magtanggol'];
  static const outlets = ['Balitang Bayan PH', 'TeleBalita 24', 'Sulyap News',
    'Tambayan Daily', 'Kanto Courier'];
  static const queens = ['Miss Talahib', 'Diva Pinya', 'Queen Sarsa',
    'Madam Sinigang', 'Lola Halo-Halo'];
  static const groups = ['BAHAGHARI', 'LUNARIS', 'Sampaguita 5', 'ASTRALA'];
  static const schools = ['Northridge University', 'Pag-asa Science High',
    'Kalikasan College', 'St. Gabriel Academy'];
  static const stores = ['Sulit Shop', 'Pabili.ph', 'Tipid Mart',
    'Bili-Bili Hub'];
  static const couriers = ['Kargo Express', 'RushJet', 'Lakad Logistics'];
  static const wallets = ['PesoGo', 'Bayad Wallet', 'TapPay'];
  static const handlesFirst = ['mika', 'jules', 'nica', 'kai', 'paolo', 'iya',
    'rafi', 'lian', 'migs', 'bea', 'tonton', 'ate_sam'];
  static const intros = ['Uy!', 'Mga besh,', 'FYI lang,', 'Hello po!',
    'Grabe,', 'Pa-share po,', 'Update:'];

  static String handle(Gen g) => '@${g.pick(handlesFirst)}${g.id()}';
}

/// Replaces `{slot}` markers.
String fillSlots(String s, Map<String, String> slots) {
  var out = s;
  slots.forEach((k, v) => out = out.replaceAll('{$k}', v));
  return out;
}
