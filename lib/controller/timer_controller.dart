import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TimerController extends GetxController {
  RxBool isRunning = false.obs;
  double timerWhiteTime = 0.0;
  double timerBlackTime = 0.0;
  RxString timesWhite = '00.00'.obs;
  RxString timesBlack = '00.00'.obs;
  Timer? _timerWhite;
  Timer? _timerBlack;
  Timer? _timer;

  void setStringTime(RxString timerString, double timerCountdown) {
    int minutes = timerCountdown ~/ 60;
    int seconds = (timerCountdown % 60).toInt();

    double decimalPart = timerCountdown - timerCountdown.truncate();

    int decimalDigit = (decimalPart * 10).truncate();
    if (decimalDigit == 0 && timerCountdown > 20.0) {
      timerString.value =
          "${minutes.toString().padLeft(1, "0")}:${seconds.toString().padLeft(2, "0")}";
    }
    if (timerWhiteTime < 20.0) {
      timerString.value =
          "${minutes.toString().padLeft(1, "0")}:${seconds.toString().padLeft(2, "0")}.${decimalDigit.toString()}";
    }
    // timerCountdown.value -= 0.1;
  }

  void setClock(double time) {
    timerWhiteTime = time;
    timerBlackTime = time;
    int minutes = timerWhiteTime ~/ 60;
    int seconds = (timerWhiteTime % 60).toInt();
    timesWhite.value =
        "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";

    minutes = timerBlackTime ~/ 60;
    seconds = (timerBlackTime % 60).toInt();
    timesBlack.value =
        "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";

    stopWhiteTimer();
    stopBlackTimer();
  }

  // void startTimer(BuildContext context, bool isWhiteTurn) {
  //   _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
  //     if (isWhiteTurn) {
  //       setStringTime(timesWhite, timerWhiteTime);
  //       timerWhiteTime -= 0.1;
  //     } else {
  //       setStringTime(timesBlack, timerBlackTime);
  //       timerBlackTime -= 0.1;
  //     }
  //     if (isZero(timerWhiteTime)) {
  //       timer.cancel();
  //       showDiaLog(context, false);
  //     }
  //     if (isZero(timerBlackTime)) {
  //       timer.cancel();
  //       showDiaLog(context, true);
  //     }
  //   });
  // }

  // Khởi động đồng hồ đếm ngược
  void startWhiteTimer(BuildContext context, bool isOver) {
    _timerWhite = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (isZero(timerWhiteTime)) {
        _timerBlack?.cancel();
        _timerWhite?.cancel();
        showDiaLog(context, false);
        isOver = true;
        return;
      }
      setStringTime(timesWhite, timerWhiteTime);
      timerWhiteTime -= 0.1;
    });
  }

  // Khởi động đồng hồ đếm ngược
  void startBlackTimer(BuildContext context, bool isOver) {
    _timerBlack = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (isZero(timerBlackTime)) {
        _timerBlack?.cancel();
        _timerWhite?.cancel();
        showDiaLog(context, true);
        isOver = true;
        return;
      }
      setStringTime(timesBlack, timerBlackTime);
      timerBlackTime -= 0.1;
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
    // isWhiteRun = false;
  }

  void stopBlackTimer() {
    _timerBlack?.cancel();
    // isBlackRun = false;
  }

  // Thiết lập lại đồng hồ đếm ngược
  void resetTimer(double value) {
    stopWhiteTimer();
    stopBlackTimer();
    // stopTimer();
    timerWhiteTime = value;
    timerBlackTime = value;
  }
}
