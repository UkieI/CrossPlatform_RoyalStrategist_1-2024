import 'package:chess_flutter_app/features/chess_board/models/bishop.dart';
import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/features/chess_board/models/king.dart';
import 'package:chess_flutter_app/features/chess_board/models/knight.dart';
import 'package:chess_flutter_app/features/chess_board/models/pawn.dart';
import 'package:chess_flutter_app/features/chess_board/models/queen.dart';
import 'package:chess_flutter_app/features/chess_board/models/rook.dart';

class ChessFunctions {}

bool isWhite(int index) {
  int x = index ~/ 8;
  int y = index % 8;

  bool isWhite = (x + y) % 2 == 0;
  return isWhite;
}

bool isInBoard(int row, int col) {
  return row >= 0 && row < 8 && col >= 0 && col < 8;
}

String? getImagePieces(ChessPieces piece) {
  if (piece is Pawn) return 'pawn';
  if (piece is Rook) return 'rook';
  if (piece is Knight) return 'knight';
  if (piece is Bishop) return 'bishop';
  if (piece is Queen) return 'queen';
  if (piece is King) return 'king';

  return '';
}
