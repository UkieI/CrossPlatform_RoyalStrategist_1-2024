import 'dart:math';

import 'package:chess_flutter_app/logic/board/game_state.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move_stack.dart';
import 'package:chess_flutter_app/logic/move_generation/opening_moves.dart';

class Board {
  static int whiteIndex = 0;
  static int blackIndex = 1;

  late List<int> square;
  List<MoveStack> movedStack = [];
  List<MoveStack> redoStack = [];

  List<ChessPiece> whitePieces = [];
  List<ChessPiece> blackPieces = [];

  // Square index of white and black king
  List<int> kingSquare = [0, 0];
  // List all possible openings
  List<Move> possibleOpenings = [];
  // List<List<Move>> possibleOpenings = List.of(openings);

  List<int> player1Rooks = [];
  List<int> player2Rooks = [];
  List<int> player1Queens = [];
  List<int> player2Queens = [];
  int indexMoveLog = 0;
  bool aiMove = true;

  // # Side to move info
  bool isWhiteToMove = true;
  int moveColour() => isWhiteToMove ? Piece.White : Piece.Black;
  int opponentColour() => isWhiteToMove ? Piece.Black : Piece.White;
  int moveColourIndex() => isWhiteToMove ? whiteIndex : blackIndex;
  int opponentColourIndex() => isWhiteToMove ? blackIndex : whiteIndex;

  // GameState
  int currentKingCastleRight = 15;
  int currentEnPassantPos = -1;
  int currentFiftyMoveCounter = 0;

  int initKingCastleRight = 0;
  int initEnPassantPos = -1;
  int initFiftyMoveCounter = 0;

  bool initBoard(String fen) {
    bool isWhiteToMove;
    if (fen.isEmpty) {
      isWhiteToMove = BoardHelper.loadPieceFromfen(this, BoardHelper.INIT_FEN);
      var openingsIndex = Random().nextInt(openings.length);
      possibleOpenings = List.of(openings[openingsIndex]);
    } else {
      isWhiteToMove = BoardHelper.loadPieceFromfen(this, fen);
    }

    initKingCastleRight = currentKingCastleRight;
    initEnPassantPos = currentEnPassantPos;
    initFiftyMoveCounter = currentFiftyMoveCounter;

    // bin 0b1111
    return isWhiteToMove;
  }

  bool resetBoard(String fen) {
    var openingsIndex = Random().nextInt(openings.length);
    possibleOpenings = List.of(openings[openingsIndex]);
    indexMoveLog = 0;
    movedStack.clear();
    redoStack.clear();
    whitePieces.clear();
    blackPieces.clear();
    currentKingCastleRight = initKingCastleRight;
    currentEnPassantPos = initEnPassantPos;
    currentFiftyMoveCounter = initFiftyMoveCounter;
    aiMove = !isWhiteToMove;
    return initBoard(fen);
  }
}

