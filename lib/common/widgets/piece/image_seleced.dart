import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:flutter/material.dart';

class SelectPieces extends StatelessWidget {
  const SelectPieces({super.key, required this.piece, required this.isRotated, required this.theme});

  final int piece;
  final String theme;
  final int isRotated;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: isRotated,
      child: Image.asset(
        'assets/images/$theme-${Piece.isWhite(piece) ? 'w' : 'b'}${Piece.getSymbol(piece).toUpperCase()}.png',
        fit: BoxFit.fill,
      ),
    );
  }
}
