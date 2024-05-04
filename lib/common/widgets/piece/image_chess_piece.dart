import 'package:chess_flutter_app/common/widgets/piece/image_seleced.dart';

import 'package:flutter/widgets.dart';

class ImageChessPieceWidget extends StatelessWidget {
  const ImageChessPieceWidget(this.piece, this.constraints, this.isRotated, {super.key, required this.theme});

  final int piece;
  final String theme;
  final int isRotated;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: SelectPieces(
          piece: piece,
          isRotated: isRotated,
          theme: theme,
        ));
  }
}
