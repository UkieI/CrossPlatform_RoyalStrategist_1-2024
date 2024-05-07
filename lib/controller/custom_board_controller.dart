import 'package:chess_flutter_app/logic/board/board.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/board/state_board_string.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move.dart';
import 'package:chess_flutter_app/logic/move_generation/move/move_stack.dart';
import 'package:chess_flutter_app/model/game_mode.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomChessBoardController extends GetxController {
  late final GameMode mode;
  // Constructor to receive the context
  CustomChessBoardController(this.mode);

  Board board = Board();
  String theme = "";
  String wSquare = "";
  String bSquare = "";
  String stateString = "";
  String inputFen = "";
  bool justInputFen = false;

  int selectedPieces = Piece.None;
  int selectedPos = -1;

  RxBool isRotated = false.obs;

  RxBool isWhiteMove = false.obs;

  @override
  void onInit() {
    super.onInit();

    theme = mode.pieceTheme;
    wSquare = mode.wSquares;
    bSquare = mode.bSquares;

    // init board
    board.isWhiteToMove = board.initBoard(mode.customFen);
    isWhiteMove.value = board.isWhiteToMove;
    stateString = mode.customFen;
    print(mode.customFen);
    update();
  }

  void onPieceSelected(int indexSquare) {
    if (indexSquare == 79) {
      isWhiteMove.value = false;
    } else if (indexSquare == 71) {
      isWhiteMove.value = true;
    }
    update();
    if (!BoardHelper.isInBoard(indexSquare)) {
      if (indexSquare == 71 || indexSquare == 79) {
        return;
      }
      int col = BoardHelper.colIndex(indexSquare);
      selectedPieces = indexSquare > 63 && indexSquare <= 71 ? Piece.makePieceII(col + 1, Piece.White) : Piece.makePieceII(col + 1, Piece.Black);
      selectedPos = indexSquare;
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
    // if a piece is selected, user tap a valid move, move there
    else if (selectedPieces != Piece.None && selectedPos != selectedPieces) {
      // move the piece
      movePiece(indexSquare);
    }

    update();
  }

  void movePiece(int indexSquare) {
    var ms = MoveStack(
      Move(selectedPos, indexSquare),
      movedPiece: selectedPieces,
      castlingRights: board.currentKingCastleRight,
    );

    ms = push(board, Move(selectedPos, indexSquare), movedPieces: selectedPieces);
    // if (BoardHelper.isInBoard(ms.move.start)) {
    //   setSquare(board, ms.move.start, Piece.None);
    // }
    selectedPieces = Piece.None;
    selectedPos = -1;
    justInputFen = false;
    updateStateString(board.square, isWhiteMove.value, ms);
    update();
  }

  void resetGame(String fen) {
    selectedPieces = Piece.None;
    selectedPos = -1;
    board.isWhiteToMove = board.resetBoard(fen);
    justInputFen = false;
    update();
  }

  void updateStateString(List<int> square, bool isWhiteTurn, MoveStack ms, {isUpdateStateHistory = true}) {
    // int enPassantPos = (previousMove!.start + previousMove!.end) ~/ 2;
    var castleRights = ms.castlingRights;
    List<bool> isWhiteCastleRight = [hasQueensideCastleRight(castleRights, true), hasKingsideCastleRight(castleRights, true)];
    List<bool> isBlackCastleRight = [hasQueensideCastleRight(castleRights, false), hasKingsideCastleRight(castleRights, false)];

    stateString = StateBoardString(
      square,
      isWhiteTurn,
      null,
      isWhiteCastleRight,
      isBlackCastleRight,
    ).toString();

    print("${Piece.getSymbol(ms.movedPiece)} |:| $stateString ${board.currentFiftyMoveCounter ~/ 2} ${board.indexMoveLog}");

    // preCastlingRight = stateString;
  }

  storeFen() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (justInputFen) {
      pref.setString("customFen", inputFen);
    } else {
      var fenString = stateString.split(" ");
      pref.setString("customFen", "${fenString[0]} ${isWhiteMove.value ? 'w' : 'b'} ${fenString[2]} - 0 0");
    }
  }

  bool isSelected(int indexSquare) {
    return selectedPos == indexSquare && BoardHelper.isInBoard(indexSquare);
  }

  bool isPreviousMoved(int indexSquare) {
    return isWhiteMove.value && indexSquare == 71 || !isWhiteMove.value && indexSquare == 79;
  }
}
