import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/game/game_state.dart';
import 'package:myapp/game/game_grid.dart'; // Assurez-vous que GameGrid est importé ici

class GameUI extends StatelessWidget {
  const GameUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        // Ici, nous construirons l'interface de jeu :
        // - Affichage du joueur actuel
        // - Affichage des scores
        // - La grille de jeu

        return Column(
          // Utiliser un Column pour empiler les éléments
          children: [
            Text('Joueur actuel: ${gameState.currentPlayer.id}'),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Score Joueur 1: ${gameState.player1Score}'),
                Text('Score Joueur 2: ${gameState.player2Score}'),
              ],
            ),
            Expanded(
              // GameGrid prend l'espace restant
              child: GameGrid(), // Votre widget de grille de jeu
            ),
          ],
        );
      },
    );
  }
}
