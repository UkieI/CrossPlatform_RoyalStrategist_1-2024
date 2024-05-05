import 'package:chess_flutter_app/logic/board/board.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move_stack.dart';
import 'package:chess_flutter_app/model/game_mode.dart';
import 'package:get/get.dart';

class CustomChessBoardController extends GetxController {
  late final GameMode mode;
  // Constructor to receive the context
  CustomChessBoardController(this.mode);

  Board board = Board();
  String theme = "";
  String wSquare = "";
  String bSquare = "";

  int selectedPieces = Piece.None;
  int selectedPos = -1;

  RxBool isRotated = false.obs;

  @override
  void onInit() {
    super.onInit();

    theme = mode.pieceTheme;
    wSquare = mode.wSquares;
    bSquare = mode.bSquares;

    // init board
    board.isWhiteToMove = board.initBoard(mode.customFen);

    // Timer.periodic(const Duration(milliseconds: 1000), (timer) {
    //   // Hành động bạn muốn lặp sau mỗi 3 giây ở đây
    //   board.isWhiteToMove ? aiMoveGenaration(true, ) : aiMoveGenaration(false, 3);
    //   update();
    // });
    update();
  }

  void onPieceSelected(int indexSquare) {
    if (!BoardHelper.isInBoard(indexSquare)) {
      return;
    }

    // No piece selected yet, this is the first selection
    if (selectedPieces == Piece.None && board.square[indexSquare] != Piece.None) {
      selectedPieces = board.square[indexSquare];
      selectedPos = indexSquare;
    } else if (selectedPos == indexSquare) {
      selectedPieces = Piece.None;
      selectedPos = -1;
      return;
    }
    // There is a piece selected, but the user can select another one of there pieces
    // else if (board.square[indexSquare] != Piece.None) {
    //   selectedPieces = board.square[indexSquare];
    //   selectedPos = indexSquare;
    // }
    // if a piece is selected, user tap a valid move, move there
    else if (selectedPieces != Piece.None && selectedPos != selectedPieces) {
      // move the piece
      movePiece(indexSquare);
    }
    // if a piece is selected, calculate the valid move;
    // validMoves.assignAll(getMovePiece(selectedPieces, selectedPos, board));
    update();
  }

  void movePiece(int indexSquare) {
    var ms = MoveStack(
      Move(selectedPos, indexSquare),
      movedPiece: board.square[selectedPos],
    );
    setSquare(board, ms.move.end, ms.movedPiece);
    setSquare(board, ms.move.start, Piece.None);
    selectedPieces = Piece.None;
    selectedPos = -1;
    update();
  }

  bool isSelected(int indexSquare) {
    return selectedPos == indexSquare;
  }
}
