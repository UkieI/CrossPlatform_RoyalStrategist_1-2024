import 'dart:math';

import 'package:chess_flutter_app/common/styles/spacing_style.dart';
import 'package:chess_flutter_app/model/game_mode.dart';
import 'package:chess_flutter_app/utils/constants/colors.dart';
import 'package:chess_flutter_app/utils/constants/sizes.dart';
import 'package:chess_flutter_app/views/chess-screen/chess_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiDifficultyView extends StatelessWidget {
  const AiDifficultyView({super.key});

  @override
  Widget build(BuildContext context) {
    AiDifficultyController controller = Get.put(AiDifficultyController());
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: TSizes.appBarHeight,
        backgroundColor: TColors.black,
        title: Text(
          'Play vs Computer',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Iconsax.arrow_left_2,
            color: Colors.white54,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: TSpacingStyle.paddingWithAppBarHeight,
        child: Column(
          children: [
            // Time
            DiffcultyChooser(controller: controller),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  GameMode mode = await controller.initGameBoard();
                  Get.to(ChessView(mode: mode));
                },
                child: Text(
                  'Play!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AiDifficultyController extends GetxController {
  Rx<int> selectedDifficultyIndex = 0.obs;
  Rx<int> selectedSideIndex = 0.obs;
  Rx<int> selectedModeIndex = (-1).obs;
  double timer = 0;
  double bonusTime = 0;

  @override
  void onInit() async {
    super.onInit();
    SharedPreferences pref = await SharedPreferences.getInstance();
    int? aiDiff = pref.getInt('aiDifficulty');
    if (aiDiff == null) {
      // If no theme preference is found, default to 'd' theme and save it
      pref.setInt('aiDifficulty', 0);
    } else {
      selectedDifficultyIndex.value = aiDiff;
    }
  }

  Map<int, String> mapSide = {
    0: "assets/images/neo-wK.png",
    1: "assets/images/neo-bK.png",
    2: "assets/images/random-side.png",
  };

  Map<int, String> mapNameMode = {
    0: "Challenge",
    1: "Frienly",
    2: "Custom",
  };

  Map<int, String> mapSubDesMode = {
    0: "No help of any kind",
    1: "Hint and undo redo allowed",
    2: "Chossing setting you want",
  };

  selectDifficulty(int difficulty) {
    selectedDifficultyIndex.value = difficulty;
  }

  selectSide(int side) {
    selectedSideIndex.value = side;
  }

  selectMode(int mode) {
    selectedModeIndex.value = mode;
  }

  int startingSide() {
    if (selectedSideIndex.value == GameMode.RandomSide) return Random().nextInt(2);
    return selectedSideIndex.value;
  }

  Future<GameMode> initGameBoard() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String theme, wSquare = '', bSquare = '';
    String? themeString = pref.getString('themePiece');
    if (themeString == null) {
      // If no theme preference is found, default to 'd' theme and save it
      theme = 'd';
      await pref.setString('themePiece', 'd');
    } else {
      theme = themeString;
      wSquare = pref.getString('wSquare')!;
      bSquare = pref.getString('bSquare')!;
    }

    GameMode mode = GameMode(
      modeFlags: GameMode.VsAiMode,
      pieceTheme: theme,
      wSquares: wSquare,
      bSquares: bSquare,
      aiDiffcullty: selectedDifficultyIndex.value + 1,
      startingSide: startingSide(),
    );

    pref.setInt('aiDifficulty', selectedDifficultyIndex.value);
    return mode;
  }
}

class DiffcultyChooser extends StatelessWidget {
  const DiffcultyChooser({
    super.key,
    required this.controller,
  });

  final AiDifficultyController controller;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          // AI difficulty
          Text('AI Difficulty', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: TSizes.spaceBtwItems),
          Obx(
            () => ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: TSizes.appBarHeight,
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: TColors.appBarLowColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 0; i < 6; i++)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.selectDifficulty(i),
                          child: Container(
                            decoration: BoxDecoration(
                              // border: Border.all(width: 1, color: TColors.appBarLowColor),
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(15), right: Radius.circular(15)),
                              color: i == controller.selectedDifficultyIndex.value ? TColors.wNeoThemeColor : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              (i + 1).toString(),
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwSections),

          // Chose who go first (black and white)
          Text('Play as side ', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: TSizes.spaceBtwItems),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < 3; i++)
                  GestureDetector(
                    onTap: () => controller.selectSide(i),
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: TColors.appBarLowColor),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(15), right: Radius.circular(15)),
                        color: i == controller.selectedSideIndex.value ? TColors.wNeoThemeColor : null,
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(TSizes.xs),
                        child: Image.asset(controller.mapSide[i]!),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Difficulty level (Challeage, Frienly, Custom)
          const SizedBox(height: TSizes.spaceBtwSections),
          Text('MODE', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: TSizes.spaceBtwItems),

          for (int i = 0; i < 3; i++)
            Obx(
              () => Padding(
                padding: const EdgeInsets.only(bottom: TSizes.md),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: i == controller.selectedModeIndex.value ? TColors.wNeoThemeColor : TColors.appBarLowColor),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(20), right: Radius.circular(20)),
                    // color: i == controller.selectedModeIndex.value ? TColors.wNeoThemeColor : null,
                  ),
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => controller.selectedModeIndex(i),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // const Icon(Iconsax.timer_1, color: TColors.appBarSelectColor),
                        // const SizedBox(width: TSizes.spaceBtwItems),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.mapNameMode[i]!,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: TSizes.spaceBtwInputFields / 3),
                              Text(
                                controller.mapSubDesMode[i]!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),

                        for (int j = 3; j > 0; j--) j - i > 0 ? const Icon(Iconsax.crown5, color: Colors.yellow) : const Icon(Iconsax.crown_14, color: TColors.appBarLowColor),
                      ],
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}


              // SizedBox(
              //   width: double.infinity,
              //   child: OutlinedButton(
              //     onPressed: () {},
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         const Icon(Iconsax.timer_1, color: TColors.appBarSelectColor),
              //         const SizedBox(width: TSizes.spaceBtwItems),
              //         Expanded(
              //           child: Center(
              //             child: Text(
              //               '10 : 00',
              //               style: Theme.of(context).textTheme.headlineSmall,
              //             ),
              //           ),
              //         ),
              //         const Icon(Iconsax.arrow_right_3, color: TColors.appBarLowColor),
              //       ],
              //     ),
              //   ),
              // ),