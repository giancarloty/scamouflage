# Architecture

Scamouflage follows an MVC-oriented structure with separate services for scenario generation, persistence, audio and network access. Some widget-local interactions and navigation remain in the views.

## Application structure

```text
lib/
├── main.dart        App entry point and initialization
├── models/         Game data, difficulty, progression and run records
├── views/          Screens, game widgets, theme and presentation
├── controllers/    Game state, session rules and navigation
└── services/       Scenario generation, audio, Firebase and API access
```

## Main components

| Component | Responsibility |
| --- | --- |
| `controllers/engine.dart` | Career Shifts, player progress and local persistence |
| `controllers/arcade_session.dart` | Arcade rounds, hearts, scoring and case selection |
| `models/arcade_models.dart` | Arcade data types and difficulty profiles |
| `services/arcade_generator.dart` | Dispatches case generation to the individual mode generators |
| `services/arcade_*_generator.dart` | Creates scenarios and evidence for each Arcade mode |
| `views/arcade_trust_impostor_chat_clip_views.dart`, `arcade_rumor_inbox_thread_views.dart` | Mini-game interfaces |
| `views/arcade_screens.dart` | Arcade hub and gameplay flow |
| `views/screens.dart` | Main navigation and Career screens |
| `services/auth_service.dart`, `cloud_save_service.dart` | Accounts and cloud progress |
| `services/backend_client.dart`, `leaderboard_service.dart` | Ranked-run requests and leaderboard reads |

## Gameplay flow

1. A view forwards the player's action to the game engine or Arcade session.
2. The controller checks the answer and updates the run state.
3. The view displays feedback and progress; the next case is generated when needed.

## Online features

Firebase Authentication manages accounts, and Cloud Firestore stores online data. Local preferences retain device progress and settings. The Express backend checks Firebase ID tokens and ranked-run submissions before writing leaderboard results. Online features depend on the deployed API and Firebase configuration.

Individual game generators remain separate because each mode has different scenario rules. Tests are kept in `test/`.
