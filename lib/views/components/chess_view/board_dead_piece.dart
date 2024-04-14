import 'package:chess_flutter_app/controller/chess_board_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class BoardDeadPieces extends StatelessWidget {
  const BoardDeadPieces({
    super.key,
    required this.isWhitePlayer,
  });

  final bool isWhitePlayer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 40,
      child: GetBuilder<ChessBoardController>(builder: (controller) {
        int length = 0;
        !isWhitePlayer
            ? length = controller.whitePiecesTaken.length
            : length = controller.blackPiecesTaken.length;
        return GridView.builder(
            itemCount: length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8),
            itemBuilder: (context, index) {
              // if (index == length) {
              //   var point =
              //       controller.whiteValue.value - controller.blackValue.value;
              //   if (point == 0) {
              //     return const SizedBox.shrink();
              //   }
              //   if (point > 0) {
              //     return !isWhite
              //         ? Center(child: Text("+${point.abs().toString()}"))
              //         : const SizedBox.shrink();
              //   }
              //   if (point < 0) {
              //     return isWhite
              //         ? Center(child: Text("+${point.abs().toString()}"))
              //         : const SizedBox.shrink();
              //   }
              // } else {
              //   return DeadPieces(
              //     piece: !isWhite
              //         ? controller.whitePiecesTaken[index]
              //         : controller.blackPiecesTaken[index],
              //     value: !isWhite
              //         ? controller.whiteTakenMap[
              //             controller.whitePiecesTaken[index].toString()]
              //         : controller.blackTakenMap[
              //             controller.blackPiecesTaken[index].toString()],
              //   );
              // }
              return null;
            });
      }),
    );
  }
}
