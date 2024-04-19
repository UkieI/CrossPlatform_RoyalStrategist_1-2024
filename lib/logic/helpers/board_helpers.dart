// ignore_for_file: constant_identifier_names

import 'package:chess_flutter_app/logic/board/board.dart';
import 'package:chess_flutter_app/logic/board/game_state.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';

class BoardHelper {
  static const INIT_FEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 0";
  static const TEST_FEN_IM_KNvK = "8/8/8/2k1N3/8/8/2Kp4/8 b - - 0 1";
  static const TEST_FEN_IM_KBvK = "8/8/8/2k1B3/8/8/2Kp4/8 b - - 0 1";
  static const TEST_FEN_IM_KBvKB = "8/8/8/2k1B3/1b6/8/2Kp4/8 b - - 0 1";
  static const TEST_FEN_DRAW = "8/8/8/2k5/8/8/4q3/K7 b - - 0 1";
  static const TEST_FEN_CASTLE = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b - - 0 1";
  static const TEST_FEN_ENPASSANT = "rnbqkbnr/ppp1p1pp/8/3pPp2/8/8/PPPP1PPP/RNBQKBNR w KQkq f3 0 1";

  static const TEST_FEN_PROMOTION_BLACK = "8/8/8/8/8/8/1K3pk1/8 w - - 0 1";
  static const TEST_FEN_PROMOTION_WHITE = "3K4/5P2/8/8/8/1k6/8/8 b - - 0 1";

  static String rowName = "87654321";
  static String colName = "abcdefgh";

  static const a1 = 56;
  static const b1 = 57;
  static const c1 = 58;
  static const d1 = 59;
  static const e1 = 60;
  static const f1 = 61;
  static const g1 = 62;
  static const h1 = 63;

  static const a8 = 0;
  static const b8 = 1;
  static const c8 = 2;
  static const d8 = 3;
  static const e8 = 4;
  static const f8 = 5;
  static const g8 = 6;
  static const h8 = 7;

  static bool isInBoard(int squareIndex) => squareIndex >= 0 && squareIndex < 64;

  static bool sameSquareColor(int squareIndex) => (rowIndex(squareIndex) + colIndex(squareIndex)) % 2 == 0;

  static int rowIndex(int squareIndex) => squareIndex >> 3;
  static int colIndex(int squareIndex) => squareIndex & 7; // 0b000111
  static int indexFromRowCol(int row, int col) => row * 8 + col;
  static bool lightSquareRowCol(int rowIndex, int colIndex) => (rowIndex + colIndex) % 2 != 0;
  static bool lightSquareSquare(int squareIndex) => lightSquareRowCol(rowIndex(squareIndex), colIndex(squareIndex));

  static String squareNameFromRowCol(int fileIndex, int rankIndex) => "${colName[fileIndex]}${rowName[rankIndex]}";

  static String squareNameFromSquare(int squareIndex) => squareNameFromRowCol(colIndex(squareIndex), rowIndex(squareIndex));

  static bool isValidRowCol(int row, int col) => row >= 0 && row < 8 && col >= 0 && col < 8;

  static bool loadPieceFromfen(Board board, String fen) {
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
          if (Piece.pieceType(piece) == Piece.King) {
            Piece.isWhite(piece) ? board.kingSquare[0] = indexSquare : board.kingSquare[1] = indexSquare;
          }
          board.square[indexSquare] = piece;
          addPiece(board, piece, indexSquare);
          col++;
        }
      }
    }

    board.initCastleRight = 15;

    if (!listFenBoard[2].contains("K")) {
      board.initCastleRight &= GameState.clearWhiteKingsideMask;
    }
    if (!listFenBoard[2].contains("Q")) {
      board.initCastleRight &= GameState.clearWhiteQueensideMask;
    }
    if (!listFenBoard[2].contains("k")) {
      board.initCastleRight &= GameState.clearBlackKingsideMask;
    }
    if (!listFenBoard[2].contains("q")) {
      board.initCastleRight &= GameState.clearBlackQueensideMask;
    }

    if (!listFenBoard[3].contains('-')) {
      col = listFenBoard[3].codeUnitAt(0) - 'a'.codeUnitAt(0);
      row = int.parse(listFenBoard[3].substring(1)) - 1;
      // board.enPassantPos = indexFromRowCol(row, col);
    }
    return listFenBoard[1].contains('w') ? true : false;
  }
}
