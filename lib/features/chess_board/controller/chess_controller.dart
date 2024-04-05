// ignore_for_file: unnecessary_overrides, invalid_use_of_protected_member

import 'package:audioplayers/audioplayers.dart';

import 'package:chess_flutter_app/features/chess_board/controller/move_log_controller.dart';
import 'package:chess_flutter_app/features/chess_board/controller/timer_controller.dart';
import 'package:chess_flutter_app/features/chess_board/logic/game_state.dart';
import 'package:chess_flutter_app/features/chess_board/logic/insufficient_material.dart';
import 'package:chess_flutter_app/features/chess_board/logic/state_string.dart';
import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/features/chess_board/models/king.dart';
import 'package:chess_flutter_app/features/chess_board/models/move.dart';
import 'package:chess_flutter_app/features/chess_board/models/pawn.dart';
import 'package:chess_flutter_app/features/chess_board/logic/board.dart';
import 'package:chess_flutter_app/utils/constants/image_strings.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChessBoardController extends GetxController {
  late final BuildContext _context;
  late final double time;

  // Constructor to receive the context
  ChessBoardController(this._context, this.time);

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

  // Boolean indicating whose turn now
  bool isWhiteTurn = true;
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
  GameState gameState = GameState();
  Board gameBoard = Board();

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
    gameBoard.initializeBoard();
    gameState.stateString =
        StateBoardString(isWhiteTurn, gameBoard.board, null, null, 0, 0)
            .toString();
    gameState.stateHistory[gameState.stateString] = 1;
  }

  void pieceSelected(int row, int col) {
    if (isGameover.value) {
      return;
    }
    if (!isInBoard(row, col)) {
      return;
    }

    // No piece selected yet, this is the first selection
    if (selectedPiece == null && gameBoard.board[row][col] != null) {
      if (gameBoard.board[row][col]!.isWhite == isWhiteTurn) {
        selectedPiece = gameBoard.board[row][col];
        selectedPosition.value = [row, col];
      }
    }
    // There is a piece selected, but the user can select another one of there pieces
    else if (gameBoard.board[row][col] != null &&
        gameBoard.board[row][col]!.isWhite == selectedPiece!.isWhite) {
      selectedPiece = gameBoard.board[row][col];
      selectedPosition.value = [row, col];
    }
    // if a piece is selected, user tap a valid move, move there
    else if (selectedPiece != null &&
        validMoves.any((element) => element[0] == row && element[1] == col)) {
      movePiece(row, col);
    }

    // if a piece is selected, calculate the valid move;
    validMoves.assignAll(gameBoard
        .calculateRealValidMove(
            selectedPosition[0], selectedPosition[1], selectedPiece, true)
        .map((innerList) => innerList.obs));

    if (selectedPiece != null) {
      // bool isKingCheck = isWhiteTurn ? isWhiteKingMove : isBlackKingMove;
      if (selectedPiece! is King && !selectedPiece!.hasMoved) {
        int rowWhitePlayerSide = isWhiteTurn ? 7 : 0;
        if (gameBoard.canKingCastling(
            true, rowWhitePlayerSide, checkStatus.value, selectedPiece)) {
          isCastling = true;
          validMoves.add([rowWhitePlayerSide, 6].obs);
        }
        if (gameBoard.canKingCastling(
            false, rowWhitePlayerSide, checkStatus.value, selectedPiece)) {
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
    // 50 moves rule
    if (isCapture) {
      gameState.noCaptureOrPawnMoves = 0;
      gameState.stateHistory.clear();
    } else {
      gameState.noCaptureOrPawnMoves++;
    }

    // select move is Pawn
    isPawnMoveEnPassantOrPromote(newRow, newCol);

    // moving the selected piece to the selected position.
    selectedPiece!.hasMoved = true;
    gameBoard.board[newRow][newCol] = selectedPiece;
    gameBoard.board[selectedPosition[0]][selectedPosition[1]] = null;

    // check king ís check
    checkStatus.value = gameBoard.isKingInCheck(!isWhiteTurn);

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

    String? enPassant = gameBoard.getPawnSkipPositions();
    List<bool> castleRight = [
      gameBoard.castleRightKingSide(true),
      gameBoard.castleRightQueenSide(true),
      gameBoard.castleRightKingSide(false),
      gameBoard.castleRightQueenSide(false)
    ];
    gameState.updateStateString(
      isWhiteTurn,
      gameBoard.board,
      castleRight,
      enPassant,
      gameState.noCaptureOrPawnMoves,
      moveLogController.moveLogs.length ~/ 2,
    );
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

  bool? isKingMoveCastle(int newRow, int newCol) {
    if (selectedPiece! is King) {
      // store postion and checking king are move
      if (selectedPiece!.isWhite) {
        // if (!isWhiteKingMove) isWhiteKingMove = true;
        gameBoard.whiteKingPositions = [newRow, newCol];
      } else {
        // if (!isBlackKingMove) isBlackKingMove = true;
        gameBoard.blackKingPositions = [newRow, newCol];
      }
      // If the king castling, moving rook to right place.
      if (selectedPiece!.hasMoved && isCastling) {
        if (newCol == 2) {
          selectedPiece = gameBoard.board[newRow][0]; // ROOK
          selectedPosition.value = [newRow, 0];
          gameBoard.board[selectedPosition[0]][3] = selectedPiece;
          gameBoard.board[selectedPosition[0]][selectedPosition[1]] = null;
          return false;
        } else if (newCol == 6) {
          selectedPiece = gameBoard.board[newRow][7]; // ROOK
          selectedPosition.value = [newRow, 7];
          gameBoard.board[selectedPosition[0]][5] = selectedPiece;
          gameBoard.board[selectedPosition[0]][selectedPosition[1]] = null;
          return true;
        }
      }

      isCastling = false;
    }
    return null;
  }

  String? isPawnMoveEnPassantOrPromote(int newRow, int newCol) {
    // if check is a pawn getting to final row of the board
    if (selectedPiece is Pawn) {
      // the white pawn get to the black side board 0
      // the black pawn get to the white side board 7
      if (newRow == 0 || newRow == 7) {
        isPromotion.value = true;
      }

      // pawns can kill like En Passant
      if (isWhiteTurn) {
        capturePieces = gameBoard.board[newRow + 1][newCol]; // Black Moved
        if (capturePieces != null &&
            capturePieces!.isWhite != isWhiteTurn &&
            newRow + 1 == 3) {
          countMapCapture(capturePieces!);
          gameBoard.board[newRow + 1][newCol] = null;
          return "${convertRow(newRow + 1)}${convertCol(newCol)}";
        }
      } else {
        // capturePieces = gameBoard.board[newRow - 1][newCol]; // White Moved
        if (capturePieces != null &&
            capturePieces!.isWhite != isWhiteTurn &&
            newRow - 1 == 4) {
          countMapCapture(capturePieces!);
          gameBoard.board[newRow - 1][newCol] = null;
          return "${convertRow(newRow - 1)}${convertCol(newCol)}";
        }
      }
      gameState.noCaptureOrPawnMoves = 0;
      gameState.stateHistory.clear();
    }
    return "";
  }

  bool capture(int newRow, int newCol) {
    bool isCapture = false;
    // ìf the new spot have an enemy piece
    if (gameBoard.board[newRow][newCol] != null) {
      // add the captured piece to the appropriate list
      capturePieces = gameBoard.board[newRow][newCol];
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
  bool gamePopUp() {
    if (gameBoard.isAnyMoveleft(!isWhiteTurn)) {
      if (checkStatus.value) {
        popUpDrawDiaglog('Checkmate',
            '${isWhiteTurn ? "White player" : "Black player"} win. ');

        return true;
      } else {
        popUpDrawDiaglog('DRAW',
            '${isWhiteTurn ? "White player " : "Black player "} not have any vaild move. ');
      }
    } else if (insuffcientMaterial.insufficientMaterial(gameBoard.board)) {
      popUpDrawDiaglog('DRAW', 'Insufficient Material');
    } else if (gameState.fiftyMoveRule()) {
      popUpDrawDiaglog('DRAW', '50 move rule');
    } else if (gameState.threeFoldRepetion()) {
      popUpDrawDiaglog('DRAW', '3 Three fold repetition');
    }
    return false;
  }

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

  // calculate move

  void pawnPromotion(ChessPieces chessPiece) {
    gameBoard.board[gameBoard.previousMoved[0]][gameBoard.previousMoved[1]] =
        chessPiece;

    isPromotion.value = false;
    checkStatus.value = gameBoard.isKingInCheck(isWhiteTurn);

    update();
    bool isCheckmate = false;
    if (gameBoard.isAnyMoveleft(isWhiteTurn)) {
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
        startRow: gameBoard.previousSelected[0],
        startCol: gameBoard.previousSelected[1],
        endRow: gameBoard.previousMoved[0],
        endCol: gameBoard.previousMoved[1],
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
    return (gameBoard.previousSelected[0] == row &&
            gameBoard.previousSelected[1] == col) ||
        (gameBoard.previousMoved[0] == row &&
            gameBoard.previousMoved[1] == col);
  }

  bool isCaptured(int row, int col) {
    return gameBoard.board[row][col] != null &&
        gameBoard.board[row][col]!.isWhite !=
            gameBoard.board[selectedPosition[0]][selectedPosition[1]]!.isWhite;
  }

  void updateStatus(int newRow, int newCol) {
    // update Status
    gameBoard.previousSelected = [selectedPosition[0], selectedPosition[1]];
    gameBoard.previousMoved = [newRow, newCol];

    selectedPosition.value = [-1, -1];
    validMoves = <RxList<int>>[].obs;
    viewIndex.value++;
    isWhiteTurn = !isWhiteTurn;

    update();
  }

  void resetGame() {
    // Navigator.pop(_context);
    gameBoard.whiteKingPositions = [7, 4];
    gameBoard.blackKingPositions = [0, 4];

    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteTakenMap.clear();
    blackTakenMap.clear();
    selectedPosition.value = [-1, -1];
    selectedPiece = null;
    capturePieces = null;
    gameBoard.previousSelected = [8, 8];
    gameBoard.previousMoved = [8, 8];
    checkStatus.value = false;
    isCastling = false;
    isWhiteTurn = true;
    isGameover.value = false;
    whiteValue.value = 0;
    blackValue.value = 0;
    validMoves.value = [];

    gameState.noCaptureOrPawnMoves = 0;
    gameState.stateHistory = {};
    gameState.stateString = "";

    moveLogController.moveLogs.clear();
    if (isClock) {
      timerController.setClock(time);
    }
    gameBoard.initializeBoard();
    update();
  }
}
