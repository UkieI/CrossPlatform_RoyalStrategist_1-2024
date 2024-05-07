// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:chess_flutter_app/common/widgets/square/square.dart';

import 'package:chess_flutter_app/controller/custom_board_controller.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBoard extends StatelessWidget {
  const CustomBoard({
    super.key,
    required this.chessController,
  });

  final CustomChessBoardController chessController;
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
                    return GetBuilder<CustomChessBoardController>(
                      builder: (controller) {
                        bool isSelected = controller.isSelected(index);
                        // bool isPreviousMoved = controller.isPreviousMoved(index);
                        // Check all valid selected pieces move
                        return Square(
                          squareColor: BoardHelper.sameSquareColor(index),
                          indexSquare: index,
                          piece: controller.board.square[index],
                          isKingIncheck: false,
                          previousMoved: controller.isPreviousMoved(index),
                          isWhiteTurn: true,
                          isSelected: isSelected,
                          isCaptured: false,
                          isValidMove: false,
                          isRotated: chessController.isRotated.value ? 2 : 0,
                          onTap: () => controller.onPieceSelected(index),
                          onPlacePosition: (indexSquare) => controller.onPieceSelected(indexSquare),
                          theme: controller.theme,
                          wSquare: chessController.wSquare,
                          bSquare: chessController.bSquare,
                          isCustomMode: true,
                        );
                      },
                    );
                  },
                ),
                // PopUp pawn promotion
              ],
            ),
          ),
        ),
      ),
    );
  }
}
