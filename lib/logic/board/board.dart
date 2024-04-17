import 'package:chess_flutter_app/common/widgets/square/square.dart';
import 'package:chess_flutter_app/logic/board/game_state.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move_stack.dart';
import 'package:chess_flutter_app/logic/move_generation/square_value.dart';

class Board {
  int whiteIndex = 0;
  int blackIndex = 1;

  late List<int> square;
  List<MoveStack> movedStack = [];
  List<MoveStack> redoStack = [];

  List<ChessPiece> whitePieces = [];
  List<ChessPiece> blackPieces = [];

  int enPassantPiece = Piece.None;
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

  late GameState currentGameState;

  bool initBoard() {
    return BoardHelper.loadPieceFromfen(this, BoardHelper.TEST_FEN_PROMOTION);
  }

  bool resetBoard() {
    movedStack.clear();
    redoStack.clear();
    whitePieces.clear();
    blackPieces.clear();
    enPassantPos = -1;
    return initBoard();
  }
}

MoveStack push(Board board, Move move, {int promotionType = Piece.None}) {
  var ms = MoveStack(move, board.square[move.start], board.square[move.end],
      board.enPassantPiece, board.enPassantPos);
  // Castled move
  if (isKingCastle(ms)) {
    castle(board, ms);
  } else {
    // make Move
    makeMove(board, ms);
    if (Piece.pieceType(ms.movedPiece) == Piece.Pawn) {
      // promotion
      if (isPromotion(ms.movedPiece, ms.move.end)) {
        ms.promotionType = promotionType;
        move.promotionType = promotionType;
        promote(board, ms);
      }
      // en Passant
      // checkEnPassant(board, ms);
      if (isPawnMovedTwoSquare(ms.move, ms.movedPiece)) {
        board.enPassantPos = (move.end + move.start) ~/ 2;
      }
    } // can taken enPassant
  }
  board.movedStack.add(ms);
  // board.enPassantPos = -1;
  board.indexMoveLog++;

  return ms;
}

MoveStack makeMoved(Board board, Move move, {int promotionType = Piece.None}) {
  var ms = MoveStack(move, board.square[move.start], board.square[move.end],
      board.enPassantPiece, board.enPassantPos);

  return ms;
}

MoveStack pushMS(Board board, MoveStack ms) {
  return push(board, ms.move, promotionType: ms.promotionType);
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
      addPiece(board, ms.enPassantPiece, ms.enPassantPos + offset);
      setSquare(board, ms.enPassantPos + offset, ms.enPassantPiece);
      board.enPassantPos = ms.enPassantPos;
    }
  }
  board.indexMoveLog--;
  return ms;
}

void makeMove(Board board, MoveStack ms, {bool isPlayerMove = false}) {
  setSquare(board, ms.move.end, ms.movedPiece);
  setSquare(board, ms.move.start, Piece.None);

  makeMovePos(ms, board);

  // ms.movedPiece
  if (ms.takenPiece != Piece.None) {
    removePiece(ms.takenPiece, board, ms.move.end);
  }
}

void undoMove(Board board, MoveStack ms) {
  setSquare(board, ms.move.start, ms.movedPiece);
  setSquare(board, ms.move.end, Piece.None);

  undoMovePos(ms, board);

  if (ms.takenPiece != Piece.None) {
    addPiece(board, ms.takenPiece, ms.move.end);
    setSquare(board, ms.move.end, ms.takenPiece);
  }
}

void makeMovePos(MoveStack ms, Board board) {
  if (Piece.isWhite(ms.movedPiece)) {
    for (var element in board.whitePieces) {
      if (element.piece == ms.movedPiece && element.pos == ms.move.start) {
        element.pos = ms.move.end;
        element.moveCount++;
      }
    }
  } else {
    for (var element in board.blackPieces) {
      if (element.piece == ms.movedPiece && element.pos == ms.move.start) {
        element.pos = ms.move.end;
        element.moveCount++;
      }
    }
  }
}

void undoMovePos(MoveStack ms, Board board) {
  if (Piece.isWhite(ms.movedPiece)) {
    for (var element in board.whitePieces) {
      if (element.piece == ms.movedPiece && element.pos == ms.move.end) {
        element.pos = ms.move.start;
        element.moveCount--;
        if (ms.isCasted) {}
      }
    }
  } else {
    for (var element in board.blackPieces) {
      if (element.piece == ms.movedPiece && element.pos == ms.move.end) {
        element.pos = ms.move.start;
        element.moveCount--;
      }
    }
  }
}

void setSquare(Board board, int? squareIndex, int piece) {
  if (squareIndex != null) {
    board.square[squareIndex] = piece;
  }
}

int evaluateBoard(Board board, bool isWhiteTurn) {
  int value = 0;
  for (var piece in board.whitePieces + board.blackPieces) {
    value += Piece.pieceValue(piece.piece) +
        squareValue(piece.piece, piece.pos, isWhiteTurn);
  }
  return value;
}

