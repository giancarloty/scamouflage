import 'package:flutter/material.dart';
import '../models/arcade_models.dart';
import '../services/auth_service.dart';
import '../services/leaderboard_service.dart';
import 'theme.dart';

/// Replaces the old "Online features – coming soon" preview card on the
/// Profile screen. Sign-in stays optional; the game works fully offline.
class AccountPanel extends StatefulWidget {
  const AccountPanel({super.key});
  @override
  State<AccountPanel> createState() => _AccountPanelState();
}

class _AccountPanelState extends State<AccountPanel> {
  final _auth = AuthService.instance;
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _registerMode = true;
  bool _hidePassword = true;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _perform(Future<void> Function() action) async {
    setState(() => _error = null);
    try {
      await action();
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Something went wrong. Please try again.');
    }
  }

  Future<void> _submitForm() => _perform(() {
        final email = _email.text.trim();
        final password = _password.text;
        if (email.isEmpty || password.isEmpty) {
          throw const AuthException('Enter your email and password.');
        }
        if (_registerMode) {
          return _auth.register(
              email: email, password: password, username: _username.text);
        }
        return _auth.signIn(email: email, password: password);
      });

  void _openLeaderboard() => Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LeaderboardScreen()));

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: deskBlue.withValues(alpha: .80),
          border: Border.all(color: deskLight, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListenableBuilder(
          listenable: _auth,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 10),
              _body(),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: captionText(13, color: coral)),
              ],
              const Divider(color: deskLight, height: 25),
              _leaderboardRow(),
            ],
          ),
        ),
      );

  Widget _header() {
    final signedIn = _auth.signedIn && _auth.username != null;
    return Row(children: [
      Icon(_auth.available ? Icons.cloud_outlined : Icons.cloud_off_outlined,
          color: parchment),
      const SizedBox(width: 9),
      Expanded(child: Text('ONLINE FEATURES', style: titleText(20, color: paperWhite))),
      InkTag(signedIn ? 'SIGNED IN' : 'OPTIONAL', color: signedIn ? mint : mustard),
    ]);
  }

  Widget _body() {
    if (!_auth.available) {
      return Text(
          'Online features are unavailable right now. The game still works '
          'offline and saves on this device.',
          style: captionText(13, color: parchment));
    }
    if (!_auth.signedIn) return _signedOutForm();
    if (_auth.profileError) {
      return Row(children: [
        Expanded(child: Text('Could not load your profile. Check your connection.',
            style: captionText(13, color: parchment))),
        TextButton(onPressed: _auth.reloadProfile, child: const Text('RETRY')),
      ]);
    }
    if (!_auth.profileLoaded) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(width: 24, height: 24,
                  child: CircularProgressIndicator(strokeWidth: 3))));
    }
    if (_auth.needsUsername) return _chooseUsername();
    return _signedInCard();
  }

  Widget _signedOutForm() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              _registerMode
                  ? 'Create an optional account to join the global rankings. '
                      'Offline play never needs one.'
                  : 'Welcome back, investigator.',
              style: captionText(13, color: parchment)),
          const SizedBox(height: 13),
          if (_registerMode) ...[
            TextField(
              controller: _username,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.alternate_email_rounded),
                labelText: 'Username',
                helperText: '3–16 letters, numbers or _',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 9),
          ],
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.mail_outline_rounded),
              labelText: 'Email address',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 9),
          TextField(
            controller: _password,
            obscureText: _hidePassword,
            onSubmitted: (_) => _auth.busy ? null : _submitForm(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(_hidePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
              ),
              labelText: 'Password',
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _auth.busy ? null : _submitForm,
              icon: Icon(_registerMode ? Icons.person_add_alt_1_rounded : Icons.login_rounded),
              label: Text(_auth.busy
                  ? 'PLEASE WAIT…'
                  : _registerMode ? 'CREATE ACCOUNT' : 'SIGN IN'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _auth.busy ? null : () => _perform(_auth.signInWithGoogle),
              icon: const Icon(Icons.account_circle_outlined),
              label: const Text('CONTINUE WITH GOOGLE'),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() {
                _registerMode = !_registerMode;
                _error = null;
              }),
              child: Text(_registerMode
                  ? 'Already have an account? Sign in'
                  : 'New here? Create an account'),
            ),
          ),
        ],
      );

  Widget _chooseUsername() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pick a username for the leaderboards. Other players will see it.',
              style: captionText(13, color: parchment)),
          const SizedBox(height: 12),
          TextField(
            controller: _username,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.alternate_email_rounded),
              labelText: 'Username',
              helperText: '3–16 letters, numbers or _',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _auth.busy
                  ? null
                  : () => _perform(() => _auth.chooseUsername(_username.text)),
              icon: const Icon(Icons.check_rounded),
              label: const Text('SAVE USERNAME'),
            ),
          ),
          TextButton(onPressed: _auth.signOut, child: const Text('Sign out')),
        ],
      );

  Widget _signedInCard() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.verified_user_outlined, color: mint),
            const SizedBox(width: 9),
            Expanded(
                child: Text('@${_auth.username}',
                    style: titleText(20, color: paperWhite),
                    overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 6),
          Text('Your best arcade runs are ranked worldwide. Offline play still works.',
              style: captionText(13, color: parchment)),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _auth.busy ? null : _auth.signOut,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('SIGN OUT'),
          ),
        ],
      );

  Widget _leaderboardRow() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.leaderboard_outlined, color: parchment),
            const SizedBox(width: 9),
            Expanded(
                child: Text('GLOBAL LEADERBOARDS',
                    style: captionText(16, color: paperWhite))),
          ]),
          const SizedBox(height: 5),
          Text(
              _auth.username != null
                  ? 'Weekly and all-time Top 50 for every mode and difficulty.'
                  : 'Anyone can look. Sign in to get ranked.',
              style: captionText(12, color: parchment)),
          const SizedBox(height: 9),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _auth.available ? _openLeaderboard : null,
              icon: const Icon(Icons.emoji_events_outlined),
              label: const Text('VIEW TOP 50'),
            ),
          ),
        ],
      );
}

