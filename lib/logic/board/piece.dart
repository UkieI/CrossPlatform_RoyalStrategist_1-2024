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
  static const typeMask = 0x07;
  static const colourMask = 0x08;

  static bool isColour(int piece, int colour) =>
      (piece & colourMask) == colour && piece != 0;

  static bool isWhite(int piece) => isColour(piece, White);

  static int pieceColour(int piece) => piece & colourMask;

  static int pieceType(int piece) => piece & typeMask;
}
