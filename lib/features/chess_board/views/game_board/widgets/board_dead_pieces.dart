import 'package:chess_flutter_app/features/chess_board/controller/chess_controller.dart';
import 'package:chess_flutter_app/common/widgets/piece/dead_pieces.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class BoardDeadPieces extends StatelessWidget {
  const BoardDeadPieces({
    super.key,
    required this.isWhite,
  });

  final bool isWhite;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 40,
      child: GetBuilder<ChessBoardController>(builder: (controller) {
        int length = 0;
        !isWhite
            ? length = controller.whitePiecesTaken.length
            : length = controller.blackPiecesTaken.length;
        return GridView.builder(
            itemCount: length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8),
            itemBuilder: (context, index) {
              if (index == length) {
                var point =
                    controller.whiteValue.value - controller.blackValue.value;
                if (point == 0) {
                  return const SizedBox.shrink();
                }
                if (point > 0) {
                  return !isWhite
                      ? Center(child: Text("+${point.abs().toString()}"))
                      : const SizedBox.shrink();
                }
                if (point < 0) {
                  return isWhite
                      ? Center(child: Text("+${point.abs().toString()}"))
                      : const SizedBox.shrink();
                }
              } else {
                return DeadPieces(
                  piece: !isWhite
                      ? controller.whitePiecesTaken[index]
                      : controller.blackPiecesTaken[index],
                  value: !isWhite
                      ? controller.whiteTakenMap[
                          controller.whitePiecesTaken[index].toString()]
                      : controller.blackTakenMap[
                          controller.blackPiecesTaken[index].toString()],
                );
              }
            });
      }),
    );
  }
}
