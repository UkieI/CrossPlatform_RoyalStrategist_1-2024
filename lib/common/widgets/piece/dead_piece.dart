import 'package:chess_flutter_app/common/widgets/piece/image_seleced.dart';
import 'package:chess_flutter_app/logic/board/piece.dart';

import 'package:flutter/material.dart';

class DeadPieces extends StatelessWidget {
  const DeadPieces({super.key, required this.piece, required this.value, required this.theme});

  final int piece;
  final String theme;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (piece != Piece.None)
          SelectPieces(
            piece: piece,
            isRotated: 0,
            theme: theme,
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
