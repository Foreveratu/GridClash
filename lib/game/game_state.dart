import 'package:flutter/material.dart';
// We might need collection later for Set.difference, uncomment if analyze complains.
import 'dart:developer' as developer;
// import 'package:collection/collection.dart';

enum CellState { empty, player1, player2 }

class Cell {
  final int row;
  final int col;
  CellState state;
  bool isAccessible = true;
  bool isBase = false;
  bool isPermanentlyAcquired = false;

  Cell({required this.row, required this.col, this.state = CellState.empty});

  // Override equals and hashCode for Set operations
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cell &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

class Player {
  final int id;
  final Color color;

  Player({required this.id, required this.color});
}

class GameState extends ChangeNotifier {
  final int gridSize = 25;
  late List<List<Cell>> grid;
  late Player currentPlayer;
  late List<Player> players;
  List<Cell> selectedCells = []; // Cells selected in the current turn
  List<Cell> attemptedCaptureCells = []; // Cells where a capture was attempted
  List<Cell> player1Base = []; // List of cells in Player 1's base
  List<Cell> player2Base = []; // List of cells in Player 2's base
  Player? winningPlayer; // Null if no player has won yet
  bool isGameOver = false; // True when a player wins

  GameState() {
    // Initialize the grid with empty cells
    grid = List.generate(
      gridSize,
      (row) => List.generate(gridSize, (col) => Cell(row: row, col: col)),
    );

    // Initialize players
    players = [
      Player(id: 1, color: Colors.blue), // Player 1 is Blue
      Player(id: 2, color: Colors.red), // Player 2 is Red
    ];

    // Initialize bases on the grid
    initializeBases();

    // Player 1 starts the game
    currentPlayer = players[0];
  }

