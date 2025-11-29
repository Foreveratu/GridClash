import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'dart:collection';
import 'dart:math';

enum CellState { empty, player1, player2 }

class Cell {
  final int row;
  final int col;
  CellState state;
  bool isAccessible = true;
  bool isBase = false;
  bool isPermanentlyAcquired = false;

  Cell({required this.row, required this.col, this.state = CellState.empty});

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
  late List<List<Cell>> grid;
  final int gridHeight;
  late Player currentPlayer;
  late List<Player> players;
  List<Cell> selectedCells = [];
  List<Cell> attemptedCaptureCells = [];
  List<Cell> player1Base = [];
  List<Cell> player2Base = [];
  Player? winningPlayer;
  bool isGameOver = false;
  final int gridWidth;

  GameState({required this.gridWidth, required this.gridHeight}) {
    grid = List.generate(
      gridHeight,
      (row) => List.generate(gridWidth, (col) => Cell(row: row, col: col)),
    );
    players = [
      Player(id: 1, color: Colors.blue),
      Player(id: 2, color: Colors.red),
    ];
    initializeBases();
    currentPlayer = players[0];
  }

  void initializeBases() {
    final random = Random();
    player1Base.clear();
    player2Base.clear();

    for (int row = 0; row < gridHeight; row++) {
      for (int col = 0; col < gridWidth; col++) {
        grid[row][col].state = CellState.empty;
        grid[row][col].isBase = false;
        grid[row][col].isPermanentlyAcquired = false;
        grid[row][col].isAccessible = true;
      }
    }

    bool player1BasePlaced = false;
    while (!player1BasePlaced) {
      final startRow = random.nextInt(gridHeight - 2);
      final startCol = random.nextInt(gridWidth - 2);
      bool areaIsEmpty = true;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (grid[startRow + i][startCol + j].state != CellState.empty) {
            areaIsEmpty = false;
            break;
          }
        }
        if (!areaIsEmpty) break;
      }
      if (areaIsEmpty) {
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            final cell = grid[startRow + i][startCol + j];
            cell.state = CellState.player1;
            cell.isBase = true;
            player1Base.add(cell);
          }
        }
        player1BasePlaced = true;
      }
    }

    final minDistance = 9.0;
    bool player2BasePlaced = false;
    int attempts = 0;
    const maxAttempts = 100;
    late int startRowPlayer2;
    while (!player2BasePlaced && attempts < maxAttempts) {
      final startCol = random.nextInt(gridWidth - 2);
      attempts++;
      bool areaIsEmpty = true;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          startRowPlayer2 = random.nextInt(gridHeight - 2);
          final cell = grid[startRowPlayer2 + i][startCol + j];
          if (cell.state != CellState.empty) {
            areaIsEmpty = false;
            break;
          }
        }
        if (!areaIsEmpty) break;
      }
      bool overlapsWithPlayer1 = false;
      for (var p1BaseCell in player1Base) {
        if (p1BaseCell.row >= startRowPlayer2 &&
            p1BaseCell.row < startRowPlayer2 + 3 &&
            p1BaseCell.col >= startCol &&
            p1BaseCell.col < startCol + 3) {
          overlapsWithPlayer1 = true;
          break;
        }
      }
      final p1CenterX = player1Base[0].col + 1.5;
      final p1CenterY = player1Base[0].row + 1.5;
      final p2CenterX = startCol + 1.5;
      final p2CenterY = startRowPlayer2 + 1.5;
      final distance = sqrt(
        pow(p2CenterX - p1CenterX, 2) + pow(p2CenterY - p1CenterY, 2),
      );
      final isFarEnough = distance >= minDistance;
      if (areaIsEmpty && !overlapsWithPlayer1 && isFarEnough) {
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            final cell = grid[startRowPlayer2 + i][startCol + j];
            cell.state = CellState.player2;
            cell.isBase = true;
            player2Base.add(cell);
          }
        }
        player2BasePlaced = true;
      }
    }

    if (!player2BasePlaced) {
      developer.log(
        'Random base placement failed after $maxAttempts attempts. Using fallback.',
      );
      for (int row = 0; row < gridHeight; row++) {
        for (int col = 0; col < gridWidth; col++) {
          if (grid[row][col].state == CellState.player2) {
            grid[row][col].state = CellState.empty;
            grid[row][col].isBase = false;
          }
        }
      }
      player2Base.clear();
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          final cell = grid[gridHeight - 3 + i][gridWidth - 3 + j];
          cell.isBase = true;
          player2Base.add(cell);
        }
      }
    }
    notifyListeners();
  }

  void _checkWinCondition() {
    final tempSelected = selectedCells.toSet();
    final currentPlayerState = _playerToCellState(currentPlayer);

    List<Cell> opponentBase = (currentPlayer.id == 1)
        ? player2Base
        : player1Base;

    bool opponentBaseCaptured = opponentBase.every((baseCell) {
      return baseCell.state == currentPlayerState ||
          tempSelected.contains(baseCell);
    });

    if (opponentBaseCaptured) {
      winningPlayer = currentPlayer;
      isGameOver = true;
      developer.log('Player ${currentPlayer.id} WINS!');
    }
  }

  void _updateConnectivity() {
    for (var player in players) {
      final allPlayerCells = grid
          .expand((row) => row)
          .where((cell) => cell.state == _playerToCellState(player))
          .toSet();
      final connectedCells = getConnectedCells(player);
      for (var cell in allPlayerCells) {
        cell.isAccessible = connectedCells.contains(cell);
      }
    }
  }

  void _updateProvisionalConnectivity() {
    final allPlayerCells = grid
        .expand((row) => row)
        .where((cell) => cell.state == _playerToCellState(currentPlayer))
        .toSet();
    final connectedCells = getConnectedCells(
      currentPlayer,
      additionalCells: selectedCells,
    );
    for (var cell in allPlayerCells) {
      cell.isAccessible = connectedCells.contains(cell);
    }
    notifyListeners();
  }

  bool _isAdjacentToOwned(int row, int col) {
    final adjacentOffsets = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ];
    for (var offset in adjacentOffsets) {
      final adjacentRow = row + offset[0];
      final adjacentCol = col + offset[1];
      if (adjacentRow >= 0 &&
          adjacentRow < gridHeight &&
          adjacentCol >= 0 &&
          adjacentCol < gridWidth) {
        final adjacentCell = grid[adjacentRow][adjacentCol];
        if ((adjacentCell.state == _playerToCellState(currentPlayer) &&
                adjacentCell.isAccessible) ||
            selectedCells.contains(adjacentCell)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _isAdjacentToOwnedForPlayer(int row, int col, Player player) {
    final playerState = _playerToCellState(player);
    final adjacentOffsets = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ];
    for (var offset in adjacentOffsets) {
      final adjacentRow = row + offset[0];
      final adjacentCol = col + offset[1];
      if (adjacentRow >= 0 &&
          adjacentRow < gridHeight &&
          adjacentCol >= 0 &&
          adjacentCol < gridWidth) {
        final adjacentCell = grid[adjacentRow][adjacentCol];
        if (adjacentCell.state == playerState && adjacentCell.isAccessible) {
          return true;
        }
      }
    }
    return false;
  }

  bool hasValidMoves(Player player) {
    for (int r = 0; r < gridHeight; r++) {
      for (int c = 0; c < gridWidth; c++) {
        final cell = grid[r][c];
        final opponentState =
            player.id == 1 ? CellState.player2 : CellState.player1;
        if ((cell.state == CellState.empty || cell.state == opponentState) &&
            !cell.isPermanentlyAcquired) {
          if (_isAdjacentToOwnedForPlayer(r, c, player)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  CellState _playerToCellState(Player player) {
    return player.id == 1 ? CellState.player1 : CellState.player2;
  }

  void selectCell(int row, int col) {
    if (isGameOver) return;

    if (row < 0 || row >= gridHeight || col < 0 || col >= gridWidth) return;

    final cell = grid[row][col];

    final isValidForSelection =
        !cell.isPermanentlyAcquired &&
        !selectedCells.contains(cell) &&
        _isAdjacentToOwned(row, col) &&
        (cell.state == CellState.empty ||
            cell.state != _playerToCellState(currentPlayer));

    if (isValidForSelection) {
      if (selectedCells.length < 5) {
        selectedCells.add(cell);
        _updateProvisionalConnectivity();
        developer.log('Selected cell: ($row, ${cell.col})');

        _checkWinCondition();

        if (isGameOver) {
          for (var selectedCell in selectedCells) {
            if (_playerToCellState(currentPlayer) != selectedCell.state &&
                selectedCell.state != CellState.empty) {
              selectedCell.isPermanentlyAcquired = true;
              developer.log(
                'Game over selected cell is permanently acquired: ($row, ${cell.col})',
              );
            }
            selectedCell.state = _playerToCellState(currentPlayer);
          }
          _updateConnectivity();
          selectedCells.clear();
          notifyListeners();
          return;
        }

        if (selectedCells.length == 5) {
          for (var selectedCell in selectedCells) {
            if (_playerToCellState(currentPlayer) != selectedCell.state &&
                selectedCell.state != CellState.empty) {
              selectedCell.isPermanentlyAcquired = true;
              developer.log(
                'Selected cell is permanently acquired: ($row, ${cell.col})',
              );
            }
            selectedCell.state = _playerToCellState(currentPlayer);
          }
          _updateConnectivity();
          selectedCells.clear();
          
          final nextPlayer = (currentPlayer.id == 1) ? players[1] : players[0];

          if (!hasValidMoves(nextPlayer)) {
            isGameOver = true;
            winningPlayer = currentPlayer;
            developer.log(
                'Player ${nextPlayer.id} is blocked. Player ${currentPlayer.id} WINS!');
          } else {
            currentPlayer = nextPlayer;
            developer.log('End of turn. Next player: ${currentPlayer.id}');
          }
        }
        notifyListeners();
      }
    } else {
      developer.log(
        'Cell ($row, ${cell.col}) validation failed. State: ${cell.state}, In Selected: ${selectedCells.contains(cell)}, Adjacent Owned: ${_isAdjacentToOwned(row, col)}',
      );
    }
  }

  void replayGame() {
    grid = List.generate(
      gridHeight,
      (row) => List.generate(gridWidth, (col) => Cell(row: row, col: col)),
    );
    player1Base.clear();
    player2Base.clear();
    initializeBases();
    selectedCells.clear();
    attemptedCaptureCells.clear();
    currentPlayer = players[0];
    winningPlayer = null;
    isGameOver = false;
    notifyListeners();
  }

  Set<Cell> getConnectedCells(Player player, {List<Cell>? additionalCells}) {
    final connectedCells = <Cell>{};
    final queue = Queue<Cell>();
    final visited = <Cell>{};
    final playerState = _playerToCellState(player);

    for (final row in grid) {
      for (final cell in row) {
        if (cell.isBase &&
            cell.state == playerState &&
            !cell.isPermanentlyAcquired &&
            !visited.contains(cell)) {
          queue.add(cell);
          visited.add(cell);
          connectedCells.add(cell);
        }
      }
    }

    final adjacentOffsets = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ];
    while (queue.isNotEmpty) {
      final currentCell = queue.removeFirst();
      for (var offset in adjacentOffsets) {
        final adjacentRow = currentCell.row + offset[0];
        final adjacentCol = currentCell.col + offset[1];
        if (adjacentRow >= 0 &&
            adjacentRow < gridHeight &&
            adjacentCol >= 0 &&
            adjacentCol < gridWidth) {
          final adjacentCell = grid[adjacentRow][adjacentCol];
          bool isPlayerCell = adjacentCell.state == playerState;
          bool isAdditionalCell =
              additionalCells?.contains(adjacentCell) ?? false;

          if ((isPlayerCell || isAdditionalCell) &&
              !visited.contains(adjacentCell)) {
            visited.add(adjacentCell);
            queue.add(adjacentCell);
            connectedCells.add(adjacentCell);
          }
        }
      }
    }
    return connectedCells;
  }

  int get player1Score {
    int count = 0;
    for (var row = 0; row < gridHeight; row++) {
      for (var col = 0; col < gridWidth; col++) {
        if (grid[row][col].state == CellState.player1) {
          count++;
        }
      }
    }
    return count;
  }

  int get player2Score {
    int count = 0;
    for (var row = 0; row < gridHeight; row++) {
      for (var col = 0; col < gridWidth; col++) {
        if (grid[row][col].state == CellState.player2) {
          count++;
        }
      }
    }
    return count;
  }
}
