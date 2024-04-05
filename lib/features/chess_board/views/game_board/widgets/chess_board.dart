import 'package:chess_flutter_app/common/widgets/popup/pop_up_pawn_promotion.dart';
import 'package:chess_flutter_app/common/widgets/square/square.dart';
import 'package:chess_flutter_app/features/chess_board/controller/chess_controller.dart';
import 'package:chess_flutter_app/utils/device/device_utility.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChessBoard extends StatelessWidget {
  const ChessBoard({
    super.key,
    required this.chessController,
    required this.isRotated,
  });
  final bool isRotated;
  final ChessBoardController chessController;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      // RotatedBox == 2 (180`) but not rotated chess peiece
      child: Expanded(
        child: Obx(
          () => RotatedBox(
            quarterTurns: chessController.isRotation.value ? 2 : 0,
            child: Stack(children: [
              GridView.builder(
                itemCount: 8 * 8,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8),
                itemBuilder: (context, index) {
                  int row = index ~/ 8;
                  int col = index % 8;
                  return GetBuilder<ChessBoardController>(
                    builder: (controller) {
                      bool isSelected = controller.isSelected(row, col);
                      bool ishlPreviousMoved =
                          controller.ishlPreviousMoved(row, col);
                      bool isValidMove = false;
                      bool isCaptured = false;
                      for (var position in controller.validMoves) {
                        // compare
                        if (position[0] == row && position[1] == col) {
                          isValidMove = true;
                          // Check if can be caputred
                          isCaptured =
                              controller.isCaptured(position[0], position[1]);
                        }
                      }

                      return Square(
                        isWhite: isWhite(index),
                        piece: controller.gameBoard.board[row][col],
                        onTap: () => controller.pieceSelected(row, col),
                        onPlacePosition: (r, c) =>
                            controller.pieceSelected(r, c),
                        position: index,
                        isSelected: isSelected,
                        isValidMove: isValidMove,
                        previousMoved: ishlPreviousMoved,
                        isCaptured: isCaptured,
                        isWhiteTurn: controller.isWhiteTurn,
                        isRotated: chessController.isRotation.value,
                      );
                    },
                  );
                },
              ),

              // PopUp pawn promotion
              GetX<ChessBoardController>(
                builder: (controller) {
                  var width = TDeviceUtils.getScreenWidth(context);
                  var xStart = (width) / 8;
                  if (controller.isPromotion.value) {
                    return PopUpPawnPromotion(
                      isWhiteTurn: controller.isWhiteTurn,
                      onPieceSelected: (chessPiece) {
                        controller.pawnPromotion(chessPiece);
                      },
                      colPromotion: controller.gameBoard.previousMoved[1],
                      width: xStart,
                      isRotated: chessController.isRotation.value,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
