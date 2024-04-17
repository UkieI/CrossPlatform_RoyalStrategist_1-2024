import 'package:chess_flutter_app/logic/board/piece.dart';

class Move {
  final int start;
  final int end;
  int promotionType;

  Move(this.start, this.end, {this.promotionType = Piece.None});
}
