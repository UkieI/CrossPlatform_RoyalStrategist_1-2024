import 'package:chess_flutter_app/features/chess_board/models/move.dart';

import 'package:get/get.dart';

class MoveLogController extends GetxController {
  RxList<String> moveLogs = <String>[].obs;
  List<String> moveHistory = [];

  // Rule to write the move for long-term storing
  // 1. The piece moving (1 letter : P , R , N , B , Q , K )
  // 2. Start positon (2 num: 0 1 2 3 4 5 6 7) like 00 is a1
  // 3. End positon (2 num: 0 1 2 3 4 5 6 7)  like 00 is a1
  // 4. Piece being captured (1 letter : _ , P , R , N , B , Q , K )
  // 5. Piece promotion (1 letter : _ , P , R , N , B , Q , K )
  // 6. Is in check (1 num: t : 1 , f  : 0)
  // 7. Game set (1 letter: 1 - 0 : 1 , 1/2 - 1/2 : 1 )
  void setMove(Move move) {
    // 1. Record the piece that is being moved, and the square that the piece is being moved to
    String strMoveFEN = move.generateFEN(move);
    String strMove = move.toString();
    moveLogs.add(strMoveFEN);
    moveHistory.add(strMove);
  }
}
