import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';

class Counting {
  final Map<String, int> whiteCount = {};
  final Map<String, int> blackCount = {};
  final List<String> pieceType = [
    'pawn',
    'rook',
    'knight',
    'bishop',
    'queen',
    'king'
  ];
  int totalCount = 0;

  Counting() {
    for (String type in pieceType) {
      whiteCount[type] = 0;
      blackCount[type] = 0;
    }
  }
  increment(ChessPieces piece) {
    String type = getNamePieces(piece);
    if (piece.isWhite) {
      whiteCount[type] = whiteCount[type]! + 1;
    } else {
      blackCount[type] = blackCount[type]! + 1;
    }
    totalCount++;
  }

  int white(String type) {
    return whiteCount[type]!;
  }

  int black(String type) {
    return blackCount[type]!;
  }
}
