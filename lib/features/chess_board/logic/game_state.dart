import 'package:chess_flutter_app/features/chess_board/logic/state_string.dart';

import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';

class GameState {
  int noCaptureOrPawnMoves = 0;
  String stateString = "";
  Map<String, int> stateHistory = {};
  List<String> stateBoardHistory = [];

  bool threeFoldRepetion() {
    return stateHistory[stateString] == 3;
  }

  bool fiftyMoveRule() {
    int fullMoves = noCaptureOrPawnMoves ~/ 2;

    return fullMoves == 50;
  }

  void updateStateString(
      bool isWhiteTurn,
      List<List<ChessPieces?>> board,
      List<bool>? isCastleKing,
      String? enPassantMove,
      int noCaptureOrPawnMoves,
      int fullmove) {
    stateString = StateBoardString(isWhiteTurn, board, isCastleKing,
            enPassantMove, noCaptureOrPawnMoves, fullmove)
        .toString();
    if (!stateHistory.containsKey(stateString)) {
      stateHistory[stateString] = 1;
    } else {
      stateHistory[stateString] = stateHistory[stateString]! + 1;
    }
  }
}
