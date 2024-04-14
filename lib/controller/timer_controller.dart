import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TimerController extends GetxController {
  RxBool isRunning = false.obs;
  RxDouble timerWhiteTime = (0.0).obs;
  RxDouble timerBlackTime = (0.0).obs;
  final timesWhite = '00.00'.obs;
  final timesBlack = '00.00'.obs;
  Timer? _timerWhite;
  Timer? _timerBlack;

  void setClock(double time) {
    timerWhiteTime.value = time;
    timerBlackTime.value = time;
    int minutes = timerWhiteTime.value ~/ 60;
    int seconds = (timerWhiteTime.value % 60).toInt();
    timesWhite.value =
        "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";

    minutes = timerBlackTime.value ~/ 60;
    seconds = (timerBlackTime.value % 60).toInt();
    timesBlack.value =
        "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";

    stopWhiteTimer();
    stopBlackTimer();
  }

  // Khởi động đồng hồ đếm ngược
  void startWhiteTimer(double seconds, BuildContext context, bool isOver) {
    _timerWhite = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (isZero(timerWhiteTime.value)) {
        _timerBlack?.cancel();
        _timerWhite?.cancel();
        showDiaLog(context, false);
        isOver = true;
        return;
      }

      int minutes = timerWhiteTime.value ~/ 60;
      int seconds = (timerWhiteTime.value % 60).toInt();
      double decimalPart =
          timerWhiteTime.value - timerWhiteTime.value.truncate();

      int decimalDigit = (decimalPart * 10).truncate();
      if (decimalDigit == 0 && timerWhiteTime.value > 20.0) {
        timesWhite.value =
            "${minutes.toString().padLeft(1, "0")}:${seconds.toString().padLeft(2, "0")}";
      }
      if (timerWhiteTime.value < 20.0) {
        timesWhite.value =
            "${minutes.toString().padLeft(1, "0")}:${seconds.toString().padLeft(2, "0")}.${decimalDigit.toString()}";
      }

      timerWhiteTime.value -= 0.1;
    });
  }

  // Khởi động đồng hồ đếm ngược
  void startBlackTimer(double seconds, BuildContext context, bool isOver) {
    _timerBlack = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (isZero(timerBlackTime.value)) {
        _timerBlack?.cancel();
        _timerWhite?.cancel();
        showDiaLog(context, true);
        isOver = true;
        return;
      }

      int minutes = timerBlackTime.value ~/ 60;
      int seconds = (timerBlackTime.value % 60).toInt();

      double decimalPart =
          timerBlackTime.value - timerBlackTime.value.truncate();

      int decimalDigit = (decimalPart * 10).truncate();

      if (decimalDigit == 0 && timerBlackTime.value > 20.0) {
        timesBlack.value =
            "${minutes.toString().padLeft(1, "0")}:${seconds.toString().padLeft(2, "0")}";
      }
      if (timerBlackTime.value < 20.0) {
        timesBlack.value =
            "${minutes.toString().padLeft(1, "0")}:${seconds.toString().padLeft(2, "0")}.${decimalDigit.toString()}";
      }
      timerBlackTime.value -= 0.1;
    });
  }

  bool isZero(double value, {double epsilon = 1e-10}) {
    return (value.abs() - 0.0).abs() < epsilon;
  }

  void showDiaLog(BuildContext context, bool isWhite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("CHECK MATE"),
        content: isWhite ? const Text("White Win") : const Text("Black Win"),
      ),
    );
  }

  // Dừng đồng hồ đếm ngược
  void stopWhiteTimer() {
    _timerWhite?.cancel();
    // isWhiteRun.value = false;
  }

  void stopBlackTimer() {
    _timerBlack?.cancel();
    // isBlackRun.value = false;
  }

  // Thiết lập lại đồng hồ đếm ngược
  void resetTimer(double value) {
    stopWhiteTimer();
    stopBlackTimer();
    // stopTimer();
    timerWhiteTime.value = value;
    timerBlackTime.value = value;
  }
}
