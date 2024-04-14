import 'package:chess_flutter_app/common/widgets/piece/image_seleced.dart';
import 'package:chess_flutter_app/utils/constants/colors.dart';

import 'package:flutter/material.dart';

class SquarePromotion extends StatelessWidget {
  const SquarePromotion({
    super.key,
    required this.isWhite,
    this.onTap,
    required this.piece,
  });
  final bool isWhite;

  final int piece;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onPanCancel: onTap,
      child: Container(
        color: TColors.fgGreenThemeColor,
        child: SelectPieces(piece: piece),
      ),
    );
  }
}
