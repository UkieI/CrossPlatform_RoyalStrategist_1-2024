import 'package:chess_flutter_app/logic/board/game_state.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move_stack.dart';
import 'package:chess_flutter_app/logic/move_generation/square_value.dart';
import 'package:get/get.dart';

class Board {
  int whiteIndex = 0;
  int blackIndex = 1;

  late List<int> square;
  List<MoveStack> movedStack = [];
  List<MoveStack> redoStack = [];

  List<ChessPiece> whitePieces = [];
  List<ChessPiece> blackPieces = [];

  // Square index of white and black king
  List<int> kingSquare = [0, 0];

  // int enPassantPiece = Piece.None;
  int enPassantPos = -1;

  List<int> player1Rooks = [];
  List<int> player2Rooks = [];
  List<int> player1Queens = [];
  List<int> player2Queens = [];
  int indexMoveLog = 0;

  // # Side to move info
  bool isWhiteToMove = true;
  int moveColour() => isWhiteToMove ? Piece.White : Piece.Black;
  int opponentColour() => isWhiteToMove ? Piece.Black : Piece.White;
  int moveColourIndex() => isWhiteToMove ? whiteIndex : blackIndex;
  int opponentColourIndex() => isWhiteToMove ? blackIndex : whiteIndex;

  late int currentKingCastleRight;
  int initCastleRight = 15;

  bool initBoard() {
    // isWhiteToMove = true;
    var isWhiteToMove = BoardHelper.loadPieceFromfen(this, BoardHelper.INIT_FEN);
    currentKingCastleRight = initCastleRight; // bin 0b1111
    return isWhiteToMove;
  }

  bool resetBoard() {
    movedStack.clear();
    redoStack.clear();
    whitePieces.clear();
    blackPieces.clear();
    return initBoard();
  }
}

MoveStack push(Board board, Move move, {int promotionType = Piece.None}) {
  var ms = MoveStack(move, board.square[move.start], board.square[move.end], -1, board.currentKingCastleRight);
  // Get all information
  int startSquare = move.start;
  int targetSquare = move.end;
  // isEnPassant bool

  int movedPiece = board.square[startSquare];
  int movedPieceType = Piece.pieceType(movedPiece);
  // board.isWhiteToMove = Piece.isWhite(movedPiece);

  int prevCastleState = board.currentKingCastleRight;
  int prevEnPassantPos = board.enPassantPos;
  int newCastlingRights = board.currentKingCastleRight;

  bool isEnPassant = (prevEnPassantPos == targetSquare && Piece.pieceType(movedPiece) == Piece.Pawn);

  int capturedPiece = isEnPassant ? Piece.makePieceIB(Piece.Pawn, !board.isWhiteToMove) : board.square[targetSquare];
  int capturedPieceType = Piece.pieceType(capturedPiece);

  // Make stardard move
  makeMove(board, ms);

  if (capturedPieceType != Piece.None) {
    int captureSquare = targetSquare;

    if (isEnPassant) {
      captureSquare = targetSquare + (board.isWhiteToMove ? 8 : -8);
      board.square[captureSquare] = Piece.None;
      ms.isEnPassant = true;
    }
    ms.takenPiece = capturedPiece;
    removePiece(ms.takenPiece, board, targetSquare);
  }

  // Handle king
  if (movedPieceType == Piece.King) {
    board.kingSquare[board.moveColourIndex()] = targetSquare;
    newCastlingRights &= board.isWhiteToMove ? 12 : 3; // 1100 & 0011
    // Handle castling
    if (isKingCastle(startSquare, targetSquare)) {
      bool kingside = targetSquare == BoardHelper.g1 || targetSquare == BoardHelper.g8;
      int castlingRookFromIndex = (kingside) ? targetSquare + 1 : targetSquare - 2;
      int castlingRookToIndex = (kingside) ? targetSquare - 1 : targetSquare + 1;

      board.square[castlingRookFromIndex] = Piece.None;
      board.square[castlingRookToIndex] = Piece.Rook | board.moveColour();
      ms.isCasted = true;

      makeMovePos(board.square[castlingRookToIndex], castlingRookFromIndex, castlingRookToIndex, board);
    }
  }

  // handle Promotion
  if (isPromotion(movedPiece, targetSquare) && promotionType != Piece.None) {
    ms.promotionType = promotionType;
    move.promotionType = promotionType;

    int promotionPiece = Piece.makePieceII(ms.promotionType, board.moveColour());
    removePiece(ms.movedPiece, board, targetSquare);
    addPiece(board, promotionPiece, targetSquare);
    setSquare(board, targetSquare, promotionPiece);
    ms.isPromotion = true;
  }

  // Pawn has moved two forwards, mark file with en-passant flag
  if (isPawnMovedTwoSquare(startSquare, targetSquare, movedPiece)) {
    ms.enPassantPos = (startSquare + targetSquare) ~/ 2;
  }
  // Update castling rights
  if (prevCastleState != 0) {
    // Any piece moving to/from rook square removes castling right for that side
    if (targetSquare == BoardHelper.h1 || startSquare == BoardHelper.h1) {
      newCastlingRights &= GameState.clearWhiteKingsideMask;
    } else if (targetSquare == BoardHelper.a1 || startSquare == BoardHelper.a1) {
      newCastlingRights &= GameState.clearWhiteQueensideMask;
    }
    if (targetSquare == BoardHelper.h8 || startSquare == BoardHelper.h8) {
      newCastlingRights &= GameState.clearBlackKingsideMask;
    } else if (targetSquare == BoardHelper.a8 || startSquare == BoardHelper.a8) {
      newCastlingRights &= GameState.clearBlackQueensideMask;
    }
    ms.castlingRights = newCastlingRights;
  }
  board.currentKingCastleRight = newCastlingRights;

  // Change side to move
  board.isWhiteToMove = !board.isWhiteToMove;

  board.movedStack.add(ms);
  // board.enPassantPos = -1;
  board.indexMoveLog++;

  // board.enPassantPos = ms.enPassantPos;

  return ms;
}

