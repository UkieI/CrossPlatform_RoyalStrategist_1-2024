import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';

import 'package:flutter/material.dart';

class SelectPieces extends StatelessWidget {
  const SelectPieces({super.key, required this.piece});

  final ChessPieces piece;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      !piece.isWhite
          ? 'assets/images/black_${getNamePieces(piece)}.png'
          : 'assets/images/white_${getNamePieces(piece)}.png',
    );
  }
}
