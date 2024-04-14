import 'package:chess_flutter_app/logic/board/piece.dart';
import 'package:flutter/widgets.dart';

class ImageChessPieceWidget extends StatelessWidget {
  const ImageChessPieceWidget(this.piece, this.constraints, {super.key});

  final int piece;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: constraints.maxWidth,
      height: constraints.maxHeight,
      child: Image.asset(
        'assets/images/${Piece.isWhite(piece) ? 'w' : 'b'}${Piece.getSymbol(piece).toUpperCase()}.png',
        fit: BoxFit.fill,
      ),
    );
  }
}
