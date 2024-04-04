import 'package:chess_flutter_app/features/chess_board/models/chess_pieces.dart';
import 'package:chess_flutter_app/utils/constants/colors.dart';
import 'package:chess_flutter_app/utils/helpers/chess_functions.dart';
import 'package:flutter/material.dart';

class SquarePromotion extends StatelessWidget {
  const SquarePromotion({
    super.key,
    required this.isWhite,
    this.onTap,
    this.piece,
  });
  final bool isWhite;

  final ChessPieces? piece;
  final void Function()? onTap;

  Widget _chessPiecesIcon() {
    return piece != null
        ? Image.asset(piece!.isWhite
            ? 'assets/images/white_${getNamePieces(piece!)}.png'
            : 'assets/images/black_${getNamePieces(piece!)}.png')
        : const Center(child: SizedBox());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onPanCancel: onTap,
      child: Container(
        color: TColors.fgGreenThemeColor,
        child: _chessPiecesIcon(),
      ),
    );
  }
}
