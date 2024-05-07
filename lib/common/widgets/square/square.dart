import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';
import 'package:chess_flutter_app/utils/constants/colors.dart';
import 'package:chess_flutter_app/common/widgets/piece/image_chess_piece.dart';
import 'package:flutter/material.dart';
import 'package:flutter_color_utils/flutter_color_utils.dart';
// import 'package:flutter_color_util/flutter_color_util.dart';
import 'package:get/get.dart';

class Square extends StatelessWidget {
  const Square({
    super.key,
    required this.squareColor,
    required this.piece,
    required this.indexSquare,
    required this.isWhiteTurn,
    required this.isKingIncheck,
    required this.previousMoved,
    required this.isCaptured,
    required this.isSelected,
    required this.isValidMove,
    required this.isCustomMode,
    this.onTap,
    this.onPlacePosition,
    required this.isRotated,
    required this.theme,
    required this.bSquare,
    required this.wSquare,
  });

  final bool squareColor;
  final int piece;
  final int indexSquare;
  final bool isKingIncheck;
  final bool previousMoved;
  final bool isWhiteTurn;
  final bool isCaptured;
  final bool isSelected;
  final bool isValidMove;
  final bool isCustomMode;
  final int isRotated;
  final String theme;
  final String bSquare;
  final String wSquare;

  final void Function()? onTap;
  final void Function(int indexSquare)? onPlacePosition;
  @override
  Widget build(BuildContext context) {
    final dragController = Get.put(DragController());
    Color? colorS;
    if ((isSelected) || previousMoved) {
      colorS = TColors.highLightThemeColors;
    } else if (!BoardHelper.isInBoard(indexSquare)) {
      colorS = TColors.backgroundApp;
    } else if (isKingIncheck) {
      colorS = Colors.red;
    } else {
      colorS = squareColor ? HexColor('#$wSquare') : HexColor('#$bSquare');
    }

    return GestureDetector(
      onTap: () {
        onTap;
        dragController.endDragging();
      },
      onPanCancel: onTap,
      child: Container(
        color: colorS,
        child: LayoutBuilder(builder: (context, constraints) {
          return Stack(children: [
            if (isValidMove) !isCaptured ? hintDot(constraints) : hintCapture(constraints),
            dragTargetChessPieces(constraints, dragController),
            rowAndColumnName(),
            if (indexSquare == 56) columnNamePositon('a'),
            if (indexSquare == 7 && isRotated == 2) columnNamePositon('8'),
          ]);
        }),
      ),
    );
  }

  DragTarget<Object> dragTargetChessPieces(BoxConstraints constraints, DragController dragController) {
    return DragTarget(
      onAcceptWithDetails: (details) => onPlacePosition!(indexSquare),
      builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
        return Container(
            decoration: accepted.isNotEmpty && BoardHelper.isInBoard(indexSquare) ? hlBoxDecoration(constraints) : null,
            child: piece != Piece.None
                ? isWhiteTurn != Piece.isWhite(piece) && !isCustomMode
                    ? ImageChessPieceWidget(
                        piece,
                        constraints,
                        isRotated,
                        theme: theme,
                      )
                    : !dragController.isDragging.value || !isSelected
                        ? draggableChessPieces(constraints, dragController)
                        : SizedBox(width: constraints.maxWidth, height: constraints.maxHeight)
                : sizeBoxMax(constraints));
      },
    );
  }

  SizedBox sizeBoxMax(BoxConstraints constraints) {
    return SizedBox(width: constraints.maxWidth, height: constraints.maxHeight);
  }

  Widget draggableChessPieces(BoxConstraints constraints, DragController dragController) {
    return Draggable(
        data: indexSquare,
        feedback: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: ImageChessPieceWidget(
            piece,
            constraints,
            0,
            theme: theme,
          ),
        ),
        onDragStarted: () => dragController.startDragging(),
        onDragCompleted: () => dragController.endDragging(),
        childWhenDragging: Container(),
        child: ImageChessPieceWidget(
          piece,
          constraints,
          isRotated,
          theme: theme,
        ));
  }

  BoxDecoration hlBoxDecoration(BoxConstraints constraints) {
    return BoxDecoration(
      border: Border.all(width: 3, color: TColors.dragTargetColors),
    );
  }

  Center hintCapture(BoxConstraints constraints) {
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

  Center hintDot(BoxConstraints constraints) {
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

  Widget rowAndColumnName() {
    if (isRotated == 0) {
      switch (indexSquare) {
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
      switch (indexSquare) {
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
        quarterTurns: isRotated,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: !squareColor ? TColors.fgGreenThemeColor : TColors.fgGreenThemeColor,
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
        quarterTurns: isRotated,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: !squareColor ? TColors.fgGreenThemeColor : TColors.fgGreenThemeColor,
          ),
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
