import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gridclash/game/game_state.dart'; // Import your game state file

class GameGrid extends StatelessWidget {
  const GameGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return GridView.builder(
          itemCount: gameState.gridWidth * gameState.gridHeight,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gameState.gridWidth,
          ),
          itemBuilder: (context, index) {
            final row = index ~/ gameState.gridWidth; // Integer division to get the row
            final col = index % gameState.gridWidth; // Modulo to get the column
            final cell = gameState.grid[row][col];

            Color cellColor;
            switch (cell.state) {
              case CellState.empty:
                cellColor = Colors.grey[300]!;
                break;
              case CellState.player1:
                cellColor =
                    gameState.players[0].color; // Use player's actual color
                break;
              case CellState.player2:
                cellColor =
                    gameState.players[1].color; // Use player's actual color
                break;
            }

            Color finalCellColor = cellColor;
            if (!cell.isAccessible) {
              finalCellColor = cellColor.withAlpha(128); // 50% opacity
            }

            final double cellSize = MediaQuery.of(context).size.width / gameState.gridWidth;
            return GestureDetector(
              onTap: () {
                gameState.selectCell(row, col);
              },
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(
                      0.5, // Add some spacing between cells
                    ),
                    decoration: BoxDecoration(
                      border: cell.isAccessible
                          ? Border.all(color: Colors.black12, width: 0.5)
                          : Border.all(
                              color: Colors.red,
                              width: 2.0,
                            ), // Red border for inaccessible cells
                      color: finalCellColor,
                    ),
                  ),
                  // Show cross for currently selected cells (temporary)
                  if (gameState.selectedCells.contains(cell))
                    Center(
                      child: Icon(
                        Icons.close,
                        color: gameState.currentPlayer.color, // Ou Colors.white
                        size: cellSize * 0.6, // Ou la taille appropriée
                      ),
                    )
                  // Show black circle for permanently acquired cells (bases included if permanently acquired)
                  else if (cell.isPermanentlyAcquired)
                    Center(
                      child: Icon(
                        Icons.circle,
                        color: Colors.black, // Cercle noir
                        size: cellSize * 0.6, // Taille appropriée
                      ),
                    )
                  // Show black cross for base cells that still belong to the original player
                  else if (cell.isBase)
                    Center(
                      child: Icon(
                        Icons.close,
                        color: Colors
                            .black, // Croix noire pour bases non capturées
                        size: cellSize * 0.6, // Taille appropriée
                      ),
                    )
                  // Show colored cross for other acquired cells (not base, not permanently acquired)
                  else if (cell.state != CellState.empty)
                    Center(
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: cellSize * 0.6, // Taille appropriée
                      ), // If neither, no icon is shown (empty cell)
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
