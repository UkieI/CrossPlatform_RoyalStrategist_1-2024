class GameState {
  final int capturedPieceType;
  final int enPassantPosition;
  final int castlingRights;
  final int fiftyMoveCounter;

  static const int clearWhiteKingsideMask = 14; // Decimal equivalent of 0b1110
  static const int clearWhiteQueensideMask = 13; // Decimal equivalent of 0b1101
  static const int clearBlackKingsideMask = 11; // Decimal equivalent of 0b1011
  static const int clearBlackQueensideMask = 7; // Decimal equivalent of 0b0111

  GameState({
    required this.capturedPieceType,
    required this.enPassantPosition,
    required this.castlingRights,
    required this.fiftyMoveCounter,
  }); // Decimal equivalent of 0b0111

  bool hasKingsideCastleRight(bool white) {
    int mask = white ? 1 : 4;
    return (castlingRights & mask) != 0;
  }

  bool hasQueensideCastleRight(bool white) {
    int mask = white ? 2 : 8;
    return (castlingRights & mask) != 0;
  }
}
