import 'package:chess_flutter_app/logic/controller/chess_board_controller.dart';
import 'package:chess_flutter_app/utils/constants/colors.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';
import 'package:chess_flutter_app/views/chess_view/square.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChessView extends StatelessWidget {
  const ChessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.backgroundApp,
      body: Column(
        children: [
          Expanded(
              child: Stack(
            children: [
              GridView.builder(
                itemCount: 64,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8),
                itemBuilder: (context, index) {
                  return GetBuilder<ChessBoardController>(
                    builder: (controller) {
                      return Square(isWhite: isWhite(index));
                    },
                  );
                },
              )
            ],
          ))
        ],
      ),
    );
  }
}
