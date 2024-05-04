import 'package:chess_flutter_app/utils/constants/colors.dart';
import 'package:chess_flutter_app/utils/constants/sizes.dart';
import 'package:chess_flutter_app/utils/helpers/helper_functions.dart';
import 'package:chess_flutter_app/views/home-screen/home_view.dart';
import 'package:chess_flutter_app/views/setting-screen/setting_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NavigationMenuHome extends StatelessWidget {
  const NavigationMenuHome({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    THelperFunctions.isDarkMode(context);
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: TSizes.appBottomBarHeight,
          elevation: 0,
          backgroundColor: TColors.dark,
          indicatorColor: TColors.white.withOpacity(0.0),
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) => controller.selectedIndex.value = index,
          destinations: [
            NavigationDestination(
              icon: Image.asset(
                'assets/images/d-bP.png',
                height: TSizes.xl,
                color: controller.isSelected(0),
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Image.asset(
                'assets/images/puzzles.png',
                height: TSizes.xl,
                color: controller.isSelected(1),
              ),
              label: 'Puzzles',
            ),
            NavigationDestination(
              icon: Icon(
                Iconsax.chart_15,
                color: controller.isSelected(2),
              ),
              label: 'Analysis',
            ),
            NavigationDestination(
              icon: Icon(
                Iconsax.menu_1,
                color: controller.isSelected(3),
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HomeView(),
    Container(color: TColors.backgroundApp),
    Container(color: TColors.backgroundApp),
    const SettingView(),
  ];

  Color isSelected(int value) {
    return selectedIndex.value == value ? TColors.appBarSelectColor : TColors.appBarLowColor;
  }
}
