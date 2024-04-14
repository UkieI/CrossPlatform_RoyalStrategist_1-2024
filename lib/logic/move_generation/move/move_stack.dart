import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move.dart';

class MoveStack {
  Move move;
  int movedPiece;
  int takenPiece;
  int enPassantPiece;
  int enPassantPos;
  bool isInCheck = false;
  bool isCasted = false;
  bool isPromotion = false;
  int promotionType = Piece.None;
  bool isEnPassant = false;

  MoveStack(this.move, this.movedPiece, this.takenPiece, this.enPassantPiece,
      this.enPassantPos);
}
