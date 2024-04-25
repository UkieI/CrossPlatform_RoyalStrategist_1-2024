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
  });

  final bool isWhite;
  final Text playerName;
  final Image image;
  final Widget timer;
  final bool isClock;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 35),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Image Player 2
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: TColors.dragTargetColors,
                ),
              ),
              child: image,
            ),

            const SizedBox(width: TSizes.defaultSpace / 2),
            // // Name Player
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [playerName, BoardDeadPieces(isWhitePlayer: isWhite)],
              ),
            ),
            if (isClock) timer,
          ],
        ),
      ),
    );
  }

  // Function to format duration into minutes and seconds
}
