import 'dart:math';

import 'package:chess_flutter_app/logic/board/board.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/evaluation/square_value.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';

class Evaluation {
  static const pawnValue = 100;
  late Board board;

  late EvaluationData whiteEval;
  late EvaluationData blackEval;

  int evalutate(Board board) {
    this.board = board;
    whiteEval = EvaluationData();
    blackEval = EvaluationData();

    MaterialInfo whitePieces = MaterialInfo(board, isWhitePieces: true);
    MaterialInfo blackPieces = MaterialInfo(board, isWhitePieces: false);

    whiteEval.materialScore = whitePieces.materialScore;
    blackEval.materialScore = blackPieces.materialScore;

    whiteEval.mopUpScore = mopUpEval(true, whitePieces, blackPieces);
    blackEval.mopUpScore = mopUpEval(false, blackPieces, whitePieces);

    // int perspective = board.isWhiteToMove != board.aiMove ? 1 : -1;
    int eval = whiteEval.sum() - blackEval.sum();

    return eval;
  }

  int mopUpEval(bool isWhite, MaterialInfo myMaterial, MaterialInfo enemyMaterial) {
    if (myMaterial.materialScore > enemyMaterial.materialScore * pawnValue * 2 && enemyMaterial.endgameT > 0) {
      int mopUpScore = 0;
      int friendlyIndex = isWhite ? Board.whiteIndex : Board.blackIndex;
      int opponentIndex = isWhite ? Board.blackIndex : Board.whiteIndex;

      int friendlyKingSquare = board.kingSquare[friendlyIndex];
      int opponentKingSquare = board.kingSquare[opponentIndex];
      // // Encourage moving king closer to opponent king
      int friendlyKingCol = BoardHelper.colIndex(friendlyKingSquare);
      int friendlyKingRow = BoardHelper.rowIndex(friendlyKingSquare);
      int opponentKingCol = BoardHelper.colIndex(opponentKingSquare);
      int opponentKingRow = BoardHelper.rowIndex(opponentKingSquare);
      // // Encourage pushing opponent king to edge of board
      int md = (friendlyKingRow - opponentKingRow).abs() + (friendlyKingCol - opponentKingCol).abs();
      int opponentKingToCenterRow = max(3 - opponentKingRow, opponentKingRow - 4);
      int opponentKingToCenterCol = max(3 - opponentKingCol, opponentKingCol - 4);
      int cmd = opponentKingToCenterRow + opponentKingToCenterCol;
      mopUpScore += 15 * cmd + 4 * (14 - md);
      return (mopUpScore * enemyMaterial.endgameT).truncate();
    }
    return 0;
  }
}

class EvaluationData {
  late int materialScore;
  late int mopUpScore;
  int sum() {
    return materialScore + mopUpScore;
  }
}

class MaterialInfo {
  final int materialScore;
  final bool isWhitePieces;
  final double endgameT;

  MaterialInfo(Board board, {required this.isWhitePieces})
      : materialScore = evaluatePiece(isWhitePieces, board),
        endgameT = calcuationEndGameVal(board, isWhitePieces);

  static double calcuationEndGameVal(Board board, bool isWhite) {
    const int queenEndgameWeight = 45;
    const int rookEndgameWeight = 20;
    const int bishopEndgameWeight = 10;
    const int knightEndgameWeight = 10;

    int endgameStartWeight = 2 * rookEndgameWeight + 2 * bishopEndgameWeight + 2 * knightEndgameWeight + queenEndgameWeight;
    int endgameWeightSum = 0;
    for (var piece in piecesForPlayer(isWhite, board)) {
      switch (Piece.pieceType(piece.piece)) {
        case Piece.Rook:
          endgameWeightSum += rookEndgameWeight;
          break;
        case Piece.Knight:
          endgameWeightSum += knightEndgameWeight;
          break;
        case Piece.Bishop:
          endgameWeightSum += bishopEndgameWeight;
          break;
        case Piece.Queen:
          endgameWeightSum += queenEndgameWeight;
          break;
      }
    }
    return 1 - min(1, endgameWeightSum / endgameStartWeight);
  }

  static int evaluatePiece(bool isWhite, Board board) {
    int value = 0;
    for (var piece in piecesForPlayer(isWhite, board)) {
      value += Piece.pieceValue(piece.piece) + squareValue(piece.piece, piece.pos, board.isWhiteToMove, inEndGame(board));
    }
    return value;
  }

  void getMaterialInfo(bool isWhite) {}
}

int forceKingToCornerEndGameVal(int myKingPos, int opKingPos, double oppEndGameVal) {
  int evaluations = 0;

  int opponentKingCol = BoardHelper.colIndex(opKingPos);
  int opponentKingRow = BoardHelper.rowIndex(opKingPos);

  int opponentKingToCenterRow = max(3 - opponentKingRow, opponentKingRow - 4);
  int opponentKingToCenterCol = max(3 - opponentKingCol, opponentKingCol - 4);

  int opponentKingFormCentre = opponentKingToCenterRow + opponentKingToCenterCol;
  evaluations += opponentKingFormCentre;

  int myKingCol = BoardHelper.colIndex(myKingPos);
  int myKingRow = BoardHelper.rowIndex(myKingPos);

  int dstBwtKingRow = (myKingRow - opponentKingRow).abs();
  int dstBwtKingCol = (myKingCol - opponentKingCol).abs();
  int dstBwtKings = dstBwtKingRow + dstBwtKingCol;
  evaluations += (14 - dstBwtKings) * 4;

  return (evaluations * 10 * oppEndGameVal).truncate();
}

bool inEndGame(Board board) {
  return board.whitePieces.length <= 3 || board.blackPieces.length <= 3;
}
// (board.blackPieces.any((element) => element.piece == Piece.BlackQueen) && board.whitePieces.any((element) => element.piece == Piece.WhiteQueen)) ||