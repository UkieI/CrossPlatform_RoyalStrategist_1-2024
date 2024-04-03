// ignore_for_file: unnecessary_null_comparison, unrelated_type_equality_checks

import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';

class Pawn extends ChessPieces {
  Pawn({
    required super.isWhite,
    super.value = 1,
    // required super.currentPosition,
  });

  @override
  List<List<int>> move(int row, int col, List<List<ChessPieces?>> board,
      List<int> previousMoved, List<int> previousSelected) {
    List<List<int>> candidateMoves = [];
    int direction = super.isWhite ? -1 : 1;

    // Pawn-specific move logic
    // pawns can move forward if the square is not occupied
    if (isInBoard(row + direction, col) &&
        board[row + direction][col] == null) {
      candidateMoves.add([row + direction, col]);
    }

    // pawns can move 2 spuares if they are at their intial position
    if ((row == 1 && !super.isWhite) || (row == 6 && super.isWhite)) {
      if (isInBoard(row + 2 * direction, col) &&
          board[row + 2 * direction][col] == null &&
          board[row + direction][col] == null) {
        candidateMoves.add([row + 2 * direction, col]);
      }
    }

    // pawns can kill diagonally
    if ((isInBoard(row + direction, col - 1) &&
        board[row + direction][col - 1] != null &&
        board[row + direction][col - 1]!.isWhite != super.isWhite)) {
      candidateMoves.add([row + direction, col - 1]);
    }
    if (isInBoard(row + direction, col + 1) &&
        board[row + direction][col + 1] != null &&
        board[row + direction][col + 1]!.isWhite != super.isWhite) {
      candidateMoves.add([row + direction, col + 1]);
    }

    // pawns can kill like En Passant
    if (canPawnEnPassant(
        row, direction, col, true, board, previousMoved, previousSelected)) {
      candidateMoves.add([row + direction, col - 1]);
    }
    if (canPawnEnPassant(
        row, direction, col, false, board, previousMoved, previousSelected)) {
      candidateMoves.add([row + direction, col + 1]);
    }

    return candidateMoves;
  }

  @override
  String toString() {
    return 'pawn';
  }

  bool canPawnEnPassant(
    int row,
    int direction,
    int col,
    bool isLeftCheck,
    List<List<ChessPieces?>> board,
    List<int> previousMoved,
    List<int> previousSelected,
  ) {
    int minusValue = isLeftCheck ? -1 : 1;
    return isInBoard(row + direction, col + minusValue) &&
        board[row + direction][col + minusValue] == null &&
        board[row][col + minusValue] != null &&
        board[row][col + minusValue]!.isWhite != isWhite &&
        board[row][col + minusValue] is Pawn &&
        col + minusValue == previousMoved[1] &&
        row == previousMoved[0] &&
        (previousMoved[0] - previousSelected[0]).abs() == 2;
  }

  @override
  int compareTo(ChessPieces other) {
    return value.compareTo(other.value);
  }
}
