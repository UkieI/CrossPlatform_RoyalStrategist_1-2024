import 'package:chess_flutter_app/common/widgets/popup/pop_up_pawn_promotion.dart';
import 'package:chess_flutter_app/common/widgets/square/square.dart';
import 'package:chess_flutter_app/controller/chess_board_controller.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';
import 'package:chess_flutter_app/utils/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChessBoard extends StatelessWidget {
  const ChessBoard({
    super.key,
    required this.chessController,
  });

  final ChessBoardController chessController;
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Obx(
        () => RotatedBox(
          quarterTurns: chessController.isRotated.value ? 2 : 0,
          child: Expanded(
            child: Stack(
              children: [
                GridView.builder(
                  itemCount: 8 * 8,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                  itemBuilder: (context, index) {
                    return GetBuilder<ChessBoardController>(
                      builder: (controller) {
                        bool isSelected = controller.isSelected(index);
                        bool isKingInCheck = controller.isKingCheck(index);
                        bool isPreviousMoved = controller.isPreviousMoved(index);
                        bool isValidMove = false;
                        bool isCaptured = false;
                        // Check all valid selected pieces move
                        for (var position in controller.validMoves) {
                          if (position == index) {
                            isValidMove = true;
                            // Check if can be caputred
                            isCaptured = controller.isCaptured(position);
                          }
                        }
                        return Square(
                          isWhite: BoardHelper.sameSquareColor(index),
                          indexSquare: index,
                          piece: controller.board.square[index],
                          isKingIncheck: isKingInCheck,
                          previousMoved: isPreviousMoved,
                          isWhiteTurn: controller.board.isWhiteToMove,
                          isSelected: isSelected,
                          isCaptured: isCaptured,
                          isValidMove: isValidMove,
                          isRotated: chessController.isRotated.value ? 2 : 0,
                          onTap: () => controller.onPieceSelected(index),
                          onPlacePosition: (indexSquare) => controller.onPieceSelected(indexSquare),
                          theme: controller.theme,
                          wSquare: chessController.wSquare,
                          bSquare: chessController.bSquare,
                        );
                      },
                    );
                  },
                ),
                // PopUp pawn promotion
                GetX<ChessBoardController>(
                  builder: (controller) {
                    var width = TDeviceUtils.getScreenWidth(context);
                    if (controller.promotion.value) {
                      return PopUpPawnPromotion(
                        isWhiteTurn: controller.board.isWhiteToMove,
                        onPieceSelected: (chessPiece) {
                          controller.pawnPromotion(chessPiece);
                        },
                        colPromotion: BoardHelper.colIndex(controller.previousMove!.end),
                        width: (width) / 8,
                        isRotated: chessController.isRotated.value ? 2 : 0,
                        theme: controller.theme,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
