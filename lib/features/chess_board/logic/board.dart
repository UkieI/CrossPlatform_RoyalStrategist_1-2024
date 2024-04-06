import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/features/chess_board/models/king.dart';
import 'package:chess_flutter_app/features/chess_board/models/pawn.dart';
import 'package:chess_flutter_app/features/chess_board/models/rook.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';

class Board {
  // A 2-dimensional list representing the chess board
  // with each containing a chess piece
  late List<List<ChessPieces?>> board;

  // iniitial postition of king
  List<int> whiteKingPositions = [7, 4];
  List<int> blackKingPositions = [0, 4];

  // the start position that the previous selected pieces move
  List<int> previousSelected = [8, 8];
  List<int> previousMoved = [8, 8];

  void initializeBoard() {
    List<List<ChessPieces?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    // // //Pawns
    // for (int i = 0; i < 8; i++) {
    //   newBoard[1][i] = Pawn(isWhite: false);
    //   newBoard[6][i] = Pawn(isWhite: true);
    // }

    // // Rooks
    // newBoard[0][0] = Rook(isWhite: false);
    // newBoard[0][7] = Rook(isWhite: false);
    // newBoard[7][0] = Rook(isWhite: true);
    // newBoard[7][7] = Rook(isWhite: true);

    // //knights
    // newBoard[0][1] = Knight(isWhite: false);
    // newBoard[0][6] = Knight(isWhite: false);
    // newBoard[7][1] = Knight(isWhite: true);
    // newBoard[7][6] = Knight(isWhite: true);

    // //bitshops
    // newBoard[0][2] = Bishop(isWhite: false);
    // newBoard[0][5] = Bishop(isWhite: false);
    // newBoard[7][2] = Bishop(isWhite: true);
    // newBoard[7][5] = Bishop(isWhite: true);

    // //queen
    // newBoard[0][3] = Queen(isWhite: false);
    // newBoard[7][3] = Queen(isWhite: true);

    // //king
    // newBoard[0][4] = King(isWhite: false);
    // newBoard[7][4] = King(isWhite: true);

    board = newBoard;
    String fen =
        "r1b1k1nr/ppp1qpp1/2np3p/2bQP3/2B5/2N2N2/P4PPP/R1B2RK1 w kq - 0 11";
    loadPositionFormfen(fen);
    // return newBoard;
  }

  bool isKingInCheck(bool isWhiteKing) {
    List<int> kingPositons =
        isWhiteKing ? whiteKingPositions : blackKingPositions;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }
        List<List<int>> piecesValidMoves =
            calculateRealValidMove(i, j, board[i][j], false);

        if (piecesValidMoves.any((move) =>
            move[0] == kingPositons[0] && move[1] == kingPositons[1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool isAnyMoveleft(bool isWhiteKing) {
    // the there is at least one legal move for any player's piece, not checkmate
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateRealValidMove(i, j, board[i][j], true);

        // if this piece is has any moves, that means not checkmate
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  List<List<int>> calculateRawValidMove(int row, int col, ChessPieces? piece) {
    List<List<int>> candidateMoves = [];
    if (piece == null) {
      return [];
    }
    candidateMoves =
        piece.move(row, col, board, previousMoved, previousSelected);
    return candidateMoves;
  }

  List<List<int>> calculateRealValidMove(
      int row, int col, ChessPieces? piece, bool checkSimulation) {
    List<List<int>> realValidMove = [];
    List<List<int>> candidateMoves = calculateRawValidMove(row, col, piece);
    // after generating all candidate moves, filter out any moves that would result in check
    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];

        // simulate future to check if safe
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMove.add(move);
        }
      }
    } else {
      realValidMove = candidateMoves;
    }
    return realValidMove;
  }

  bool simulatedMoveIsSafe(
      ChessPieces piece, int startRow, int startCol, int endRow, int endCol) {
    // save the current board state
    ChessPieces? orignalDestinationPiece = board[endRow][endCol];
    // if the piece is the king, save its current position and update to the new one
    List<int>? orignalKingPosition;
    if (piece is King) {
      orignalKingPosition =
          piece.isWhite ? whiteKingPositions : blackKingPositions;

      // update the king position
      if (piece.isWhite) {
        whiteKingPositions = [endRow, endCol];
      } else {
        blackKingPositions = [endRow, endCol];
      }
    }

    // simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // check if our king in underatack
    bool kingInCheck = isKingInCheck(piece.isWhite);

    // restore board to original state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = orignalDestinationPiece;

    // if the piece is the king, restore it original position
    if (piece is King) {
      if (piece.isWhite) {
        whiteKingPositions = orignalKingPosition!;
      } else {
        blackKingPositions = orignalKingPosition!;
      }
    }

    // if king is in check = true, means its not a safe move, safe move = false
    return !kingInCheck;
  }

