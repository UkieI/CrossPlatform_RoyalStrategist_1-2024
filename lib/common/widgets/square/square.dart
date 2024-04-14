import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/utils/constants/colors.dart';
import 'package:chess_flutter_app/common/widgets/piece/image_chess_piece.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class Square extends StatelessWidget {
  const Square({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.indexSquare,
    required this.isWhiteTurn,
    required this.isKingIncheck,
    required this.previousMoved,
    required this.isCaptured,
    required this.isSelected,
    required this.isValidMove,
    this.onTap,
    this.onPlacePosition,
  });

  final bool isWhite;
  final int piece;
  final int indexSquare;
  final bool isKingIncheck;
  final bool previousMoved;
  final bool isWhiteTurn;
  final bool isCaptured;
  final bool isSelected;
  final bool isValidMove;
  final void Function()? onTap;
  final void Function(int indexSquare)? onPlacePosition;
  @override
  Widget build(BuildContext context) {
    final dragController = Get.put(DragController());
    Color? squareColor;
    if (isSelected || previousMoved) {
      squareColor = TColors.highLightThemeColors;
    } else if (isKingIncheck) {
      squareColor = Colors.red;
    } else {
      squareColor =
          isWhite ? TColors.bgGreenThemeColor : TColors.fgGreenThemeColor;
    }
    return GestureDetector(
      onTap: () {
        onTap;
        dragController.endDragging();
      },
      onPanCancel: onTap,
      child: Container(
        color: squareColor,
        child: LayoutBuilder(builder: (context, constraints) {
          return Stack(children: [
            if (isValidMove)
              !isCaptured ? hintDot(constraints) : hintCapture(constraints),
            dragTargetChessPieces(constraints, dragController),
          ]);
        }),
      ),
    );
  }

  DragTarget<Object> dragTargetChessPieces(
      BoxConstraints constraints, DragController dragController) {
    return DragTarget(
      onAcceptWithDetails: (details) {
        onPlacePosition!(indexSquare);
      },
      onWillAcceptWithDetails: (data) {
        dragController.startDragging();
        return true;
      },
      builder: (BuildContext context, List<dynamic> accepted,
          List<dynamic> rejected) {
        return Container(
            decoration:
                accepted.isNotEmpty ? hlBoxDecoration(constraints) : null,
            child: piece != Piece.None
                ? isWhiteTurn != Piece.isWhite(piece)
                    ? ImageChessPieceWidget(piece, constraints)
                    : !dragController.isDragging.value || !isSelected
                        ? draggableChessPieces(constraints, dragController)
                        : SizedBox(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight)
                : sizeBoxMax(constraints));
      },
    );
  }

  SizedBox sizeBoxMax(BoxConstraints constraints) {
    return SizedBox(width: constraints.maxWidth, height: constraints.maxHeight);
  }

  Widget draggableChessPieces(
    BoxConstraints constraints,
    DragController dragController,
  ) {
    return Draggable(
        data: indexSquare,
        feedback: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: ImageChessPieceWidget(piece, constraints),
        ),
        onDragStarted: () => dragController.startDragging(),
        onDragCompleted: () => dragController.endDragging(),
        childWhenDragging: Container(),
        child: ImageChessPieceWidget(piece, constraints));
  }

  BoxDecoration hlBoxDecoration(
    BoxConstraints constraints,
  ) {
    return BoxDecoration(
      border: Border.all(width: 3, color: TColors.dragTargetColors),
    );
  }

  Center hintCapture(
    BoxConstraints constraints,
  ) {
    return Center(
      child: SizedBox(
        height: constraints.maxHeight * 0.9,
        width: constraints.maxWidth * 0.9,
        child: const CircularProgressIndicator(
          color: TColors.hintGreenThemeColors,
          value: 1,
        ),
      ),
    );
  }

  Center hintDot(
    BoxConstraints constraints,
  ) {
    return Center(
      child: Container(
        width: constraints.maxWidth * 0.35,
        height: constraints.maxHeight * 0.35,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: TColors.hintGreenThemeColors,
        ),
      ),
    );
  }
}

class DragController extends GetxController {
  var isDragging = false.obs;

  void startDragging() {
    isDragging.value = true;
  }

  void endDragging() {
    isDragging.value = false;
  }
}
