import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/engine.dart';
import 'services/game_audio.dart';
import 'views/screens.dart';
import 'views/theme.dart';
// This is the main entry point for the Scamouflage app. It initializes the game engine, sets up the app's theme and orientation, and runs the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: midnight,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  await GameAudio.instance.initialize();
  runApp(const ScamouflageApp());
}

class ScamouflageApp extends StatefulWidget {
  const ScamouflageApp({super.key});
  @override State<ScamouflageApp> createState() => _ScamouflageAppState();
}

class _ScamouflageAppState extends State<ScamouflageApp> with WidgetsBindingObserver {
  late final GameEngine game;
  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    game = GameEngine();
    game.load();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    GameAudio.instance.appVisible(state == AppLifecycleState.resumed);
  }

  @override void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    game.dispose();
    super.dispose();
  }
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'Scamouflage: Trust or Bust',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: midnight,
      colorScheme: const ColorScheme.dark(primary: mustard, secondary: mint, surface: deskBlue, onPrimary: coal, onSurface: parchment),
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme),
    ),
    home: GameScreens(game: game),
  );
}
