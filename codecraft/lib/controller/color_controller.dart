import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class ColorController extends GetxController {
  Color _defaultMain = Color.fromRGBO(40, 40, 40, 1);
  Color get main => (_darkMode.value) ? (_defaultMain) : (_defaultContrast);

  Color _defaultContrast = Color.fromRGBO(235, 235, 235, 1);
  Color get contrast => (_darkMode.value) ? (_defaultContrast) : (_defaultMain);

  Color _style = Colors.green;
  Color get style => _style;

  MaterialColor materialColor = Colors.green;

  Color _alternative = Colors.blue;
  Color get alternative => _alternative;

  Color get light => _defaultContrast;
  Color get dark => _defaultMain;

  Color get extremeMain => (_darkMode.value) ? (black) : (white);
  Color get extremeContrast => (_darkMode.value) ? (white) : (black);
  
  Color get white => Colors.white;
  Color get black => Colors.black;

  RxBool _darkMode = true.obs;
  bool get isDarkMode => _darkMode.value;
  bool get isLightMode => !(_darkMode.value);

  T chooser<T>({required T darkMode, required T lightMode}) {
    if (_darkMode.value) {
      return darkMode;
    } else {
      return lightMode;
    }
  }

  void darkModeChanger() {
    _darkMode.value = !(_darkMode.value);
  }

  FontWeight get fontWeight => (_darkMode.value) ? FontWeight.normal : FontWeight.w500;
}