  void loadPositionFormfen(String fen) {
    List<List<ChessPieces?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));
    List<String> listFenBoard = fen.split(' ');
    String fenBoard = listFenBoard[0];
    int row = 0, col = 0;

    for (var rune in fenBoard.runes) {
      String char = String.fromCharCode(rune);
      if (char == '/') {
        row++;
        col = 0;
      } else {
        if (isDigit(char)) {
          col += int.parse(char);
        } else {
          // bool isWhite = (char.toUpperCase() == char);
          ChessPieces pieces = recharPiecePEN(char)!;
          if (pieces is King) {
            pieces.isWhite
                ? whiteKingPositions = [row, col]
                : blackKingPositions = [row, col];
          }
          newBoard[row][col] = pieces;
          col++;
        }
      }
    }

    if (!(listFenBoard[1].contains("K") || listFenBoard[1].contains("Q"))) {
      newBoard[whiteKingPositions[0]][whiteKingPositions[1]]!.hasMoved = true;
    }
    if (!(listFenBoard[1].contains("K") || listFenBoard[1].contains("q"))) {
      newBoard[whiteKingPositions[0]][whiteKingPositions[1]]!.hasMoved = true;
    }
    board = newBoard;
  }

  bool canKingCastling(bool isKingSide, int rowWhitePlayerSide, bool isCheck,
      ChessPieces? pieces) {
    int colKingPosition = 4;
    if (isCheck) {
      return false;
    }

    if (pieces!.hasMoved) {
      return false;
    }
    if (board[rowWhitePlayerSide][7] is! Rook ||
        board[rowWhitePlayerSide][0] is! Rook) {
      return false;
    }

    if (isKingSide) {
      for (int i = 5; i < 7; i++) {
        if (board[rowWhitePlayerSide][i] != null ||
            !simulatedMoveIsSafe(board[rowWhitePlayerSide][colKingPosition]!,
                rowWhitePlayerSide, colKingPosition, rowWhitePlayerSide, i)) {
          return false;
        }
      }
    } else {
      for (int i = 1; i < 4; i++) {
        if (board[rowWhitePlayerSide][i] != null ||
            !simulatedMoveIsSafe(board[rowWhitePlayerSide][colKingPosition]!,
                rowWhitePlayerSide, colKingPosition, rowWhitePlayerSide, i)) {
          return false;
        }
      }
    }
    return true;
  }

  bool isUnmovedKingAndRook(List<int> kingPosition, List<int> rookPosition) {
    if (board[kingPosition[0]][kingPosition[1]] == null ||
        board[rookPosition[0]][rookPosition[1]] == null) {
      return false;
    }
    ChessPieces king = board[kingPosition[0]][kingPosition[1]]!;
    ChessPieces rook = board[rookPosition[0]][rookPosition[1]]!;
    return king is King && rook is Rook && !king.hasMoved && !rook.hasMoved;
  }

  bool castleRightKingSide(bool isWhiteTurn) {
    return (isWhiteTurn)
        ? isUnmovedKingAndRook([7, 4], [7, 7])
        : isUnmovedKingAndRook([0, 4], [0, 7]);
  }

  bool castleRightQueenSide(bool isWhiteTurn) {
    return (isWhiteTurn)
        ? isUnmovedKingAndRook([7, 4], [7, 0])
        : isUnmovedKingAndRook([0, 4], [0, 0]);
  }

  String? getPawnSkipPositions() {
    var rowEnd = previousMoved[0];
    var colEnd = previousMoved[1];
    if (rowEnd == 8 && colEnd == 8) {
      return null;
    }
    if (board[rowEnd][colEnd] is Pawn &&
        (rowEnd - previousSelected[0]).abs() == 2) {
      bool isWhite = board[rowEnd][colEnd]!.isWhite;
      if (board[rowEnd][colEnd + 1] is Pawn &&
          board[rowEnd][colEnd + 1]!.isWhite != isWhite) {
        return "${convertRow(rowEnd)}${convertCol(colEnd + 1)}";
      }
      if (board[rowEnd][colEnd - 1] is Pawn &&
          board[rowEnd][colEnd - 1]!.isWhite != isWhite) {
        return "${convertRow(rowEnd)}${convertCol(colEnd - 1)}";
      }
    }
    return null;
  }
}