MoveStack pushMS(Board board, MoveStack ms) {
  return push(board, ms.move, promotionType: ms.promotionType);
}

MoveStack pop(Board board) {
  board.isWhiteToMove = !board.isWhiteToMove;

  bool undoingWhiteMove = board.isWhiteToMove;

  MoveStack ms = board.movedStack.removeLast();
  // bool undoingWhiteMove = Piece.isWhite(ms.movedPiece);
  int movedFrom = ms.move.start;
  int movedTo = ms.move.end;
  int movedPiece = ms.isPromotion ? Piece.makePieceII(Piece.Pawn, board.moveColour()) : board.square[movedTo];
  int movedPieceType = Piece.pieceType(movedPiece);
  int capturedPieceType = Piece.pieceType(ms.takenPiece);

  if (ms.isPromotion) {
    int promotedPiece = board.square[movedTo];
    // Piece.makePieceII(Piece.Pawn, board.moveColour());
    removePiece(promotedPiece, board, movedTo);
    addPiece(board, ms.movedPiece, movedTo);
  }

  undoMove(board, ms);

  if (ms.takenPiece != Piece.None) {
    int captureSquare = movedTo;
    int capturedPiece = Piece.makePieceIB(capturedPieceType, !undoingWhiteMove);

    if (ms.isEnPassant) {
      captureSquare = movedTo + ((undoingWhiteMove) ? 8 : -8);
    }
    addPiece(board, ms.takenPiece, captureSquare);
    board.square[captureSquare] = capturedPiece;
  }

  if (movedPieceType == Piece.King) {
    board.kingSquare[undoingWhiteMove ? 0 : 1] = movedFrom;

    // Undo castling
    if (ms.isCasted) {
      int rookPiece = Piece.makePieceIB(Piece.Rook, undoingWhiteMove);
      bool kingside = movedTo == BoardHelper.g1 || movedTo == BoardHelper.g8;
      int rookSquareBeforeCastling = kingside ? movedTo + 1 : movedTo - 2;
      int rookSquareAfterCastling = kingside ? movedTo - 1 : movedTo + 1;
      // Undo castling by returning rook to original square
      board.square[rookSquareAfterCastling] = Piece.None;
      board.square[rookSquareBeforeCastling] = rookPiece;

      undoMovePos(board.square[rookSquareBeforeCastling], rookSquareAfterCastling, rookSquareBeforeCastling, board);
    }
  }

  if (board.movedStack.isEmpty) {
    board.currentKingCastleRight = board.initCastleRight;
    board.enPassantPos = -1;
  } else {
    board.currentKingCastleRight = board.movedStack.last.castlingRights;
    board.enPassantPos = board.movedStack.last.enPassantPos;
  }

  board.indexMoveLog--;

  return ms;
}

