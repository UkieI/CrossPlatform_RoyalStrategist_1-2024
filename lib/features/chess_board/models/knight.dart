// ignore_for_file: unnecessary_null_comparison

import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';

class Knight extends ChessPieces {
  Knight({
    required super.isWhite,
    super.value = 3,
    // required super.currentPosition,
  });
  @override
  String toString() {
    return "knight";
  }

  @override
  List<List<int>> move(int row, int col, List<List<ChessPieces?>> board,
      List<int> previousMoved, List<int> previousSelected) {
    List<List<int>> candidateMoves = [];
    var knightMoves = [
      [-2, -1],
      [-2, 1],
      [-1, 2],
      [-1, -2],
      [1, -2],
      [1, 2],
      [2, -1],
      [2, 1]
    ];
    for (var moves in knightMoves) {
      var newRow = row + moves[0];
      var newCol = col + moves[1];
      if (!isInBoard(newRow, newCol)) continue;
      if (board[newRow][newCol] != null) {
        if (board[newRow][newCol]!.isWhite != super.isWhite) {
          candidateMoves.add([newRow, newCol]); // capture
        }
        continue; //block
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
