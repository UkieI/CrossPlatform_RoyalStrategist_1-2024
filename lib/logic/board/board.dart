import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move_stack.dart';
import 'package:chess_flutter_app/logic/move_generation/move_generation.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';

class Board {
  late List<int> square;
  List<MoveStack> movedStack = [];
  List<MoveStack> redoStack = [];

  List<int> whitePieces = [];
  List<int> blackPieces = [];

  List<int> kingPositions = [60, 4]; // [0] : whiteKing ; [1] : blackKing
  bool isWhiteKingMoved = false;
  bool isBlackKingMoved = false;
  List<bool> isRookHasMoved = List.filled(4,
      false); // [0] => Pos : 0 , [1] => Pos : 7, [2] => Pos : 56,  [3] => Pos : 63
  bool isWhiteKingInCheck = false;
  bool isBlackKingInCheck = false;
  int enPassantPiece = Piece.None;
  int enPassantPos = -1;

  List<int> player1Rooks = [];
  List<int> player2Rooks = [];
  List<int> player1Queens = [];
  List<int> player2Queens = [];
  int indexMoveLog = 0;
  int noCaptureOrPawnMoves = 0;

  initBoard() {
    String fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 0";
    BoardHelper.loadPieceFromfen(this, fen);
  }
}

MoveStack push(Board board, Move move,
    {bool isPlayerMoved = false, int promotionType = Piece.None}) {
  var ms = MoveStack(move, board.square[move.start], board.square[move.end],
      board.enPassantPiece, board.enPassantPos);
  // Castled move
  if (isKingCastle(ms) && isPlayerMoved) {
    makeMove(board, ms);
    castle(board, ms);
  } else {
    // make Move
    makeMove(board, ms, isPlayerMove: isPlayerMoved);
    if (Piece.pieceType(ms.movedPiece) == Piece.Pawn && isPlayerMoved) {
      // promotion
      if (isPromotion(ms.movedPiece, ms.move.end)) {
        ms.promotionType = promotionType;
        promote(board, ms);
      }
      // en Passant
      checkEnPassant(board, ms);
      if (isPawnMovedTwoSquare(move)) {
        board.enPassantPos = (move.end + move.start) ~/ 2;
      }
      board.noCaptureOrPawnMoves = 0;
    } // can taken enPassant
    if (isKingInCheck(board, !Piece.isWhite(board.square[ms.move.end])) &&
        isPlayerMoved) {
      ms.isInCheck = true;
    }
    // board.enPassantPos = ms.enPassantPos;
  }
  board.movedStack.add(ms);
  board.indexMoveLog++;
  board.noCaptureOrPawnMoves++;
  return ms;
}

MoveStack pushMS(Board board, MoveStack ms) {
  return push(board, ms.move,
      promotionType: ms.promotionType, isPlayerMoved: true);
}

MoveStack pop(Board board) {
  MoveStack ms = board.movedStack.removeLast();
  board.enPassantPos = ms.enPassantPos;

  // if that previous move is Castling
  if (ms.isCasted) {
    undoCastle(board, ms);
  } else {
    // standard Move

    undoMove(board, ms);
    if (ms.isPromotion) {
      // undo Promotion pawn
      undoPromote(board, ms);
    }
    if (ms.isEnPassant) {
      var offset = Piece.isWhite(ms.movedPiece) ? 8 : -8;
      // undo EnPassant capture
      addPiece(board, ms.enPassantPiece);
      setSquare(board, ms.enPassantPos + offset, ms.enPassantPiece);
    }
  }
  board.indexMoveLog--;
  return ms;
}

void makeMove(Board board, MoveStack ms, {bool isPlayerMove = false}) {
  setSquare(board, ms.move.end, ms.movedPiece);
  setSquare(board, ms.move.start, Piece.None);
  if (Piece.pieceType(ms.movedPiece) == Piece.King) {
    Piece.isWhite(ms.movedPiece)
        ? board.kingPositions[0] = ms.move.end
        : board.kingPositions[1] = ms.move.end;
  }
  // ms.movedPiece
  if (ms.takenPiece != Piece.None) {
    removePiece(ms.takenPiece, board);
    if (isPlayerMove) {
      board.noCaptureOrPawnMoves = 0;
    }
  }
}

