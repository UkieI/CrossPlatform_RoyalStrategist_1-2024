import 'package:chess_flutter_app/controller/timer_controller.dart';
import 'package:chess_flutter_app/logic/board/board.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move.dart';

import 'package:chess_flutter_app/logic/move_generation/move_generation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: constant_identifier_names
const TIMER_ACCURACY_MS = 100;

class ChessBoardController extends GetxController {
  late final BuildContext _context;
  late final double _time;
  // Constructor to receive the context
  ChessBoardController(this._context, this._time);

  // Timer Controller
  late TimerController timerController;

  Board board = Board();

  bool isWhiteTurn = true;
  bool isGameOver = false;
  bool isHasTimer = false;

  int selectedPieces = 0;
  int selectedPos = -1;

  List<int> validMoves = [];

  RxMap whitePiecesTaken = {}.obs;
  RxMap blackPiecesTaken = {}.obs;

  RxBool promotion = false.obs;
  RxBool isInCheck = false.obs;

  Move? previousMove;

  // Setting timer

  @override
  void onInit() {
    super.onInit();
    board.initBoard();
    if (_time != 0) {
      timerController = Get.put(TimerController());
      timerController.setClock(_time);
      isHasTimer = true;
    }
  }

  void onPieceSelected(int indexSquare) {
    if (!BoardHelper.isInBoard(indexSquare)) {
      return;
    }

    // No piece selected yet, this is the first selection
    if (selectedPieces == Piece.None &&
        board.square[indexSquare] != Piece.None) {
      if (Piece.isWhite(board.square[indexSquare]) == isWhiteTurn) {
        selectedPieces = board.square[indexSquare];
        selectedPos = indexSquare;
      }
    }
    // There is a piece selected, but the user can select another one of there pieces
    else if (board.square[indexSquare] != Piece.None &&
        Piece.isWhite(board.square[indexSquare]) ==
            Piece.isWhite(selectedPieces)) {
      selectedPieces = board.square[indexSquare];
      selectedPos = indexSquare;
    }
    // if a piece is selected, user tap a valid move, move there
    else if (selectedPieces != Piece.None &&
        validMoves.any((element) => element == indexSquare)) {
      // move the piece
      movePiece(indexSquare);
    }
    // if a piece is selected, calculate the valid move;
    validMoves.assignAll(getMovePiece(selectedPieces, selectedPos, board));
    update();
  }

  void movePiece(int indexSquare) {
    gameTimerManagement();
    if (validMoves.contains(indexSquare)) {
      if (isPromotion(board.square[selectedPos], indexSquare)) {
        promotion.value = true;
        push(board, Move(selectedPos, indexSquare), isPlayerMoved: true);
        updateBoard(selectedPos, indexSquare);
      } else {
        var ms =
            push(board, Move(selectedPos, indexSquare), isPlayerMoved: true);
        updateBoard(selectedPos, indexSquare);
        isInCheck.value = ms.isInCheck;
        gamePopUp();
      }

      board.redoStack.clear();
    }
  }

  void gameTimerManagement() {
    if (isHasTimer) {
      if (isWhiteTurn) {
        timerController.stopWhiteTimer();
        timerController.startBlackTimer(
            timerController.timerBlackTime.value, _context, isGameOver);
      } else {
        timerController.stopBlackTimer();
        timerController.startWhiteTimer(
            timerController.timerWhiteTime.value, _context, isGameOver);
      }
    }
  }

  void undoMove() {
    if (board.movedStack.isNotEmpty) {
      var msRedo = pop(board);
      board.redoStack.add(msRedo);
      var msLast = board.movedStack.last;
      isInCheck.value = msLast.isInCheck;

      updateBoard(msRedo.move.start, msRedo.move.end);
    }
  }

  void redoMove() {
    if (board.redoStack.isNotEmpty) {
      var ms = board.redoStack.removeLast();
      pushMS(board, ms);
      isInCheck.value = ms.isInCheck;
      updateBoard(ms.move.start, ms.move.end);
    }
  }

  void moveCompletion() {
    //
  }

  //Pop up game state
  bool gamePopUp() {
    if (isAnyMoveleft(board, isWhiteTurn)) {
      if (isInCheck.value) {
        isGameOver = true;
        popUpCheckmate();
        return true;
      } else {
        isGameOver = true;
        popUpDrawDiaglog('DRAW',
            '${isWhiteTurn ? "White player " : "Black player "} not have any vaild move. ');
        return true;
      }
    } else if (insufficientMaterial(board)) {
      isGameOver = true;
      popUpDrawDiaglog('DRAW', 'Insufficient Material');
      return true;
    } else if (fiftyMoveRule(board)) {
      isGameOver = true;
      popUpDrawDiaglog('DRAW', '50 move rule');
      return true;
    } else if (threeFoldRepetion()) {
      isGameOver = true;
      popUpDrawDiaglog('DRAW', '3 Three fold repetition');
      return true;
    }
    return false;
  }

  void popUpCheckmate() {
    if (isHasTimer) {
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

  void popUpDrawDiaglog(String title, String content) {
    showDialog(
      context: _context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
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

  void updateBoard(int sPos, int ePos) {
    validMoves = [];
    previousMove = Move(sPos, ePos);
    selectedPieces = Piece.None;
    selectedPos = -1;
    isWhiteTurn = !isWhiteTurn;
    update();
  }

  void resetGame() {
    validMoves = [];
    previousMove = Move(-1, -1);
    selectedPieces = Piece.None;
    selectedPos = -1;
    isWhiteTurn = true;
    board.whitePieces.clear();
    board.blackPieces.clear();

    board.initBoard();

    if (isHasTimer) {
      timerController.setClock(_time);
    }
    update();
  }

  bool isSelected(int indexSquare) {
    return selectedPos == indexSquare;
  }

  void pawnPromotion(int piece) {
    if (promotion.value) {
      promotion.value = false;
      pop(board);
      var ms = push(board, Move(previousMove!.start, previousMove!.end),
          promotionType: piece, isPlayerMoved: true);
      // board.square[previousMove!.end] = piece;
      isInCheck.value = ms.isInCheck;
      gamePopUp();
      update();
    }
  }

  bool isPreviousMoved(int squareIndex) {
    if (previousMove == null) {
      return false;
    }
    return previousMove!.start == squareIndex ||
        previousMove!.end == squareIndex;
  }

  bool isCaptured(int indexSquare) {
    return board.square[indexSquare] != Piece.None &&
        !Piece.isSameColor(
            board.square[indexSquare], board.square[selectedPos]);
  }
}
