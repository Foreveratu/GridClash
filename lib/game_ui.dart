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
            Text(
              'Joueur actuel: ${gameState.currentPlayer.id}',
              style: TextStyle(
                color: gameState
                    .currentPlayer
                    .color, // Utiliser la couleur du joueur actuel
                fontWeight: FontWeight
                    .bold, // Optionnel: rendre le texte en gras pour plus de visibilité
                fontSize: 18.0, // Optionnel: ajuster la taille si nécessaire
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Score Joueur 1: ${gameState.player1Score}',
                  style: TextStyle(
                    color: gameState
                        .players[0]
                        .color, // Utiliser la couleur du joueur actuel
                    fontWeight: FontWeight
                        .bold, // Optionnel: rendre le texte en gras pour plus de visibilité
                    fontSize:
                        18.0, // Optionnel: ajuster la taille si nécessaire
                  ),
                ),
                Text(
                  'Score Joueur 2: ${gameState.player2Score}',
                  style: TextStyle(
                    color: gameState
                        .players[1]
                        .color, // Utiliser la couleur du joueur actuel
                    fontWeight: FontWeight
                        .bold, // Optionnel: rendre le texte en gras pour plus de visibilité
                    fontSize:
                        18.0, // Optionnel: ajuster la taille si nécessaire
                  ),
                ),
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