void undoMove(Board board, MoveStack ms) {
  setSquare(board, ms.move.start, ms.movedPiece);
  setSquare(board, ms.move.end, Piece.None);
  if (Piece.pieceType(ms.movedPiece) == Piece.King) {
    Piece.isWhite(ms.movedPiece)
        ? board.kingPositions[0] = ms.move.start
        : board.kingPositions[1] = ms.move.start;
  }
  if (ms.takenPiece != Piece.None) {
    addPiece(board, ms.takenPiece);
    setSquare(board, ms.move.end, ms.takenPiece);
  }
  // ms.movedPiece?.moveCount--;
}

void setSquare(Board board, int? squareIndex, int piece) {
  if (squareIndex != null) {
    board.square[squareIndex] = piece;
  }
}

int evaluateBoard(Board board) {
  int value = 0;
  for (int piece in board.whitePieces + board.blackPieces) {
    value += Piece.pieceValue(piece);
  }
  return value;
}

void removePiece(int piece, Board board) {
  if (piece != Piece.None) {
    piecesForPlayer(Piece.isWhite(piece), board).remove(piece);
  }
}

void addPiece(Board board, int piece) {
  if (piece != Piece.None) {
    piecesForPlayer(Piece.isWhite(piece), board).add(piece);
  }
}

List<int> piecesForPlayer(bool isWhite, Board board) {
  return isWhite ? board.whitePieces : board.blackPieces;
}

List<int> rooksForPlayer(bool isWhite, Board board) {
  return isWhite ? board.player1Rooks : board.player2Rooks;
}

List<int> queensForPlayer(bool isWhite, Board board) {
  return isWhite ? board.player1Queens : board.player2Queens;
}

void castle(Board board, MoveStack ms) {
  var eCol = BoardHelper.colIndex(ms.move.end);
  if (eCol == 2) {
    setSquare(board, ms.move.end + 1, board.square[ms.move.end - 2]);
    setSquare(board, ms.move.end - 2, Piece.None);
  } else if (eCol == 6) {
    setSquare(board, ms.move.end - 1, board.square[ms.move.end + 1]);
    setSquare(board, ms.move.end + 1, Piece.None);
  }
  Piece.isWhite(ms.movedPiece)
      ? board.kingPositions[0] = ms.move.end
      : board.kingPositions[1] = ms.move.end;
  ms.isCasted = true;
}

void undoCastle(Board board, MoveStack ms) {
  var eCol = BoardHelper.colIndex(ms.move.end);
  setSquare(board, ms.move.start, board.square[ms.move.end]);
  setSquare(board, ms.move.end, Piece.None);
  // Queen Side
  if (eCol == 2) {
    // Rook
    setSquare(board, ms.move.end - 2, board.square[ms.move.end + 1]);
    setSquare(board, ms.move.end + 1, Piece.None);
  } else if (eCol == 6) {
    // Rook
    setSquare(board, ms.move.end + 1, board.square[ms.move.end - 1]);
    setSquare(board, ms.move.end - 1, Piece.None);
  }
  Piece.isWhite(ms.movedPiece)
      ? board.kingPositions[0] = ms.move.end
      : board.kingPositions[1] = ms.move.end;
  ms.isCasted = true;
}

void promote(Board board, MoveStack ms) {
  // ms.movedPiece = ms.promotionType != Piece.None ?  ChessPieceType.promotion;

  if (ms.promotionType != Piece.None) {
    removePiece(ms.movedPiece, board);
    addPiece(board, ms.promotionType);
    // addPromotedPiece(board, ms);
    setSquare(board, ms.move.end, ms.promotionType);
  }
  ms.isPromotion = true;
}

