// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:chess_flutter_app/logic/board/board.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move_and_value.dart';
import 'package:chess_flutter_app/logic/move_generation/move_generation.dart';

const INITIAL_ALPHA = -40000;
const STALEMATE_ALPHA = -20000;
const INITIAL_BETA = 40000;
const STALEMATE_BETA = 20000;

Move calculateAIMove(Board board, bool isWhiteTurn) {
  return _alphaBeta(board, isWhiteTurn, Move(0, 0), 0, 4, INITIAL_ALPHA, INITIAL_BETA).move;
}

Move randomAIMove(Board board, bool isWhiteTurn) {
  List<Move> listMove = allMoves(board, isWhiteTurn);
  listMove.shuffle();
  return listMove[Random().nextInt(listMove.length)];
}

MoveAndValue _alphaBeta(Board board, bool isWhiteTurn, Move move, int depth, int maxDepth, int alpha, int beta) {
  if (depth == maxDepth) {
    return MoveAndValue(move, evaluateBoard(board, isWhiteTurn));
  }
  var bestMove = MoveAndValue(Move(0, 0), isWhiteTurn ? INITIAL_ALPHA : INITIAL_BETA);

  for (var move in allMoves(board, isWhiteTurn)) {
    push(board, move, promotionType: move.promotionType);
    var result = _alphaBeta(board, !isWhiteTurn, move, depth + 1, maxDepth, alpha, beta);
    result.move = move;
    pop(board);

    if (isWhiteTurn) {
      if (result.value > bestMove.value) {
        bestMove = result;
      }
      alpha = max(alpha, bestMove.value);
      if (alpha >= beta) {
        break;
      }
    } else {
      if (result.value < bestMove.value) {
        bestMove = result;
      }
      beta = min(beta, bestMove.value);
      if (beta <= alpha) {
        break;
      }
    }
  }
  if (bestMove.value.abs() == INITIAL_BETA && !isKingInCheck(board, isWhiteTurn)) {
    if (piecesForPlayer(isWhiteTurn, board).length == 1) {
      bestMove.value = isWhiteTurn ? STALEMATE_BETA : STALEMATE_ALPHA;
    } else {
      bestMove.value = isWhiteTurn ? STALEMATE_ALPHA : STALEMATE_BETA;
    }
  }
  return bestMove;
}
