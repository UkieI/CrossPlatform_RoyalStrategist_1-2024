// ignore_for_file: unnecessary_null_comparison

import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';

class Bishop extends ChessPieces {
  Bishop({
    required super.isWhite,
    super.value = 3,
    // required super.currentPosition,
  });

  @override
  String toString() {
    return "bishop";
  }

  @override
  List<List<int>> move(int row, int col, List<List<ChessPieces?>> board,
      List<int> previousMoved, List<int> previousSelected) {
    List<List<int>> candidateMoves = [];
    var directions = [
      [-1, -1],
      [-1, 1],
      [1, -1],
      [1, 1]
    ];
    for (var direction in directions) {
      var i = 1;
      while (true) {
        var newRow = row + i * direction[0];
        var newCol = col + i * direction[1];
        if (!isInBoard(newRow, newCol)) break;
        if (board[newRow][newCol] != null) {
          if (board[newRow][newCol]!.isWhite != super.isWhite) {
            candidateMoves.add([newRow, newCol]); // capture
          }
          break; // block
        }
        candidateMoves.add([newRow, newCol]);
        i++;
      }
    }

    return candidateMoves;
  }

  @override
  int compareTo(ChessPieces other) {
    return value.compareTo(other.value);
  }
}
