import 'package:chess_flutter_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class ButtonNavigation extends StatelessWidget {
  const ButtonNavigation({
    super.key,
    required this.icon,
    required this.text,
    this.onPressed,
  });

  final Icon icon;
  final Text text;

  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [icon, const SizedBox(height: TSizes.sm), text],
      ),
    );
  }
}
