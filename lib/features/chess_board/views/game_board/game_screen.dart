import 'package:chess_flutter_app/features/chess_board/controller/chess_controller.dart';
import 'package:chess_flutter_app/features/chess_board/views/game_board/widgets/bottom_navigation.dart';
import 'package:chess_flutter_app/features/chess_board/views/game_board/widgets/chess_board.dart';
import 'package:chess_flutter_app/features/chess_board/views/game_board/widgets/move_log_container.dart';

import 'package:chess_flutter_app/features/chess_board/views/game_board/widgets/player_container.dart';

import 'package:chess_flutter_app/utils/constants/colors.dart';
import 'package:chess_flutter_app/utils/constants/sizes.dart';

import 'package:chess_flutter_app/utils/helpers/helper_functions.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

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
      bottomNavigationBar: BottomNavigationGameScreen(
          dark: dark, chessController: chessController),
      body: Column(
        children: [
          // Move log
          const MoveLogContainer(),
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
