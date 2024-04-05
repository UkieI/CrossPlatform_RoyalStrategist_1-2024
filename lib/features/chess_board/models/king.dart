// ignore_for_file: unnecessary_null_comparison

import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';

class King extends ChessPieces {
  King({required super.isWhite, super.value = 1000, super.hasMoved = false
      // required super.currentPosition,
      });

  @override
  List<List<int>> move(int row, int col, List<List<ChessPieces?>> board,
      List<int> previousMoved, List<int> previousSelected) {
    List<List<int>> candidateMoves = [];
    var directions = [
      [-1, 0], //up
      [1, 0], //down
      [0, -1], //right
      [0, 1], //left
      [-1, -1],
      [-1, 1],
      [1, -1],
      [1, 1]
    ];
    for (var direction in directions) {
      var newRow = row + 1 * direction[0];
      var newCol = col + 1 * direction[1];
      if (!isInBoard(newRow, newCol)) continue;
      if (board[newRow][newCol] != null) {
        if (board[newRow][newCol]!.isWhite != super.isWhite) {
          candidateMoves.add([newRow, newCol]); // capture
        }
        continue; // block
      }
      candidateMoves.add([newRow, newCol]);
    }

    return candidateMoves;
  }

  @override
  int compareTo(ChessPieces other) {
    return value.compareTo(other.value);
  }
}
