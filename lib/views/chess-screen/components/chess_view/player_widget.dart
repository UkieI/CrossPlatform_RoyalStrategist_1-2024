import 'package:chess_flutter_app/utils/constants/colors.dart';
import 'package:chess_flutter_app/utils/constants/sizes.dart';
import 'package:chess_flutter_app/views/chess-screen/components/chess_view/board_dead_piece.dart';
import 'package:flutter/material.dart';

class PlayerContainer extends StatelessWidget {
  const PlayerContainer({
    super.key,
    required this.isWhite,
    required this.playerName,
    required this.image,
    required this.timer,
    required this.isClock,
    required this.theme,
  });

  final bool isWhite;
  final Text playerName;
  final Image image;
  final Widget timer;
  final bool isClock;
  final String theme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // color: isWhite ? Colors.red : Colors.amber,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image Player 2
          const SizedBox(width: TSizes.iconXs),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: TColors.dragTargetColors,
              ),
            ),
            child: image,
          ),
          const SizedBox(width: TSizes.sm),
          // const SizedBox(width: TSizes.defaultSpace / 2),
          // Name Player
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: TSizes.md),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: playerName,
                ),
                Center(child: BoardDeadPieces(isWhitePlayer: isWhite, theme: theme)),
              ],
            ),
          ),
          const SizedBox(width: TSizes.sm),
          if (isClock) timer,
          if (!isClock) const SizedBox(height: 40, width: 100),
          const SizedBox(width: TSizes.iconXs),
        ],
      ),
    );
  }

  // Function to format duration into minutes and seconds
}
