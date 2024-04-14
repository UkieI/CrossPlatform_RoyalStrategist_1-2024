import 'package:chess_flutter_app/controller/chess_board_controller.dart';
import 'package:chess_flutter_app/utils/constants/colors.dart';
import 'package:chess_flutter_app/utils/constants/sizes.dart';

import 'package:chess_flutter_app/views/components/chess_view/bottom_navigation.dart';
import 'package:chess_flutter_app/views/components/chess_view/chess_board.dart';
import 'package:chess_flutter_app/views/components/chess_view/player_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChessView extends StatelessWidget {
  const ChessView({super.key, required this.setTimer});
  final double setTimer;
  @override
  Widget build(BuildContext context) {
    final chessController = Get.put(ChessBoardController(context, setTimer));
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
      bottomNavigationBar:
          BottomNavigationGameScreen(chessController: chessController),
      body: Column(
        children: [
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
              'assets/images/bK.png',
              width: TSizes.appBarHeight,
              fit: BoxFit.cover,
            ),
            isClock: setTimer != 0,
          ),
          const ChessBoard(),
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
              'assets/images/wK.png',
              width: TSizes.appBarHeight,
              fit: BoxFit.cover,
            ),
            isClock: setTimer != 0,
          ),
        ],
      ),
    );
  }
}
