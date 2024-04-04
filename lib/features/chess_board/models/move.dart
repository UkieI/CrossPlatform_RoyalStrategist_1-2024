import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';

import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';

class Move {
  final int index;
  final ChessPieces chessPiece;
  final int startRow;
  final int startCol;
  final int endRow;
  final int endCol;
  final ChessPieces? capturePiece;
  final ChessPieces? promotionPiece;
  final bool isKingCheck;
  final bool? isPrefix; // null ,  true : Row , false : Col
  // final bool isCastle;
  final bool?
      isCasteKingSide; // null ,  true : Castle King side, false : Castle Queen Side
  final bool isCheckmate;
  Move({
    required this.index,
    required this.chessPiece,
    required this.startRow,
    required this.startCol,
    required this.endRow,
    required this.endCol,
    this.capturePiece,
    this.promotionPiece,
    required this.isKingCheck,
    // required this.isCastle,
    this.isCasteKingSide,
    this.isPrefix,
    required this.isCheckmate,
  });

  @override
  String toString() {
    String strMove = convertPiece(chessPiece);
    strMove += "$startRow$startCol$endRow$endCol";
    strMove += capturePiece != null ? convertPiece(capturePiece!) : "_";
    strMove += promotionPiece != null ? convertPiece(promotionPiece!) : "_";
    strMove += isKingCheck ? "1" : "0";
    strMove += isCheckmate ? "#" : "";
    return strMove;
  }

  // Create Forsyth–Edwards Notation for displaying
  String generateFEN(Move move) {
    String strFEN = "";
    bool isCapture = capturePiece != null;
    String piece = convertPiece(chessPiece);
    var sRow = convertRow(startRow);
    var sCol = convertCol(startCol);
    var eRow = convertRow(endRow);
    var eCol = convertCol(endCol);
    //  Is King are castling
    if (isCasteKingSide != null) {
      return strFEN = (isCasteKingSide!) ? "O-O" : "O-O-O";
    }

    // 2. Name moving pieces
    strFEN += piece;

    // 3. is have isPrefix
    if (isPrefix != null) {
      isPrefix! ? strFEN += sRow : strFEN += sCol;
    }

    // 4. Is that move is capture
    if (isCapture) {
      strFEN += "x";
    }

    // 5. check promotion Piece
    if (promotionPiece != null) {
      return strFEN +=
          "$eRow$eCol=${convertPiece(promotionPiece!)}${isKingCheck ? "+" : ""}";
    }
    // 5. Is Pawn are Promotion Piece
    strFEN += "$eRow$eCol";

    if (isCheckmate) {
      return strFEN += "#";
    }
    // 6. Is check
    if (isKingCheck) {
      strFEN += "+";
    }

    return strFEN;
  }
}
