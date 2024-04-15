// ignore_for_file: constant_identifier_names

import 'package:chess_flutter_app/logic/board/board.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';

class BoardHelper {
  static const INIT_FEN =
      "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 0";
  static const TEST_FEN_IM_KNvK = "8/8/8/2k1N3/8/8/2Kp4/8 b - - 0 1";
  static const TEST_FEN_IM_KBvK = "8/8/8/2k1B3/8/8/2Kp4/8 b - - 0 1";
  static const TEST_FEN_IM_KBvKB = "8/8/8/2k1B3/1b6/8/2Kp4/8 b - - 0 1";
  static const TEST_FEN_DRAW = "8/8/8/2k5/8/8/4q3/K7 b - - 0 1";
  static String rowName = "12345678";
  static String colName = "abcdefgh";

  static const a1 = 0;
  static const b1 = 1;
  static const c1 = 2;
  static const d1 = 3;
  static const e1 = 4;
  static const f1 = 5;
  static const g1 = 6;
  static const h1 = 7;

  static const a8 = 56;
  static const b8 = 57;
  static const c8 = 58;
  static const d8 = 59;
  static const e8 = 60;
  static const f8 = 61;
  static const g8 = 62;
  static const h8 = 63;

  static bool isInBoard(int squareIndex) =>
      squareIndex >= 0 && squareIndex < 64;

  static bool sameSquareColor(int squareIndex) =>
      (rowIndex(squareIndex) + colIndex(squareIndex)) % 2 == 0;

  static int rowIndex(int squareIndex) => squareIndex >> 3;
  static int colIndex(int squareIndex) => squareIndex & 7; // 0b000111
  static int indexFromRowCol(int row, int col) => row * 8 + col;
  static bool lightSquareRowCol(int rowIndex, int colIndex) =>
      (rowIndex + colIndex) % 2 != 0;
  static bool lightSquareSquare(int squareIndex) =>
      lightSquareRowCol(rowIndex(squareIndex), colIndex(squareIndex));

  static String squareNameFromRowCol(int fileIndex, int rankIndex) =>
      "${colName[fileIndex]}${rankIndex + 1}";

  static String squareNameFromSquare(int squareIndex) =>
      squareNameFromRowCol(colIndex(squareIndex), rowIndex(squareIndex));

  static bool isValidRowCol(int row, int col) =>
      row >= 0 && row < 8 && col >= 0 && col < 8;

  static void loadPieceFromfen(Board board, String fen) {
    board.square = List.filled(64, 0);
    List<String> listFenBoard = fen.split(' ');
    String fenBoard = listFenBoard[0];
    int row = 0, col = 0;

    for (var rune in fenBoard.runes) {
      String char = String.fromCharCode(rune);
      if (char == '/') {
        row++;
        col = 0;
      } else {
        if (isDigit(char)) {
          col += int.parse(char);
        } else {
          int indexSquare = indexFromRowCol(row, col);
          int piece = Piece.getPieceFromSymbol(char);
          board.square[indexSquare] = piece;
          addPiece(board, piece, indexSquare);
          col++;
        }
      }
    }
  }
}