// ===========================================================================

class _BoardData {
  final List<LeaderboardEntry> top;
  final MyStanding? mine;
  const _BoardData(this.top, this.mine);
}

/// Top 50 for one period x mode x difficulty, plus the player's own rank.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  static final List<(String, String)> _modes = [
    ('mix', 'ENDLESS MIX'),
    for (final m in ArcadeMode.values) (m.name, m.title),
  ];

  BoardPeriod _period = BoardPeriod.weekly;
  String _mode = 'mix';
  ArcadeDifficulty _difficulty = ArcadeDifficulty.easy;
  late Future<_BoardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_BoardData> _load() async {
    final service = LeaderboardService.instance;
    final top = await service.fetchTop(_period, _mode, _difficulty);
    MyStanding? mine;
    try {
      mine = await service.fetchStanding(_period, _mode, _difficulty);
    } catch (_) {
      // The list is still useful without the player's own rank.
    }
    return _BoardData(top, mine);
  }

  void _change(VoidCallback update) {
    setState(() {
      update();
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: midnight,
        appBar: AppBar(
          backgroundColor: midnight,
          title: Text('LEADERBOARD', style: titleText(24)),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _change(() {}),
            ),
          ],
        ),
        body: Column(children: [
          _filters(),
          Expanded(child: _results()),
          _yourRank(),
        ]),
      );

  Widget _filters() => Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<BoardPeriod>(
              segments: const [
                ButtonSegment<BoardPeriod>(
                    value: BoardPeriod.weekly, label: Text('THIS WEEK')),
                ButtonSegment<BoardPeriod>(
                    value: BoardPeriod.allTime, label: Text('ALL-TIME')),
              ],
              selected: {_period},
              onSelectionChanged: (s) => _change(() => _period = s.first),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ArcadeDifficulty>(
              segments: [
                for (final d in ArcadeDifficulty.values)
                  ButtonSegment<ArcadeDifficulty>(value: d, label: Text(d.title)),
              ],
              selected: {_difficulty},
              onSelectionChanged: (s) => _change(() => _difficulty = s.first),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (final (key, label) in _modes)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(label,
                        style: typewriter(11,
                            color: _mode == key ? coal : parchment)),
                    selected: _mode == key,
                    selectedColor: mustard,
                    backgroundColor: deskBlue,
                    onSelected: (_) => _change(() => _mode = key),
                  ),
                ),
            ]),
          ),
        ]),
      );

  Widget _results() {
    if (!AuthService.instance.available) {
      return _message('Online rankings are unavailable right now.');
    }
    return FutureBuilder<_BoardData>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return _message(
              'Can’t load rankings. Internet is needed only for online rankings.',
              retry: true);
        }
        final top = snap.data!.top;
        if (top.isEmpty) {
          return _message(_period == BoardPeriod.weekly
              ? 'No scores yet this week. Be the first!'
              : 'No scores yet. Be the first!');
        }
        final me = AuthService.instance.user?.uid;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          itemCount: top.length,
          itemBuilder: (context, i) => _row(top[i], top[i].uid == me),
        );
      },
    );
  }

  Widget _message(String text, {bool retry = false}) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(text, textAlign: TextAlign.center, style: captionText(14)),
            if (retry) ...[
              const SizedBox(height: 10),
              OutlinedButton(onPressed: () => _change(() {}), child: const Text('TRY AGAIN')),
            ],
          ]),
        ),
      );

  Widget _row(LeaderboardEntry e, bool mine) {
    const medals = ['🥇', '🥈', '🥉'];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: mine ? mustard.withValues(alpha: .18) : deskBlue,
        border: Border.all(color: mine ? mustard : deskLight, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        SizedBox(
          width: 44,
          child: Text(e.rank <= 3 ? medals[e.rank - 1] : '#${e.rank}',
              style: e.rank <= 3 ? const TextStyle(fontSize: 22) : titleText(17)),
        ),
        Expanded(
          child: Text(mine ? '${e.username} (you)' : e.username,
              overflow: TextOverflow.ellipsis,
              style: captionText(15, color: paperWhite, weight: FontWeight.w700)),
        ),
        Text('${e.score} XP', style: typewriter(13, color: mustard)),
      ]),
    );
  }

  Widget _yourRank() => SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
              color: deskBlue, border: Border(top: BorderSide(color: deskLight))),
          child: ListenableBuilder(
            listenable: AuthService.instance,
            builder: (context, _) {
              if (AuthService.instance.username == null) {
                return Text('Sign in on the Profile tab to get ranked.',
                    style: captionText(13));
              }
              return FutureBuilder<_BoardData>(
                future: _future,
                builder: (context, snap) {
                  final mine = snap.data?.mine;
                  return Text(
                    mine == null
                        ? 'YOUR RANK: play a run on this board to get ranked.'
                        : 'YOUR RANK: #${mine.rank} • best ${mine.score} XP',
                    style: captionText(14, color: mustard, weight: FontWeight.w700),
                  );
                },
              );
            },
          ),
        ),
      );
}