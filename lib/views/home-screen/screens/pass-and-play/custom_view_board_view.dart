import 'package:chess_flutter_app/controller/custom_board_controller.dart';
import 'package:chess_flutter_app/model/game_mode.dart';
import 'package:chess_flutter_app/utils/constants/colors.dart';
import 'package:chess_flutter_app/utils/constants/sizes.dart';
import 'package:chess_flutter_app/views/chess-screen/components/chess_view/chess_board.dart';
import 'package:chess_flutter_app/views/home-screen/components/custom_board.dart';
import 'package:flutter/material.dart';
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
      // bottomNavigationBar: BottomNavigationGameScreen(chessController: chessController),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Expanded(child: Container()),
          // Move log
          CustomBoard(chessController: chessController),
          // PieceChess : White and Black
        ],
      ),
    );
  }
}
