import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/game/game_state.dart';

void main() {
  group('GameState', () {
    test(
      'getConnectedCells returns all cells in a fully connected grid for a player',
      () {
        final gameState = GameState();
        // Assume player 1 takes over the entire grid
        for (int row = 0; row < gameState.gridSize; row++) {
          for (int col = 0; col < gameState.gridSize; col++) {
            gameState.grid[row][col].state = CellState.player1;
            // Mark a cell as base for the BFS to start
            if (row == 0 && col == 0) {
              gameState.grid[row][col].isBase = true;
            }
          }
        }

        final connectedCells = gameState.getConnectedCells(
          gameState.players[0],
        );

        expect(connectedCells.length, gameState.gridSize * gameState.gridSize);
        for (int i = 0; i < gameState.gridSize; i++) {
          for (int j = 0; j < gameState.gridSize; j++) {
            expect(connectedCells, contains(Cell(row: i, col: j)));
          }
        }
      },
    );

    test(
      'getConnectedCells returns only connected cells in a grid with disconnected sections',
      () {
        final gameState = GameState();
        // Set up a grid with a disconnected section for player 1
        // Set all cells to player 1 initially
        for (int row = 0; row < gameState.gridSize; row++) {
          for (int col = 0; col < gameState.gridSize; col++) {
            gameState.grid[row][col].state = CellState.player1;
            gameState.grid[row][col].isBase = false;
          }
        }

        // Create a barrier of empty cells in the middle column
        final barrierCol = gameState.gridSize ~/ 2;
        for (int row = 0; row < gameState.gridSize; row++) {
          gameState.grid[row][barrierCol].state = CellState.empty;
        }

        // Set player 1's base in the left section (e.g., at (0,0))
        gameState.grid[0][0].isBase = true;
        gameState.grid[0][0].state = CellState.player1;

        final connectedCells = gameState.getConnectedCells(
          gameState.players[0],
        );

        // The number of connected cells should be the number of cells on the left side of the barrier
        // For a 25x25 grid, the barrier is at col 12. Columns 0-11 are on the left (12 columns).
        final expectedConnectedCount = gameState.gridSize * barrierCol;
        expect(connectedCells.length, expectedConnectedCount);

        // Verify that cells beyond the barrier (columns barrierCol + 1 to gridSize - 1) are not included
        for (int row = 0; row < gameState.gridSize; row++) {
          for (int col = barrierCol + 1; col < gameState.gridSize; col++) {
            expect(connectedCells, isNot(contains(Cell(row: row, col: col))));
          }
        }
      },
    );

    test('getConnectedCells returns an empty set for an empty grid', () {
      final gameState = GameState();
      // Reset the grid to be empty
      for (int row = 0; row < gameState.gridSize; row++) {
        for (int col = 0; col < gameState.gridSize; col++) {
          gameState.grid[row][col].state = CellState.empty;
          gameState.grid[row][col].isBase = false; // Ensure no base cells
        }
      }

      final connectedCells = gameState.getConnectedCells(gameState.players[0]);
      expect(connectedCells, isEmpty);
    });

    test(
      'getConnectedCells returns a set with the single cell for a 1x1 grid belonging to the player',
      () {
        final gameState = GameState();
        // Reset grid to empty for this specific test case
        for (int row = 0; row < gameState.gridSize; row++) {
          for (int col = 0; col < gameState.gridSize; col++) {
            gameState.grid[row][col].state = CellState.empty;
            gameState.grid[row][col].isBase = false;
          }
        }
        // Set a single cell to belong to player 1 and be their base
        gameState.grid[0][0].state = CellState.player1;
        gameState.grid[0][0].isBase = true;

        final connectedCells = gameState.getConnectedCells(
          gameState.players[0],
        );
        expect(connectedCells.length, 1);
        expect(connectedCells, contains(Cell(row: 0, col: 0)));
      },
    );
  });
}
