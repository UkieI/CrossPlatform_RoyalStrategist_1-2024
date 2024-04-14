// ignore_for_file: constant_identifier_names

import 'package:chess_flutter_app/logic/board/board.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move.dart';

const List<List<int>> ROOK_DIRECTIONS = [
  [-1, 0], //up
  [1, 0], //down
  [0, -1], //right
  [0, 1] //left
];

const List<List<int>> BISHOP_DIRECTIONS = [
  [-1, -1],
  [-1, 1],
  [1, -1],
  [1, 1]
];

const List<List<int>> KNIGHT_DIRECTIONS = [
  [-2, -1],
  [-2, 1],
  [-1, 2],
  [-1, -2],
  [1, -2],
  [1, 2],
  [2, -1],
  [2, 1]
];

List<int> getMovePiece(int piece, int sPos, Board board, {bool legal = true}) {
  List<int> moves;
  switch (Piece.pieceType(piece)) {
    case Piece.Pawn:
      {
        moves = pawnMoves(piece, sPos, board);
        break;
      }
    case Piece.Bishop:
      {
        moves = bishopMoves(piece, sPos, board);
        break;
      }
    case Piece.Knight:
      {
        moves = knightMoves(piece, sPos, board);
        break;
      }
    case Piece.Rook:
      {
        moves = rookMoves(piece, sPos, board);
        break;
      }
    case Piece.Queen:
      {
        moves = queenMoves(piece, sPos, board);
        break;
      }
    case Piece.King:
      {
        moves = kingMoves(piece, sPos, board, legal);
        break;
      }
    default:
      {
        moves = [];
        break;
      }
  }
  if (legal) {
    moves.removeWhere((ePos) => movePutsKingInCheck(board, piece, sPos, ePos));
  }

  return moves;
}

List<int> pawnMoves(int piece, int sPos, Board board) {
  List<int> moves = [];
  var isPieceWhite = Piece.isWhite(piece);
  var row = BoardHelper.rowIndex(sPos);
  var col = BoardHelper.colIndex(sPos);
  int attackSquare;
  var offset = isPieceWhite ? -8 : 8;
  int direction = isPieceWhite ? -1 : 1;
  var firstSquare = sPos + offset;

  // Pawn-specific move logic
  // pawns can move forward if the square is not occupied
  if (BoardHelper.isInBoard(firstSquare) &&
      board.square[firstSquare] == Piece.None) {
    moves.add(firstSquare);
  }

  // pawns can move 2 spuares if they are at their intial position
  if ((row == 1 && !isPieceWhite) || (row == 6 && isPieceWhite)) {
    var secondSquare = firstSquare + offset;
    if (board.square[secondSquare] == Piece.None) {
      moves.add(secondSquare);
    }
  }

  // pawns can kill diagonally
  attackSquare = BoardHelper.indexFromRowCol(row + direction, col - 1);

  if (BoardHelper.isValidRowCol(row + direction, col - 1) &&
      ((board.square[attackSquare] != Piece.None &&
              !Piece.isColour(piece, board.square[attackSquare])) ||
          canTakeEnPassant(board, attackSquare))) {
    moves.add(BoardHelper.indexFromRowCol(row + direction, col - 1));
  }

  attackSquare = BoardHelper.indexFromRowCol(row + direction, col + 1);
  if (BoardHelper.isValidRowCol(row + direction, col + 1) &&
      ((board.square[attackSquare] != Piece.None &&
              !Piece.isColour(piece, board.square[attackSquare])) ||
          canTakeEnPassant(board, attackSquare))) {
    moves.add(BoardHelper.indexFromRowCol(row + direction, col + 1));
  }

  return moves;
}

// bool canTakeEnPassant(Board board, int pawn, int diagonal) {
//   var offset = Piece.isWhite(pawn) ? 8 : -8;
//   var takenPiece = board.square[diagonal + offset];
//   return takenPiece != Piece.None &&
//       !Piece.isSameColor(takenPiece, pawn) &&
//       takenPiece == board.enPassantPiece;
// }

bool canTakeEnPassant(Board board, int attackSquare) {
  return board.square[attackSquare] == Piece.None &&
      board.enPassantPos == attackSquare;
}

List<int> knightMoves(int knight, int sPos, Board board) {
  return movesFromDirections(knight, sPos, board, KNIGHT_DIRECTIONS, false);
}

List<int> bishopMoves(int bishop, int sPos, Board board) {
  return movesFromDirections(bishop, sPos, board, BISHOP_DIRECTIONS, true);
}

List<int> rookMoves(int rook, int sPos, Board board) {
  return movesFromDirections(rook, sPos, board, ROOK_DIRECTIONS, true);
}

