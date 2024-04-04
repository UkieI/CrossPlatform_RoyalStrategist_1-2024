import 'package:chess_flutter_app/features/chess_board/logic/state_string.dart';

import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';

import 'package:get/get.dart';

class GameState {
  RxInt noCaptureOrPawnMoves = 0.obs;
  String stateString = "";
  Map<String, int> stateHistory = {};
  List<String> stateBoardHistory = [];

  bool threeFoldRepetion() {
    return stateHistory[stateString] == 3;
  }

  bool fiftyMoveRule() {
    int fullMoves = noCaptureOrPawnMoves.value ~/ 2;

    return fullMoves == 50;
  }

  void updateStateString(bool isWhiteTurn, List<List<ChessPieces?>> board,
      bool? isCastleKing, String? enPassantMove) {
    stateString =
        StateBoardString(isWhiteTurn, board, isCastleKing, enPassantMove)
            .toString();
    if (!stateHistory.containsKey(stateString)) {
      stateHistory[stateString] = 1;
    } else {
      stateHistory[stateString] = stateHistory[stateString]! + 1;
    }
  }
}
