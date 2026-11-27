/// Application navigation rules. This controller does not build widgets.
/// UI widgets ask it whether a transition is allowed and then rebuild.
enum GameView { home, arcade, career, leaderboard, profile, desk, summary }

class NavigationController {
  GameView current = GameView.home;

  static const menuTabs = <GameView>{
    GameView.home,
    GameView.arcade,
    GameView.career,
    GameView.leaderboard,
    GameView.profile,
  };

  /// The bottom tabs must never interrupt an active Arcade challenge.
  bool openTab(GameView tab, {required bool arcadePlaying}) {
    if (arcadePlaying || !menuTabs.contains(tab)) return false;
    current = tab;
    return true;
  }

  bool get onMenu => menuTabs.contains(current);

  void enterCareerChallenge() => current = GameView.desk;

  void showCareerSummary() => current = GameView.summary;

  void returnHome() => current = GameView.home;
}
