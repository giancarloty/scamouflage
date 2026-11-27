import 'package:flutter/material.dart';
import '../models/arcade_models.dart';
import '../services/auth_service.dart';
import '../services/leaderboard_service.dart';
import 'theme.dart';
import 'package:flutter/gestures.dart';

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
      if (mounted) {
        setState(() => _error = 'Something went wrong. Please try again.');
      }
    }
  }

  Future<void> _submitForm() => _perform(() {
    final identifier = _email.text.trim();
    final password = _password.text;
    if (_registerMode) {
      if (_username.text.trim().isEmpty ||
          identifier.isEmpty ||
          password.isEmpty) {
        throw const AuthException('Enter your username, email, and password.');
      }
      return _auth.register(
        email: identifier,
        password: password,
        username: _username.text,
      );
    }
    if (identifier.isEmpty || password.isEmpty) {
      throw const AuthException('Enter your email or username and password.');
    }
    return _auth.signIn(identifier: identifier, password: password);
  });

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
        ],
      ),
    ),
  );

  Widget _header() {
    final signedIn = _auth.signedIn && _auth.username != null;
    return Row(
      children: [
        Icon(
          _auth.available ? Icons.cloud_outlined : Icons.cloud_off_outlined,
          color: parchment,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            'ONLINE FEATURES',
            style: titleText(20, color: paperWhite),
          ),
        ),
        InkTag(
          signedIn ? 'SIGNED IN' : 'OPTIONAL',
          color: signedIn ? mint : mustard,
        ),
      ],
    );
  }

  Widget _body() {
    if (!_auth.available) {
      return Text(
        'Online features are unavailable right now. The game still works '
        'offline and saves on this device.',
        style: captionText(13, color: parchment),
      );
    }
    if (!_auth.signedIn) return _signedOutForm();
    if (_auth.profileError) {
      return Row(
        children: [
          Expanded(
            child: Text(
              'Could not load your profile. Check your connection.',
              style: captionText(13, color: parchment),
            ),
          ),
          TextButton(
            onPressed: _auth.reloadProfile,
            child: const Text('RETRY'),
          ),
        ],
      );
    }
    if (!_auth.profileLoaded) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      );
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
        style: captionText(13, color: parchment),
      ),
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
        keyboardType: _registerMode
            ? TextInputType.emailAddress
            : TextInputType.text,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(
            _registerMode
                ? Icons.mail_outline_rounded
                : Icons.person_outline_rounded,
          ),
          labelText: _registerMode ? 'Email address' : 'Email or Username',
          border: const OutlineInputBorder(),
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
            icon: Icon(
              _hidePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
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
          icon: Icon(
            _registerMode
                ? Icons.person_add_alt_1_rounded
                : Icons.login_rounded,
          ),
          label: Text(
            _auth.busy
                ? 'PLEASE WAIT…'
                : _registerMode
                ? 'CREATE ACCOUNT'
                : 'SIGN IN',
          ),
        ),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () => setState(() {
            _registerMode = !_registerMode;
            _error = null;
          }),
          child: Text(
            _registerMode
                ? 'Already have an account? Sign in'
                : 'New here? Create an account',
          ),
        ),
      ),
    ],
  );

  Widget _chooseUsername() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Pick a username for the leaderboards. Other players will see it.',
        style: captionText(13, color: parchment),
      ),
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

  Future<void> _showChangeUsernameDialog() async {
    final ctrl = TextEditingController(text: _auth.username ?? '');
    final next = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: deskBlue,
        title: Text('CHANGE USERNAME', style: titleText(20, color: mustard)),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.alternate_email_rounded),
            labelText: 'New username',
            helperText: '3–16 letters, numbers or _',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (next != null && next.trim().isNotEmpty) {
      await _perform(() => _auth.changeUsername(next));
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: deskBlue,
        title: Text('DELETE ACCOUNT?', style: titleText(20, color: coral)),
        content: Text(
          'This permanently deletes your account, cloud save, and leaderboard scores. This cannot be undone.',
          style: captionText(14, color: paperWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: coral),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _perform(_auth.deleteAccount);
    }
  }

  Widget _signedInCard() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: mint),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              '@${_auth.username}',
              style: titleText(20, color: paperWhite),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        'Your progress, cosmetics, and best runs sync across devices.',
        style: captionText(13, color: parchment),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: _auth.busy ? null : _showChangeUsernameDialog,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('CHANGE USERNAME'),
          ),
          OutlinedButton.icon(
            onPressed: _auth.busy ? null : _auth.signOut,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('SIGN OUT'),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: coral),
            onPressed: _auth.busy ? null : _confirmDeleteAccount,
            icon: const Icon(Icons.delete_forever_outlined),
            label: const Text('DELETE ACCOUNT'),
          ),
        ],
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
  final bool embedded;
  const LeaderboardScreen({super.key, this.embedded = false});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  static final List<(String, String)> _modes = [
    ('overall', 'OVERALL XP'),
    ('mix', 'ENDLESS MIX'),
    for (final m in ArcadeMode.values) (m.name, m.title),
  ];

  BoardPeriod _period = BoardPeriod.weekly;
  String _mode = 'overall';
  ArcadeDifficulty _difficulty = ArcadeDifficulty.easy;
  late Future<_BoardData> _future;

  final ScrollController _modeScroll = ScrollController();

  @override
  void dispose() {
    _modeScroll.dispose();
    super.dispose();
  }

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
      automaticallyImplyLeading: !widget.embedded,
      title: Text('LEADERBOARD', style: titleText(24)),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => _change(() {}),
        ),
      ],
    ),
    body: Column(
      children: [
        _filters(),
        Expanded(child: _results()),
        _yourRank(),
      ],
    ),
  );

  Widget _filters() => Padding(
    padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
    child: SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stretch = constraints.maxWidth >= 920;
              if (stretch) {
                return Row(
                  children: [
                    for (var i = 0; i < _modes.length; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(child: _modeTab(_modes[i].$1, _modes[i].$2)),
                    ],
                  ],
                );
              }
              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: Scrollbar(
                  controller: _modeScroll,
                  thumbVisibility: true,
                  interactive: true,
                  child: SingleChildScrollView(
                    controller: _modeScroll,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        for (var i = 0; i < _modes.length; i++) ...[
                          if (i > 0) const SizedBox(width: 6),
                          _modeTab(_modes[i].$1, _modes[i].$2),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (_mode != 'overall') ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<BoardPeriod>(
                segments: const [
                  ButtonSegment<BoardPeriod>(
                    value: BoardPeriod.weekly,
                    label: Text('THIS WEEK'),
                  ),
                  ButtonSegment<BoardPeriod>(
                    value: BoardPeriod.allTime,
                    label: Text('ALL-TIME'),
                  ),
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
                    ButtonSegment<ArcadeDifficulty>(
                      value: d,
                      label: Text(d.title),
                    ),
                ],
                selected: {_difficulty},
                onSelectionChanged: (s) => _change(() => _difficulty = s.first),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _modeTab(String key, String label) {
    final selected = _mode == key;
    return Material(
      color: selected ? mustard : deskBlue,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => _change(() => _mode = key),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? mustard : parchment.withValues(alpha: .5),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check_rounded, size: 14, color: coal),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typewriter(11, color: selected ? coal : parchment),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            retry: true,
          );
        }
        final top = snap.data!.top;
        if (top.isEmpty) {
          return _message(
            _mode == 'overall'
                ? 'No overall XP scores synced yet. Play and sign in to be first!'
                : _period == BoardPeriod.weekly
                ? 'No scores yet this week. Be the first!'
                : 'No scores yet. Be the first!',
          );
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, textAlign: TextAlign.center, style: captionText(14)),
          if (retry) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => _change(() {}),
              child: const Text('TRY AGAIN'),
            ),
          ],
        ],
      ),
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
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              e.rank <= 3 ? medals[e.rank - 1] : '#${e.rank}',
              style: e.rank <= 3
                  ? const TextStyle(fontSize: 22)
                  : titleText(17),
            ),
          ),
          Expanded(
            child: Text(
              mine ? '${e.username} (you)' : e.username,
              overflow: TextOverflow.ellipsis,
              style: captionText(
                15,
                color: paperWhite,
                weight: FontWeight.w700,
              ),
            ),
          ),
          Text('${e.score} XP', style: typewriter(13, color: mustard)),
        ],
      ),
    );
  }

  Widget _yourRank() => SafeArea(
    top: false,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: deskBlue,
        border: Border(top: BorderSide(color: deskLight)),
      ),
      child: ListenableBuilder(
        listenable: AuthService.instance,
        builder: (context, _) {
          if (AuthService.instance.username == null) {
            return Text(
              'Sign in on the Profile tab to get ranked.',
              style: captionText(13),
            );
          }
          return FutureBuilder<_BoardData>(
            future: _future,
            builder: (context, snap) {
              final mine = snap.data?.mine;
              return Text(
                mine == null
                    ? (_mode == 'overall'
                          ? 'YOUR RANK: earn XP and sync to get ranked.'
                          : 'YOUR RANK: play a run on this board to get ranked.')
                    : (_mode == 'overall'
                          ? 'YOUR RANK: #${mine.rank} • ${mine.score} total XP'
                          : 'YOUR RANK: #${mine.rank} • best ${mine.score} XP'),
                style: captionText(14, color: mustard, weight: FontWeight.w700),
              );
            },
          );
        },
      ),
    ),
  );
}

/// Dedicated page for signing in, registering, changing username, or deleting account.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: midnight,
    appBar: AppBar(
      backgroundColor: midnight,
      title: Text('ACCOUNT', style: titleText(24, color: mustard)),
    ),
    body: SafeArea(
      child: DeskBackdrop(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: const AccountPanel(),
            ),
          ),
        ),
      ),
    ),
  );
}
