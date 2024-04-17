import 'package:chess_flutter_app/views/chess_view.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      // title: TTexts.appName,
      // themeMode: ThemeMode.system,
      // theme: TAppTheme.lightTheme,
      // darkTheme: TAppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: ChessView(
        setTimer: 0,
      ),
    );
  }
}
