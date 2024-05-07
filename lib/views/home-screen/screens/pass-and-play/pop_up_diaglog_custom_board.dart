import 'package:chess_flutter_app/controller/chess_board_controller.dart';
import 'package:chess_flutter_app/controller/custom_board_controller.dart';
import 'package:chess_flutter_app/logic/board/board.dart';
import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';
import 'package:chess_flutter_app/utils/constants/colors.dart';

import 'package:chess_flutter_app/utils/constants/sizes.dart';
import 'package:chess_flutter_app/utils/constants/text_strings.dart';
import 'package:chess_flutter_app/views/home-screen/components/custom_board.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';

class PopUpDialogOptionsCustomBoard extends StatelessWidget {
  const PopUpDialogOptionsCustomBoard({
    super.key,
    required this.chessController,
  });

  final CustomChessBoardController chessController;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TSizes.sm,
          vertical: TSizes.xs,
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: TSizes.spaceBtwItems),
              // Flip Board
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  chessController.resetGame(BoardHelper.INIT_FEN);
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Reset Board',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              // Copy as PNG
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  chessController.resetGame(BoardHelper.EMPTY_FEN);
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Clear Board',
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
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DiaglogInputFen(chessController: chessController);
                    },
                  );
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Import FEN',
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

class DiaglogInputFen extends StatelessWidget {
  const DiaglogInputFen({super.key, required this.chessController});
  final CustomChessBoardController chessController;

  bool isValidFen(String fen) {
    var splitFen = fen.split(" ");
    chessController.isWhiteMove.value = splitFen[1].contains('w') ? true : false;
    return BoardHelper.regexBoardCheck.hasMatch(splitFen[0]) &&
        BoardHelper.regexMoveCheck.hasMatch(splitFen[1]) &&
        BoardHelper.regexCastlingRightCheck.hasMatch(splitFen[2]) &&
        BoardHelper.regexEnPassantCheck.hasMatch(splitFen[3]) &&
        BoardHelper.regexNoCaptureOrPawnMoveCheck.hasMatch(splitFen[4]) &&
        BoardHelper.regexNoCaptureOrPawnMoveCheck.hasMatch(splitFen[5]);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TSizes.xl,
            vertical: TSizes.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                'Import FEN',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              TextFormField(
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TSizes.sm),
                    borderSide: const BorderSide(
                      color: TColors.backgroundColor,
                      width: 2.0,
                    ),
                  ),
                  labelText: 'FEN',
                ),
                onChanged: (value) {
                  // print("press");
                  chessController.inputFen = value;
                },
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    if (isValidFen(chessController.inputFen)) {
                      Fluttertoast.showToast(
                        msg: "Input FEN successfully",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.SNACKBAR,
                        timeInSecForIosWeb: 1,
                        backgroundColor: TColors.wNeoThemeColor,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      Navigator.pop(context);
                      chessController.resetGame(chessController.inputFen);
                      chessController.justInputFen = true;
                    } else {
                      Fluttertoast.showToast(
                        msg: "Invalid FEN string!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.SNACKBAR,
                        timeInSecForIosWeb: 1,
                        backgroundColor: TColors.backgroundApp,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: TColors.wNeoThemeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
