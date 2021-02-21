import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class ColorController extends GetxController {
  Color bgColorDefault = Color.fromRGBO(235, 235, 235, 1);
  Rx<Color> bgColor = Color.fromRGBO(235, 235, 235, 1).obs;
  Color bgColorContrastDefault = Color.fromRGBO(50, 50, 50, 1);
  Rx<Color> bgColorContrast = Color.fromRGBO(50, 50, 50, 1).obs;
  Color appStyleColor = Colors.blue;
  Color appAltColor = Colors.green;
  RxBool isDarkMode = false.obs;
  void darkModeChanger() {
    if(isDarkMode.value) {
      bgColor.value = bgColorDefault;
      bgColorContrast.value = bgColorContrastDefault;
    } else {
      bgColor.value = bgColorContrastDefault;
      bgColorContrast.value = bgColorDefault;
    }
    isDarkMode.value = !(isDarkMode.value);
  }
}