import 'package:chess_flutter_app/features/chess_board/models/counting.dart';
import 'package:chess_flutter_app/features/chess_board/models/bishop.dart';
import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';

class InsuffcientMaterial {
  Counting countPieces(List<List<ChessPieces?>> board) {
    Counting counting = Counting();
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] != null) {
          counting.increment(board[i][j]!);
        }
      }
    }

    return counting;
  }

  bool insufficientMaterial(List<List<ChessPieces?>> newBoard) {
    Counting counting = countPieces(newBoard);

    return isKingVKing(counting) ||
        isKingBishopVKing(counting) ||
        isKingKnightVKing(counting) ||
        isKingBishopVKingBishop(counting, newBoard);
  }

  bool isKingVKing(Counting counting) {
    return counting.totalCount == 2;
  }

  bool isKingKnightVKing(Counting counting) {
    return counting.totalCount == 3 &&
        (counting.white('knight') == 1 || counting.black('knight') == 1);
  }

  bool isKingBishopVKing(Counting counting) {
    return counting.totalCount == 3 &&
        (counting.white('bishop') == 1 || counting.black('bishop') == 1);
  }

  bool isKingBishopVKingBishop(
      Counting counting, List<List<ChessPieces?>> board) {
    if (counting.totalCount != 4) {
      return false;
    }
    if (counting.white('bishop') != 1 || counting.black('bishop') != 1) {
      return false;
    }
    List<int> wBishopPos = findPiece(Bishop(isWhite: true), board);
    List<int> bBishopPos = findPiece(Bishop(isWhite: false), board);

    return sameSquareColor(wBishopPos) == sameSquareColor(bBishopPos);
  }

  List<int> findPiece(ChessPieces piece, List<List<ChessPieces?>> board) {
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] != null &&
            piece.isWhite == board[i][j]!.isWhite &&
            getNamePieces(board[i][j]!) == getNamePieces(piece)) {
          return [i, j];
        }
      }
    }
    return [-1, -1];
  }
}
