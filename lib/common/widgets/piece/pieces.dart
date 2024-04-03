import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';
import 'package:flutter/material.dart';

class Piece extends StatelessWidget {
  const Piece({
    super.key,
    required this.piece,
    required this.constraints,
    required this.isRotated,
  });

  final ChessPieces? piece;
  final BoxConstraints constraints;
  final bool isRotated;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.5),
      child: SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxWidth,
        child: RotatedBox(
            quarterTurns: !isRotated ? 0 : 2,
            child: Image.asset(
              piece!.isWhite
                  ? 'assets/images/white_${getImagePieces(piece!)}.png'
                  : 'assets/images/black_${getImagePieces(piece!)}.png',
              fit: BoxFit.fill,
            )),
      ),
    );
  }
}
