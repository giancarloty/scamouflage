import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/engine.dart';
import 'services/game_audio.dart';
import 'views/screens.dart';
import 'views/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/cloud_save_service.dart';

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
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AuthService.instance.init();
  } catch (e) {
    debugPrint('Firebase unavailable: $e');
  }
  await GameAudio.instance.initialize();
  runApp(const ScamouflageApp());
}

class ScamouflageApp extends StatefulWidget {
  const ScamouflageApp({super.key});
  @override
  State<ScamouflageApp> createState() => _ScamouflageAppState();
}

class _ScamouflageAppState extends State<ScamouflageApp> with WidgetsBindingObserver {
  late final GameEngine game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    game = GameEngine();
    game.load().then((_) => CloudSaveService.instance.attach(game));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    GameAudio.instance.appVisible(state == AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Scamouflage: Trust or Bust',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: midnight,
          colorScheme: const ColorScheme.dark(
            primary: mustard,
            secondary: mint,
            surface: deskBlue,
            onPrimary: coal,
            onSurface: parchment,
          ),
          textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme),
        ),
        home: GameScreens(game: game),
      );
}