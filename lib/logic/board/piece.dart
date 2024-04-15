// ignore_for_file: constant_identifier_names

enum PieceType { none, pawn, rook, knight, bishop, king, queen }

class Piece {
  static const None = 0;
  static const Pawn = 1;
  static const Knight = 2;
  static const Bishop = 3;
  static const Rook = 4;
  static const Queen = 5;
  static const King = 6;

  // Piece Colours
  static const White = 0;
  static const Black = 8;

  // Pieces
  static const WhitePawn = Pawn | White; // 1
  static const WhiteKnight = Knight | White; // 2
  static const WhiteBishop = Bishop | White; // 3
  static const WhiteRook = Rook | White; // 4
  static const WhiteQueen = Queen | White; // 5
  static const WhiteKing = King | White; // 6

  static const BlackPawn = Pawn | Black; // 9
  static const BlackKnight = Knight | Black; // 10
  static const BlackBishop = Bishop | Black; // 11
  static const BlackRook = Rook | Black; // 12
  static const BlackQueen = Queen | Black; // 13
  static const BlackKing = King | Black; // 14
  static const typeMask = 7;
  static const colourMask = 8;

  static int makePieceII(int pieceType, int pieceColor) =>
      pieceType | pieceColor;
  static int makePieceIB(int pieceType, bool pieceColor) =>
      makePieceII(pieceType, pieceColor ? White : Black);

  static bool isColour(int piece, int colour) =>
      (piece & colourMask) == colour && piece != 0;

  static bool isWhite(int piece) => isColour(piece, White);

  static int pieceColour(int piece) => piece & colourMask;

  static int pieceType(int piece) => piece & typeMask;

  static bool isSameColor(int thisPiece, int thatPiece) =>
      pieceColour(thisPiece) == pieceColour(thatPiece);

  static String getSymbol(int piece) {
    int type = pieceType(piece);
    var symbol = (() {
      switch (type) {
        case Rook:
          return 'R';
        case Knight:
          return 'N';
        case Bishop:
          return 'B';
        case Queen:
          return 'Q';
        case King:
          return 'K';
        case Pawn:
          return 'P';
        default:
          return ' ';
      }
    })();
    symbol = isWhite(piece) ? symbol : symbol.toLowerCase();
    return symbol;
  }

  static String getSymbolMoveLog(int piece) {
    int type = pieceType(piece);
    var symbol = (() {
      switch (type) {
        case Rook:
          return 'R';
        case Knight:
          return 'N';
        case Bishop:
          return 'B';
        case Queen:
          return 'Q';
        case King:
          return 'K';
        case Pawn:
          return '';
        default:
          return '';
      }
    })();
    return symbol;
  }

  int getPieceTypeFromSymbol(String symbol) {
    symbol = symbol.toUpperCase();
    switch (symbol) {
      case 'R':
        return Rook;
      case 'N':
        return Knight;
      case 'B':
        return Bishop;
      case 'Q':
        return Queen;
      case 'K':
        return King;
      case 'P':
        return Pawn;
      default:
        return None;
    }
  }

  static int getPieceFromSymbol(String symbol) {
    int pieceType = 0;
    var symbolUpCase = symbol.toUpperCase();
    switch (symbolUpCase) {
      case 'R':
        pieceType = Rook;
        break;
      case 'N':
        pieceType = Knight;
        break;
      case 'B':
        pieceType = Bishop;
        break;
      case 'Q':
        pieceType = Queen;
        break;
      case 'K':
        pieceType = King;
        break;
      case 'P':
        pieceType = Pawn;
        break;
      default:
        pieceType = None;
        break;
    }
    int piece = makePieceIB(pieceType, symbolUpCase == symbol);
    return piece;
  }

  static int pieceValue(int piece) {
    int value = 0;
    int type = pieceType(piece);

    switch (type) {
      case Rook:
        value = 500;
        break;
      case Knight:
        value = 300;
        break;
      case Bishop:
        value = 300;
        break;
      case Queen:
        value = 900;
        break;
      case King:
        value = 2000;
        break;
      case Pawn:
        value = 100;
        break;
      default:
        value = 0;
        break;
    }
    return isWhite(piece) ? value : -value;
  }
}

class ChessPiece {
  int piece;
  int pos;
  int moveCount = 0;

  ChessPiece(this.piece, this.pos);
}
