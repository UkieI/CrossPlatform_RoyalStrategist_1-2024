import 'package:chess_flutter_app/features/chess_board/views/game_board/game_board.dart';
import 'package:chess_flutter_app/utils/constants/text_strings.dart';
import 'package:chess_flutter_app/utils/theme/theme.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: TTexts.appName,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const GameScreens(
        isRotated: false,
        time: 25,
      ),
      // home: Scaffold(
      //   body: DragableWidget(),
      // ),
    );
  }
}
