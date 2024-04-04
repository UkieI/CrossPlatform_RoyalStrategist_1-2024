import 'package:chess_flutter_app/common/widgets/piece/select_pieces.dart';
import 'package:chess_flutter_app/common/widgets/piece/pieces.dart';

import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/utils/constants/colors.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

class Square extends StatelessWidget {
  const Square({
    super.key,
    required this.isWhite,
    this.onTap,
    this.piece,
    required this.isSelected,
    required this.isValidMove,
    required this.previousMoved,
    required this.isCaptured,
    required this.isWhiteTurn,
    this.position,
    this.onPlacePosition,
    required this.isRotated,
  });
  final bool isWhite;
  final bool isSelected;
  final bool isValidMove;
  final bool previousMoved;
  final bool isCaptured;
  final bool isWhiteTurn;
  final int? position;
  final bool isRotated;
  final ChessPieces? piece;
  final void Function()? onTap;
  final void Function(int row, int col)? onPlacePosition;

  BoxDecoration hlBoxDecoration() {
    return BoxDecoration(
      border: Border.all(width: 3, color: TColors.dragTargetColors),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dragController = Get.put(DragController());
    Color? squareColor;
    // The currently selected piece on the chess board
    if (isSelected || previousMoved) {
      squareColor = TColors.highLightThemeColors;
    } else {
      squareColor =
          isWhite ? TColors.bgGreenThemeColor : TColors.fgGreenThemeColor;
    }
    return GestureDetector(
      onTap: onTap,
      onPanCancel: onTap,

      // onPanStart: (details) => dragController.endDragging(),
      child: Container(
        color: squareColor,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: [
              // show hint move
              if (isValidMove) !isCaptured ? hintDot() : hintCapture(),

              dragTargetChessPieces(constraints, dragController),
              // setting for dragable
              // if (piece != null && isWhiteTurn == piece!.isWhite)
              // draggableChessPieces(constraints),

              if (!isRotated) rowAndColumnName(),
              if (!isRotated && position == 56) columnNamePositon('a'),
              if (isRotated) rowAndColumnName(),
              if (isRotated && position == 7) columnNamePositon('8'),
            ],
          );
        }),
      ),
    );
  }

// DragController dragController,
  DragTarget<Object> dragTargetChessPieces(
      BoxConstraints constraints, DragController dragController) {
    return DragTarget(
      onAcceptWithDetails: (details) {
        int row = position! ~/ 8;
        int col = position! % 8;
        dragController.dragTagetPosition = [row, col];

        return;
        // dragController.endDragging();
      },
      onWillAcceptWithDetails: (data) {
        dragController.startDragging();
        return true;
      },
      builder: (BuildContext context, List<dynamic> accepted,
          List<dynamic> rejected) {
        return Container(
            decoration: accepted.isNotEmpty ? hlBoxDecoration() : null,
            child: piece != null
                ? isWhiteTurn != piece!.isWhite
                    ? SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: Piece(
                          piece: piece,
                          constraints: constraints,
                          isRotated: isRotated,
                        ),
                      )
                    : !dragController.isDragging.value || !isSelected
                        ? draggableChessPieces(constraints, dragController)
                        : SizedBox(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight)
                : SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight));
      },
    );
  }

  Widget draggableChessPieces(
    BoxConstraints constraints,
    DragController dragController,
  ) {
    return Draggable(
      data: position,
      feedback: SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: SelectPieces(
          piece: piece!,
        ),
      ),
      onDragStarted: () => dragController.startDragging(),
      // onDraggableCanceled: (velocity, offset) => dragController.endDragging(),
      onDragCompleted: () {
        onPlacePosition!(dragController.dragTagetPosition[0],
            dragController.dragTagetPosition[1]);
        dragController.dragTagetPosition = [-1, -1];
        dragController.endDragging();
      },
      onDragEnd: (details) => {},
      childWhenDragging: Container(),
      child: isWhiteTurn == piece!.isWhite
          ? Piece(
              piece: piece,
              constraints: constraints,
              isRotated: isRotated,
            )
          : SizedBox(
              width: constraints.maxWidth, height: constraints.maxHeight),
    );
  }

  Widget rowAndColumnName() {
    if (!isRotated) {
      switch (position) {
        case 0:
          return rowNamePositon(8.toString());
        case 8:
          return rowNamePositon(7.toString());
        case 16:
          return rowNamePositon(6.toString());
        case 24:
          return rowNamePositon(5.toString());
        case 32:
          return rowNamePositon(4.toString());
        case 40:
          return rowNamePositon(3.toString());
        case 48:
          return rowNamePositon(2.toString());
        case 56:
          return rowNamePositon(1.toString());
        case 57:
          return columnNamePositon('b');
        case 58:
          return columnNamePositon('c');
        case 59:
          return columnNamePositon('d');
        case 60:
          return columnNamePositon('e');
        case 61:
          return columnNamePositon('f');
        case 62:
          return columnNamePositon('g');
        case 63:
          return columnNamePositon('h');
      }
    } else {
      switch (position) {
        case 0:
          return rowNamePositon('a');
        case 1:
          return rowNamePositon('b');
        case 2:
          return rowNamePositon('c');
        case 3:
          return rowNamePositon('d');
        case 4:
          return rowNamePositon('e');
        case 5:
          return rowNamePositon('f');
        case 6:
          return rowNamePositon('g');
        case 7:
          return rowNamePositon('h');
        case 15:
          return columnNamePositon(7.toString());
        case 23:
          return columnNamePositon(6.toString());
        case 31:
          return columnNamePositon(5.toString());
        case 39:
          return columnNamePositon(4.toString());
        case 47:
          return columnNamePositon(3.toString());
        case 55:
          return columnNamePositon(2.toString());
        case 63:
          return columnNamePositon(1.toString());
      }
    }
    return const SizedBox.shrink();
  }

  Widget rowNamePositon(String text) {
    return Positioned(
      top: 1,
      left: 2,
      child: RotatedBox(
        quarterTurns: isRotated ? 2 : 0,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: !isWhite
                ? TColors.bgGreenThemeColor
                : TColors.fgGreenThemeColor,
          ),
        ),
      ),
    );
  }

  Widget columnNamePositon(String text) {
    return Positioned(
      bottom: 1,
      right: 3,
      child: RotatedBox(
        quarterTurns: isRotated ? 2 : 0,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: !isWhite
                ? TColors.bgGreenThemeColor
                : TColors.fgGreenThemeColor,
          ),
        ),
      ),
    );
  }

  Center hintCapture() {
    return const Center(
      child: SizedBox(
        height: 55,
        width: 55,
        child: CircularProgressIndicator(
          color: TColors.hintGreenThemeColors,
          value: 1,
        ),
      ),
    );
  }

  Center hintDot() {
    return Center(
      child: Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: TColors.hintGreenThemeColors,
        ),
      ),
    );
  }
}

// class DragController extends GetxController {

// }

class DragController extends GetxController {
  var isDragging = false.obs;
  RxBool isRelease = false.obs;
  List<int> dragTagetPosition = [-1, -1];
  void startDragging() {
    isDragging.value = true;
  }

  void endDragging() {
    isDragging.value = false;
  }
}
