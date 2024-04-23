// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:chess_flutter_app/logic/board/board.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/evaluation/evaluation.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move_and_value.dart';
import 'package:chess_flutter_app/logic/move_generation/move_generation.dart';

const INITIAL_ALPHA = -40000;
const STALEMATE_ALPHA = -20000;
const INITIAL_BETA = 40000;
const STALEMATE_BETA = 20000;

Move calculateAIMove(Board board, int depth, bool isAiColor) {
  if (board.possibleOpenings.isNotEmpty) {
    return openingMove(board, isAiColor, depth);
  } else {
    var move = _alphaBeta(board, Move(0, 0), 0, depth, INITIAL_ALPHA, INITIAL_BETA);
    print(move.value);
    return move.move;
  }
}

Move randomAIMove(Board board, bool isWhiteTurn) {
  List<Move> listMove = allMoves(board);
  listMove.shuffle();
  return listMove[Random().nextInt(listMove.length)];
}

MoveAndValue _alphaBeta(Board board, Move move, int depth, int maxDepth, int alpha, int beta) {
  Evaluation eval;
  if (depth == maxDepth) {
    eval = Evaluation();
    return MoveAndValue(move, eval.evalutate(board));
  }
  var bestMove = MoveAndValue(Move(0, 0), board.isWhiteToMove ? INITIAL_ALPHA : INITIAL_BETA);

  for (var move in allMoves(board)) {
    push(board, move, promotionType: move.promotionType);
    var result = _alphaBeta(board, move, depth + 1, maxDepth, alpha, beta);
    result.move = move;
    pop(board);

    if (board.isWhiteToMove) {
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
  if (bestMove.value.abs() == INITIAL_BETA && !calculateInCheckState(board, board.isWhiteToMove)) {
    if (piecesForPlayer(board.isWhiteToMove, board).length == 1) {
      bestMove.value = !board.isWhiteToMove ? STALEMATE_BETA : STALEMATE_ALPHA;
    } else {
      bestMove.value = !board.isWhiteToMove ? STALEMATE_ALPHA : STALEMATE_BETA;
    }
  }

  // if (isAnyMoveleft(board, board.isWhiteToMove)) {
  //   bestMove.value = !board.isWhiteToMove ? INITIAL_ALPHA : INITIAL_BETA;
  // }

  return bestMove;
}

Move openingMove(Board board, bool isAiMove, int detph) {
  List<Move> possibleMoves = board.possibleOpenings;
  Move move;
  bool isBestMove = false;
  do {
    if (possibleMoves.isEmpty) {
      return _alphaBeta(board, Move(0, 0), 0, detph, INITIAL_ALPHA, INITIAL_BETA).move;
    }
    move = possibleMoves.first;

    push(board, move);
    var result = _alphaBeta(board, move, 0, 1, INITIAL_ALPHA, INITIAL_BETA);
    result.move = move;
    pop(board);

    if (result.value < -100) {
      isBestMove = true;
    }
    board.possibleOpenings.remove(move);
  } while (Piece.isWhite(board.square[move.start]) != isAiMove || board.square[move.start] == Piece.None || !isBestMove);
  return move;
}

void getRandomOpeningMoves(Board board) {}


// Move openingMove(Board board) {
//   print('1');
//   List<Move> possibleMoves = board.possibleOpenings.map((opening) => opening[board.indexMoveLog]).toList();
//   print('1');
//   return possibleMoves[Random.secure().nextInt(possibleMoves.length)];
//   // board.possibleOpenings = List.of(openings[Random().nextInt(openings.length)]);
// }
