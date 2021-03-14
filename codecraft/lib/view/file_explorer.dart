import 'dart:io';

import 'package:codecraft/functions.dart';
import 'package:codecraft/main.dart';
import 'package:codecraft/controller/explorer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

FocusNode explorerFocusNode = FocusNode(
  canRequestFocus: true,
  descendantsAreFocusable: true,
);
FocusNode explorerPathFocusNode = FocusNode(canRequestFocus: true);
TextEditingController explorerPathController = TextEditingController(text: '');
ExplorerController explorerController = ExplorerController();
List<FileSystemEntity> contentList;

/*
  Thanks to Tim Whiting
  https://github.com/TimWhiting
  for demonstrating the use of Actions, Shortcuts and Intent
  in his Sample Code and his Test App that tested the use of
  Tab, Shift, Enter, Escape keys to navigate between various
  TextFields, Buttons and areas of the application.
*/

class NavigateBackIntent extends Intent {
  NavigateBackIntent();
}

class NavigateBackAction extends Action<NavigateBackIntent> {
  @override
  void invoke(covariant NavigateBackIntent intent) {
    Get.back();
  }
}

class FocusChangeIntent extends Intent {
  final int count;
  final bool focus;
  FocusChangeIntent({this.count, this.focus});
}

class FocusChangeAction extends Action<FocusChangeIntent> {
  @override
  void invoke(covariant FocusChangeIntent intent) {
    if (intent.focus) {
      explorerPathFocusNode.unfocus();
    }
    if ((explorerController.selectedContent.value + intent.count) >=
        explorerController.contents.length) {
      explorerController.selectedContent.value = explorerController.contents.length - 1;
    } else if ((explorerController.selectedContent.value + intent.count) <= -1) {
      if (intent.count == -1) {
        explorerController.selectedContent.value = -1;
        explorerPathFocusNode.requestFocus();
      } else {
        explorerController.selectedContent.value = 0;
      }
    } else {
      explorerController.selectedContent.value += intent.count;
      if (explorerController.selectedContent.value == 0) {
        explorerFocusNode.unfocus();
      }
    }
  }
}

class SelectContentIntent extends Intent {
  final String name;
  final String type;
  final String path;
  SelectContentIntent({this.name, this.type, this.path});
}

class SelectContentAction extends Action<SelectContentIntent> {
  @override
  void invoke(covariant SelectContentIntent intent) {
    if (intent.type == 'File') {
      String newPath;
      newPath = intent.path.substring(0, intent.path.length - intent.name.length);
      createNewFile(fileName: intent.name, filePath: newPath);
      editController.activeFile.value++;
      File openingFile = File(intent.path);
      openingFile.open(mode: FileMode.read);
      readFile(openingFile);
      textEditControl = TextEditingController(
          text: editController.fileContent[editController.activeFile.value]['content']
              [editController.fileList[editController.activeFile.value]['activeLine']]);
      Get.back();
    } else {
      folderContentSync(intent.path);
    }
  }
}

void folderContentSync(String currentPath) {
  explorerController.selectedContent.value = -1;
  explorerController.contents.clear();
  explorerController.path.value = currentPath;
  explorerController.eDirectory.value = Directory(explorerController.path.value);
  explorerPathController.text = explorerController.path.value;
  contentList = explorerController.eDirectory.value.listSync(recursive: false);
  for (int i = 0; i < contentList.length; i++) {
    FileSystemEntity element = contentList[i];
    String name = '';
    if (element.path.contains('/')) {
      name = element.path.split('/')[element.path.split('/').length - 1];
    }
    if (element.path.contains('\\')) {
      name = element.path.split('\\')[element.path.split('\\').length - 1];
    }
    if (element is File) {
      explorerController.contents.add({
        'name': name,
        'path': element.path,
        'type': 'File',
      });
    } else if (element is Directory) {
      explorerController.contents.add({
        'name': name,
        'path': element.path,
        'type': 'Folder',
      });
    }
  }
  explorerController.selectedContent.value = 0;
}

