import 'package:chess_flutter_app/utils/constants/colors.dart';
import 'package:chess_flutter_app/views/home-screen/home-view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavigationChess extends StatelessWidget {
  const BottomNavigationChess({
    super.key,
    required this.dark,
    required this.children,
  });

  final bool dark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 80,
      elevation: 0,
      backgroundColor: TColors.black,
      indicatorColor: TColors.white.withOpacity(0),
      surfaceTintColor: Colors.white,
      destinations: children,
    );
  }
}