List<int> queenMoves(int queen, int sPos, Board board) {
  return movesFromDirections(
      queen, sPos, board, ROOK_DIRECTIONS + BISHOP_DIRECTIONS, true);
}

List<int> kingMoves(int king, int sPos, Board board, bool legal) {
  return movesFromDirections(
          king, sPos, board, ROOK_DIRECTIONS + BISHOP_DIRECTIONS, false) +
      kingCastleMoves(king, sPos, board, legal);
}

List<int> movesFromDirections(
    int piece, int sPos, Board board, var directions, bool isRepeat) {
  List<int> moves = [];
  for (List<int> direction in directions) {
    int row = BoardHelper.rowIndex(sPos);
    int col = BoardHelper.colIndex(sPos);
    do {
      row += direction[0];
      col += direction[1];
      if (BoardHelper.isValidRowCol(row, col)) {
        int possiblePiece = board.square[BoardHelper.indexFromRowCol(row, col)];
        if (possiblePiece != Piece.None) {
          if (!Piece.isSameColor(possiblePiece, piece)) {
            moves.add(BoardHelper.indexFromRowCol(row, col));
          }
          break;
        } else {
          moves.add(BoardHelper.indexFromRowCol(row, col));
        }
      }
      if (!isRepeat) {
        break;
      }
    } while (BoardHelper.isValidRowCol(row, col));
  }
  return moves;
}

List<int> kingCastleMoves(int king, int sPos, Board board, bool legal) {
  List<int> moves = [];

  bool rookQueenSide, rookKingSide;
  if (Piece.isWhite(king)) {
    rookQueenSide = board.isRookHasMoved[0];
    rookKingSide = board.isRookHasMoved[1];
  } else {
    rookQueenSide = board.isRookHasMoved[2];
    rookKingSide = board.isRookHasMoved[3];
  }
  if (!isKingInCheck(board, Piece.isWhite(king))) {
    // King Side Check
    if (canCastle(board, king, sPos, rookKingSide, isCastleKingSide: true)) {
      moves.add(sPos + 2);
    }
    // Queen Side Check
    if (canCastle(board, king, sPos, rookQueenSide, isCastleKingSide: false)) {
      moves.add(sPos - 2);
    }
  }
  return moves;
}

bool canCastle(Board board, int king, int sPos, bool isRookHasMove,
    {bool isCastleKingSide = true}) {
  var isKingMoved =
      Piece.isWhite(king) ? board.isWhiteKingMoved : board.isBlackKingMoved;
  if (isKingMoved) {
    return false;
  }
  if (isRookHasMove) {
    false;
  }

  if (isCastleKingSide) {
    for (var i = sPos + 1; i < sPos + 3; i++) {
      if (board.square[i] != Piece.None ||
          movePutsKingInCheck(board, king, sPos, i)) {
        return false;
      }
    }
  } else {
    for (var i = sPos - 1; i > sPos - 4; i--) {
      if (board.square[i] != Piece.None ||
          movePutsKingInCheck(board, king, sPos, i)) {
        return false;
      }
    }
  }

  return true;
}

bool movePutsKingInCheck(Board board, int piece, int sPos, int ePos) {
  push(board, Move(sPos, ePos), isPlayerMoved: false);
  var check = isKingInCheck(board, Piece.isWhite(piece));
  pop(board);
  return check;
}

bool isKingInCheck(Board board, bool isWhiteKing) {
  // Check
  int kingPositons =
      isWhiteKing ? board.kingPositions[0] : board.kingPositions[1];
  int kingOpponment =
      isWhiteKing ? board.kingPositions[1] : board.kingPositions[0];
  for (int indexSquare = 0; indexSquare < 64; indexSquare++) {
    if (board.square[indexSquare] == Piece.None ||
        isWhiteKing == Piece.isWhite(board.square[indexSquare]) ||
        indexSquare == kingOpponment ||
        indexSquare == kingPositons) {
      continue;
    }
    List<int> pieceValidMoves = getMovePiece(
        board.square[indexSquare], indexSquare, board,
        legal: false);

    if (pieceValidMoves.any((move) => move == kingPositons)) {
      return true;
    }
  }
  return false;
}

bool isAnyMoveleft(Board board, bool isWhiteKing) {
  // the there is at least one legal move for any player's piece, not checkmate
  for (int indexSquare = 0; indexSquare < 64; indexSquare++) {
    if (board.square[indexSquare] == Piece.None ||
        isWhiteKing != Piece.isWhite(board.square[indexSquare])) {
      continue;
    }

    List<int> pieceValidMoves =
        getMovePiece(board.square[indexSquare], indexSquare, board);

    // if this piece is has any moves, that means not checkmate
    if (pieceValidMoves.isNotEmpty) {
      return false;
    }
  }

  return true;
}
