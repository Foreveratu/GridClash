import 'package:flutter_test/flutter_test.dart';
import 'package:gridclash/game/game_state.dart';

void main() {
  group('GameState', () {
    // Assuming a default grid size for most tests, can be overridden in specific tests
    test(
      'getConnectedCells returns all cells in a fully connected grid for a player',
      () {
        final gameState = GameState(gridWidth: 15, gridHeight: 20);
        // Assume player 1 takes over the entire grid (15x20) - width 15, height 20
        for (int row = 0; row < gameState.gridHeight; row++) {
          for (int col = 0; col < gameState.gridWidth; col++) {
            gameState.grid[row][col].state = CellState.player1;
            // Mark a cell as base for the BFS to start
            if (row == 0 && col == 0) {
              gameState.grid[row][col].isBase =
                  true; // Mark a cell as base for the BFS to start
            }
          }
        }

        final connectedCells = gameState.getConnectedCells(
          gameState.players[0],
        );

        expect(
          connectedCells.length,
          gameState.gridWidth * gameState.gridHeight,
        );
        for (int i = 0; i < gameState.gridHeight; i++) {
          for (int j = 0; j < gameState.gridWidth; j++) {
            expect(
              connectedCells,
              contains(Cell(row: i, col: j)),
            ); // Access gridSize from gameState object
          }
        }
      },
    );

    test(
      'getConnectedCells returns only connected cells in a grid with disconnected sections',
      () {
        final gameState = GameState(gridWidth: 15, gridHeight: 20);
        // Set up a grid with a disconnected section for player 1 (15x20) - width 15, height 20
        // Set all cells to player 1 initially
        for (int row = 0; row < gameState.gridHeight; row++) {
          for (int col = 0; col < gameState.gridWidth; col++) {
            // Access gridSize from gameState object
            gameState.grid[row][col].state = CellState.player1;
            gameState.grid[row][col].isBase = false;
          }
        }

        // Create a barrier of empty cells in the middle column
        final barrierCol =
            gameState.gridWidth ~/
            2; // Use gridWidth for barrier column calculation
        for (int row = 0; row < gameState.gridHeight; row++) {
          gameState.grid[row][barrierCol].state = CellState.empty;
        }

        // Set player 1's base in the left section (e.g., at (0,0))
        gameState.grid[0][0].isBase = true;
        gameState.grid[0][0].state = CellState.player1;

        final connectedCells = gameState.getConnectedCells(
          gameState.players[0],
        );

        // The number of connected cells should be the number of cells on the left side of the barrier
        // For a 15x20 grid, the barrier is at col 7. Columns 0-6 are on the left (7 columns).
        final expectedConnectedCount = gameState.gridHeight * barrierCol;
        expect(connectedCells.length, expectedConnectedCount);

        // Verify that cells beyond the barrier (columns barrierCol + 1 to gridSize -1) are not included
        for (int row = 0; row < gameState.gridHeight; row++) {
          for (int col = barrierCol + 1; col < gameState.gridWidth; col++) {
            // Access gridSize from gameState object
            expect(
              connectedCells,
              isNot(contains(Cell(row: row, col: col))),
            ); // Use Cell with row and col
          }
        }
      },
    );

    test('getConnectedCells returns an empty set for an empty grid', () {
      final gameState = GameState(gridWidth: 15, gridHeight: 20);
      // Reset the grid to be empty (assuming a 15x20 grid)
      for (int row = 0; row < gameState.gridHeight; row++) {
        for (int col = 0; col < gameState.gridWidth; col++) {
          // Use gridWidth for columns
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
        final gameState = GameState(
          gridWidth: 15,
          gridHeight: 20,
        ); // Test with a 1x1 grid
        // Reset grid to empty for this specific test case
        for (int row = 0; row < gameState.gridHeight; row++) {
          for (int col = 0; col < gameState.gridWidth; col++) {
            // Use gridWidth for columns
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