class FileExplorer extends StatelessWidget {
  FileExplorer() {
    if (explorerController.path.value == '') {
      explorerController.path.value = directory.path;
      explorerController.eDirectory.value = directory;
      explorerPathController.text = explorerController.path.value;
      explorerController.contents = directoryContents;
    } else {
      folderContentSync(explorerController.path.value);
    }
    explorerPathFocusNode.requestFocus();
    explorerController.selectedContent.value = -1;
  }
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: colorController.bgColor.value,
        body: Actions(
          actions: {
            NavigateBackIntent: NavigateBackAction(),
            FocusChangeIntent: FocusChangeAction(),
            SelectContentIntent: SelectContentAction(),
          },
          child: Shortcuts(
            shortcuts: (explorerController.selectedContent.value == (-1))
                ? {
                    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
                        NavigateBackIntent(),
                    LogicalKeySet(LogicalKeyboardKey.escape): NavigateBackIntent(),
                    LogicalKeySet(LogicalKeyboardKey.arrowDown):
                        FocusChangeIntent(count: 1, focus: true),
                  }
                : {
                    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
                        NavigateBackIntent(),
                    LogicalKeySet(LogicalKeyboardKey.escape): NavigateBackIntent(),
                    LogicalKeySet(LogicalKeyboardKey.arrowLeft):
                        FocusChangeIntent(count: -1, focus: false),
                    LogicalKeySet(LogicalKeyboardKey.arrowRight):
                        FocusChangeIntent(count: 1, focus: false),
                    LogicalKeySet(LogicalKeyboardKey.arrowUp): FocusChangeIntent(
                        count: (explorerController.selectedContent.value == 0)
                            ? (-1)
                            : (-explorerController.rowContentCount.value),
                        focus: false),
                    LogicalKeySet(LogicalKeyboardKey.arrowDown): FocusChangeIntent(
                        count: explorerController.rowContentCount.value, focus: false),
                    LogicalKeySet(LogicalKeyboardKey.enter): SelectContentIntent(
                        name: explorerController.contents[explorerController.selectedContent.value]
                            ['name'],
                        type: explorerController.contents[explorerController.selectedContent.value]
                            ['type'],
                        path: explorerController.contents[explorerController.selectedContent.value]
                            ['path']),
                  },
            child: Column(
              children: [
                RawKeyboardListener(
                  focusNode: explorerFocusNode,
                  child: Container(),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(15),
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: TextField(
                    focusNode: explorerPathFocusNode,
                    controller: explorerPathController,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    autofocus: true,
                    cursorWidth: editController.editFontSize.value / 1.5,
                    cursorColor: colorController.bgColorContrast.value,
                    cursorHeight: editController.editFontSize.value * 1.4,
                    enableInteractiveSelection: true,
                    enabled: true,
                    decoration: InputDecoration(border: InputBorder.none),
                    style: TextStyle(
                      color: colorController.bgColorContrast.value,
                      fontFamily: fontFamily,
                      fontSize: editController.editFontSize.value * 0.8,
                      fontWeight: (colorController.isDarkMode.value)
                          ? (FontWeight.normal)
                          : (FontWeight.w500),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: colorController.bgColor.value,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: (explorerController.selectedContent.value == (-1))
                          ? (colorController.appStyleColor)
                          : (Colors.transparent),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        offset:
                            (colorController.isDarkMode.value) ? (Offset(5, 5)) : (Offset(-5, -5)),
                        color: colorController.contrastExtreme.value
                            .withOpacity((colorController.isDarkMode.value) ? 0.5 : 1),
                        blurRadius: 10,
                      ),
                      BoxShadow(
                        offset:
                            (colorController.isDarkMode.value) ? (Offset(-5, -5)) : (Offset(5, 5)),
                        color: colorController.bgColorContrast.value.withOpacity(0.1),
                        blurRadius: 10,
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(20),
                    color: colorController.bgColor.value,
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: explorerController.rowContentCount.value,
                          childAspectRatio: 1 / 1,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: explorerController.contents.length,
                        itemBuilder: (context, i) {
                          return Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.all(5),
                            height: 50,
                            width: 50,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  iconPicker(
                                      name: explorerController.contents[i]['name'],
                                      type: explorerController.contents[i]['type']),
                                  color: (explorerController.contents[i]['name'].substring(0, 1) ==
                                          '.')
                                      ? (colorController.bgColorContrast.value.withOpacity(0.6))
                                      : (colorController.bgColorContrast.value.withOpacity(0.9)),
                                  size: 70,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  explorerController.contents[i]['name'],
                                  style: TextStyle(
                                    color: (explorerController.contents[i]['name']
                                                .substring(0, 1) ==
                                            '.')
                                        ? (colorController.bgColorContrast.value.withOpacity(0.7))
                                        : (colorController.bgColorContrast.value.withOpacity(1)),
                                    fontFamily: fontFamily,
                                    fontWeight: (colorController.isDarkMode.value)
                                        ? (FontWeight.w500)
                                        : (FontWeight.bold),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                              color: colorController.bgColor.value,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: (explorerController.selectedContent.value == i)
                                      ? (colorController.appStyleColor.withOpacity(0.7))
                                      : (Colors.transparent),
                                  width: 4.0),
                            ),
                          );
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  IconData iconPicker({String name, String type}) {
    Map<String, IconData> fileIconMap = {
      'git': MdiIcons.git,
      'gitignore': MdiIcons.git,
      'gitattributes': MdiIcons.git,
      'gitmodules': MdiIcons.git,
      'linux': MdiIcons.linux,
      'windows': MdiIcons.microsoftWindows,
      'mac': MdiIcons.apple,
      'macos': MdiIcons.apple,
      'yaml': MdiIcons.codeJson,
      'lock': MdiIcons.lock,
      'idea': MdiIcons.lightbulb,
      'metadata': MdiIcons.database,
      'package': MdiIcons.package,
      'packages': MdiIcons.packageVariant,
      'lib': MdiIcons.libraryShelves,
      'cpp': MdiIcons.languageCpp,
      'c': MdiIcons.languageC,
      'css': MdiIcons.languageCss3,
      'js': MdiIcons.languageJavascript,
      'json': MdiIcons.codeJson,
      'hs': MdiIcons.languageHaskell,
      'py': MdiIcons.languagePython,
      'php': MdiIcons.languagePhp,
      'md': MdiIcons.languageMarkdown,
      'vscode': MdiIcons.microsoftVisualStudioCode,
    };
    if (type == 'Folder') {
      if (name.contains('.')) {
        // String ext = name.split('.')[name.split('.').length - 1].toLowerCase();
        // if (fileIconMap.containsKey(ext)) {
        // return fileIconMap[ext];
        // } else {
        return MdiIcons.folder;
        // }
      } else {
        // if (fileIconMap.containsKey(name.toLowerCase())) {
        //   return fileIconMap[name.toLowerCase()];
        // } else {
        return MdiIcons.folder;
        // }
      }
    } else {
      if (name.contains('.')) {
        String ext = name.split('.')[name.split('.').length - 1].toLowerCase();
        if (fileIconMap.containsKey(ext)) {
          return fileIconMap[ext];
        } else {
          return MdiIcons.file;
        }
      } else {
        if (fileIconMap.containsKey(name.toLowerCase())) {
          return fileIconMap[name.toLowerCase()];
        } else {
          return MdiIcons.file;
        }
      }
    }
  }
}