void removePiece(int piece, Board board, int pos) {
  if (piece != Piece.None) {
    piecesForPlayer(Piece.isWhite(piece), board)
        .removeWhere((element) => element.piece == piece && element.pos == pos);
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

void castle(Board board, MoveStack ms) {
  MoveStack? msR;
  setSquare(board, ms.move.end, ms.movedPiece);
  setSquare(board, ms.move.start, Piece.None);
  makeMovePos(ms, board);
  var eCol = BoardHelper.colIndex(ms.move.end);
  // [0] => Pos : 0 , [1] => Pos : 7, [2] => Pos : 56,  [3] => Pos : 63
  if (eCol == 2) {
    setSquare(board, ms.move.end + 1, board.square[ms.move.end - 2]);
    setSquare(board, ms.move.end - 2, Piece.None);
    msR = MoveStack(Move(ms.move.end - 2, ms.move.end + 1),
        board.square[ms.move.end + 1], 0, 0, 0);
  } else if (eCol == 6) {
    setSquare(board, ms.move.end - 1, board.square[ms.move.end + 1]);
    setSquare(board, ms.move.end + 1, Piece.None);
    msR = MoveStack(Move(ms.move.end + 1, ms.move.end - 1),
        board.square[ms.move.end - 1], 0, 0, 0);
  }
  makeMovePos(msR!, board);

  ms.isCasted = true;
}

void undoCastle(Board board, MoveStack ms) {
  var eCol = BoardHelper.colIndex(ms.move.end);
  MoveStack? msR;
  setSquare(board, ms.move.start, board.square[ms.move.end]);
  setSquare(board, ms.move.end, Piece.None);
  undoMovePos(ms, board);
  // Queen Side
  if (eCol == 2) {
    // Rook
    setSquare(board, ms.move.end - 2, board.square[ms.move.end + 1]);
    setSquare(board, ms.move.end + 1, Piece.None);
    msR = MoveStack(Move(ms.move.end - 2, ms.move.end + 1),
        board.square[ms.move.end - 2], 0, 0, 0);
  } else if (eCol == 6) {
    // Rook
    setSquare(board, ms.move.end + 1, board.square[ms.move.end - 1]);
    setSquare(board, ms.move.end - 1, Piece.None);
    msR = MoveStack(Move(ms.move.end + 1, ms.move.end - 1),
        board.square[ms.move.end + 1], 0, 0, 0);
  }
  undoMovePos(msR!, board);
}

void promote(Board board, MoveStack ms) {
  // ms.movedPiece = ms.promotionType != Piece.None ?

  if (ms.promotionType != Piece.None) {
    removePiece(ms.movedPiece, board, ms.move.end);
    addPiece(board, ms.promotionType, ms.move.end);
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
  if (ms.promotionType != Piece.None) {
    ms.movedPiece = Piece.Pawn;
    removePiece(ms.promotionType, board, ms.move.start);
    addPiece(board, ms.movedPiece, ms.move.start);
    setSquare(board, ms.move.start, ms.movedPiece);
  }

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
    removePiece(board.square[squareIndex], board, squareIndex);
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
  return Piece.pieceType(piece) == Piece.Pawn && (row == 7 || row == 0);
}

bool isPawnMovedTwoSquare(Move move, int piece) {
  return (move.start - move.end).abs() == 16 &&
      Piece.pieceType(piece) == Piece.Pawn;
}

ChessPiece getKingChessPiece(int king, board) {
  return piecesForPlayer(Piece.isWhite(king), board)
      .firstWhere((element) => Piece.pieceType(element.piece) == Piece.King);
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
      (board.whitePieces.any((element) => element.piece == Piece.WhiteKnight) ||
          board.blackPieces
              .any((element) => element.piece == Piece.BlackKnight));
}

bool isKingBishopVKing(Board board) {
  return (board.whitePieces.length + board.blackPieces.length) == 3 &&
      (board.whitePieces.any((element) => element.piece == Piece.WhiteBishop) ||
          board.blackPieces
              .any((element) => element.piece == Piece.BlackBishop));
}

bool isKingBishopVKingBishop(Board board) {
  if ((board.whitePieces.length + board.blackPieces.length) != 4) {
    return false;
  }
  if (board.whitePieces
              .where((element) => element.piece == Piece.WhiteBishop)
              .length !=
          1 ||
      board.blackPieces
              .where((element) => element.piece == Piece.BlackBishop)
              .length !=
          1) {
    return false;
  }

  var wBishopPos = board.whitePieces
      .firstWhere((element) => element.piece == Piece.WhiteBishop);
  var bBishopPos = board.blackPieces
      .firstWhere((element) => element.piece == Piece.BlackBishop);
  return BoardHelper.sameSquareColor(wBishopPos.pos) ==
      BoardHelper.sameSquareColor(bBishopPos.pos);
}

List<bool> isCastleRight(Board board, bool isWhiteKing) {
  var cRQueenSide = false;
  var cRKingSide = false;
  var kingPos = isWhiteKing ? 60 : 4;
  var rookKingSidePos = isWhiteKing ? 63 : 7;
  var rookQueenSidePos = isWhiteKing ? 56 : 0;
  List<ChessPiece> rookList = [];
  for (var piece in piecesForPlayer(isWhiteKing, board)) {
    if (Piece.pieceType(piece.piece) == Piece.King &&
        (piece.pos != kingPos || piece.moveCount != 0)) {
      return [];
    }
    if (Piece.pieceType(piece.piece) == Piece.Rook) {
      rookList.add(piece);
    }
  }
  for (var rook in rookList) {
    // Queen side
    if (rook.pos == rookQueenSidePos && rook.moveCount == 0) {
      cRQueenSide = true;
    }
    // King side
    if (rook.pos == rookKingSidePos && rook.moveCount == 0) {
      cRKingSide = true;
    }
  }
  return [cRQueenSide, cRKingSide];
}

// bool _inEndGame(Board board) {
//   return (_queensForPlayer(Player.player1, board).isEmpty &&
//           _queensForPlayer(Player.player2, board).isEmpty) ||
//       piecesForPlayer(Player.player1, board).length <= 3 ||
//       piecesForPlayer(Player.player2, board).length <= 3;
// }
