// ignore_for_file: constant_identifier_names

import 'package:chess_flutter_app/logic/board/board.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move.dart';
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
    if (board.square[secondSquare] == Piece.None &&
        board.square[firstSquare] == Piece.None) {
      moves.add(secondSquare);
    }
  }

  // pawns can kill diagonallyw
  attackSquare = BoardHelper.indexFromRowCol(row + direction, col - 1);

  if (BoardHelper.isValidRowCol(row + direction, col - 1) &&
      ((board.square[attackSquare] != Piece.None &&
              !Piece.isSameColor(piece, board.square[attackSquare])) ||
          ((row == 3 || row == 4) && canTakeEnPassant(board, attackSquare)))) {
    moves.add(BoardHelper.indexFromRowCol(row + direction, col - 1));
  }

  attackSquare = BoardHelper.indexFromRowCol(row + direction, col + 1);
  if (BoardHelper.isValidRowCol(row + direction, col + 1) &&
      ((board.square[attackSquare] != Piece.None &&
              !Piece.isSameColor(piece, board.square[attackSquare])) ||
          ((row == 3 || row == 4) && canTakeEnPassant(board, attackSquare)))) {
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
      kingCastleMoves(king, board, legal);
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

// ignore: non_constant_identifier_names
List<int> kingCastleMoves(int King, Board board, bool legal) {
  List<int> moves = [];
  // var king = piecesForPlayer(Piece.isWhite(King), board)
  //     .firstWhere((element) => Piece.pieceType(element.piece) == Piece.King);
  var king = getKingChessPiece(King, board);
  // var king = Piece.isWhite(King) ? board.whiteKing : board.blackKing;
  var rookList = piecesForPlayer(Piece.isWhite(King), board)
      .where((element) => Piece.pieceType(element.piece) == Piece.Rook)
      .toList();
  if (!legal || !isKingInCheck(board, Piece.isWhite(King))) {
    for (var rook in rookList) {
      if (king.pos - rook.pos > 0) {
        if (canCastle(board, king, rook, legal)) moves.add(king.pos - 2);
      } else {
        if (canCastle(board, king, rook, legal)) moves.add(king.pos + 2);
      }
    }
  }

  return moves;
}

bool canCastle(Board board, ChessPiece king, ChessPiece rook, bool legal,
    {bool isCastleKingSide = true}) {
  if (king.moveCount != 0) {
    return false;
  }
  if (rook.moveCount != 0) {
    return false;
  }

  var offset = king.pos - rook.pos > 0 ? 1 : -1;
  var squareIndex = rook.pos;
  while (squareIndex != king.pos) {
    squareIndex += offset;
    if ((board.square[squareIndex] != Piece.None && king.pos != squareIndex) ||
        (legal &&
            kingInCheckAtSquare(
                board, Piece.isWhite(king.piece), squareIndex))) {
      return false;
    }
  }

  return true;
}

bool movePutsKingInCheck(Board board, int piece, int sPos, int ePos) {
  push(board, Move(sPos, ePos));
  var check = isKingInCheck(board, Piece.isWhite(piece));
  pop(board);
  return check;
}

bool kingInCheckAtSquare(Board board, bool isWhiteKing, int kingPos) {
  for (var piece in piecesForPlayer(!isWhiteKing, board)) {
    if (getMovePiece(piece.piece, piece.pos, board, legal: false)
        .contains(kingPos)) {
      return true;
    }
  }
  return false;
}

bool isKingInCheck(Board board, bool isWhiteKing) {
  // Check
  int kingPositons =
      getKingChessPiece(isWhiteKing ? Piece.White : Piece.Black, board).pos;

  for (var piece in piecesForPlayer(!isWhiteKing, board)) {
    if (getMovePiece(piece.piece, piece.pos, board, legal: false)
        .any((elements) => elements == kingPositons)) {
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
  if (ms.isPromotion) {
    return strFEN +=
        "${BoardHelper.squareNameFromSquare(ms.move.end)}=${Piece.getSymbol(ms.promotionType)}${ms.isInCheck ? "+" : ""}";
  }
  strFEN += Piece.getSymbolMoveLog(ms.movedPiece);
  if (ms.takenPiece != Piece.None || ms.enPassantPiece != Piece.None) {
    strFEN += "x";
  }

  strFEN += BoardHelper.squareNameFromSquare(ms.move.end);
  if (isAnyMoveLeft && isInCheck) {
    return strFEN += "#";
  }
  if (isInCheck) {
    strFEN += "+";
  }
  return strFEN;
}