void addPromotedPiece(Board board, MoveStack ms) {
  switch (Piece.pieceType(ms.promotionType)) {
    case Piece.Queen:
      {
        if (ms.movedPiece != Piece.None) {
          queensForPlayer(Piece.isWhite(ms.movedPiece), board)
              .add(ms.movedPiece);
        }
      }
      break;
    case Piece.Rook:
      {
        if (ms.movedPiece != Piece.None) {
          rooksForPlayer(Piece.isWhite(ms.movedPiece), board)
              .add(ms.movedPiece);
        }
      }
      break;
    default:
      {}
  }
}

void undoPromote(Board board, MoveStack ms) {
  // ms.movedPiece = Piece.Pawn;
  // removePiece(ms.promotionType, board);
  // addPiece(board, ms.movedPiece);

  switch (Piece.pieceType(ms.promotionType)) {
    case Piece.Queen:
      {
        queensForPlayer(Piece.isWhite(ms.movedPiece), board)
            .remove(ms.movedPiece);
      }
      break;
    case Piece.Rook:
      {
        rooksForPlayer(Piece.isWhite(ms.movedPiece), board)
            .remove(ms.movedPiece);
      }
      break;
    default:
      {}
  }
}

void checkEnPassant(Board board, MoveStack ms) {
  var offset = Piece.isWhite(ms.movedPiece) ? 8 : -8;
  var squareIndex = ms.move.end + offset;
  if (board.square[squareIndex] != Piece.None &&
      ms.move.end == board.enPassantPos) {
    ms.enPassantPiece = board.square[squareIndex];
    removePiece(board.square[squareIndex], board);
    setSquare(board, squareIndex, Piece.None);
    ms.isEnPassant = true;
  } else {
    board.enPassantPos = -1;
  }
}

bool isKingCastle(MoveStack ms) {
  return (ms.move.start - ms.move.end).abs() == 2 &&
      Piece.pieceType(ms.movedPiece) == Piece.King;
}

bool isPromotion(int piece, int ePos) {
  var row = BoardHelper.rowIndex(ePos);
  return piece == Piece.Pawn && (row == 7 || row == 0);
}

bool isPawnMovedTwoSquare(Move move) {
  return (move.start - move.end).abs() == 16;
}

bool insufficientMaterial(Board board) {
  return isKingVKing(board) ||
      isKingBishopVKing(board) ||
      isKingKnightVKing(board) ||
      isKingBishopVKingBishop(board);
}

bool isKingVKing(Board board) {
  return (board.whitePieces.length + board.blackPieces.length) == 2;
}

bool isKingKnightVKing(Board board) {
  return (board.whitePieces.length + board.blackPieces.length) == 3 &&
      (board.whitePieces.contains(Piece.WhiteKnight) ||
          board.blackPieces.contains(Piece.BlackKnight));
}

bool isKingBishopVKing(Board board) {
  return (board.whitePieces.length + board.blackPieces.length) == 3 &&
      (board.whitePieces.contains(Piece.WhiteBishop) ||
          board.blackPieces.contains(Piece.BlackBishop));
}

bool isKingBishopVKingBishop(Board board) {
  if ((board.whitePieces.length + board.blackPieces.length) != 4) {
    return false;
  }
  if (board.whitePieces
              .where((element) => element == Piece.WhiteBishop)
              .length !=
          1 ||
      board.blackPieces
              .where((element) => element == Piece.BlackBishop)
              .length !=
          1) {
    return false;
  }
  int wBishopPos = findPiece(Piece.WhiteBishop, board);
  int bBishopPos = findPiece(Piece.BlackBishop, board);

  return BoardHelper.sameSquareColor(wBishopPos) ==
      BoardHelper.sameSquareColor(bBishopPos);
}

int findPiece(int piece, Board board) {
  for (int squareIndex = 0; squareIndex < 64; squareIndex++) {
    if (board.square[squareIndex] != Piece.None &&
        board.square[squareIndex] == piece) {
      return squareIndex;
    }
  }
  return -1;
}

bool fiftyMoveRule(Board board) {
  int fullMoves = board.noCaptureOrPawnMoves ~/ 2;
  return fullMoves == 50;
}

bool threeFoldRepetion() {
  // return stateHistory[stateString] == 3;
  return false;
}
