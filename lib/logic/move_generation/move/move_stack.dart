// ignore_for_file: constant_identifier_names

import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move.dart';

class MoveStack {
  Move move;
  int movedPiece;
  int takenPiece;

  // GameState
  int enPassantPos;
  int castlingRights;
  int fiftyMoveCounter;

  // bool isPromotion = false;
  int promotionType = Piece.None;

  int flags = NoFlags;
  static const NoFlags = 0;
  static const EnPassantCaptureFlag = 1;
  static const CastleFlag = 2;
  static const isPromotion = 3;

  MoveStack(this.move, this.movedPiece, this.takenPiece, this.enPassantPos, this.castlingRights, this.fiftyMoveCounter);
}
