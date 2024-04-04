import 'package:chess_flutter_app/common/widgets/navigation/navigation_button/navigation_button.dart';
import 'package:chess_flutter_app/common/widgets/navigation/navigation_menu.dart';
import 'package:chess_flutter_app/features/chess_board/controller/chess_controller.dart';

import 'package:chess_flutter_app/features/chess_board/views/game_board/widgets/dialog_options.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class BottomNavigationGameScreen extends StatelessWidget {
  const BottomNavigationGameScreen({
    super.key,
    required this.dark,
    required this.chessController,
  });

  final bool dark;
  final ChessBoardController chessController;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationChess(
      dark: dark,
      children: [
        ButtonNavigation(
          icon: const Icon(Iconsax.task, color: Colors.white54),
          text: const Text(
            'Optional',
            style: TextStyle(color: Colors.white54),
          ),
          onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return PopUpDialogOptions(chessController: chessController);
              }),
        ),
        ButtonNavigation(
          icon: const Icon(Iconsax.add, color: Colors.white54),
          text: const Text('New', style: TextStyle(color: Colors.white54)),
          onPressed: () => chessController.resetGame(),
        ),
        ButtonNavigation(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white54),
          text: const Text('Back', style: TextStyle(color: Colors.white54)),
          onPressed: () {},
        ),
        ButtonNavigation(
          icon: const Icon(Iconsax.arrow_right_3, color: Colors.white54),
          text: const Text('Foward', style: TextStyle(color: Colors.white54)),
          onPressed: () {},
        ),
      ],
    );
  }
}
