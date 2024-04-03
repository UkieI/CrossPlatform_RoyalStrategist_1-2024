import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';

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
  });
}
