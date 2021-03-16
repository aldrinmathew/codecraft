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

class ExitExplorerIntent extends Intent {
  ExitExplorerIntent();
}

class ExitExplorerAction extends Action<ExitExplorerIntent> {
  @override
  void invoke(covariant ExitExplorerIntent intent) {
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
      explorerController.history[explorerController.historyIndex.value]['selection'] =
          explorerController.selectedContent.value;
    } else if ((explorerController.selectedContent.value + intent.count) <= -1) {
      if (intent.count == -1) {
        explorerController.selectedContent.value = -1;
        explorerController.history[explorerController.historyIndex.value]['selection'] =
            explorerController.selectedContent.value;
        explorerPathFocusNode.requestFocus();
      } else {
        explorerController.selectedContent.value = 0;
        explorerController.history[explorerController.historyIndex.value]['selection'] =
            explorerController.selectedContent.value;
      }
    } else {
      explorerController.selectedContent.value += intent.count;
      explorerController.history[explorerController.historyIndex.value]['selection'] =
          explorerController.selectedContent.value;
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
      if (explorerController.historyIndex.value == (explorerController.history.length - 1)) {
        explorerController.history.add({
          'path': intent.path,
          'selection': explorerController.selectedContent.value,
        });
      } else {
        explorerController.history[explorerController.historyIndex.value + 1] = {
          'path': intent.path,
          'selection': explorerController.selectedContent.value,
        };
        for (int i = explorerController.historyIndex.value + 2;
            i < explorerController.history.length;
            i++) {
          explorerController.history.removeAt(i);
        }
      }
      explorerController.historyIndex.value++;
    }
  }
}

class PreviousDirectoryIntent extends Intent {
  PreviousDirectoryIntent();
}

class PreviousDirectoryAction extends Action<PreviousDirectoryIntent> {
  @override
  void invoke(covariant PreviousDirectoryIntent intent) {
    if (explorerController.historyIndex.value > 0) {
      explorerController.historyIndex.value--;
    }
    explorerController.path.value =
        explorerController.history[explorerController.historyIndex.value]['path'];
    folderContentSync(explorerController.path.value);
  }
}

class NextDirectoryIntent extends Intent {
  NextDirectoryIntent();
}

class NextDirectoryAction extends Action<NextDirectoryIntent> {
  @override
  void invoke(covariant NextDirectoryIntent intent) {
    if (explorerController.historyIndex.value < (explorerController.history.length - 1)) {
      explorerController.historyIndex.value++;
    }
    explorerController.path.value =
        explorerController.history[explorerController.historyIndex.value]['path'];
    explorerController.selectedContent.value =
        explorerController.history[explorerController.historyIndex.value]['selection'];
    folderContentSync(explorerController.path.value);
  }
}

void folderContentSync(String currentPath) {
  explorerController.selectedContent.value = -1;
  explorerController.contents.clear();
  explorerController.path.value = currentPath;
  explorerController.explorerDirectory.value = Directory(explorerController.path.value);
  explorerPathController.text = explorerController.path.value;
  contentList = explorerController.explorerDirectory.value.listSync(recursive: false);
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
      explorerController.explorerDirectory.value = directory;
      explorerPathController.text = explorerController.path.value;
      explorerController.contents = directoryContents;
    } else {
      explorerController.path.value =
          explorerController.history[explorerController.historyIndex.value]['path'];
      explorerController.selectedContent.value =
          explorerController.history[explorerController.historyIndex.value]['selection'];
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
            ExitExplorerIntent: ExitExplorerAction(),
            FocusChangeIntent: FocusChangeAction(),
            SelectContentIntent: SelectContentAction(),
            PreviousDirectoryIntent: PreviousDirectoryAction(),
            NextDirectoryIntent: NextDirectoryAction(),
          },
          child: Shortcuts(
            shortcuts: (explorerController.selectedContent.value == (-1))
                ? {
                    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
                        ExitExplorerIntent(),
                    LogicalKeySet(LogicalKeyboardKey.escape): ExitExplorerIntent(),
                    LogicalKeySet(LogicalKeyboardKey.arrowDown):
                        FocusChangeIntent(count: 1, focus: true),
                  }
                : {
                    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
                        ExitExplorerIntent(),
                    LogicalKeySet(LogicalKeyboardKey.escape): ExitExplorerIntent(),
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
                          ['path'],
                    ),
                    LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.arrowLeft):
                        PreviousDirectoryIntent(),
                    LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.arrowRight):
                        NextDirectoryIntent(),
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
