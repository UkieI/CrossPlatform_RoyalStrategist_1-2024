import 'package:chess_flutter_app/logic/helpers/board_helpers.dart';
import 'package:chess_flutter_app/model/game_mode.dart';
import 'package:chess_flutter_app/utils/constants/colors.dart';
import 'package:chess_flutter_app/utils/constants/sizes.dart';
import 'package:chess_flutter_app/views/chess-screen/chess_view.dart';
import 'package:chess_flutter_app/views/home-screen/screens/pass-and-play/custom_board_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PassAndPlayView extends StatelessWidget {
  const PassAndPlayView({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(PassAndPlayController());
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: TSizes.appBarHeight,
        backgroundColor: TColors.black,
        title: Text(
          'Pass and Play',
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
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: SettingModePassAndPlay(controller: controller),
              ),
            ),
            // Board Rotated
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    GameMode mode = await controller.initGameBoard(GameMode.PassAndPlayMode);
                    Get.to(ChessView(mode: mode));
                  },
                  child: Text(
                    'Play',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingModePassAndPlay extends StatelessWidget {
  const SettingModePassAndPlay({
    super.key,
    required this.controller,
  });
  final PassAndPlayController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: TSizes.xl),
          child: SizedBox(
            height: TSizes.appBarHeight,
            width: double.infinity,
            child: Image.asset(
              'assets/images/pass-and-play.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        // Headline
        Text(
          'Play with a friend offline',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        Container(
          color: TColors.backgroundButtonColor,
          height: TSizes.buttonPassSize,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: TSizes.sm, horizontal: TSizes.md),
            child: Row(
              children: [
                Text(
                  'White',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      controller.blackInput.value = value;
                    },
                    controller: TextEditingController(text: "Player 1"),
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                )
              ],
            ),
          ),
        ),
        Container(
          color: TColors.backgroundButtonColor,
          height: TSizes.buttonPassSize,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: TSizes.sm, horizontal: TSizes.md),
            child: Row(
              children: [
                Text(
                  'Black',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      controller.blackInput.value = value;
                    },
                    controller: TextEditingController(text: "Player 2"),
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                )
              ],
            ),
          ),
        ),
        Obx(
          () => ExpansionPanelList(
            expandedHeaderPadding: const EdgeInsets.all(0),
            materialGapSize: 0,
            dividerColor: TColors.backgroundButtonColor,
            children: [
              ExpansionPanel(
                isExpanded: controller.isOpen[0].value,
                headerBuilder: (context, isExpanded) {
                  return SizedBox(
                    height: TSizes.buttonPassSize,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: TSizes.sm, horizontal: TSizes.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Type',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Obx(
                            () => Text(
                              controller.typeGame.value,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.symmetric(vertical: TSizes.sm, horizontal: TSizes.md),
                  child: Row(
                    children: [
                      for (int i = 0; i < 3; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: TSizes.xs, horizontal: TSizes.xs),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(12)),
                              child: Container(
                                color: i == controller.indexTypeGame.value ? TColors.wNeoThemeColor : null,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    controller.selectedTypeGame(i);
                                    if (i == 2) {
                                      GameMode mode = await controller.initGameBoard(GameMode.CustomBoardMode);
                                      Get.to(ChessCustomView(mode: mode));
                                    }
                                  },
                                  child: Text(
                                    controller.typeGameString[i]!,
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              ExpansionPanel(
                isExpanded: controller.isOpen[1].value,
                headerBuilder: (context, isExpanded) {
                  return SizedBox(
                    height: TSizes.buttonPassSize,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: TSizes.sm, horizontal: TSizes.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Time Control',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Obx(
                            () => Text(
                              controller.timeGame.value,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
                  child: Column(
                    children: [
                      for (int i = 0; i < 4; i++)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (int j = 0; j < 3; j++)
                              if (controller.timeControlString.containsKey(i * 3 + j))
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      child: Container(
                                        color: i * 3 + j == controller.indexTimeGame.value ? TColors.wNeoThemeColor : null,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            controller.selectedTimeGame(i * 3 + j);
                                          },
                                          child: Text(
                                            controller.timeControlString[i * 3 + j]!,
                                            style: Theme.of(context).textTheme.titleSmall,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                          ],
                        )
                    ],
                  ),
                ),
              ),
            ],
            expansionCallback: (panelIndex, isExpanded) => controller.setOpen(panelIndex),
          ),
        ),

        // Board Rotated
      ],
    );
  }
}

class PassAndPlayController extends GetxController {
  List<RxBool> isOpen = [
    false.obs,
    false.obs,
    false.obs,
  ];

  RxString whiteInput = "Player 1".obs;
  RxString blackInput = "Player 2".obs;
  RxString typeGame = "Standard".obs;
  RxString timeGame = "None".obs;
  RxInt indexTypeGame = 0.obs;
  RxInt indexTimeGame = 9.obs;
  @override
  void onInit() async {
    super.onInit();
    SharedPreferences pref = await SharedPreferences.getInstance();
    indexTypeGame.value = pref.getInt("previousTypeMode") == null ? 0 : pref.getInt("previousTypeMode")!;
    indexTimeGame.value = pref.getInt("previousTimeMode") == null ? 9 : pref.getInt("previousTimeMode")!;
    typeGame.value = typeGameString[indexTypeGame.value]!;
    timeGame.value = timeControlString[indexTimeGame.value]!;
  }

  Map<int, String> typeGameString = {
    0: "Standard",
    1: "Chess960",
    2: "Custom",
  };

  Map<int, String> timeControlString = {
    0: "30 min",
    1: "15 | 10",
    2: "10 min",
    3: "5 | 5",
    4: "3 | 2",
    5: "2 | 1",
    6: "5 min",
    7: "3 min",
    8: "1 min",
    9: "None",
  };

  setOpen(int index) {
    isOpen[index].value = !isOpen[index].value;
  }

  selectedTypeGame(int index) {
    indexTypeGame.value = index;
    typeGame.value = typeGameString[index]!;
  }

  selectedTimeGame(int index) {
    indexTimeGame.value = index;
    timeGame.value = timeControlString[index]!;
  }

  Future<GameMode> initGameBoard(int modeFlag) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    // pref.setString('themePiece', '');
    String theme, wSquare = '', bSquare = '';
    double timer = 0, bonusTime = 0;
    var timeString = List.of(timeGame.value.split(" "));

    // Init Timer
    if (timeString.length == 1) {
      timer = 0;
    } else if (timeString.length == 2) {
      timer = double.parse(timeString[0]) * 60;
    } else if (timeString.length == 3) {
      timer = double.parse(timeString[0]) * 60;
      bonusTime = double.parse(timeString[2]);
    }

    // initString
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
    String? fenString = pref.getString('customFen');
    fenString ??= BoardHelper.INIT_FEN;

    GameMode mode = GameMode(
      modeFlags: modeFlag,
      pieceTheme: theme,
      wSquares: wSquare,
      bSquares: bSquare,
      startingSide: GameMode.WhiteSide,
      timer: timer,
      bonusTime: bonusTime,
      customFen: indexTypeGame.value == GameMode.CustomBoardMode ? fenString : "",
    );

    pref.setInt("previousTypeMode", indexTypeGame.value);
    pref.setInt("previousTimeMode", indexTimeGame.value);
    return mode;
  }
}
