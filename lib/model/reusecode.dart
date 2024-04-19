  // MoveStack makeMove(Move move, {int promotionType = Piece.None, bool isInSearch = false}) {
  //   var ms = MoveStack(move, square[move.start], square[move.end], enPassantPos);

  //   // Get all information
  //   int startSquare = move.start;
  //   int targetSquare = move.end;
  //   // isEnPassant bool

  //   int movedPiece = square[startSquare];
  //   int movedPieceType = Piece.pieceType(movedPiece);

  //   bool isEnPassant = (enPassantPos == targetSquare && movedPiece == Piece.Pawn);
  //   int capturedPiece = isEnPassant ? Piece.makePieceII(Piece.Pawn, opponentColour()) : square[targetSquare];
  //   int capturedPieceType = Piece.pieceType(capturedPiece);

  //   int prevCastleState = currentGameState.castlingRights;
  //   int prevEnPassant;
  //   int newCastlingRights = currentGameState.castlingRights;
  //   int newEnPassantCol = 0;

  //   // Update bitboard of moved piece (pawn promotion is a special case and is corrected later)
  //   movePiece(movedPiece, startSquare, targetSquare);

  //   // Get move flags
  //   // Is this move are promoted
  //   // Handle captured
  //   if (capturedPieceType != Piece.None || isEnPassant) {
  //     int captureSquare = targetSquare;
  //     if (isEnPassant) {
  //       captureSquare = targetSquare + (isWhiteToMove ? -8 : 8);
  //       square[captureSquare] = Piece.None;
  //     }
  //   }

  //   // Handle king
  //   if (movedPieceType == Piece.King) {
  //     kingSquare[moveColourIndex()] = targetSquare;
  //     newCastlingRights &= isWhiteToMove ? 12 : 3; // 1100 & 0011
  //     // Handle castling
  //     if (isKingCastle(startSquare, targetSquare)) {
  //       bool kingside = targetSquare == BoardHelper.g1 || targetSquare == BoardHelper.g8;
  //       int castlingRookFromIndex = (kingside) ? targetSquare + 1 : targetSquare - 2;
  //       int castlingRookToIndex = (kingside) ? targetSquare - 1 : targetSquare + 1;

  //       square[castlingRookFromIndex] = Piece.None;
  //       square[castlingRookToIndex] = Piece.Rook | moveColour();
  //       ms.isCasted = true;
  //     }
  //   }
  //   // Handle promotion
  //   if (isPromotion(movedPiece, startSquare, targetSquare)) {
  //     ms.promotionType = promotionType;
  //     move.promotionType = promotionType;
  //     int promotionPiece = Piece.makePieceII(promotionType, moveColour());
  //     square[targetSquare] = promotionPiece;
  //     ms.isPromotion = true;
  //   }

  //   // Pawn has moved two forwards, mark file with en-passant flag
  //   if (isPawnMovedTwoSquare(movedPiece, startSquare, targetSquare)) {
  //     enPassantPos = (move.end + move.start) ~/ 2;
  //     print(enPassantPos);
  //   }

  //   // Update castling rights
  //   if (prevCastleState != 0) {
  //     // Any piece moving to/from rook square removes castling right for that side
  //     if (targetSquare == BoardHelper.h1 || startSquare == BoardHelper.h1) {
  //       newCastlingRights &= GameState.clearBlackKingsideMask;
  //     } else if (targetSquare == BoardHelper.a1 || startSquare == BoardHelper.a1) {
  //       newCastlingRights &= GameState.clearWhiteQueensideMask;
  //     }
  //     if (targetSquare == BoardHelper.h8 || startSquare == BoardHelper.h8) {
  //       newCastlingRights &= GameState.clearBlackKingsideMask;
  //     } else if (targetSquare == BoardHelper.a8 || startSquare == BoardHelper.a8) {
  //       newCastlingRights &= GameState.clearBlackQueensideMask;
  //     }
  //   }

  //   // Change side to move
  //   isWhiteToMove = !isWhiteToMove;
  //   int newFiftyMoveCounter = currentGameState.fiftyMoveCounter + 1;

  //   // Pawn moves and captures reset the fifty move counter and clear 3-fold repetition history
  //   if (movedPieceType == Piece.Pawn || capturedPieceType != Piece.None) {
  //     if (!isInSearch) {}
  //     // newFiftyMoveCounter = 0;
  //   }

  //   GameState newState = GameState(capturedPieceType: capturedPieceType, enPassantPosition: enPassantPos, castlingRights: newCastlingRights, fiftyMoveCounter: newFiftyMoveCounter);
  //   gameStateHistory.add(newState);
  //   currentGameState = newState;
  //   return ms;
  // }

  // // Undo a move previously made on the board
  // void unmakeMove(MoveStack ms, {bool inSearch = false}) {
  //   // Swap colour to move
  //   isWhiteToMove = !isWhiteToMove;
  //   bool undoingWhiteMove = isWhiteToMove;

  //   int movedFrom = ms.move.start;
  //   int movedTo = ms.move.end;

  //   int movedPiece = ms.isPromotion ? Piece.makePieceII(Piece.Pawn, moveColour()) : square[movedTo];
  //   int movedPieceType = Piece.pieceType(movedPiece);

  //   // If undoing promotion, then remove piece from promotion square and replace with pawn
  //   if (ms.isPromotion) {
  //     int promotedPiece = square[movedTo];
  //     int pawnPiece = Piece.makePieceII(Piece.Pawn, moveColour());
  //     // TotalPieceCountWithoutPawnsAndKings--;
  //   }
  //   movePiece(movedPiece, movedTo, movedFrom);
  //   // Undo capture
  //   if (ms.takenPiece != Piece.None) {
  //     int captureSquare = movedTo;
  //     int capturedPiece = ms.takenPiece;

  //     if (ms.isEnPassant) {
  //       captureSquare = movedTo + ((undoingWhiteMove) ? -8 : 8);
  //     }

  //     // Add back captured piece
  //     square[captureSquare] = capturedPiece;
  //   }
  //   if (movedPieceType == Piece.King) {
  //     kingSquare[moveColourIndex()] = movedFrom;
  //     // Undo castling
  //     if (ms.isCasted) {
  //       int rookPiece = Piece.makePieceII(Piece.Rook, moveColour());
  //       bool kingside = movedTo == BoardHelper.g1 || movedTo == BoardHelper.g8;
  //       int rookSquareBeforeCastling = kingside ? movedTo + 1 : movedTo - 2;
  //       int rookSquareAfterCastling = kingside ? movedTo - 1 : movedTo + 1;

  //       // Undo castling by returning rook to original square

  //       square[rookSquareAfterCastling] = Piece.None;
  //       square[rookSquareBeforeCastling] = rookPiece;
  //     }
  //   }
  //   gameStateHistory.removeLast();
  //   currentGameState = gameStateHistory.last;
  // }

  // movePiece(int piece, int start, int end) {
  //   square[start] = Piece.None;
  //   square[end] = piece;
  // }

  // bool isKingCastle(int start, int end) {
  //   return (start - end).abs() == 2;
  // }

  // bool isPromotion(int piece, int start, int end) {
  //   var row = BoardHelper.rowIndex(end);
  //   return Piece.pieceType(piece) == Piece.Pawn && (row == 7 || row == 0);
  // }

  // bool isPawnMovedTwoSquare(int piece, int start, int end) {
  //   return (start - end).abs() == 16 && Piece.pieceType(piece) == Piece.Pawn;
  // }

  // void initialize() {
  //   kingSquare = [];
  // }