import 'package:chess_flutter_app/common/styles/spacing_style.dart';
import 'package:chess_flutter_app/utils/constants/sizes.dart';
import 'package:chess_flutter_app/utils/constants/text_strings.dart';
import 'package:chess_flutter_app/views/chess-screen/chess_view.dart';
import 'package:chess_flutter_app/views/home-screen/components/bottom-navigation-home.dart';

import 'package:flutter/material.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: TSpacingStyle.paddingWithAppBarHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child: Column(
              children: [
                const SizedBox(height: TSizes.spaceBtwSections / 2),
                Center(child: Text('Settings', style: Theme.of(context).textTheme.displayMedium)),
                const SizedBox(height: TSizes.spaceBtwSections),
                // App Theme

                // Piece Theme

                // show hint move

                // show move history

                // sound enabled
              ],
            )),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Back',
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
