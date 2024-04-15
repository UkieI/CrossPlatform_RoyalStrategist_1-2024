import 'package:chess_flutter_app/logic/board/board.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';

class StateBoardString {
  String sb = "";

  StateBoardString(
    Board board,
    bool isWhiteTurn,
    String? enPassantMove,
    List<bool> isWhiteCastleRight,
    List<bool> isBlackCastleRight,
  ) {
    // Add piece placement data
    addPiecePlacement(board);
    sb += ' ';
    // Add current player
    addCurrentPlayer(isWhiteTurn);
    sb += ' ';
    // Add castling rights
    addCastlingRights(isWhiteCastleRight, isBlackCastleRight);
    sb += ' ';
    // Add en passant data
    addEnPassant(enPassantMove);
    // sb += ' ${noCaptureOrPawnMoves.toString()}';
    // sb += ' ${fullmove.toString()}';
  }

  @override
  String toString() {
    return sb.toString();
  }

  void addRowData(Board board, int row) {
    int empty = 0;
    for (int c = 0; c < 8; c++) {
      if (board.square[BoardHelper.indexFromRowCol(row, c)] == Piece.None) {
        empty++;
        continue;
      }
      if (empty > 0) {
        sb += empty.toString();
        empty = 0;
      }
      sb += Piece.getSymbol(board.square[BoardHelper.indexFromRowCol(row, c)]);
    }
    if (empty > 0) {
      sb += empty.toString();
    }
  }

  void addPiecePlacement(Board board) {
    for (int r = 0; r < 8; r++) {
      if (r != 0) {
        sb += "/";
      }
      addRowData(board, r);
    }
  }

  void addCurrentPlayer(bool isWhiteTurn) {
    isWhiteTurn ? sb += 'w' : sb += 'b';
  }

  void addCastlingRights(
      List<bool> isWhiteCastleRight, List<bool> isBlackCastleRight) {
    if (isWhiteCastleRight.isEmpty && isBlackCastleRight.isEmpty) {
      sb += '-';
      return;
    }

    if (isWhiteCastleRight.isNotEmpty) {
      if (isWhiteCastleRight[1]) {
        sb += 'K';
      }
      if (isWhiteCastleRight[0]) {
        sb += 'Q';
      }
    }
    if (isBlackCastleRight.isNotEmpty) {
      if (isBlackCastleRight[1]) {
        sb += 'k';
      }
      if (isBlackCastleRight[0]) {
        sb += 'q';
      }
    }
  }

  void addEnPassant(String? enPassantMove) {
    if (enPassantMove != null) {
      sb += enPassantMove;
      return;
    }
    sb += '-';
  }
}
