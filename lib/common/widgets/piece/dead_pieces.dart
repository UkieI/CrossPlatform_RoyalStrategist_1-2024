import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';

import 'package:flutter/material.dart';

class DeadPieces extends StatelessWidget {
  const DeadPieces({super.key, required this.piece, required this.value});

  final ChessPieces? piece;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (piece != null)
          Image.asset(
            !piece!.isWhite
                ? 'assets/images/black_${getNamePieces(piece!)}.png'
                : 'assets/images/white_${getNamePieces(piece!)}.png',
          ),
        if (value != 1)
          Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                height: 15,
                width: 15,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: Center(
                  child: Text(
                    value.toString(),
                    style: const TextStyle(fontSize: 8),
                  ),
                ),
              ))
      ],
    );
  }
}
