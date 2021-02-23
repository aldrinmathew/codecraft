import 'package:get/state_manager.dart';

class GlobalController extends GetxController {
  RxString globalTime = ''.obs;
  RxInt globalFontSize = 15.obs;
  RxString displayFont = "FiraCode".obs;
  RxBool symbolAutoComplete = true.obs;
}