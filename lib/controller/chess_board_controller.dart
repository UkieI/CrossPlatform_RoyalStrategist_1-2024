import 'package:chess_flutter_app/controller/timer_controller.dart';
import 'package:chess_flutter_app/logic/board/board.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/board/state_board_string.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move_stack.dart';

import 'package:chess_flutter_app/logic/move_generation/move_generation.dart';
import 'package:chess_flutter_app/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';

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

  // Rule to write the move for long-term storing
  // 1. The piece moving (1 letter : P , R , N , B , Q , K )
  // 2. Start positon (2 num: 0 1 2 3 4 5 6 7) like 00 is a1
  // 3. End positon (2 num: 0 1 2 3 4 5 6 7)  like 00 is a1
  // 4. Piece being captured (1 letter : _ , P , R , N , B , Q , K )
  // 5. Piece promotion (1 letter : _ , P , R , N , B , Q , K )
  // 6. Is in check (1 num: t : 1 , f  : 0)
  // 7. Game set (1 letter: 1 - 0 : 1 , 1/2 - 1/2 : 1 )
  RxList<String> moveLogs = <String>[].obs;

  bool isWhiteTurn = true;
  bool isGameOver = false;
  bool isHasTimer = false;

  int selectedPieces = Piece.None;
  int selectedPos = -1;

  List<int> validMoves = [];

  RxMap whitePiecesTaken = {}.obs;
  RxMap blackPiecesTaken = {}.obs;

  RxBool promotion = false.obs;
  RxBool isInCheck = false.obs;
  RxBool isEnableRedo = false.obs;
  RxBool isEnableUndo = false.obs;

  Move? previousMove;

  // State board variables
  Map<String, int> stateHistory = {};
  int noCaptureOrPawnMoves = 0;
  String stateString = "";

  final sound = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    isWhiteTurn = board.initBoard();
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
    } else if (selectedPos == indexSquare) {
      selectedPieces = Piece.None;
      selectedPos = -1;
      return;
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
        isEnableRedo.value = false;
        isEnableUndo.value = false;
        updateBoard(selectedPos, indexSquare);
      } else {
        var ms =
            push(board, Move(selectedPos, indexSquare), isPlayerMoved: true);
        updateBoard(selectedPos, indexSquare);
        isInCheck.value = isKingInCheck(board, isWhiteTurn);
        var isAnyMoveLeft = isAnyMoveleft(board, !isWhiteTurn);
        gamePopUp(isAnyMoveLeft);
        moveLogs.add(moveLogString(ms, isAnyMoveLeft, isInCheck.value));
        updateStateString(board, !isWhiteTurn, ms);
        ms.takenPiece != Piece.None ||
                Piece.pieceType(ms.movedPiece) == Piece.Pawn
            ? noCaptureOrPawnMoves = 0
            : noCaptureOrPawnMoves++;

        playSound(ms);
      }
      isEnableUndo.value = true;

      board.redoStack.clear();
    }
  }

  void playSound(MoveStack ms) {
    if (isInCheck.value) {
      sound.play(AssetSource(TImages.audioCheck));
    } else if (ms.takenPiece != Piece.None) {
      sound.play(AssetSource(TImages.audioCapture));
    } else {
      sound.play(AssetSource(TImages.audioMove));
    }
  }

  void gameTimerManagement() {
    if (isHasTimer) {
      if (isWhiteTurn) {
        timerController.stopWhiteTimer();
        timerController.startBlackTimer(_context, isGameOver);
      } else {
        timerController.stopBlackTimer();
        timerController.startWhiteTimer(_context, isGameOver);
      }
    }
  }

  void undoMove() {
    if (board.movedStack.isNotEmpty) {
      gameTimerManagement();
      var msRedo = pop(board);
      board.redoStack.add(msRedo);
      moveLogs.removeLast();
      updateBoard(msRedo.move.start, msRedo.move.end);
      updateStateString(board, isWhiteTurn, msRedo,
          isUpdateStateHistory: false);
      playSound(msRedo);
      if (board.movedStack.isEmpty) {
        isEnableUndo.value = false;
        isInCheck.value = false;
        previousMove = null;
      } else {
        isInCheck.value = board.movedStack.last.isInCheck;
        isEnableRedo.value = true;
      }
    }
  }

  void redoMove() {
    if (board.redoStack.isNotEmpty) {
      gameTimerManagement();
      var ms = board.redoStack.removeLast();
      pushMS(board, ms);
      var isKingCheck = isKingInCheck(board, !isWhiteTurn);
      moveLogs.add(moveLogString(
        ms,
        isAnyMoveleft(board, !isWhiteTurn),
        isKingCheck,
      ));
      isInCheck.value = isKingCheck;
      updateBoard(ms.move.start, ms.move.end);
      updateStateString(board, !isWhiteTurn, ms);
      playSound(ms);
      if (board.redoStack.isEmpty) {
        isEnableRedo.value = false;
      } else {
        isEnableUndo.value = true;
      }
    }
  }

  //Pop up game state
  bool gamePopUp(bool isAnyMoveLeft) {
    if (isAnyMoveLeft) {
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
    } else if (fiftyMoveRule()) {
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
    isInCheck.value = false;
    board.movedStack.clear();
    board.redoStack.clear();
    board.whitePieces.clear();
    board.blackPieces.clear();
    // board.isRookHasMoved = List.filled(4, 0);
    // board.isKingHasMoved = List.filled(2, 0);
    board.enPassantPos = -1;
    board.initBoard();
    moveLogs.clear();

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
      isInCheck.value = isKingInCheck(board, isWhiteTurn);
      var isAnyMoveLeft = isAnyMoveleft(board, !isWhiteTurn);
      moveLogs.add(moveLogString(ms, isAnyMoveLeft, isInCheck.value));
      gamePopUp(isAnyMoveLeft);
      isEnableRedo.value = true;
      isEnableUndo.value = true;
      updateStateString(board, !isWhiteTurn, ms);
      sound.play(AssetSource(TImages.audioPromote));
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

  bool isKingCheck(int indexSquare) {
    return isInCheck.value
        ? indexSquare ==
            getKingChessPiece(isWhiteTurn ? Piece.White : Piece.Black, board)
                .pos
        : false;
  }

  bool fiftyMoveRule() {
    int fullMoves = 2;
    return fullMoves == 50;
  }

  bool threeFoldRepetion() {
    return stateHistory[stateString] == 3;
  }

  void updateStateString(Board board, bool isWhiteTurn, MoveStack ms,
      {isUpdateStateHistory = true}) {
    int enPassantPos = isPawnMovedTwoSquare(ms.move, ms.movedPiece)
        ? (ms.move.end + ms.move.start) ~/ 2
        : -1;
    List<bool> isWhiteCastleRight = isCastleRight(board, true);
    List<bool> isBlackCastleRight = isCastleRight(board, false);
    var previouseState = stateString;
    stateString = StateBoardString(
      board,
      isWhiteTurn,
      enPassantPos != -1
          ? BoardHelper.squareNameFromSquare(enPassantPos)
          : null,
      isWhiteCastleRight,
      isBlackCastleRight,
    ).toString();
    isUpdateStateHistory
        ? !stateHistory.containsKey(stateString)
            ? stateHistory[stateString] = 1
            : stateHistory[stateString] = stateHistory[stateString]! + 1
        : stateHistory[previouseState] == 1
            ? stateHistory.remove(previouseState)
            : stateHistory[previouseState] = stateHistory[previouseState]! - 1;
  }
}
