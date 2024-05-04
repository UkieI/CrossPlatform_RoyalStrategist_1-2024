import 'package:chess_flutter_app/common/styles/spacing_style.dart';
import 'package:chess_flutter_app/utils/constants/colors.dart';
import 'package:chess_flutter_app/utils/constants/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    SettingsController controller = Get.put(SettingsController());
    return Scaffold(
      body: Padding(
        padding: TSpacingStyle.paddingWithAppBarHeight,
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: TSizes.spaceBtwSections / 2),
            Center(child: Text('Settings', style: Theme.of(context).textTheme.displayMedium)),
            const SizedBox(height: TSizes.spaceBtwSections),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const ClampingScrollPhysics(),
                children: [
                  // App Theme
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Text('App Theme', style: Theme.of(context).textTheme.titleLarge),
                  ),
                  Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: Color(0x20000000),
                    ),
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: controller.nameTheme.length),
                      selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
                        background: Color(0x20000000),
                      ),
                      itemExtent: 50,
                      onSelectedItemChanged: (int value) => controller.selectSquareTheme(value),
                      children: [
                        for (int i = 0; i < controller.nameTheme.length; i++) Center(child: Text(controller.nameTheme[i]!, style: Theme.of(context).textTheme.headlineSmall)),
                      ],
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  // Piece Theme
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Text('Piece Theme', style: Theme.of(context).textTheme.titleLarge),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    child: Container(
                      height: 120,
                      decoration: const BoxDecoration(color: Color(0x20000000)),
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(
                                initialItem: controller.nameTheme.length,
                              ),
                              selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
                                background: Color(0x20000000),
                              ),
                              itemExtent: 50,
                              onSelectedItemChanged: (index) => controller.selectThemePieces(index),
                              children: [
                                for (int i = 0; i < controller.nameTheme.length; i++) Center(child: Text(controller.nameTheme[i]!, style: Theme.of(context).textTheme.headlineSmall)),
                              ],
                            ),
                          ),
                          Container(height: 120, width: 80, color: TColors.wNeoThemeColor, child: const Center(child: Text('Preview Picees'))),
                        ],
                      ),
                    ),
                  )
                  // show hint move

                  // show move history

                  // sound enabled
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  int pieceValue = controller.seclectedThemePieces.value;
                  int themeValue = controller.seclectedThemeApp.value;
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  pref.setString('themePiece', controller.appTheme[pieceValue]!);
                  var themeList = controller.squareTheme[themeValue]!.split(" ");
                  pref.setString('wSquare', themeList[0]);
                  pref.setString('bSquare', themeList[1]);
                  // pref.setString('backGroundColor', controller.appTheme[value]!);
                },
                child: Text(
                  'Save Theme',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsController extends GetxController {
  Map<int, String> appTheme = {
    0: "d",
    1: "wood",
    2: "neo",
    3: "glass",
    4: "gr",
  };

  Map<int, String> nameTheme = {
    0: "Default Theme",
    1: "Wood Theme",
    2: "Neo Theme",
    3: "Glass Theme",
    4: "Game Room",
  };

  Map<int, String> squareTheme = {
    0: "779954 e9edcc",
    1: "b88762 edd6b0",
    3: "282f3b 677081",
    2: "01a300 98c34e",
    4: "724924 c7a973",
  };

  RxInt seclectedThemePieces = 0.obs;
  RxInt seclectedThemeApp = 0.obs;

  selectThemePieces(int themePieces) {
    seclectedThemePieces.value = themePieces;
  }

  selectSquareTheme(int themeSquare) {
    seclectedThemeApp.value = themeSquare;
  }
}
