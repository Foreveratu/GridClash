import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts
import 'package:provider/provider.dart'; // Import Provider
import 'package:myapp/game/game_state.dart'; // Import your GameState
import 'package:myapp/game_ui.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameState(), // Provide GameState
      child: const MyApp(),
    ),
  );
}

// ThemeProvider class to manage the theme state (Assuming you still use this or similar)
// class ThemeProvider with ChangeNotifier {
//   ThemeMode _themeMode = ThemeMode.system; // Default to system theme

//   ThemeMode get themeMode => _themeMode;

//   void toggleTheme() {
//     _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
//     notifyListeners();
//   }

//   void setSystemTheme() {
//     _themeMode = ThemeMode.system;
//     notifyListeners();
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const MaterialColor primarySeedColor = Colors.deepPurple;

    // Define a common TextTheme
    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.oswald(
        fontSize: 57,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
    );

    // Light Theme
    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

    // Dark Theme
    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: primarySeedColor.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

    // Note: Assuming you are using a direct MyHomePage or similar for the home screen
    // If you have routing set up (e.g., go_router), you would configure routes here
    return MaterialApp(
      title: 'Flutter Material AI App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode
          .system, // Or Consumer<ThemeProvider>(...) if ThemeProvider is used
      home: const MyHomePage(), // Assuming your game UI is in MyHomePage
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  // Dans la méthode build de votre widget principal (ex: MyHomePage)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture de Territoire'), // Votre titre
      ),
      body: Consumer<GameState>(
        // Utiliser Consumer pour écouter les changements dans GameState
        builder: (context, gameState, child) {
          if (gameState.isGameOver) {
            // Si la partie est terminée, afficher l'écran de victoire
            return Center(
              // Center le contenu
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Aligner au centre verticalement
                children: [
                  Text(
                    // Message de victoire
                    'Joueur ${gameState.winningPlayer!.id} GAGNE !', // Utiliser le joueur gagnant
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: gameState
                          .winningPlayer!
                          .color, // Utiliser la couleur du joueur gagnant
                    ),
                  ),
                  const SizedBox(height: 20), // Espacement
                  ElevatedButton(
                    // Bouton Replay
                    onPressed: () {
                      gameState
                          .replayGame(); // Appeler la méthode replay (à créer)
                    },
                    child: const Text('Rejouer'),
                  ),
                ],
              ),
            );
          } else {
            // Si la partie n'est pas terminée, afficher la grille de jeu
            return GameUI();
          }
        },
      ),
    );
  }
}
