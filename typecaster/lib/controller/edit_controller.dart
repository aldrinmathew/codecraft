import 'package:get/state_manager.dart';

class EditController extends GetxController {
  RxDouble fontSize = 14.0.obs;
  RxDouble editFontSize = 25.0.obs;
  RxBool editMode = false.obs;
  RxString cacheText = ''.obs;
  RxInt activeFile = 0.obs;
  RxString editModeTime = ''.obs;
  List<Map<String, dynamic>> fileList = [
    {
      'fileID': 1,
      'fileName': 'Untitled 1',
      'activeLine': 0,
      'path': '',
      'saved': false,
    },
  ];
  List<Map<String, List<String>>> fileContent = [
    {
      'content': [
        '',
      ],
    },
  ];
}
