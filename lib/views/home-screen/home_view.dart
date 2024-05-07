// ignore: file_names
import 'package:chess_flutter_app/common/styles/spacing_style.dart';
import 'package:chess_flutter_app/utils/constants/sizes.dart';
import 'package:chess_flutter_app/views/home-screen/screens/chosse-ai-difficulty/ai_diffculty_view.dart';
import 'package:chess_flutter_app/views/home-screen/screens/pass-and-play/pass_and_play_view.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: TSpacingStyle.paddingWithAppBarHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chess',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            // Button game-play
            Padding(
              padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwSections),
              child: Column(
                children: [
                  // VS Computer
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Get.to(const AiDifficultyView()),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/vs-ai.png',
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems),
                          Text(
                            'vs Computer',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: TSizes.spaceBtwItems),
                  // Custom Game
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/custom-game.png',
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems),
                          Text(
                            'Custom game',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  // pass-and-play
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Get.to(const PassAndPlayView()),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/pass-and-play.png',
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems),
                          Text(
                            'Pass and Play',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections * 2),

                  // Start Game Button
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton(
                  //     onPressed: () {},
                  //     child: Text(
                  //       'Start Game',
                  //       style: Theme.of(context).textTheme.headlineSmall,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
