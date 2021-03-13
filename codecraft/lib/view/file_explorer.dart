import 'dart:io';

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

class FileExplorer extends StatelessWidget {
  FileExplorer() {
    if (explorerController.path.value == '') {
      explorerController.path.value = directory.path;
      explorerController.eDirectory.value = directory;
      explorerPathController.text = explorerController.path.value;
      explorerController.contents = directoryContents;
    } else {
      explorerController.contents.clear();
      explorerController.eDirectory.value = Directory(explorerController.path.value);
      explorerPathController.text = explorerController.path.value;
      contentList = explorerController.eDirectory.value.listSync(recursive: false);
      for (int i = 0; i < contentList.length; i++) {
        FileSystemEntity element = contentList[i];
        String name = '';
        name = element.path.split('/')[element.path.split('/').length - 1];
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
    }
    explorerFocusNode.requestFocus();
  }
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: colorController.bgColor.value,
        body: RawKeyboardListener(
          focusNode: explorerFocusNode,
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(15),
                height: MediaQuery.of(context).size.height * 0.07,
                child: TextField(
                  focusNode: explorerPathFocusNode,
                  controller: explorerPathController,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  autofocus: false,
                  cursorWidth: editController.editFontSize.value / 1.5,
                  cursorColor: colorController.bgColorContrast.value,
                  cursorHeight: editController.editFontSize.value * 1.4,
                  enableInteractiveSelection: true,
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
                        crossAxisCount: 7,
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
                                color:
                                    (explorerController.contents[i]['name'].substring(0, 1) == '.')
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
                                  color: (explorerController.contents[i]['name'].substring(0, 1) ==
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
                                width: 3.0),
                          ),
                        );
                      }),
                ),
              ),
            ],
          ),
          onKey: (keyEvent) {
            if (keyEvent.isControlPressed) {
              if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyF)) {
                Get.back();
              }
            }
          },
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
        String ext = name.split('.')[name.split('.').length - 1].toLowerCase();
        if (fileIconMap.containsKey(ext)) {
          return fileIconMap[ext];
        } else {
          return MdiIcons.folder;
        }
      } else {
        if (fileIconMap.containsKey(name.toLowerCase())) {
          return fileIconMap[name.toLowerCase()];
        } else {
          return MdiIcons.folder;
        }
      }
    } else {
      if (name.contains('.')){String ext = name.split('.')[name.split('.').length - 1].toLowerCase();
      if (fileIconMap.containsKey(ext)) {
        return fileIconMap[ext];
      } else {
        return MdiIcons.file;
      }} else {
        if (fileIconMap.containsKey(name.toLowerCase())) {
          return fileIconMap[name.toLowerCase()];
        } else {
          return MdiIcons.file;
        }
      }
    }
  }
}