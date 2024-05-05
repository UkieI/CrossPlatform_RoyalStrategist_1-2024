import 'package:chess_flutter_app/controller/chess_board_controller.dart';
import 'package:chess_flutter_app/model/game_mode.dart';
import 'package:chess_flutter_app/utils/constants/colors.dart';
import 'package:chess_flutter_app/utils/constants/sizes.dart';

import 'package:chess_flutter_app/views/chess-screen/components/chess_view/bottom_navigation.dart';
import 'package:chess_flutter_app/views/chess-screen/components/chess_view/chess_board.dart';
import 'package:chess_flutter_app/views/chess-screen/components/chess_view/move_log_widget.dart';
import 'package:chess_flutter_app/views/chess-screen/components/chess_view/player_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChessView extends StatelessWidget {
  const ChessView({super.key, required this.mode});
  // final double setTimer;
  final GameMode mode;
  @override
  Widget build(BuildContext context) {
    final chessController = Get.put(ChessBoardController(context, mode));
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
      bottomNavigationBar: BottomNavigationGameScreen(chessController: chessController),
      body: Column(
        children: [
          // Move log
          const MoveLogContainer(),
          // Player 1
          PlayerContainer(
            timer: Container(
              height: 40,
              width: 100,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(TSizes.sm)),
                color: Colors.white,
              ),
              child: Center(
                child: Obx(
                  () => Text(
                    chessController.timerController.timesBlack.value,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
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
              'assets/images/d-bK.png',
              width: TSizes.appBarHeight,
              fit: BoxFit.cover,
            ),
            isClock: mode.timer != 0, theme: chessController.theme,
          ),
          ChessBoard(chessController: chessController),
          PlayerContainer(
            timer: Container(
              height: 40,
              width: 100,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(TSizes.sm)),
                color: Colors.white,
              ),
              child: Center(
                child: Obx(
                  () => Text(
                    chessController.timerController.timesWhite.value,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ),
            playerName: const Text(
              "Player 2",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            isWhite: true,
            image: Image.asset(
              'assets/images/d-wK.png',
              width: TSizes.appBarHeight,
              fit: BoxFit.cover,
            ),
            isClock: mode.timer != 0,
            theme: chessController.theme,
          ),
        ],
      ),
    );
  }
}
