// ignore_for_file: constant_identifier_names

import 'package:chess_flutter_app/logic/board/board.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move_and_value.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move_stack.dart';

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

const PROMOTIONS = [Piece.Queen, Piece.Rook, Piece.Bishop, Piece.Knight];

List<Move> allMoves(Board board) {
  List<MoveAndValue> lmv = [];
  // Load all the oppoments pieces
  for (var piece in piecesForPlayer(board.isWhiteToMove, board)) {
    var eSquareList = getMovePiece(piece.piece, piece.pos, board);
    var sSquare = piece.pos;
    // Get all valid move pieces
    for (var eSquare in eSquareList) {
      // Check if is pawn go to promotion
      if (isPromotion(piece.piece, eSquare)) {
        for (var promotion in PROMOTIONS) {
          var move = MoveAndValue(Move(sSquare, eSquare, promotionType: promotion), 0);
          push(board, move.move, promotionType: promotion);
          move.value = evaluateBoard(board);
          pop(board);
          lmv.add(move);
        }
      } else {
        var move = MoveAndValue(Move(sSquare, eSquare), 0);
        push(board, move.move);
        move.value = evaluateBoard(board);
        pop(board);
        lmv.add(move);
      }
    }
  }
  lmv.sort((a, b) => board.isWhiteToMove ? b.value.compareTo(a.value) : a.value.compareTo(b.value));
  return lmv.map((move) => move.move).toList();
}

