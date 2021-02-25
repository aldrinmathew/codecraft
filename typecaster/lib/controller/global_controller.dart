import 'package:get/state_manager.dart';

class GlobalController extends GetxController {
  RxString globalTime = ''.obs;
  RxDouble globalFontSize = 12.0.obs;
  RxString displayFont = "FiraCode".obs;
  RxBool symbolAutoComplete = true.obs;
}