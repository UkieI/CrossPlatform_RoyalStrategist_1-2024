import 'package:chess_flutter_app/common/widgets/square/square.dart';
import 'package:chess_flutter_app/controller/custom_board_controller.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';
import 'package:chess_flutter_app/model/game_mode.dart';
import 'package:chess_flutter_app/utils/constants/colors.dart';
import 'package:chess_flutter_app/utils/constants/sizes.dart';
import 'package:chess_flutter_app/views/chess-screen/components/chess_view/chess_board.dart';
import 'package:chess_flutter_app/views/home-screen/components/custom_board.dart';
import 'package:chess_flutter_app/views/home-screen/screens/pass-and-play/bottom_custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ChessCustomView extends StatelessWidget {
  const ChessCustomView({super.key, required this.mode});
  // final double setTimer;
  final GameMode mode;
  @override
  Widget build(BuildContext context) {
    final chessController = Get.put(CustomChessBoardController(mode));
    return Scaffold(
      backgroundColor: TColors.backgroundApp,
      appBar: AppBar(
        toolbarHeight: TSizes.appBarHeight,
        backgroundColor: TColors.black,
        title: const Text(
          'Chess',
          style: TextStyle(color: TColors.white),
        ),
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.menu,
            color: Colors.white54,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationCustomBoard(chessController: chessController),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Container()),

          CustomBoard(chessController: chessController),

          Expanded(
            flex: 2,
            child: GridView.builder(
              itemCount: 8 * 2,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) {
                return GetBuilder<CustomChessBoardController>(
                  builder: (controller) {
                    var squareIndex = index + 64;
                    bool isSelected = controller.isSelected(squareIndex);
                    bool isWhiteSelectedPiece = squareIndex > 63 && squareIndex <= 71;

                    int col = BoardHelper.colIndex(squareIndex);
                    bool canMake = col != 6 && col != 7 && col != 5;
                    // bool isPreviousMoved = controller.isPreviousMoved(squareIndex);
                    // Check all valid selected pieces move
                    return Square(
                      squareColor: BoardHelper.sameSquareColor(squareIndex),
                      indexSquare: squareIndex,
                      piece: canMake
                          ? isWhiteSelectedPiece
                              ? Piece.makePieceII(col + 1, Piece.White)
                              : Piece.makePieceII(col + 1, Piece.Black)
                          : col == 7
                              ? isWhiteSelectedPiece
                                  ? Piece.WhitePawn
                                  : Piece.BlackPawn
                              : Piece.None,
                      isKingIncheck: false,
                      previousMoved: controller.isPreviousMoved(squareIndex),
                      isWhiteTurn: squareIndex == 79 || squareIndex != 71,
                      isSelected: isSelected,
                      isCaptured: false,
                      isValidMove: false,
                      isRotated: 0,
                      onTap: () => controller.onPieceSelected(squareIndex),
                      onPlacePosition: (indexSquare) => controller.onPieceSelected(indexSquare),
                      theme: controller.theme,
                      wSquare: chessController.wSquare,
                      bSquare: chessController.bSquare,
                      isCustomMode: squareIndex != 71 && squareIndex != 79,
                    );
                  },
                );
              },
            ),
          ),
          // PopUp pawn promotion
        ],
      ),
    );
  }
}
