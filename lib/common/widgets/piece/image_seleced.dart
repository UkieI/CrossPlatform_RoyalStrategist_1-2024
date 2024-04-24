import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:flutter/material.dart';

class SelectPieces extends StatelessWidget {
  const SelectPieces({super.key, required this.piece});

  final int piece;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/glass-${Piece.isWhite(piece) ? 'w' : 'b'}${Piece.getSymbol(piece).toUpperCase()}.png',
      fit: BoxFit.fill,
    );
  }
}
