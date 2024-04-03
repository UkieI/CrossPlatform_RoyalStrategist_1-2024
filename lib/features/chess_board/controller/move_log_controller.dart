import 'package:chess_flutter_app/features/chess_board/models/bishop.dart';
import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/features/chess_board/models/king.dart';
import 'package:chess_flutter_app/features/chess_board/models/knight.dart';
import 'package:chess_flutter_app/features/chess_board/models/move.dart';
import 'package:chess_flutter_app/features/chess_board/models/pawn.dart';
import 'package:chess_flutter_app/features/chess_board/models/queen.dart';
import 'package:chess_flutter_app/features/chess_board/models/rook.dart';
import 'package:get/get.dart';

class MoveLogController extends GetxController {
  RxList<String> moveLogs = <String>[].obs;
  List<String> moveHistory = [];

  void setMove(Move move) {
    // 1. Record the piece that is being moved, and the square that the piece is being moved to
    var piece = convertPiece(move.chessPiece);

    var sRow = convertRow(move.startRow);
    var sCol = convertCol(move.startCol);

    var eRow = convertRow(move.endRow);
    var eCol = convertCol(move.endCol);

    String strMove = "$piece$sRow$sCol$eRow$eCol";

    // if (move.chessPiece.isWhite)

    moveLogs.add(strMove);
  }

  // Rule to write the move for long-term storing
  // 1. The piece moving (1 letter : P , R , N , B , Q , K )
  // 2. Start positon (2 num: 0 1 2 3 4 5 6 7) like 00 is a1
  // 3. End positon (2 num: 0 1 2 3 4 5 6 7)  like 00 is a1
  // 4. Piece being captured (1 letter : _ , P , R , N , B , Q , K )
  // 5. Piece promotion (1 letter : _ , P , R , N , B , Q , K )
  // 6. Is in check (1 num: t : 1 , f  : 0)
  String moveStoring() {
    return "";
  }

  Move? getMove(int index) {
    String strMove = moveLogs[index];
    bool isWhite = index % 2 == 0;

    var piece = reConvertPiece(strMove[0], isWhite);
    List<int> listIndex = [1, 2, 3, 4];
    if (piece is Pawn) listIndex = [0, 1, 2, 3];

    var sRow = reConvertRow(strMove[listIndex[0]]);
    var sCol = reConvertCol(strMove[listIndex[1]]);

    var eRow = reConvertRow(strMove[listIndex[2]]);
    var eCol = reConvertCol(strMove[listIndex[3]]);
    var capturePiece;
    var promotionPiece;

    return Move(
        index: index,
        chessPiece: piece,
        startRow: sRow,
        startCol: sCol,
        endRow: eRow,
        endCol: eCol,
        capturePiece: capturePiece,
        promotionPiece: promotionPiece,
        isKingCheck: true);
  }

  String? convertPiece(ChessPieces piece) {
    if (piece is Pawn) return "";
    if (piece is Rook) return "R";
    if (piece is Knight) return "N";
    if (piece is Bishop) return "B";
    if (piece is Queen) return "Q";
    if (piece is King) return "K";

    return null;
  }

  ChessPieces reConvertPiece(String piece, bool isWhite) {
    switch (piece) {
      case "":
        return Pawn(isWhite: isWhite);
      case "R":
        return Rook(isWhite: isWhite);
      case "N":
        return Knight(isWhite: isWhite);
      case "B":
        return Bishop(isWhite: isWhite);
      case "Q":
        return Queen(isWhite: isWhite);
      case "K":
        return King(isWhite: isWhite);
    }

    return Pawn(isWhite: isWhite);
  }

  int reConvertRow(String row) {
    switch (row) {
      case "8":
        return 8;
      case "7":
        return 7;
      case "6":
        return 6;
      case "5":
        return 5;
      case "4":
        return 4;
      case "3":
        return 3;
      case "2":
        return 2;
      case "1":
        return 1;
    }
    return 8;
  }

  int reConvertCol(String col) {
    switch (col) {
      case "a":
        return 0;
      case "b":
        return 1;
      case "c":
        return 2;
      case "d":
        return 3;
      case "e":
        return 4;
      case "f":
        return 5;
      case "g":
        return 6;
      case "h":
        return 7;
    }
    return 8;
  }

  String convertRow(int row) {
    switch (row) {
      case 0:
        return "8";
      case 1:
        return "7";
      case 2:
        return "6";
      case 3:
        return "5";
      case 4:
        return "4";
      case 5:
        return "3";
      case 6:
        return "2";
      case 7:
        return "1";
    }
    return "";
  }

  String convertCol(int col) {
    switch (col) {
      case 0:
        return "a";
      case 1:
        return "b";
      case 2:
        return "c";
      case 3:
        return "d";
      case 4:
        return "e";
      case 5:
        return "f";
      case 6:
        return "g";
      case 7:
        return "h";
    }
    return "";
  }
}
