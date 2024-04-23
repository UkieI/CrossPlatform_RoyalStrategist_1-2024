import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';

class StateBoardString {
  String sb = "";

  StateBoardString(
    List<int> square,
    bool isWhiteTurn,
    String? enPassantMove,
    List<bool> isWhiteCastleRight,
    List<bool> isBlackCastleRight,
  ) {
    // Add piece placement data
    addPiecePlacement(square);
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

  void addRowData(List<int> square, int row) {
    int empty = 0;
    for (int c = 0; c < 8; c++) {
      if (square[BoardHelper.indexFromRowCol(row, c)] == Piece.None) {
        empty++;
        continue;
      }
      if (empty > 0) {
        sb += empty.toString();
        empty = 0;
      }
      sb += Piece.getSymbol(square[BoardHelper.indexFromRowCol(row, c)]);
    }
    if (empty > 0) {
      sb += empty.toString();
    }
  }

  void addPiecePlacement(List<int> square) {
    for (int r = 0; r < 8; r++) {
      if (r != 0) {
        sb += "/";
      }
      addRowData(square, r);
    }
  }

  void addCurrentPlayer(bool isWhiteTurn) {
    isWhiteTurn ? sb += 'w' : sb += 'b';
  }

  void addCastlingRights(List<bool> isWhiteCastleRight, List<bool> isBlackCastleRight) {
    if (isWhiteCastleRight.isEmpty && isBlackCastleRight.isEmpty) {
      sb += '-';
      return;
    }

    if (!(isWhiteCastleRight[0] || isWhiteCastleRight[1] || isBlackCastleRight[0] || isBlackCastleRight[1])) {
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