  void initializeBases() {
    // Player 1 base (bottom-left)
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final row = gridSize - 3 + i;
        final col = j;
        if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
          grid[row][col].state = CellState.player1;
          grid[row][col].isBase = true; // Mark as base cell
          player1Base.add(grid[row][col]); // Add to base list
        }
      }
    }

    // Player 2 base (top-right)
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final row = i;
        final col = gridSize - 3 + j;
        if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
          grid[row][col].state = CellState.player2;
          grid[row][col].isBase = true; // Mark as base cell
          player2Base.add(grid[row][col]); // Add to base list
        }
      }
    }

    developer.log('Player 1 Base Cells:');
    for (var cell in player1Base) {
      developer.log('  (${cell.row}, ${cell.col})');
    }
    developer.log('Player 2 Base Cells:');
    for (var cell in player2Base) {
      developer.log('  (${cell.row}, ${cell.col})');
    }

    notifyListeners(); // Notify listeners that the grid has changed
  }

  // Helper to check if a cell is adjacent to a cell owned by the current player or in selectedCells
  bool _isAdjacentToOwned(int row, int col) {
    final adjacentOffsets = [
      [-1, 0], [1, 0], [0, -1], [0, 1], // Up, Down, Left, Right
    ];

    for (var offset in adjacentOffsets) {
      final adjacentRow = row + offset[0];
      final adjacentCol = col + offset[1];

      // Check if the adjacent cell is within bounds
      if (adjacentRow >= 0 &&
          adjacentRow < gridSize &&
          adjacentCol >= 0 &&
          adjacentCol < gridSize) {
        final adjacentCell = grid[adjacentRow][adjacentCol];

        // Check if the adjacent cell belongs to current player (base or captured) AND is accessible
        // OR if the adjacent cell is in the temporarily selected cells AND is accessible
        // OR if the adjacent cell belongs to the opponent AND is NOT accessible (target for capture)
        if (
        // Case 1: Adjacent cell belongs to current player and is accessible
        (adjacentCell.state == _playerToCellState(currentPlayer) &&
                adjacentCell.isAccessible) ||
            // Case 2: Adjacent cell is in temporarily selected cells and is accessible
            (selectedCells.contains(adjacentCell) &&
                adjacentCell.isAccessible) ||
            // Case 3: Adjacent cell belongs to opponent and is NOT accessible (target for capture)
            (adjacentCell.state != _playerToCellState(currentPlayer) &&
                adjacentCell.state != CellState.empty &&
                !adjacentCell.isAccessible)) {
          return true; // Found a valid adjacent cell to expand from
        }
      }
    }
    return false; // No adjacent cell owned by the player or in selectedCells found
  }

  // Helper to determine the CellState corresponding to a Player
  CellState _playerToCellState(Player player) {
    return player.id == 1 ? CellState.player1 : CellState.player2;
  }

  // Handles a cell tap
  void selectCell(int row, int col) {
    // Clear previous attempted captures at the start of a new tap sequence
    attemptedCaptureCells.clear();
    if (row < 0 || row >= gridSize || col < 0 || col >= gridSize) {
      return;
    }

    final cell = grid[row][col]; // Get the cell instance

    // Check if the cell is accessible (not disconnected)
    /*if (!cell.isAccessible) {
      developer.log('Cell ($row, $col) is inaccessible.'); // Debug print
      return;
    }*/

    // Validation:
    // 1. Cell must be empty, OR
    //    If not empty and NOT permanently acquired, must be an opponent's cell (including base).
    // 2. Cell must not already be in selectedCells for this turn. // Duplicate comment - Keeping one
    // 2. Cell must not already be in selectedCells for this turn.
    // 3. Cell must be adjacent to player's territory (owned or temporarily selected).
    final isValidForSelection =
        !cell
            .isPermanentlyAcquired && // La case ne doit PAS être définitivement acquise
        !selectedCells.contains(
          cell,
        ) && // La case ne doit pas déjà être sélectionnée ce tour
        _isAdjacentToOwned(
          row,
          col,
        ) && // La case doit être adjacente à un territoire accessible du joueur
        (cell.state == CellState.empty ||
            cell.state !=
                _playerToCellState(
                  currentPlayer,
                )); // Et si elle n'est pas définitivement acquise, elle doit être vide OU appartenir à l'adversaire.

    if (isValidForSelection) {
      // If the cell is valid and not already selected, add it to selectedCells
      if (selectedCells.length < 5) {
        // Check for 5-cell limit
        selectedCells.add(cell); // Add the cell to the list of selected cells

        notifyListeners(); // Notify listeners to update UI with temporary selection (cross)

        // *** Immediate Connectivity Check for the current player ***
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Get all cells owned by the current player BEFORE temporarily changing selectedCells
          final allCurrentPlayerCellsBeforeSelection = grid
              .expand((row) => row)
              .where((cell) => cell.state == _playerToCellState(currentPlayer))
              .toSet();

          // Temporarily change state of selected cells for connectivity check
          List<CellState> originalStates = [];
          for (var selectedCell in selectedCells) {
            originalStates.add(selectedCell.state);
            selectedCell.state = _playerToCellState(currentPlayer);
          }

          // Get all cells connected to the current player's base
          final connectedCurrentPlayerCells = _getConnectedCells(currentPlayer);

          // Update accessibility based on the immediate check
          for (var playerCell in allCurrentPlayerCellsBeforeSelection) {
            playerCell.isAccessible = connectedCurrentPlayerCells.contains(
              playerCell,
            );
          }

          // *** End Immediate Connectivity Check ***
          notifyListeners(); // Notify listeners to reflect immediate accessibility changes

          // Determine the opponent player
          final opponentPlayer = (currentPlayer.id == 1)
              ? players[1]
              : players[0];
          final opponentBase = (opponentPlayer.id == 1)
              ? player1Base
              : player2Base;

          // Log the state of each opponent base cell before checking victory
          developer.log('Checking opponent base cells for victory:');
          for (var baseCell in opponentBase) {
            developer.log(
              '  Base Cell (${baseCell.row}, ${baseCell.col}): State = ${baseCell.state}, isBase = ${baseCell.isBase}',
            );
          }

          // Check if all opponent's base cells belong to the current player
          bool currentPlayerWins = true;

          for (var baseCell in opponentBase) {
            if (baseCell.state != _playerToCellState(currentPlayer)) {
              currentPlayerWins = false;
              break; // No need to check further, not all base cells are captured
            }
          }

          if (currentPlayerWins) {
            // Handle win condition (e.g., display message, stop game)
            developer.log('Player ${currentPlayer.id} WINS!');
            winningPlayer = currentPlayer; // Set the winning player
            isGameOver = true; // Mark the game as over
            // Si le jeu est terminé, on arrête le traitement de ce tour
            notifyListeners(); // Notify listeners for the game over state change
            return; // Sortir de la méthode selectCell
          }

          // Restore original states of selected cells
          for (int i = 0; i < selectedCells.length; i++) {
            selectedCells[i].state = originalStates[i];
          }

          notifyListeners();
        });

        // If the game is over, stop processing this turn
        if (isGameOver) {
          return; // Exit selectCell
        }

        // *** Immediate Connectivity Check for the opponent player ***
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final opponentPlayer = (currentPlayer.id == 1)
              ? players[1]
              : players[0];

          // Get all cells owned by the opponent BEFORE any temporary changes (shouldn't be any for opponent here, but good practice)
          final allOpponentPlayerCells = grid
              .expand((row) => row)
              .where((cell) => cell.state == _playerToCellState(opponentPlayer))
              .toSet();

          // Get all cells connected to the opponent player's base
          final connectedOpponentPlayerCells = _getConnectedCells(
            opponentPlayer,
          );

          // Update accessibility based on the immediate check for the opponent
          for (var opponentCell in allOpponentPlayerCells) {
            opponentCell.isAccessible = connectedOpponentPlayerCells.contains(
              opponentCell,
            );
          }

          // *** End Immediate Connectivity Check for the opponent player ***

          // Notify listeners to reflect immediate accessibility changes for the opponent as well
          notifyListeners(); // <-- This notifyListeners will update for opponent's accessibility changes
        });

        // *** End Immediate Connectivity Check ***
        developer.log(
          'Selected cell: ($row, ${cell.col})',
        ); // Debug print - Added cell.col

        // Check if 5 cells have been selected
        if (selectedCells.length == 5) {
          // Apply changes, clear selected cells, and switch player
          for (var selectedCell in selectedCells) {
            // If the selected cell was an opponent's cell, mark it as permanently acquired
            if (_playerToCellState(currentPlayer) != selectedCell.state &&
                selectedCell.state != CellState.empty) {
              selectedCell.isPermanentlyAcquired = true;
            }

            selectedCell.state = _playerToCellState(
              currentPlayer,
            ); // Set cell state to current player
          }

          // Log the state of selected cells after applying changes
          developer.log('State of selected cells after applying changes:');
          for (var selectedCell in selectedCells) {
            developer.log(
              '  Selected Cell (${selectedCell.row}, ${selectedCell.col}): State = ${selectedCell.state}, isBase = ${selectedCell.isBase}, isPermanentlyAcquired = ${selectedCell.isPermanentlyAcquired}',
            );
          }

          selectedCells.clear(); // Clear selected cells for the next turn

          // Switch to the next player
          currentPlayer = (currentPlayer.id == 1) ? players[1] : players[0];
          developer.log(
            'End of turn. Next player: ${currentPlayer.id}',
          ); // Debug print

          notifyListeners(); // Notify listeners for final state changes, player switch, and accessibility updates
        }
      }
    } else {
      // Optional: Allow deselecting a cell if it was already selected in this turn
      // if (selectedCells.contains(cell)) {
      //   selectedCells.remove(cell);
      //   notifyListeners();
      // }
      developer.log(
        'Cell ($row, ${cell.col}) validation failed. State: ${cell.state}, In Selected: ${selectedCells.contains(cell)}, Adjacent Owned: ${_isAdjacentToOwned(row, col)}',
      ); // Debug print - More details
    }
  }

  // Resets the game state for a new game
  void replayGame() {
    // Reset grid
    grid = List.generate(
      gridSize,
      (row) => List.generate(gridSize, (col) => Cell(row: row, col: col)),
    );

    // Reset bases
    player1Base.clear(); // Clear existing base cell references
    player2Base.clear();
    initializeBases(); // Re-initialize bases on the new grid

    // Reset turn state
    selectedCells.clear();
    attemptedCaptureCells.clear();
    currentPlayer = players[0]; // Player 1 starts again

    // Reset win state
    winningPlayer = null;
    isGameOver = false;

    notifyListeners(); // Notify listeners to reset the UI
  }

  // Helper to get all cells connected to a player's base using BFS
  Set<Cell> _getConnectedCells(Player player) {
    final connectedCells = <Cell>{};
    final queue = <Cell>[];
    final visited = <Cell>{};

    final playerState = _playerToCellState(player);

    // Start BFS from all cells of the player, including selected ones
    // Iterate over all cells to find those that belong to the player OR are in selectedCells (if checking current player)
    for (var row = 0; row < gridSize; row++) {
      for (var col = 0; col < gridSize; col++) {
        final cell = grid[row][col];
        // Include base cells AND selected cells (if checking current player) as starting points
        if (cell.state == playerState && cell.isBase) {
          // Always start from bases
          if (!visited.contains(cell)) {
            queue.add(cell);
            visited.add(cell);
            connectedCells.add(cell);
          }
        } else if (player == currentPlayer && selectedCells.contains(cell)) {
          // Also start from selected cells if checking current player
          if (!visited.contains(cell)) {
            queue.add(cell);
            visited.add(cell);
            connectedCells.add(cell);
          }
        }
      }
    }

    final adjacentOffsets = [
      [-1, 0], [1, 0], [0, -1], [0, 1], // Up, Down, Left, Right
    ];

    while (queue.isNotEmpty) {
      final currentCell = queue.removeAt(
        0,
      ); // Use removeAt(0) for List as a queue

      for (var offset in adjacentOffsets) {
        final adjacentRow = currentCell.row + offset[0];
        final adjacentCol = currentCell.col + offset[1];

        // Check if the adjacent cell is within bounds
        if (adjacentRow >= 0 &&
            adjacentRow < gridSize &&
            adjacentCol >= 0 &&
            adjacentCol < gridSize) {
          final adjacentCell = grid[adjacentRow][adjacentCol];

          // Check if the adjacent cell belongs to the same player
          // AND has not been visited yet
          if (adjacentCell.state == playerState &&
              !visited.contains(adjacentCell)) {
            visited.add(adjacentCell);
            queue.add(adjacentCell);
            connectedCells.add(
              adjacentCell,
            ); // Add to the set of connected cells
          }
        }
      }
    }

    return connectedCells; // Return the set of all cells connected to the base
  }

  // Getters for player scores
  int get player1Score {
    int count = 0;
    for (var row = 0; row < gridSize; row++) {
      for (var col = 0; col < gridSize; col++) {
        if (grid[row][col].state == CellState.player1) {
          count++;
        }
      }
    }
    return count;
  }

  int get player2Score {
    int count = 0;
    for (var row = 0; row < gridSize; row++) {
      for (var col = 0; col < gridSize; col++) {
        if (grid[row][col].state == CellState.player2) {
          count++;
        }
      }
    }
    return count;
  }

  // TODO: Add Win Condition Check logic
} // End of GameState class
