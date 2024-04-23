import 'dart:async';
import 'dart:math';

import 'package:chess_flutter_app/controller/timer_controller.dart';
import 'package:chess_flutter_app/logic/board/board.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/board/state_board_string.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';
import 'package:chess_flutter_app/logic/move_generation/ai_move_caculation.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move_stack.dart';

import 'package:chess_flutter_app/logic/move_generation/move_generation.dart';
import 'package:chess_flutter_app/logic/move_generation/opening_moves.dart';
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

  //  CancelableOperation? aiOperation;

  // RxBool isWhiteTurn = true.obs;
  bool isGameOver = false;
  bool isHasTimer = false;
  bool isAimove = false;

  int selectedPieces = Piece.None;
  int selectedPos = -1;

  List<int> validMoves = [];

  List<String> keyPiecesTaken = ['P', 'R', 'N', 'B', 'Q'];
  Map<String, int> piecesTaken = {};
  RxInt whiteTakenValue = 0.obs;
  RxInt blackTakenValue = 0.obs;

  RxBool promotion = false.obs;
  RxBool isInCheck = false.obs;
  RxBool isEnableRedo = false.obs;
  RxBool isEnableUndo = false.obs;

  Move? previousMove;

  // State board variables
  Map<String, int> stateHistory = {};
  int noCaptureOrPawnMoves = 0;
  String stateString = "";
  String preCastlingRight = "";

  final sound = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    board.isWhiteToMove = board.initBoard();
    isAimove = board.aiMove;
    if (_time != 0) {
      timerController = Get.put(TimerController());
      timerController.setClock(_time);
      isHasTimer = true;
    }

    // Timer.periodic(const Duration(milliseconds: 1000), (timer) {
    //   // Hành động bạn muốn lặp sau mỗi 3 giây ở đây
    //   board.isWhiteToMove ? aiMoveGenaration(true, ) : aiMoveGenaration(false, 3);
    //   update();
    // });
  }

  void onPieceSelected(int indexSquare) {
    if (!BoardHelper.isInBoard(indexSquare)) {
      return;
    }

    // No piece selected yet, this is the first selection
    if (selectedPieces == Piece.None && board.square[indexSquare] != Piece.None) {
      if (Piece.isWhite(board.square[indexSquare]) == board.isWhiteToMove) {
        selectedPieces = board.square[indexSquare];
        selectedPos = indexSquare;
      }
    } else if (selectedPos == indexSquare) {
      selectedPieces = Piece.None;
      selectedPos = -1;
      return;
    }
    // There is a piece selected, but the user can select another one of there pieces
    else if (board.square[indexSquare] != Piece.None && Piece.isWhite(board.square[indexSquare]) == Piece.isWhite(selectedPieces)) {
      selectedPieces = board.square[indexSquare];
      selectedPos = indexSquare;
    }
    // if a piece is selected, user tap a valid move, move there
    else if (selectedPieces != Piece.None && validMoves.any((element) => element == indexSquare)) {
      // move the piece
      movePiece(indexSquare);
    }
    // if a piece is selected, calculate the valid move;
    validMoves.assignAll(getMovePiece(selectedPieces, selectedPos, board));
    update();
  }

  void movePiece(int indexSquare) async {
    if (validMoves.contains(indexSquare)) {
      var ms = push(board, Move(selectedPos, indexSquare));
      updateBoard(selectedPos, indexSquare);
      makeCapturePiece(ms.takenPiece);
      if (isPromotion(board.square[previousMove!.end], previousMove!.end)) {
        promotion.value = true;

        isEnableRedo.value = false;
        isEnableUndo.value = false;
      } else {
        isInCheck.value = calculateInCheckState(board, board.isWhiteToMove);
        var isAnyMoveLeft = isAnyMoveleft(board, !board.isWhiteToMove);
        gamePopUp(isAnyMoveLeft);
        moveLogs.add(moveLogString(ms, isAnyMoveLeft, isInCheck.value));
        updateStateString(board.square, !board.isWhiteToMove, ms);

        playSound(ms);

        // ai Move
        if (board.isWhiteToMove == isAimove) {
          gameTimerManagement();
          aiMoveGenaration(isAimove, 4);
        }
        isEnableUndo.value = true;
      }
      board.redoStack.clear();
    }
  }

  void makeCapturePiece(int capturePiece) {
    if (capturePiece != Piece.None) {
      var symbol = Piece.getSymbol(capturePiece);
      if (piecesTaken.containsKey(symbol)) {
        piecesTaken[symbol] = piecesTaken[symbol]! + 1;
      } else {
        piecesTaken[symbol] = 1;
      }
      var pieceValue = Piece.pieceValue(capturePiece).abs() ~/ 100;
      Piece.isWhite(capturePiece) ? whiteTakenValue.value += pieceValue : blackTakenValue.value += pieceValue;
    }
  }

  void undoCapturePiece(int capturePiece) {
    if (capturePiece != Piece.None) {
      var symbol = Piece.getSymbol(capturePiece);
      if (piecesTaken[symbol] == 1) {
        piecesTaken.remove(symbol);
      } else {
        piecesTaken[symbol] = piecesTaken[symbol]! - 1;
      }

      var pieceValue = Piece.pieceValue(capturePiece).abs() ~/ 100;
      Piece.isWhite(capturePiece) ? whiteTakenValue.value -= pieceValue : blackTakenValue.value -= pieceValue;
    }
  }

  void aiMoveGenaration(bool isAiMove, int depth) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!isGameOver) {
      try {
        var move = calculateAIMove(board, depth, isAiMove);
        var ms = push(board, move, promotionType: move.promotionType);
        makeCapturePiece(ms.takenPiece);
        updateStateString(board.square, isAiMove, ms);
        updateBoard(move.start, move.end);

        isInCheck.value = calculateInCheckState(board, !isAiMove);
        var isAnyMoveLeft = isAnyMoveleft(board, isAiMove);
        gamePopUp(isAnyMoveLeft);
        moveLogs.add(moveLogString(ms, isAnyMoveLeft, isInCheck.value));

        playSound(ms);
        // ignore: empty_catches
      } catch (e) {}
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
      if (board.isWhiteToMove) {
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
      List<int> prerivousBoard = List.of(board.square);
      gameTimerManagement();
      var msRedo = pop(board);
      board.redoStack.add(msRedo);
      undoCapturePiece(msRedo.takenPiece);
      isInCheck.value = calculateInCheckState(board, !board.isWhiteToMove);
      moveLogs.removeLast();
      updateBoard(msRedo.move.start, msRedo.move.end);
      updateStateString(prerivousBoard, board.isWhiteToMove, msRedo, isUpdateStateHistory: false);

      playSound(msRedo);
      if (board.movedStack.isEmpty) {
        board.possibleOpenings = List.of(openings[Random().nextInt(openings.length)]);
      }
      if (board.movedStack.isEmpty) {
        isEnableUndo.value = false;
        isInCheck.value = false;
        previousMove = null;
      } else {
        isEnableRedo.value = true;
      }
      update();
    }
  }

  void redoMove() {
    if (board.redoStack.isNotEmpty) {
      gameTimerManagement();
      var ms = board.redoStack.removeLast();
      pushMS(board, ms);
      makeCapturePiece(ms.takenPiece);
      isInCheck.value = calculateInCheckState(board, !board.isWhiteToMove);
      moveLogs.add(moveLogString(ms, isAnyMoveleft(board, !board.isWhiteToMove), isInCheck.value));
      updateBoard(ms.move.start, ms.move.end);
      updateStateString(board.square, !board.isWhiteToMove, ms);

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
        popUpDrawDiaglog('DRAW', '${board.isWhiteToMove ? "White player " : "Black player "} not have any vaild move. ');
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
      board.isWhiteToMove ? timerController.stopBlackTimer() : timerController.stopWhiteTimer();
    }
    showDialog(
      context: _context,
      builder: (context) => AlertDialog(
        title: const Text("CHECK MATE"),
        content: !board.isWhiteToMove ? const Text("White Win") : const Text("Black Win"),
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
    // isWhiteTurn.value = !isWhiteTurn.value;
    // isWhiteTurn = !board.isWhiteToMove;
    update();
  }

  void resetGame() {
    validMoves = [];
    previousMove = Move(-1, -1);
    selectedPieces = Piece.None;
    selectedPos = -1;
    board.isWhiteToMove = board.resetBoard();
    isInCheck.value = false;
    stateHistory.clear();
    moveLogs.clear();
    isGameOver = false;
    piecesTaken.clear();
    whiteTakenValue.value = 0;
    blackTakenValue.value = 0;

    // isWhiteTurn.value = board.isWhiteToMove;
    isAimove = !board.isWhiteToMove;
    count = 0;
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
      // disable popUp promotion pawn
      promotion.value = false;
      pop(board);
      var ms = push(board, Move(previousMove!.start, previousMove!.end), promotionType: piece);
      // board.square[previousMove!.end] = piece;

      // check if is are be in end
      isInCheck.value = calculateInCheckState(board, board.isWhiteToMove);
      var isAnyMoveLeft = isAnyMoveleft(board, board.isWhiteToMove);
      moveLogs.add(moveLogString(ms, isAnyMoveLeft, isInCheck.value));
      gamePopUp(isAnyMoveLeft);

      // when pop up promotion not undo and redo
      isEnableRedo.value = true;
      isEnableUndo.value = true;

      // update for state of game
      updateStateString(board.square, !board.isWhiteToMove, ms);

      // play sound
      sound.play(AssetSource(TImages.audioPromote));

      update();
      // after promotion moves
      aiMoveGenaration(isAimove, 4);
    }
  }

  bool isPreviousMoved(int squareIndex) {
    if (previousMove == null) {
      return false;
    }
    return previousMove!.start == squareIndex || previousMove!.end == squareIndex;
  }

  bool isCaptured(int indexSquare) {
    return board.square[indexSquare] != Piece.None && !Piece.isSameColor(board.square[indexSquare], board.square[selectedPos]);
  }

  bool isKingCheck(int indexSquare) {
    var kingPos = board.isWhiteToMove ? board.kingSquare[0] : board.kingSquare[1];

    return isInCheck.value ? indexSquare == kingPos : false;
  }

  bool fiftyMoveRule() {
    return board.currentFiftyMoveCounter ~/ 2 == 50;
  }

  bool threeFoldRepetion() {
    return stateHistory[stateString] == 3;
  }

  int count = 0;
  void updateStateString(List<int> square, bool isWhiteTurn, MoveStack ms, {isUpdateStateHistory = true}) {
    int enPassantPos = ms.enPassantPos;
    // int enPassantPos = (previousMove!.start + previousMove!.end) ~/ 2;
    var castleRights = ms.castlingRights;
    List<bool> isWhiteCastleRight = [hasQueensideCastleRight(castleRights, true), hasQueensideCastleRight(castleRights, true)];
    List<bool> isBlackCastleRight = [hasQueensideCastleRight(castleRights, false), hasQueensideCastleRight(castleRights, false)];

    stateString = StateBoardString(
      square,
      isWhiteTurn,
      enPassantPos != -1 ? BoardHelper.squareNameFromSquare(enPassantPos) : null,
      isWhiteCastleRight,
      isBlackCastleRight,
    ).toString();

    print(
        "${++count} |:| ${Piece.getSymbol(ms.movedPiece)} ${BoardHelper.squareNameFromSquare(ms.move.start)} ${BoardHelper.squareNameFromSquare(ms.move.end)} |:| $stateString ${board.currentFiftyMoveCounter ~/ 2} ${board.indexMoveLog}");
    isUpdateStateHistory
        ? !stateHistory.containsKey(stateString)
            ? stateHistory[stateString] = 1
            : stateHistory[stateString] = stateHistory[stateString]! + 1
        : stateHistory[stateString] == 1
            ? stateHistory.remove(stateString)
            : stateHistory[stateString] = stateHistory[stateString]! - 1;
    // preCastlingRight = stateString;
  }
}
