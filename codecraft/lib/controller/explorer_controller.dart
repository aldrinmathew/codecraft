import 'dart:io';

import 'package:codecraft/main.dart';
import 'package:get/state_manager.dart';

class ExplorerController extends GetxController {
  RxString path = ''.obs;
  List<String> previousDirectories = [];
  Rx<Directory> explorerDirectory = directory.obs;
  List<Map<String, String>> contents = [];
  RxInt selectedContent = 0.obs;
  RxInt rowContentCount = 7.obs;
  RxInt historyIndex = 0.obs;
  List<Map<String, dynamic>> history = [
    {
      'path': Directory.current.path,
      'selection': -1,
    }
  ];
}
