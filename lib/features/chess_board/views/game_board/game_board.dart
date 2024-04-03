import 'package:chess_flutter_app/common/widgets/navigation/navigation_button/navigation_button.dart';
import 'package:chess_flutter_app/common/widgets/navigation/navigation_menu.dart';
import 'package:chess_flutter_app/features/chess_board/controller/chess_controller.dart';
import 'package:chess_flutter_app/features/chess_board/controller/move_log_controller.dart';

import 'package:chess_flutter_app/features/chess_board/views/game_board/widgets/player_container.dart';

import 'package:chess_flutter_app/common/widgets/popup/pop_up_pawn_promotion.dart';
import 'package:chess_flutter_app/common/widgets/square/square.dart';
import 'package:chess_flutter_app/utils/constants/colors.dart';
import 'package:chess_flutter_app/utils/constants/sizes.dart';
import 'package:chess_flutter_app/utils/constants/text_strings.dart';

import 'package:chess_flutter_app/utils/device/device_utility.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';
import 'package:chess_flutter_app/utils/helpers/helper_functions.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class GameScreens extends StatelessWidget {
  const GameScreens({super.key, required this.time, required this.isRotated});

  final double time;
  final bool isRotated;

  @override
  Widget build(BuildContext context) {
    final chessController = Get.put(ChessBoardController(context, time));
    chessController.isRotation.value = isRotated;
    final dark = THelperFunctions.isDarkMode(context);
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
      bottomNavigationBar: BottomNavigationChess(
        dark: dark,
        children: [
          ButtonNavigation(
            icon: const Icon(Iconsax.task, color: Colors.white54),
            text: const Text(
              'Optional',
              style: TextStyle(color: Colors.white54),
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: SizedBox(
                        width: 500,
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: TSizes.spaceBtwItems),
                              // Flip Board
                              TextButton(
                                onPressed: () {
                                  chessController.isRotation.value =
                                      !chessController.isRotation.value;
                                  Navigator.pop(context);
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      TTexts.flipBoard,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: TSizes.spaceBtwItems / 2),
                              // Copy as PNG
                              TextButton(
                                onPressed: () {},
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      TTexts.copyAsPNG,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: TSizes.spaceBtwItems / 2),
                              // New Game
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  chessController.resetGame();
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      TTexts.newGame,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: TSizes.spaceBtwItems),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            },
          ),
          ButtonNavigation(
            icon: const Icon(Iconsax.add, color: Colors.white54),
            text: const Text('New', style: TextStyle(color: Colors.white54)),
            onPressed: () => chessController.resetGame(),
          ),
          ButtonNavigation(
            icon: const Icon(Iconsax.arrow_left_2, color: Colors.white54),
            text: const Text('Back', style: TextStyle(color: Colors.white54)),
            onPressed: () {},
          ),
          ButtonNavigation(
            icon: const Icon(Iconsax.arrow_right_3, color: Colors.white54),
            text: const Text('Foward', style: TextStyle(color: Colors.white54)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Move log
          Padding(
            padding: const EdgeInsets.all(0),
            child: SizedBox(
              height: 40,
              child: GetX<MoveLogController>(
                builder: (controller) {
                  return ListView.builder(
                    itemCount: controller.moveLogs.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      if (index % 2 == 0) {
                        return Row(
                          children: [
                            const SizedBox(width: 10),
                            Text(
                              '${index ~/ 2}.',
                              style: const TextStyle(color: Colors.white),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(
                                  color: Colors.white60,
                                ),
                                padding: const EdgeInsets.all(0),
                              ),
                              onPressed: () {},
                              child: Text(controller.moveLogs[index],
                                  style:
                                      const TextStyle(color: Colors.white54)),
                            )
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(
                                  color: Colors.white60,
                                ),
                                padding: const EdgeInsets.all(0),
                              ),
                              onPressed: () {},
                              child: Text(controller.moveLogs[index],
                                  style:
                                      const TextStyle(color: Colors.white54)),
                            ),
                          ],
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
          // Player 1
          PlayerContainer(
            timer: Obx(
              () => Container(
                height: 40,
                width: 100,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(TSizes.sm)),
                  color: Colors.white,
                ),
                child: Center(
                    child: Text(
                  chessController.timerController.timesBlack.value,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                )),
              ),
            ),
            // timerController: chessController.timerController,
            playerName: const Text(
              "Player 1",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            isWhite: false,
            image: Image.asset(
              'assets/images/black_king.png',
              width: TSizes.appBarHeight,
              fit: BoxFit.cover,
            ),
            isClock: time != 0,
          ),
          // CHESS BOARD
          ChessBoard(
            chessController: chessController,
            isRotated: isRotated,
          ),
          // Player 2
          PlayerContainer(
            timer: Obx(
              () => Container(
                height: 40,
                width: 100,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(TSizes.sm)),
                  color: Colors.white,
                ),
                child: Center(
                    child: Text(
                  chessController.timerController.timesWhite.value,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                )),
              ),
            ),
            playerName: const Text(
              "Player 2",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            isWhite: true,
            image: Image.asset(
              'assets/images/white_king.png',
              width: TSizes.appBarHeight,
              fit: BoxFit.cover,
            ),
            isClock: time != 0,
          ),
        ],
      ),
    );
  }
}

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
                        piece: controller.board[row][col],
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
                  var height = TDeviceUtils.getScreenHeight(context);
                  var xStart = (width) / 8;

                  if (controller.isPromotion.value) {
                    return PopUpPawnPromotion(
                      isWhiteTurn: controller.isWhiteTurn,
                      onPieceSelected: (chessPiece) {
                        controller.showPopupPromotion(chessPiece);
                      },
                      colPromotion: controller.previousMoved[1],
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
