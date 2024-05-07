import 'package:chess_flutter_app/common/widgets/navigation/navigation_button/navigation_button.dart';
import 'package:chess_flutter_app/common/widgets/navigation/navigation_menu.dart';
import 'package:chess_flutter_app/controller/chess_board_controller.dart';
import 'package:chess_flutter_app/controller/custom_board_controller.dart';

import 'package:chess_flutter_app/views/chess-screen/components/chess_view/dialog_options.dart';
import 'package:chess_flutter_app/views/home-screen/screens/pass-and-play/pop_up_diaglog_custom_board.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class BottomNavigationCustomBoard extends StatelessWidget {
  const BottomNavigationCustomBoard({
    super.key,
    required this.chessController,
  });

  final CustomChessBoardController chessController;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationChess(
      dark: true,
      children: [
        ButtonNavigation(
            icon: const Icon(Iconsax.menu_1, color: Colors.white54),
            text: const Text(
              'Optional',
              style: TextStyle(color: Colors.white54),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return PopUpDialogOptionsCustomBoard(chessController: chessController);
                },
              );
            }),
        ButtonNavigation(
          icon: const Icon(Iconsax.refresh, color: Colors.white54),
          text: const Text('Flip', style: TextStyle(color: Colors.white54)),
          onPressed: () {
            chessController.isRotated.value = !chessController.isRotated.value;
          },
        ),
        ButtonNavigation(
          icon: const Icon(Iconsax.archive_tick, color: Colors.white54),
          text: const Text('Ok', style: TextStyle(color: Colors.white54)),
          onPressed: () {
            chessController.storeFen();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