MoveStack push(Board board, Move move, {int promotionType = Piece.None, int movedPieces = Piece.None}) {
  var ms = MoveStack(
    move,
    movedPiece: movedPieces != Piece.None ? movedPieces : board.square[move.start],
    takenPiece: board.square[move.end],
    enPassantPos: -1,
    castlingRights: board.currentKingCastleRight,
    fiftyMoveCounter: board.currentFiftyMoveCounter,
  );
  // Get all information
  int startSquare = move.start;
  int targetSquare = move.end;

  // isEnPassant bool

  int movedPiece = ms.movedPiece;
  int movedPieceType = Piece.pieceType(movedPiece);

  int prevCastleState = board.currentKingCastleRight;
  int prevEnPassantPos = board.currentEnPassantPos;
  int newCastlingRights = board.currentKingCastleRight;

  bool isEnPassant = (prevEnPassantPos == targetSquare && Piece.pieceType(movedPiece) == Piece.Pawn);

  int capturedPiece = isEnPassant ? Piece.makePieceII(Piece.Pawn, board.opponentColour()) : board.square[targetSquare];
  // int capturedPieceType = Piece.pieceType(capturedPiece);

  // Make stardard move
  makeMove(board, ms);

  if (capturedPiece != Piece.None) {
    int captureSquare = targetSquare;

    if (isEnPassant) {
      captureSquare = targetSquare + (board.isWhiteToMove ? 8 : -8);
      board.square[captureSquare] = Piece.None;
      ms.flags = MoveStack.EnPassantCaptureFlag;
      // ms.isEnPassant = true;
    }
    ms.takenPiece = capturedPiece;
    removePiece(ms.takenPiece, board, targetSquare);
  }

  // Handle king
  if (movedPieceType == Piece.King) {
    board.kingSquare[board.moveColourIndex()] = targetSquare;
    newCastlingRights &= (board.isWhiteToMove) ? 12 : 3; // 1100 & 0011
    // Handle castling
    if (isKingCastle(startSquare, targetSquare)) {
      bool kingside = targetSquare == BoardHelper.g1 || targetSquare == BoardHelper.g8;
      int castlingRookFromIndex = (kingside) ? targetSquare + 1 : targetSquare - 2;
      int castlingRookToIndex = (kingside) ? targetSquare - 1 : targetSquare + 1;

      // makeMove(board, ms);
      board.square[castlingRookFromIndex] = Piece.None;
      board.square[castlingRookToIndex] = Piece.Rook | board.moveColour();
      ms.flags = MoveStack.CastleFlag;
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

    // ms.isPromotion = true;
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
  }

  // Change side to move
  board.isWhiteToMove = !board.isWhiteToMove;
  int newFiftyMoveCounter = board.currentFiftyMoveCounter + 1;

  // Pawn moves and captures reset the fifty move counter and clear 3-fold repetition history
  if (movedPieceType == Piece.Pawn || capturedPiece != Piece.None) {
    newFiftyMoveCounter = 0;
  }

  // Set again current state board
  ms.castlingRights = newCastlingRights;
  ms.fiftyMoveCounter = newFiftyMoveCounter;

  board.currentKingCastleRight = ms.castlingRights;
  board.currentEnPassantPos = ms.enPassantPos;
  board.currentFiftyMoveCounter = ms.fiftyMoveCounter;

  board.indexMoveLog++;
  board.movedStack.add(ms);
  return ms;
}

MoveStack pushMS(Board board, MoveStack ms) {
  return push(board, ms.move, promotionType: ms.promotionType);
}

MoveStack pop(Board board) {
  // Swap colour to move
  board.isWhiteToMove = !board.isWhiteToMove;

  bool undoingWhiteMove = board.isWhiteToMove;

  MoveStack ms = board.movedStack.removeLast();

  // bool undoingWhiteMove = Piece.isWhite(ms.movedPiece);
  int movedFrom = ms.move.start;
  int movedTo = ms.move.end;
  int flags = ms.flags;

  bool undoingPromotion = ms.promotionType != Piece.None;
  bool undoingEnPassant = flags == MoveStack.EnPassantCaptureFlag;
  bool undoingCastleKing = flags == MoveStack.CastleFlag;

  int movedPiece = undoingPromotion ? Piece.makePieceII(Piece.Pawn, board.moveColour()) : board.square[movedTo];
  int movedPieceType = Piece.pieceType(movedPiece);

  if (undoingPromotion) {
    int promotedPiece = board.square[movedTo];
    // int pawnPiece =Piece.makePieceII(Piece.Pawn, board.moveColour());
    removePiece(promotedPiece, board, movedTo);
    addPiece(board, movedPiece, movedTo);
  }

  undoMove(board, ms);

  if (ms.takenPiece != Piece.None) {
    int captureSquare = movedTo;
    // int capturedPiece = Piece.makePieceII(capturedPieceType, board.opponentColour());

    if (undoingEnPassant) {
      captureSquare = movedTo + ((undoingWhiteMove) ? 8 : -8);
    }
    addPiece(board, ms.takenPiece, captureSquare);
    board.square[captureSquare] = ms.takenPiece;
  }

  if (movedPieceType == Piece.King) {
    board.kingSquare[board.moveColourIndex()] = movedFrom;

    // Undo castling
    if (undoingCastleKing) {
      int rookPiece = Piece.makePieceII(Piece.Rook, board.moveColour());
      bool kingside = movedTo == BoardHelper.g1 || movedTo == BoardHelper.g8;
      int rookSquareBeforeCastling = kingside ? movedTo + 1 : movedTo - 2;
      int rookSquareAfterCastling = kingside ? movedTo - 1 : movedTo + 1;
      // Undo castling by returning rook to original square
      board.square[rookSquareAfterCastling] = Piece.None;
      board.square[rookSquareBeforeCastling] = rookPiece;

      undoMovePos(rookPiece, rookSquareBeforeCastling, rookSquareAfterCastling, board);
    }
  }
  board.indexMoveLog--;

  if (board.movedStack.isEmpty) {
    board.currentKingCastleRight = board.initKingCastleRight;
    board.currentEnPassantPos = board.initEnPassantPos;
    board.currentFiftyMoveCounter = board.initFiftyMoveCounter;
  } else {
    var msLast = board.movedStack.last;
    board.currentFiftyMoveCounter = msLast.fiftyMoveCounter;
    board.currentKingCastleRight = msLast.castlingRights;
    board.currentEnPassantPos = msLast.enPassantPos;
  }

  return ms;
}

void makeMove(Board board, MoveStack ms) {
  setSquare(board, ms.move.end, ms.movedPiece);
  if (BoardHelper.isInBoard(ms.move.start)) {
    setSquare(board, ms.move.start, Piece.None);
  }

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

bool hasKingsideCastleRight(int castlingRights, bool white) {
  int mask = white ? 1 : 4;
  return (castlingRights & mask) != 0;
}

bool hasQueensideCastleRight(int castlingRights, bool white) {
  int mask = white ? 2 : 8;
  return (castlingRights & mask) != 0;
}

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
