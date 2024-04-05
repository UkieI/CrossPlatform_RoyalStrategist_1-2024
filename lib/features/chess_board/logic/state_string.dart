import 'package:chess_flutter_app/features/chess_board/models/bishop.dart';
import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/features/chess_board/models/king.dart';
import 'package:chess_flutter_app/features/chess_board/models/knight.dart';
import 'package:chess_flutter_app/features/chess_board/models/pawn.dart';
import 'package:chess_flutter_app/features/chess_board/models/queen.dart';
import 'package:chess_flutter_app/features/chess_board/models/rook.dart';

class StateBoardString {
  String sb = "";

  StateBoardString(
      bool isWhiteTurn,
      List<List<ChessPieces?>> board,
      List<bool>? isCastleKing,
      String? enPassantMove,
      int noCaptureOrPawnMoves,
      int fullmove) {
    // Add piece placement data
    addPiecePlacement(board);
    sb += ' ';
    // Add current player
    addCurrentPlayer(isWhiteTurn);
    sb += ' ';
    // Add castling rights
    addCastlingRights(isCastleKing);
    sb += ' ';
    // Add en passant data
    addEnPassant(enPassantMove);
    // sb += ' ${noCaptureOrPawnMoves.toString()}';
    // sb += ' ${fullmove.toString()}';
  }

  @override
  String toString() {
    // print(sb);
    return sb.toString();
  }

  String charPiecePEN(ChessPieces piece) {
    String c = '';
    if (piece is Pawn) c = 'p';
    if (piece is Rook) c = 'r';
    if (piece is Knight) c = "n";
    if (piece is Bishop) c = "b";
    if (piece is Queen) c = "q";
    if (piece is King) c = "k";

    if (piece.isWhite) {
      return c.toUpperCase();
    }
    return c;
  }

  void addRowData(List<List<ChessPieces?>> board, int row) {
    int empty = 0;
    for (int c = 0; c < 8; c++) {
      if (board[row][c] == null) {
        empty++;
        continue;
      }
      if (empty > 0) {
        sb += empty.toString();
        empty = 0;
      }
      sb += charPiecePEN(board[row][c]!);
    }
    if (empty > 0) {
      sb += empty.toString();
    }
  }

  void addPiecePlacement(List<List<ChessPieces?>> board) {
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

  void addCastlingRights(List<bool>? isCastleKing) {
    if (isCastleKing == null) {
      sb += '-';
      return;
    }
    if (!(isCastleKing[0] ||
        isCastleKing[1] ||
        isCastleKing[2] ||
        isCastleKing[3])) {
      sb += '-';
      return;
    }

    if (isCastleKing[0]) {
      sb += 'K';
    }
    if (isCastleKing[1]) {
      sb += 'Q';
    }

    if (isCastleKing[2]) {
      sb += 'k';
    }
    if (isCastleKing[3]) {
      sb += 'q';
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
