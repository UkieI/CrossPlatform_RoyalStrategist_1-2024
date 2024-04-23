// ignore_for_file: constant_identifier_names

import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';

int squareValue(int piece, int pos, bool isWhiteTurn, bool isInEndGame) {
  var indexSquare = isWhiteTurn ? pos : pos + 56 - 16 * (pos / 8).floor();
  int value;
  switch (Piece.pieceType(piece)) {
    case Piece.Pawn:
      {
       value = isInEndGame ? PAWN_END_TABLE[indexSquare] : PAWN_TABLE[indexSquare];
      }
      break;
    case Piece.Knight:
      {
        value = KNIGHT_TABLE[indexSquare];
      }
      break;
    case Piece.Bishop:
      {
        value = BISHOP_TABLE[indexSquare];
      }
      break;
    case Piece.Rook:
      {
        value = ROOK_TABLE[indexSquare];
      }
      break;
    case Piece.Queen:
      {
        value = QUEEN_TABLE[indexSquare];
      }
      break;
    case Piece.King:
      {
        value = isInEndGame ? KING_END_TABLE[indexSquare] : KING_TABLE[indexSquare];
      }
      break;
    default:
      {
        value = 0;
      }
      break;
  }
  return value;
}

class PieceSquareTable {
  static int read(var table, int square, bool isWhite) {
    if (isWhite) {
      int col = BoardHelper.colIndex(square);
      int row = BoardHelper.rowIndex(square);
      row = 7 - row;
      square = BoardHelper.indexFromRowCol(row, col);
    }
    return table[square];
  }
}

// dart: fmt_off

const KING_TABLE = [
  -30, -40, -40, -50, -50, -40, -40, -30,
  -30, -40, -40, -50, -50, -40, -40, -30,
  -30, -40, -40, -50, -50, -40, -40, -30,
  -30, -40, -40, -50, -50, -40, -40, -30,
  -20, -30, -30, -40, -40, -30, -30, -20,
  -10, -20, -20, -20, -20, -20, -20, -10,
   20,  20, -10, -10, -10, -10,  20,  20,
   20,  30,  10,   0,   0,  10,  30,  20
];

const KING_END_TABLE = [
  -20, -10, -10, -10, -10, -10, -10, -20,
  -5,   0,   5,   5,   5,   5,   0,  -5,
  -10, -5,   20,  30,  30,  20,  -5, -10,
  -15, -10,  35,  45,  45,  35, -10, -15,
  -20, -15,  30,  40,  40,  30, -15, -20,
  -25, -20,  20,  25,  25,  20, -20, -25,
  -30, -25,   0,   0,   0,   0, -25, -30,
  -50, -30, -30, -30, -30, -30, -30, -50
];

const QUEEN_TABLE = [
  -20, -10, -10,  -5,  -5, -10, -10, -20,
  -10,   0,   0,   0,   0,   0,   0, -10,
  -10,   0,   5,   5,   5,   5,   0, -10,
   -5,   0,   5,   5,   5,   5,   0,  -5,
    0,   0,   5,   5,   5,   5,   0,  -5,
  -10,   5,   5,   5,   5,   5,   0, -10,
  -10,   0,   5,   0,   0,   0,   0, -10,
  -20, -10, -10,  -5,  -5, -10, -10, -20
];

const ROOK_TABLE = [
    0,   0,   0,   0,   0,   0,   0,   0,
    5,  10,  10,  10,  10,  10,  10,   5,
   -5,   0,   0,   0,   0,   0,   0,  -5,
   -5,   0,   0,   0,   0,   0,   0,  -5,
   -5,   0,   0,   0,   0,   0,   0,  -5,
   -5,   0,   0,   0,   0,   0,   0,  -5,
   -5,   0,   0,   0,   0,   0,   0,  -5,
    0,   0,   0,   5,   5,   0,   0,   0
];

const BISHOP_TABLE = [
  -20, -10, -10, -10, -10, -10, -10, -20,
  -10,   0,   0,   0,   0,   0,   0, -10,
  -10,   0,   5,  10,  10,   5,   0, -10,
  -10,   5,   5,  10,  10,   5,   5, -10,
  -10,   0,  10,  10,  10,  10,   0, -10,
  -10,  10,  10,  10,  10,  10,  10, -10,
  -10,   5,   0,   0,   0,   0,   5, -10,
  -20, -10, -10, -10, -10, -10, -10, -20
];

const KNIGHT_TABLE = [
  -50, -40, -30, -30, -30, -30, -40, -50,
  -40, -20,   0,   0,   0,   0, -20, -40,
  -30,   0,  10,  15,  15,  10,   0, -30,
  -30,   5,  15,  20,  20,  15,   5, -30,
  -30,   0,  15,  20,  20,  15,   0, -30,
  -30,   5,  10,  15,  15,  10,   5, -30,
  -40, -20,   0,   5,   5,   0, -20, -40,
  -50, -40, -30, -30, -30, -30, -40, -50
];

const PAWN_TABLE = [
  0,   0,   0,   0,   0,   0,   0,   0,
  50,  50,  50,  50,  50,  50,  50,  50,
  10,  10,  20,  30,  30,  20,  10,  10,
  5,   5,  10,  25,  25,  10,   5,   5,
  0,   0,   0,  20,  20,   0,   0,   0,
  5,  -5, -10,   0,   0, -10,  -5,   5,
  5,  10,  10, -20, -20,  10,  10,   5,
  0,   0,   0,   0,   0,   0,   0,   0
];

const PAWN_END_TABLE = [
  0,   0,   0,   0,   0,   0,   0,   0,
  80,  80,  80,  80,  80,  80,  80,  80,
  50,  50,  50,  50,  50,  50,  50,  50,
  30,  30,  30,  30,  30,  30,  30,  30,
  20,  20,  20,  20,  20,  20,  20,  20,
  10,  10,  10,  10,  10,  10,  10,  10,
  10,  10,  10,  10,  10,  10,  10,  10,
  0,   0,   0,   0,   0,   0,   0,   0
];
// dart: fmt_on
