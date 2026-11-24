import 'package:flutter_test/flutter_test.dart';
import 'package:scamouflage/controllers/navigation_controller.dart';

void main() {
  test('all four tabs stay in the menu, never start gameplay', () {
    final controller = NavigationController();
    for (final tab in NavigationController.menuTabs) {
      expect(controller.openTab(tab, arcadePlaying: false), true);
      expect(controller.current, tab);
      expect(controller.onMenu, true);
    }
  });

  test('an active arcade run cannot be interrupted by menu tabs', () {
    final controller = NavigationController();
    controller.openTab(GameView.arcade, arcadePlaying: false);
    expect(controller.openTab(GameView.home, arcadePlaying: true), false);
    expect(controller.current, GameView.arcade);
  });

  test('career gameplay and result pages are separate from menu tabs', () {
    final controller = NavigationController();
    controller.enterCareerChallenge();
    expect(controller.current, GameView.desk);
    expect(controller.onMenu, false);
    controller.showCareerSummary();
    expect(controller.current, GameView.summary);
    expect(controller.onMenu, false);
    controller.returnHome();
    expect(controller.onMenu, true);
  });
}
