import 'package:chess_flutter_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  const Square({super.key, required this.isWhite});
  final bool isWhite;
  @override
  Widget build(BuildContext context) {
    Color? squareColor;
    squareColor =
        isWhite ? TColors.bgGreenThemeColor : TColors.fgGreenThemeColor;
    return Container(
      color: squareColor,
    );
  }
}
