import 'package:get/state_manager.dart';

class EditController extends GetxController {
  RxDouble fontSize = 14.0.obs;
  RxDouble editFontSize = 25.0.obs;
  RxBool editMode = false.obs;
  RxString cacheText = ''.obs;
  RxInt activeFile = 0.obs;
  RxString editModeTime = ''.obs;
  RxInt tabSpace = 4.obs;
  RxString endOfLine = 'LF'.obs;
  RxInt characterChange = 0.obs;
  List<Map<String, dynamic>> fileList = [
    {
      'fileID': 1,
      'fileName': 'Welcome',
      'extension': '',
      'activeLine': 0,
      'path': '',
      'endOfLine': 'system',
      'encoding': 'UTF-8',
      'onDisk': false,
      'saved': false,
      'syntax': '',
    },
  ];
  List<Map<String, List<String>>> fileContent = [
    {
      'content': [
        '',
      ],
    },
  ];
  RxDouble typingSpeed = 0.0.obs;
  RxInt wordCount = 0.obs;
  RxBool isAlphaNum = false.obs;
  RxInt characterCount = 0.obs;
  RxInt errorCount = 0.obs;

  String get activeLine => fileContent[activeFile.value]['content']![fileList[activeFile.value]['activeLine']];
  set activeLine(String value) {
    fileContent[activeFile.value]['content']![fileList[activeFile.value]['activeLine']] = value;
  }
  
  int get activeLineIndex => fileList[activeFile.value]['activeLine'];
  set activeLineIndex(int value) {
    fileList[activeFile.value]['activeLine'] = value;
  }
  
  List<String> get contentList => fileContent[activeFile.value]['content'] ?? [];
  set contentList(List<String> values) {
    fileContent[activeFile.value]['content'] = values;
  }
  
  int get lineCount => fileContent[activeFile.value]['content']!.length;
  
  void insertContent({required int index, required String content}) {
    fileContent[activeFile.value]['content']!.insert(index, content);
  }

}