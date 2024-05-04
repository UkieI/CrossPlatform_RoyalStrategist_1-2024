import 'package:chess_flutter_app/controller/chess_board_controller.dart';

import 'package:chess_flutter_app/utils/constants/sizes.dart';
import 'package:chess_flutter_app/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';

class PopUpDialogOptions extends StatelessWidget {
  const PopUpDialogOptions({
    super.key,
    required this.chessController,
  });

  final ChessBoardController chessController;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 500,
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: TSizes.spaceBtwItems),
              // Flip Board
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  chessController.quarterTurns();
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      TTexts.flipBoard,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              // Copy as PNG
              TextButton(
                onPressed: () {},
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      TTexts.copyAsPNG,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              // New Game
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  chessController.resetGame();
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      TTexts.newGame,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
            ],
          ),
        ),
      ),
    );
  }
}