void makeMove(Board board, MoveStack ms, {bool isPlayerMove = false}) {
  setSquare(board, ms.move.end, ms.movedPiece);
  setSquare(board, ms.move.start, Piece.None);

  makeMovePos(ms.movedPiece, ms.move.start, ms.move.end, board);
}

void undoMove(Board board, MoveStack ms) {
  setSquare(board, ms.move.start, ms.movedPiece);
  setSquare(board, ms.move.end, Piece.None);

  undoMovePos(ms.movedPiece, ms.move.start, ms.move.end, board);
}

void makeMovePos(int piece, int start, int end, Board board) {
  for (var element in piecesForPlayer(Piece.isWhite(piece), board)) {
    if (element.piece == piece && element.pos == start) {
      element.pos = end;
    }
  }
}

void undoMovePos(int piece, int start, int end, Board board) {
  for (var element in piecesForPlayer(Piece.isWhite(piece), board)) {
    if (element.piece == piece && element.pos == end) {
      element.pos = start;
    }
  }
}

void setSquare(Board board, int? squareIndex, int piece) {
  if (squareIndex != null) {
    board.square[squareIndex] = piece;
  }
}

int evaluateBoard(Board board, bool isWhiteMove) {
  int value = 0;
  for (var piece in board.whitePieces + board.blackPieces) {
    value += Piece.pieceValue(piece.piece) + squareValue(piece.piece, piece.pos, isWhiteMove);
  }
  return value;
}

void removePiece(int piece, Board board, int pos) {
  if (piece != Piece.None) {
    piecesForPlayer(Piece.isWhite(piece), board).removeWhere((element) => element.piece == piece && element.pos == pos);
  }
}

void addPiece(Board board, int piece, int pos) {
  if (piece != Piece.None) {
    piecesForPlayer(Piece.isWhite(piece), board).add(ChessPiece(piece, pos));
  }
}

List<ChessPiece> piecesForPlayer(bool isWhite, Board board) {
  return isWhite ? board.whitePieces : board.blackPieces;
}

List<int> rooksForPlayer(bool isWhite, Board board) {
  return isWhite ? board.player1Rooks : board.player2Rooks;
}

List<int> queensForPlayer(bool isWhite, Board board) {
  return isWhite ? board.player1Queens : board.player2Queens;
}

void promote(Board board, MoveStack ms) {
  // ms.movedPiece = ms.promotionType != Piece.None ?

  if (ms.promotionType != Piece.None) {
    removePiece(ms.movedPiece, board, ms.move.end);
    addPiece(board, ms.promotionType, ms.move.end);
    setSquare(board, ms.move.end, ms.promotionType);
    ms.isPromotion = true;
  }
}

void addPromotedPiece(Board board, MoveStack ms) {
  switch (Piece.pieceType(ms.promotionType)) {
    case Piece.Queen:
      {
        if (ms.movedPiece != Piece.None) {
          queensForPlayer(Piece.isWhite(ms.movedPiece), board).add(ms.movedPiece);
        }
      }
      break;
    case Piece.Rook:
      {
        if (ms.movedPiece != Piece.None) {
          rooksForPlayer(Piece.isWhite(ms.movedPiece), board).add(ms.movedPiece);
        }
      }
      break;
    default:
      {}
  }
}

