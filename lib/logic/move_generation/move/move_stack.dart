import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move.dart';

class MoveStack {
  Move move;
  int movedPiece;
  int takenPiece;
  int enPassantPos;
  bool isInCheck = false;
  bool isCasted = false;
  bool isPromotion = false;
  bool isEnPassant = false;
  int castlingRights;
  int promotionType = Piece.None;

  MoveStack(this.move, this.movedPiece, this.takenPiece, this.enPassantPos, this.castlingRights);
}
