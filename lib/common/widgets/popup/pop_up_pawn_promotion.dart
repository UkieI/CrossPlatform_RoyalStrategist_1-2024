import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/features/chess_board/views/game_board/widgets/chess_pieces_selector.dart';

import 'package:flutter/material.dart';

class PopUpPawnPromotion extends StatelessWidget {
  const PopUpPawnPromotion({
    super.key,
    required this.isWhiteTurn,
    required this.onPieceSelected,
    required this.colPromotion,
    required this.width,
    required this.isRotated,
  });
  final bool isWhiteTurn;
  final Function(ChessPieces) onPieceSelected;
  final int colPromotion;
  final double width;

  final bool isRotated;

  @override
  Widget build(BuildContext context) {
    final rotated = isRotated ? 2 : 0;
    return !isWhiteTurn
        ? Positioned(
            top: 0,
            left: width * colPromotion,
            child: RotatedBox(
              quarterTurns: rotated,
              child: ChessPieceSelector(
                width: width,
                onPieceSelected: onPieceSelected,
                isWhite: !isWhiteTurn,
              ),
            ))
        : Positioned(
            bottom: 0,
            left: width * colPromotion,
            child: RotatedBox(
              quarterTurns: rotated,
              child: ChessPieceSelector(
                width: width,
                onPieceSelected: onPieceSelected,
                isWhite: !isWhiteTurn,
              ),
            ),
          );
  }
}
