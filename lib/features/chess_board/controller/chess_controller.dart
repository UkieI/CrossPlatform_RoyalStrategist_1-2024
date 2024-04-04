// ignore_for_file: unnecessary_overrides, invalid_use_of_protected_member

import 'package:audioplayers/audioplayers.dart';

import 'package:chess_flutter_app/features/chess_board/controller/move_log_controller.dart';
import 'package:chess_flutter_app/features/chess_board/controller/timer_controller.dart';
import 'package:chess_flutter_app/features/chess_board/logic/insufficient_material.dart';
import 'package:chess_flutter_app/features/chess_board/models/bishop.dart';
import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/features/chess_board/models/king.dart';
import 'package:chess_flutter_app/features/chess_board/models/knight.dart';
import 'package:chess_flutter_app/features/chess_board/models/move.dart';
import 'package:chess_flutter_app/features/chess_board/models/pawn.dart';
import 'package:chess_flutter_app/features/chess_board/models/queen.dart';
import 'package:chess_flutter_app/features/chess_board/models/rook.dart';
import 'package:chess_flutter_app/utils/constants/image_strings.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChessBoardController extends GetxController {
  late final BuildContext _context;
  late final double time;

  // Constructor to receive the context
  ChessBoardController(this._context, this.time);
  // A 2-dimensional list representing the chess board
  // with each containing a chess piece
  late List<List<ChessPieces?>> board;

  // A list of valid moves for the currently selected piece
  // each move is represented as a list of valid moves for the current piece
  RxList<RxList<int>> validMoves = <RxList<int>>[].obs;

  // List of white pieces that have been taken by black players
  RxList<ChessPieces> whitePiecesTaken = <ChessPieces>[].obs;
  // List of black pieces that have been taken by white players
  RxList<ChessPieces> blackPiecesTaken = <ChessPieces>[].obs;
  RxMap whiteTakenMap = {}.obs;
  RxMap blackTakenMap = {}.obs;
  RxInt whiteValue = 0.obs;
  RxInt blackValue = 0.obs;

  // If no piece is selected, this is null
  ChessPieces? selectedPiece;
  ChessPieces? capturePieces;

  // The row index of the new piece
  // Defaults to value = -1 indicated no piece is currently selected;
  RxList<int> selectedPosition = [-1, -1].obs;

  // the start position that the previous selected pieces move
  List<int> previousSelected = [8, 8];
  List<int> previousMoved = [8, 8];

  // iniitial postition of king
  List<int> whiteKingPositions = [7, 4];
  List<int> blackKingPositions = [0, 4];

  // Boolean indicating whose turn now
  bool isWhiteTurn = true;
  bool isWhiteKingMove = false;
  bool isBlackKingMove = false;
  bool isCastling = false;
  bool isClock = false;
  RxBool isRotation = false.obs;
  RxBool checkStatus = false.obs;
  RxBool isPromotion = false.obs;
  RxBool isGameover = false.obs;
  RxInt viewIndex = 0.obs;

  // Timer Controller
  late TimerController timerController;
  late MoveLogController moveLogController;
  InsuffcientMaterial insuffcientMaterial = InsuffcientMaterial();

  final player = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    moveLogController = Get.put(MoveLogController());

    if (time != 0) {
      timerController = Get.put(TimerController());
      timerController.setClock(time);
      isClock = true;
    }

    _initializeBoard();
  }

  void _initializeBoard() {
    List<List<ChessPieces?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    //Pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = Pawn(isWhite: false);
      newBoard[6][i] = Pawn(isWhite: true);
    }

    // Rooks
    newBoard[0][0] = Rook(isWhite: false);
    newBoard[0][7] = Rook(isWhite: false);
    newBoard[7][0] = Rook(isWhite: true);
    newBoard[7][7] = Rook(isWhite: true);

    //knights
    newBoard[0][1] = Knight(isWhite: false);
    newBoard[0][6] = Knight(isWhite: false);
    newBoard[7][1] = Knight(isWhite: true);
    newBoard[7][6] = Knight(isWhite: true);

    //bitshops
    newBoard[0][2] = Bishop(isWhite: false);
    newBoard[0][5] = Bishop(isWhite: false);
    newBoard[7][2] = Bishop(isWhite: true);
    newBoard[7][5] = Bishop(isWhite: true);

    //queen
    newBoard[0][3] = Queen(isWhite: false);
    newBoard[7][3] = Queen(isWhite: true);

    //king
    newBoard[0][4] = King(isWhite: false);
    newBoard[7][4] = King(isWhite: true);

    board = newBoard;
  }

  void pieceSelected(int row, int col) {
    if (isGameover.value) {
      return;
    }
    if (!isInBoard(row, col)) {
      return;
    }

    // No piece selected yet, this is the first selection
    if (selectedPiece == null && board[row][col] != null) {
      if (board[row][col]!.isWhite == isWhiteTurn) {
        selectedPiece = board[row][col];
        selectedPosition.value = [row, col];
      }
    }
    // There is a piece selected, but the user can select another one of there pieces
    else if (board[row][col] != null &&
        board[row][col]!.isWhite == selectedPiece!.isWhite) {
      selectedPiece = board[row][col];
      selectedPosition.value = [row, col];
    }
    // if a piece is selected, user tap a valid move, move there
    else if (selectedPiece != null &&
        validMoves.any((element) => element[0] == row && element[1] == col)) {
      movePiece(row, col);
    }

    // if a piece is selected, calculate the valid move;
    validMoves.assignAll(calculateRealValidMove(
            selectedPosition[0], selectedPosition[1], selectedPiece, true)
        .map((innerList) => innerList.obs));
    if (selectedPiece != null) {
      bool isKingCheck = isWhiteTurn ? isWhiteKingMove : isBlackKingMove;
      if (selectedPiece! is King && !isKingCheck) {
        int rowWhitePlayerSide = isWhiteTurn ? 7 : 0;
        if (canKingCastling(true, rowWhitePlayerSide)) {
          isCastling = true;
          validMoves.add([rowWhitePlayerSide, 6].obs);
        }
        if (canKingCastling(false, rowWhitePlayerSide)) {
          isCastling = true;
          validMoves.add([rowWhitePlayerSide, 2].obs);
        }
      }
    }
    update();
  }

  void movePiece(int newRow, int newCol) {
    gameTimeManagement();
    // ìf the new spot have an enemy piece
    bool isCapture = capture(newRow, newCol);
    // select move is Pawn
    bool isEnPassant = isPawnMoveEnPassantOrPromote(newRow, newCol);

    // moving the selected piece to the selected position.
    board[newRow][newCol] = selectedPiece;
    board[selectedPosition[0]][selectedPosition[1]] = null;

    // check king ís check
    checkStatus.value = isKingInCheck(!isWhiteTurn);

    // play sound
    if (!isCapture) player.play(AssetSource(TImages.audioMove));
    if (checkStatus.value) player.play(AssetSource(TImages.audioCheck));

    // if the moveing piece is king
    bool? isKingCastle = isKingMoveCastle(newRow, newCol);

    bool isCheckmate = gamePopUp();

    if (!isPromotion.value) {
      moveLogController.setMove(
        Move(
          index: viewIndex.value,
          chessPiece: selectedPiece!,
          startRow: selectedPosition[0],
          startCol: selectedPosition[1],
          endRow: newRow,
          endCol: newCol,
          capturePiece: capturePieces,
          isKingCheck: checkStatus.value,
          isCasteKingSide: isKingCastle,
          isCheckmate: isCheckmate,
        ),
      );
      capturePieces = null;
      selectedPiece = null;
    }

    // update Status
    updateStatus(newRow, newCol);
  }

  void gameTimeManagement() {
    if (isClock) {
      if (isWhiteTurn) {
        timerController.stopWhiteTimer();
        timerController.startBlackTimer(
            timerController.timerBlackTime.value, _context, isGameover);
      } else {
        timerController.stopBlackTimer();
        timerController.startWhiteTimer(
            timerController.timerWhiteTime.value, _context, isGameover);
      }
    }
  }

  bool gamePopUp() {
    if (isAnyMoveleft(!isWhiteTurn)) {
      if (checkStatus.value) {
        popUpCheckmate();
        return true;
      } else {
        popUpDrawDiaglog('DRAW', '${!isWhiteTurn} not have any vaild move. ');
      }
    } else if (insuffcientMaterial.insufficientMaterial(board)) {
      popUpDrawDiaglog('DRAW', 'Insufficient Material');
    }
    return false;
  }

  bool? isKingMoveCastle(int newRow, int newCol) {
    if (selectedPiece! is King) {
      bool isKingCheck = isWhiteTurn ? isWhiteKingMove : isBlackKingMove;
      // store postion and checking king are move
      if (selectedPiece!.isWhite) {
        if (!isWhiteKingMove) isWhiteKingMove = true;
        whiteKingPositions = [newRow, newCol];
      } else {
        if (!isBlackKingMove) isBlackKingMove = true;
        blackKingPositions = [newRow, newCol];
      }

      // If the king castling, moving rook to right place.
      if (!isKingCheck && isCastling) {
        if (newCol == 2) {
          selectedPiece = board[newRow][0]; // ROOK
          selectedPosition.value = [newRow, 0];
          board[selectedPosition[0]][3] = selectedPiece;
          board[selectedPosition[0]][selectedPosition[1]] = null;
          return false;
        } else if (newCol == 6) {
          selectedPiece = board[newRow][7]; // ROOK
          selectedPosition.value = [newRow, 7];
          board[selectedPosition[0]][5] = selectedPiece;
          board[selectedPosition[0]][selectedPosition[1]] = null;
          return true;
        }
      }

      isCastling = false;
    }
    return null;
  }

  bool isPawnMoveEnPassantOrPromote(int newRow, int newCol) {
    // if check is a pawn getting to final row of the board
    if (selectedPiece is Pawn) {
      // the white pawn get to the black side board 0
      // the black pawn get to the white side board 7
      if (newRow == 0 || newRow == 7) {
        isPromotion.value = true;
      }

      // pawns can kill like En Passant
      if (isWhiteTurn) {
        var capturePieces = board[newRow + 1][newCol]; // Black Moved
        if (capturePieces != null &&
            capturePieces.isWhite != isWhiteTurn &&
            newRow + 1 == 3) {
          blackPiecesTaken.add(capturePieces);
          board[newRow + 1][newCol] = null;
          return true;
        }
      } else {
        var capturePieces = board[newRow - 1][newCol]; // White Moved
        if (capturePieces != null &&
            capturePieces.isWhite != isWhiteTurn &&
            newRow - 1 == 4) {
          whitePiecesTaken.add(capturePieces);
          board[newRow - 1][newCol] = null;
          return true;
        }
      }
    }
    return false;
  }

  bool canKingCastling(bool isKingSide, int rowWhitePlayerSide) {
    int colRookPosition = isKingSide ? 7 : 0;
    int colKingPosition = 4;
    if (checkStatus.value) {
      return false;
    }

    if (board[rowWhitePlayerSide][colRookPosition]! is! Rook ||
        board[rowWhitePlayerSide][colKingPosition]! is! King) {
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

  bool capture(int newRow, int newCol) {
    bool isCapture = false;
    // ìf the new spot have an enemy piece
    if (board[newRow][newCol] != null) {
      // add the captured piece to the appropriate list
      capturePieces = board[newRow][newCol];
      countMapCapture(capturePieces!);
      // countDuplicateNumbers(capturePieces, false);
      isCapture = true;
      player.play(AssetSource(TImages.audioCapture));
    }
    return isCapture;
  }

  void countMapCapture(ChessPieces capturePieces) {
    String name = capturePieces.toString();
    if (capturePieces.isWhite) {
      if (whiteTakenMap.containsKey(name)) {
        whiteTakenMap[name]++;
      } else {
        whiteTakenMap[name] = 1;
        whitePiecesTaken.add(capturePieces);
        whitePiecesTaken.sort((a, b) => a.compareTo(b));
      }
      whiteValue.value += capturePieces.value;
    } else {
      if (blackTakenMap.containsKey(name)) {
        blackTakenMap[name]++;
      } else {
        blackTakenMap[name] = 1;
        blackPiecesTaken.add(capturePieces);
        blackPiecesTaken.sort((a, b) => a.compareTo(b));
      }
      blackValue.value += capturePieces.value;
    }
  }

  bool isHasPrefix(ChessPieces pieces, int row, int col) {
    return false;
  }

  //Pop up game state
  void popUpDrawDiaglog(String title, String content) {
    showDialog(
      context: _context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        // content:
        //     !isWhiteTurn ? const Text("White Win") : const Text("Black Win"),
        actions: [
          TextButton(
              onPressed: () {
                resetGame();
                Navigator.of(context).pop();
              },
              child: const Text("Play again"))
        ],
      ),
    );
  }

  void popUpCheckmate() {
    if (isClock) {
      isWhiteTurn
          ? timerController.stopBlackTimer()
          : timerController.stopWhiteTimer();
    }
    showDialog(
      context: _context,
      builder: (context) => AlertDialog(
        title: const Text("CHECK MATE"),
        content:
            !isWhiteTurn ? const Text("White Win") : const Text("Black Win"),
        actions: [
          TextButton(
              onPressed: () {
                resetGame();
                Navigator.of(context).pop();
              },
              child: const Text("Play again"))
        ],
      ),
    );
  }

  void updateStatus(int newRow, int newCol) {
    // update Status
    previousSelected = [selectedPosition[0], selectedPosition[1]];
    previousMoved = [newRow, newCol];

    selectedPosition.value = [-1, -1];
    validMoves = <RxList<int>>[].obs;
    viewIndex.value++;
    isWhiteTurn = !isWhiteTurn;

    update();
  }

  // calculate move
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

  void pawnPromotion(ChessPieces chessPiece) {
    board[previousMoved[0]][previousMoved[1]] = chessPiece;

    isPromotion.value = false;
    checkStatus.value = isKingInCheck(isWhiteTurn);

    update();
    bool isCheckmate = false;
    if (isAnyMoveleft(isWhiteTurn)) {
      if (checkStatus.value) {
        popUpCheckmate();
        isCheckmate = true;
      } else {
        popUpDrawDiaglog('DRAW', '${!isWhiteTurn} not have any vaild move. ');
      }
    }

    moveLogController.setMove(
      Move(
        index: viewIndex.value,
        chessPiece: selectedPiece!,
        startRow: previousSelected[0],
        startCol: previousSelected[1],
        endRow: previousMoved[0],
        endCol: previousMoved[1],
        capturePiece: capturePieces,
        isKingCheck: checkStatus.value,
        promotionPiece: chessPiece,
        isCheckmate: isCheckmate,

        // isCastle: false
      ),
    );
    player.play(AssetSource(TImages.audioPromote));
    selectedPiece = null;
    capturePieces = null;
    update();
  }

  // view function
  bool isSelected(int row, int col) {
    return selectedPosition[0] == row && selectedPosition[1] == col;
  }

  bool ishlPreviousMoved(int row, int col) {
    return (previousSelected[0] == row && previousSelected[1] == col) ||
        (previousMoved[0] == row && previousMoved[1] == col);
  }

  bool isCaptured(int row, int col) {
    return board[row][col] != null &&
        board[row][col]!.isWhite !=
            board[selectedPosition[0]][selectedPosition[1]]!.isWhite;
  }

  void resetGame() {
    // Navigator.pop(_context);
    _initializeBoard();
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteTakenMap.clear();
    blackTakenMap.clear();
    whiteKingPositions = [7, 4];
    blackKingPositions = [0, 4];
    selectedPosition.value = [-1, -1];
    selectedPiece = null;
    previousSelected = [8, 8];
    previousMoved = [8, 8];
    checkStatus.value = false;
    isCastling = false;
    isWhiteTurn = true;
    isWhiteKingMove = false;
    isBlackKingMove = false;
    isGameover.value = false;
    whiteValue.value = 0;
    blackValue.value = 0;
    validMoves.value = [];
    moveLogController.moveLogs.clear();
    if (isClock) {
      timerController.setClock(time);
    }

    update();
  }
}