List<int> getMovePiece(int piece, int sPos, Board board, {bool legal = true}) {
  List<int> moves;
  switch (Piece.pieceType(piece)) {
    case Piece.Pawn:
      {
        moves = pawnMoves(piece, sPos, board);
      }
      break;
    case Piece.Bishop:
      {
        moves = bishopMoves(piece, sPos, board);
      }
      break;
    case Piece.Knight:
      {
        moves = knightMoves(piece, sPos, board);
      }
      break;
    case Piece.Rook:
      {
        moves = rookMoves(piece, sPos, board);
      }
      break;
    case Piece.Queen:
      {
        moves = queenMoves(piece, sPos, board);
      }
      break;
    case Piece.King:
      {
        moves = kingMoves(piece, sPos, board, legal);
      }
      break;
    default:
      {
        moves = [];
      }
      break;
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
  if (BoardHelper.isInBoard(firstSquare) && board.square[firstSquare] == Piece.None) {
    moves.add(firstSquare);
  }

  // pawns can move 2 spuares if they are at their intial position
  if ((row == 1 && !isPieceWhite) || (row == 6 && isPieceWhite)) {
    var secondSquare = firstSquare + offset;
    if (board.square[secondSquare] == Piece.None && board.square[firstSquare] == Piece.None) {
      moves.add(secondSquare);
    }
  }

  // pawns can kill diagonallyw
  attackSquare = BoardHelper.indexFromRowCol(row + direction, col - 1);

  if (BoardHelper.isValidRowCol(row + direction, col - 1) &&
      ((board.square[attackSquare] != Piece.None && !Piece.isSameColor(piece, board.square[attackSquare])) || ((row == 3 || row == 4) && canTakeEnPassant(board, attackSquare)))) {
    moves.add(BoardHelper.indexFromRowCol(row + direction, col - 1));
  }

  attackSquare = BoardHelper.indexFromRowCol(row + direction, col + 1);
  if (BoardHelper.isValidRowCol(row + direction, col + 1) &&
      ((board.square[attackSquare] != Piece.None && !Piece.isSameColor(piece, board.square[attackSquare])) || ((row == 3 || row == 4) && canTakeEnPassant(board, attackSquare)))) {
    moves.add(BoardHelper.indexFromRowCol(row + direction, col + 1));
  }

  return moves;
}

bool canTakeEnPassant(Board board, int attackSquare) {
  return board.square[attackSquare] == Piece.None && board.movedStack.last.enPassantPos == attackSquare;
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
  return movesFromDirections(queen, sPos, board, ROOK_DIRECTIONS + BISHOP_DIRECTIONS, true);
}

List<int> kingMoves(int king, int sPos, Board board, bool legal) {
  return movesFromDirections(king, sPos, board, ROOK_DIRECTIONS + BISHOP_DIRECTIONS, false) + kingCastleMoves(king, board, legal);
}

List<int> movesFromDirections(int piece, int sPos, Board board, var directions, bool isRepeat) {
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

// ignore: non_constant_identifier_names
List<int> kingCastleMoves(int king, Board board, bool legal) {
  List<int> moves = [];
  if (board.currentKingCastleRight == 0) {
    return moves;
  }

  bool isWhite = Piece.isWhite(king);
  int kingPos = isWhite ? board.kingSquare[0] : board.kingSquare[1];
  if (!legal || !isKingInCheck(board, isWhite)) {
    if (canCastle(board, king, kingPos, legal, isCastleKingSide: true)) moves.add(kingPos + 2);
    if (canCastle(board, king, kingPos, legal, isCastleKingSide: false)) moves.add(kingPos - 2);
  }
  return moves;
}

bool canCastle(Board board, int king, int kingPos, bool legal, {bool isCastleKingSide = true}) {
  bool isWhite = Piece.isWhite(king);
  if (isCastleKingSide) {
    if (hasKingsideCastleRight(board.currentKingCastleRight, isWhite)) {
      if (!BoardHelper.isInBoard(kingPos + 3) || Piece.pieceType(board.square[kingPos + 3]) != Piece.Rook) {
        return false;
      }
      for (int i = 1; i < 3; i++) {
        if (board.square[kingPos + i] != Piece.None || (legal && kingInCheckAtSquare(board, isWhite, kingPos + i))) {
          return false;
        }
      }
      return true;
    }
  } else {
    if (hasQueensideCastleRight(board.currentKingCastleRight, isWhite)) {
      if (!BoardHelper.isInBoard(kingPos - 4) || Piece.pieceType(board.square[kingPos - 4]) != Piece.Rook) {
        return false;
      }
      for (int i = 1; i < 4; i++) {
        if (board.square[kingPos - i] != Piece.None || (legal && kingInCheckAtSquare(board, isWhite, kingPos - i))) {
          return false;
        }
      }
      return true;
    }
  }
  return false;
}

bool movePutsKingInCheck(Board board, int piece, int sPos, int ePos) {
  push(board, Move(sPos, ePos));
  var check = isKingInCheck(board, Piece.isWhite(piece));
  pop(board);
  return check;
}

bool kingInCheckAtSquare(Board board, bool isWhiteKing, int kingPos) {
  for (var piece in piecesForPlayer(!isWhiteKing, board)) {
    if (getMovePiece(piece.piece, piece.pos, board, legal: false).contains(kingPos)) {
      return true;
    }
  }
  return false;
}

bool isKingInCheck(Board board, bool isWhiteKing) {
  int kingPositons = isWhiteKing ? board.kingSquare[0] : board.kingSquare[1];

  for (var piece in piecesForPlayer(!isWhiteKing, board)) {
    if (getMovePiece(piece.piece, piece.pos, board, legal: false).any((elements) => elements == kingPositons)) {
      return true;
    }
  }

  return false;
}

bool isAnyMoveleft(Board board, bool isWhiteKing) {
  for (var piece in piecesForPlayer(!isWhiteKing, board)) {
    List<int> pieceValidMoves = getMovePiece(piece.piece, piece.pos, board);
    if (pieceValidMoves.isNotEmpty) {
      return false;
    }
  }
  return true;
}

String moveLogString(MoveStack ms, bool isAnyMoveLeft, bool isInCheck) {
  String strFEN = "";
  if (ms.isCasted) {
    if (BoardHelper.colIndex(ms.move.end) == 2) {
      return "O-O-O";
    }
    if (BoardHelper.colIndex(ms.move.end) == 6) {
      return "O-O";
    }
  }

  strFEN += Piece.getSymbolMoveLog(ms.movedPiece);
  if (ms.takenPiece != Piece.None) {
    strFEN += "x";
  }

  strFEN += BoardHelper.squareNameFromSquare(ms.move.end);

  if (ms.isPromotion) {
    strFEN = "";
    strFEN += "${BoardHelper.squareNameFromSquare(ms.move.end)}=${Piece.getSymbol(ms.promotionType)}${ms.isInCheck ? "+" : ""}";
  }

  if (isAnyMoveLeft && isInCheck) {
    return strFEN += "# 1 - 0";
  }
  if (isAnyMoveLeft && !isInCheck) {
    return strFEN += " 1/2 - 1/2";
  }
  if (isInCheck) {
    strFEN += "+";
  }
  return strFEN;
}