void undoPromote(Board board, MoveStack ms) {
  if (ms.promotionType != Piece.None) {
    ms.movedPiece = Piece.Pawn;
    removePiece(ms.promotionType, board, ms.move.start);
    addPiece(board, ms.movedPiece, ms.move.start);
    setSquare(board, ms.move.start, ms.movedPiece);
  }

  switch (Piece.pieceType(ms.promotionType)) {
    case Piece.Queen:
      {
        queensForPlayer(Piece.isWhite(ms.movedPiece), board).remove(ms.movedPiece);
      }
      break;
    case Piece.Rook:
      {
        rooksForPlayer(Piece.isWhite(ms.movedPiece), board).remove(ms.movedPiece);
      }
      break;
    default:
      {}
  }
}

void checkEnPassant(Board board, MoveStack ms) {
  var offset = Piece.isWhite(ms.movedPiece) ? 8 : -8;
  var squareIndex = ms.move.end + offset;
  if (board.square[squareIndex] != Piece.None && ms.move.end == board.enPassantPos) {
    ms.takenPiece = board.square[squareIndex];
    removePiece(board.square[squareIndex], board, squareIndex);
    setSquare(board, squareIndex, Piece.None);
    ms.isEnPassant = true;
  } else {
    board.enPassantPos = -1;
  }
}

bool hasKingsideCastleRight(int castlingRights, bool white) {
  int mask = white ? 1 : 4;
  return (castlingRights & mask) != 0;
}

bool hasQueensideCastleRight(int castlingRights, bool white) {
  int mask = white ? 2 : 8;
  return (castlingRights & mask) != 0;
}

// bool isKingCastle(MoveStack ms) {
//   return (ms.move.start - ms.move.end).abs() == 2 && Piece.pieceType(ms.movedPiece) == Piece.King;
// }
bool isKingCastle(int start, int end) {
  return (start - end).abs() == 2;
}

bool isPromotion(int piece, int ePos) {
  var row = BoardHelper.rowIndex(ePos);
  return Piece.pieceType(piece) == Piece.Pawn && (row == 7 || row == 0);
}

bool isPawnMovedTwoSquare(int sPos, int ePos, int piece) {
  return (sPos - ePos).abs() == 16 && Piece.pieceType(piece) == Piece.Pawn;
}

// ChessPiece getKingChessPiece(int king, board) {
//   return piecesForPlayer(Piece.isWhite(king), board).firstWhere((element) => Piece.pieceType(element.piece) == Piece.King);
// }

bool insufficientMaterial(Board board) {
  return isKingVKing(board) || isKingBishopVKing(board) || isKingKnightVKing(board) || isKingBishopVKingBishop(board);
}

bool isKingVKing(Board board) {
  return (board.whitePieces.length + board.blackPieces.length) == 2;
}

bool isKingKnightVKing(Board board) {
  return (board.whitePieces.length + board.blackPieces.length) == 3 &&
      (board.whitePieces.any((element) => element.piece == Piece.WhiteKnight) || board.blackPieces.any((element) => element.piece == Piece.BlackKnight));
}

bool isKingBishopVKing(Board board) {
  return (board.whitePieces.length + board.blackPieces.length) == 3 &&
      (board.whitePieces.any((element) => element.piece == Piece.WhiteBishop) || board.blackPieces.any((element) => element.piece == Piece.BlackBishop));
}

bool isKingBishopVKingBishop(Board board) {
  if ((board.whitePieces.length + board.blackPieces.length) != 4) {
    return false;
  }
  if (board.whitePieces.where((element) => element.piece == Piece.WhiteBishop).length != 1 || board.blackPieces.where((element) => element.piece == Piece.BlackBishop).length != 1) {
    return false;
  }

  var wBishopPos = board.whitePieces.firstWhere((element) => element.piece == Piece.WhiteBishop);
  var bBishopPos = board.blackPieces.firstWhere((element) => element.piece == Piece.BlackBishop);
  return BoardHelper.sameSquareColor(wBishopPos.pos) == BoardHelper.sameSquareColor(bBishopPos.pos);
}



// bool _inEndGame(Board board) {
//   return (_queensForPlayer(Player.player1, board).isEmpty &&
//           _queensForPlayer(Player.player2, board).isEmpty) ||
//       piecesForPlayer(Player.player1, board).length <= 3 ||
//       piecesForPlayer(Player.player2, board).length <= 3;
// }
