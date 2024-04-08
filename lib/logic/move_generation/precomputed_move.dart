import 'dart:ffi';
import 'dart:math';

import 'package:chess_flutter_app/features/chess_board/models/move.dart';
import 'package:chess_flutter_app/logic/board/board.dart';
import 'package:chess_flutter_app/logic/board/move_and_value.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';

class PrecomputedMove {
  // First 4 are orthogonal, last 4 are diagonals (N, S, W, E, NW, SE, NE, SW)
  static List<int> directionOffset = [8, -8, -1, 1, 7, -7, 9, -9];
  static List<List<int>> numSquaresToEdge = [];

  // Stores array of indices for each square a knight can land on from any square on the board
  // So for example, knightMoves[0] is equal to {10, 17}, meaning a knight on a1 can jump to c2 and b3
  static List<List<int>> knightMoves = [];
  static List<List<int>> kingMoves = [];
  static precomputedMoveData() {
    List<int> allKnightJumps = [15, 17, -17, -15, 10, -6, 6, -10];

    for (int squareIndex = 0; squareIndex < 64; squareIndex) {
      int x = squareIndex ~/ 8;
      int y = squareIndex % 8;

      int north = 7 - x;
      int south = x;
      int west = y;
      int east = 7 - y;
      numSquaresToEdge[squareIndex][0] = north;
      numSquaresToEdge[squareIndex][1] = south;
      numSquaresToEdge[squareIndex][2] = west;
      numSquaresToEdge[squareIndex][3] = east;
      numSquaresToEdge[squareIndex][4] = min(north, west);
      numSquaresToEdge[squareIndex][5] = min(south, east);
      numSquaresToEdge[squareIndex][6] = min(north, east);
      numSquaresToEdge[squareIndex][7] = min(south, west);

      List<int> legalKnightJumps = [];
      int knightBitboard = 0;
      for (int knightJumpDelta in allKnightJumps) {
        int knightJumpSquare = squareIndex + knightJumpDelta;
        if (knightJumpSquare >= 0 && knightJumpSquare < 64) {
          int knightSquareX = knightJumpSquare ~/ 8;
          int knightSquareY = knightJumpSquare % 8;
          int maxCoordMoveDst = max(
            (x - knightSquareX).abs(),
            (y - knightSquareY).abs(),
          );
          if (maxCoordMoveDst == 2) {
            legalKnightJumps.add(knightJumpSquare);
            knightBitboard |= (1 << knightJumpSquare);
          }
        }

        knightMoves[squareIndex] = legalKnightJumps;
      }
    }
  }

  List<Move> allMoves(bool isWhite, Board board) {
    List<MoveAndValue> moves = [];
    var pieces = List.from(piecesForPlayer(isWhite, board));
    for (var piece in pieces) {
      var square = movesForPiece(piece, board);
    }

    return moves.map((move) => move.move).toList();
  }
}

List<int> movesForPiece(int piece, Board board, {bool legal = true}) {
  List<int> moves = [];

  for (int squareIndex = 0; squareIndex < 64; squareIndex) {
    switch (Piece.pieceType(piece)) {
      case Piece.Pawn:
        {
          // moves = _pawnMoves(piece, board);
        }
        break;
      case Piece.Knight:
        {
          // moves = _knightMoves(piece, board);
        }
        break;
      case Piece.Bishop:
        {
          // moves = _bishopMoves(piece, board);
        }
        break;
      case Piece.Rook:
        {
          // moves = _rookMoves(piece, board, legal);
        }
        break;
      case Piece.Queen:
        {
          // moves = _queenMoves(piece, board);
        }
        break;
      case Piece.King:
        {
          // moves = _kingMoves(piece, board, legal);
        }
        break;
      default:
        {
          moves = [];
        }
    }
  }
  // if (legal) {
  //   moves.removeWhere((move) => _movePutsKingInCheck(piece, move, board));
  // }
  return moves;
}

// List<int> _pawnMoves(int pawn, Board board) {
//   List<int> moves = [];
//   var offset = Piece.isWhite(pawn) ? -8 : 8;
//   var firstTile = pawn + offset;
//   // pawns can move forward if the square is not occupied
//   if (board.board[firstTile] == 0) {
//     moves.add(firstTile);
//   }

//   // pawns can move 2 spuares if they are at their intial position
//   if (){

//   }
//   return moves + _pawnDiagonalAttacks(pawn, board);
// }

// List<int> _pawnDiagonalAttacks(int pawn, Board board) {
//   List<int> moves = [];
//   var diagonals =
//       pawn.player == Player.player1 ? PAWN_DIAGONALS_1 : PAWN_DIAGONALS_2;
//   for (var diagonal in diagonals) {
//     var row = tileToRow(pawn.tile) + diagonal.up;
//     var col = tileToCol(pawn.tile) + diagonal.right;
//     if (_inBounds(row, col)) {
//       var takenPiece = board.tiles[_rowColToTile(row, col)];
//       if ((takenPiece != null &&
//               takenPiece.player == oppositePlayer(pawn.player)) ||
//           _canTakeEnPassant(pawn.player, _rowColToTile(row, col), board)) {
//         moves.add(_rowColToTile(row, col));
//       }
//     }
//   }
//   return moves;
// }
