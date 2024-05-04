import 'package:chess_flutter_app/views/chess-screen/components/chess_view/chess_piece_selector.dart';

import 'package:flutter/material.dart';

class PopUpPawnPromotion extends StatelessWidget {
  const PopUpPawnPromotion({
    super.key,
    required this.isWhiteTurn,
    required this.onPieceSelected,
    required this.colPromotion,
    required this.width,
    required this.isRotated,
    required this.theme,
  });
  final bool isWhiteTurn;
  final Function(int) onPieceSelected;
  final int colPromotion;
  final double width;
  final int isRotated;
  final String theme;

  @override
  Widget build(BuildContext context) {
    return !isWhiteTurn
        ? Positioned(
            top: 0,
            left: width * colPromotion,
            child: ChessPieceSelector(
              width: width,
              onPieceSelected: onPieceSelected,
              isWhite: !isWhiteTurn,
              isRotated: isRotated,
              theme: theme,
            ))
        : Positioned(
            bottom: 0,
            left: width * colPromotion,
            child: ChessPieceSelector(
              width: width,
              onPieceSelected: onPieceSelected,
              isWhite: !isWhiteTurn,
              isRotated: isRotated,
              theme: theme,
            ),
          );
  }
}
