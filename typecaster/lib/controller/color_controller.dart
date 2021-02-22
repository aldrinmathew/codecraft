import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class ColorController extends GetxController {
  Color bgColorDefault = Color.fromRGBO(50, 50, 50, 1);
  Rx<Color> bgColor = Color.fromRGBO(50, 50, 50, 1).obs;
  Color bgColorContrastDefault = Color.fromRGBO(235, 235, 235, 1);
  Rx<Color> bgColorContrast = Color.fromRGBO(235, 235, 235, 1).obs;
  Rx<Color> contrastExtreme = Colors.black.obs;
  Color appStyleColor = Colors.blue;
  Color appAltColor = Colors.green;
  RxBool isDarkMode = true.obs;
  void darkModeChanger() {
    if(isDarkMode.value) {
      bgColor.value = bgColorContrastDefault;
      bgColorContrast.value = bgColorDefault;
      contrastExtreme.value = Colors.white;
    } else {
      bgColor.value = bgColorDefault;
      bgColorContrast.value = bgColorContrastDefault;
      contrastExtreme.value = Colors.black;
    }
    isDarkMode.value = !(isDarkMode.value);
  }
}