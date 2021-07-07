import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:intl/intl.dart';

import 'view/status_bar.dart';
import 'view/new_file.dart';
import 'view/save_file.dart';
import 'view/file_explorer.dart';
import 'controller/global_controller.dart';
import 'functions.dart';
import 'controller/edit_controller.dart';

import 'globals.dart';

Directory directory = Directory(Directory.current.path);
Directory codecraftDirectory = Directory(Directory.current.path);
Directory autosaveDirectory = Directory(Directory.current.path);
List<Map<String, String>> directoryContents = [];
bool previousOpen = false;

void main(List<String> arguments) {
  Intl.defaultLocale = 'en_BR';

  if (arguments.length == 0) {
    if (Directory.current.path[Directory.current.path.length - 1] != '/') {
      directory = Directory(Directory.current.path + '/');
    } else {
      directory = Directory(Directory.current.path);
    }
  } else if ((arguments[0] == '.')) {
    if (Directory.current.path[Directory.current.path.length - 1] != '/') {
      directory = Directory(Directory.current.path + '/');
    } else {
      directory = Directory(Directory.current.path);
    }
  } else {
    String cachePath = arguments[0];
    if (FileSystemEntity.typeSync(cachePath) != FileSystemEntityType.notFound) {
      if (FileSystemEntity.typeSync(cachePath).toString() == 'directory') {
        directory = Directory(cachePath);
      } else if (FileSystemEntity.typeSync(cachePath).toString() == 'file') {
        File cacheFile = File(cachePath);
        cacheFile.open();
        String fileName = '';
        if (cachePath.contains('/')) {
          fileName = cachePath.split('/')[cachePath.split('/').length - 1];
        }
        if (fileName.contains('\\')) {
          fileName = fileName.split('\\')[fileName.split('\\').length - 1];
        }
        cachePath = cachePath.substring(0, cachePath.length - fileName.length);
        directory = Directory(cachePath);
        createNewFile(fileName: fileName, filePath: cachePath);
        edit.activeFile.value++;
        readFile(cacheFile);
      }
    }
  }

  List<FileSystemEntity> contents = directory.listSync(recursive: false);
  for (int i = 0; i < contents.length; i++) {
    FileSystemEntity element = contents[i];
    String name = '';
    name = element.path.substring(2).split('/')[element.path.substring(2).split('/').length - 1];
    if (element is File) {
      if (directory.path == '') {
        directoryContents.add({
          'name': name,
          'path': element.path.substring(2),
          'type': 'File',
        });
      } else {
        directoryContents.add({
          'name': name,
          'path': element.path,
          'type': 'File',
        });
      }
    } else if (element is Directory) {
      if (directory.path == '') {
        directoryContents.add({
          'name': name,
          'path': element.path.substring(2),
          'type': 'Folder',
        });
        if (element.path.substring(2) == '.codecraft') {
          previousOpen = true;
          autosaveDirectory = Directory('.codecraft/autosave');
          autosaveDirectory.create();
        } else {
          codecraftDirectory = Directory('.codecraft');
          codecraftDirectory.create(recursive: false);
          autosaveDirectory = Directory('.codecraft/autosave');
          autosaveDirectory.create(recursive: true);
        }
      } else {
        directoryContents.add({
          'name': name,
          'path': element.path,
          'type': 'Folder',
        });
        if (element.path == '.codecraft') {
          previousOpen = true;
          autosaveDirectory = Directory('.codecraft/autosave');
          autosaveDirectory.create();
        } else {
          codecraftDirectory = Directory('.codecraft');
          codecraftDirectory.create(recursive: false);
          autosaveDirectory = Directory('.codecraft/autosave');
          autosaveDirectory.create(recursive: true);
        }
      }
    }
  }

  edit.fileList[edit.activeFile.value]['path'] = directory.path;

  if (Platform.isWindows) {
    edit.endOfLine.value = '\r\n';
  } else {
    edit.endOfLine.value = '\n';
  }

  runApp(CodeCraft());
}

String fontFamily = 'FiraCode';
EditController edit = EditController();
GlobalController globalController = GlobalController();
TextEditingController textEdit = TextEditingController();
FocusNode editTextFocusNode = FocusNode(canRequestFocus: true);
FocusNode homeViewFocusNode = FocusNode(canRequestFocus: true);
StopWatchTimer editModeTimer = StopWatchTimer(
  onChange: (value) {
    String displayTime = StopWatchTimer.getDisplayTime(value);
    edit.editModeTime.value = displayTime;
  },
);
StopWatchTimer globalTimer = StopWatchTimer(
  onChange: (value) {
    String displayTime = StopWatchTimer.getDisplayTime(value);
    globalController.globalTime.value = displayTime;
  },
);

class CodeCraft extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Codecraft',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: color.materialColor,
      ),
      home: HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  AlertDialog newFileDialog = AlertDialog(
    backgroundColor: color.main,
    content: TextField(
      enabled: true,
      decoration: InputDecoration(
        border: InputBorder.none,
      ),
    ),
    contentPadding: EdgeInsets.zero,
    titlePadding: EdgeInsets.zero,
  );

  void initState() {
    homeViewFocusNode = FocusNode(
      canRequestFocus: true,
      descendantsAreFocusable: true,
    );
    homeViewFocusNode.requestFocus();
    editTextFocusNode = FocusNode(
      canRequestFocus: true,
      descendantsAreFocusable: false,
    );
    newFileNameFocusNode = FocusNode(
      canRequestFocus: true,
      descendantsAreFocusable: false,
    );
    textEdit = TextEditingController(text: '');
    globalTimer.onExecute.add(StopWatchExecute.start);
    super.initState();
  }

  void dispose() async {
    await editModeTimer.dispose();
    globalTimer.onExecute.add(StopWatchExecute.stop);
    await globalTimer.dispose();
    super.dispose();
  }

  Widget openFiles(BuildContext mainContext) {
    return Positioned(
      top: 0.0,
      left: 0.0,
      child: Container(
        child: Row(
          children: [
            for (int i = 0; i < edit.fileList.length; i++)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Row(
                        children: [
                          if (edit.activeFile.value == i)
                            Icon(
                              Icons.file_present,
                              size: 15,
                              color: color.contrast
                                  .withOpacity((edit.activeFile.value == i) ? (0.5) : (0.3)),
                            ),
                          Text(
                            (edit.fileList[i]['extension'] == '')
                                ? (edit.fileList[i]['fileName'])
                                : (edit.fileList[i]['fileName'] +
                                    '.' +
                                    edit.fileList[i]['extension']),
                            style: TextStyle(
                              color: color.contrast
                                  .withOpacity((edit.activeFile.value == i) ? (0.8) : (0.5)),
                              fontFamily: fontFamily,
                              fontWeight: (edit.activeFile.value == i)
                                  ? (FontWeight.bold)
                                  : (FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: color.main,
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          if (edit.activeFile.value == i)
                            BoxShadow(
                              blurRadius: 3,
                              color: color.contrast.withOpacity(0.1),
                              offset: color.chooser(
                                darkMode: Offset(-3, -3),
                                lightMode: Offset(3, 3),
                              ),
                            ),
                          if (edit.activeFile.value == i)
                            BoxShadow(
                              blurRadius: 3,
                              color: color.dark.withOpacity(
                                color.chooser(darkMode: 0.8, lightMode: 0.2),
                              ),
                              offset: color.chooser(
                                darkMode: Offset(-3, -3),
                                lightMode: Offset(3, 3),
                              ),
                            )
                        ],
                      ),
                    ),
                    if (!(edit.fileList[i]['saved']))
                      Positioned(
                        top: 0.0,
                        right: 0.0,
                        child: Icon(
                          Icons.circle,
                          size: 12,
                          color: color.contrast,
                        ),
                      ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget editPanel(BuildContext mainContext) {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.only(top: 20, bottom: 25),
            alignment: Alignment.bottomCenter,
            height: (MediaQuery.of(mainContext).size.height -
                    (MediaQuery.of(mainContext).size.height *
                        0.06 *
                        (edit.editFontSize.value / 20))) /
                2,
            width: MediaQuery.of(mainContext).size.width,
            child: ((edit.activeLineIndex) != 0)
                ? FittedBox(
                    child: ClipRRect(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = upperSectionLoopInitializer(mainContext);
                              upperSectionloopCandidate(mainContext, i);
                              i++)
                            Container(
                              width: MediaQuery.of(mainContext).size.width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  spacingLineNumber(),
                                  Container(
                                    padding: EdgeInsets.only(right: 20),
                                    width: MediaQuery.of(mainContext).size.width * 0.03,
                                    alignment: Alignment.centerRight,
                                    child: FittedBox(
                                      child: Text(
                                        lineNumber(i),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: color.contrast.withOpacity(0.5),
                                          fontFamily: fontFamily,
                                          fontSize: edit.fontSize.value,
                                          fontWeight: FontWeight.normal,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(mainContext).size.width * 0.90,
                                    child: RichText(
                                      text: TextSpan(
                                        children: lineContent(i),
                                        style: TextStyle(
                                          color: color.contrast.withOpacity(0.8),
                                          fontFamily: globalController.displayFont.value,
                                          fontWeight: color.fontWeight,
                                          fontSize: edit.fontSize.value,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                : (Container()),
          ),
        ),
        if (edit.editMode.value)
          Container(
            height: MediaQuery.of(mainContext).size.height * 0.06 * (edit.editFontSize.value / 20),
          ),
        Expanded(
          child: (lowerSectionValidity())
              ? (Container(
                  padding: EdgeInsets.only(top: 25, bottom: 20),
                  alignment: Alignment.topCenter,
                  height: (MediaQuery.of(mainContext).size.height -
                          (MediaQuery.of(mainContext).size.height *
                              0.06 *
                              (edit.editFontSize.value / 20))) /
                      2,
                  width: MediaQuery.of(mainContext).size.width,
                  child: FittedBox(
                    child: ClipRRect(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = edit.fileList[edit.activeFile.value]['activeLine'] + 1;
                              lowerSectionLoopCandidate(mainContext, i);
                              i++)
                            Container(
                              width: MediaQuery.of(mainContext).size.width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  spacingLineNumber(),
                                  Container(
                                    padding: EdgeInsets.only(right: 20),
                                    width: MediaQuery.of(mainContext).size.width * 0.03,
                                    alignment: Alignment.centerRight,
                                    child: FittedBox(
                                      child: Text(
                                        lineNumber(i),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: color.contrast.withOpacity(0.5),
                                          fontFamily: fontFamily,
                                          fontSize: edit.fontSize.value,
                                          fontWeight: FontWeight.normal,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(mainContext).size.width * 0.90,
                                    child: RichText(
                                      text: TextSpan(
                                        children: lineContent(i),
                                        style: TextStyle(
                                          color: color.contrast.withOpacity(0.8),
                                          fontFamily: globalController.displayFont.value,
                                          fontWeight: color.fontWeight,
                                          fontSize: edit.fontSize.value,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ))
              : (Container()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext mainContext) {
    return Obx(() {
      return Scaffold(
        backgroundColor: color.main,
        body: Container(
          height: MediaQuery.of(mainContext).size.height,
          width: MediaQuery.of(mainContext).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20),
                height: MediaQuery.of(mainContext).size.height * 0.97,
                width: MediaQuery.of(mainContext).size.width,
                child: RawKeyboardListener(
                  focusNode: homeViewFocusNode,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      openFiles(mainContext),
                      if (edit.editMode.value) editPanel(mainContext),
                      if (edit.editMode.value)
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(mainContext).size.width * 0.9,
                                  height: (MediaQuery.of(mainContext).size.height *
                                      0.06 *
                                      (edit.editFontSize.value / 20)),
                                  child: TextField(
                                    focusNode: editTextFocusNode,
                                    controller: textEdit,
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    autofocus: false,
                                    cursorWidth: edit.editFontSize.value / 1.5,
                                    cursorColor: color.contrast,
                                    cursorHeight: edit.editFontSize.value * 1.4,
                                    enableInteractiveSelection: true,
                                    decoration: null,
                                    style: TextStyle(
                                      color: color.contrast,
                                      fontFamily: fontFamily,
                                      fontSize: edit.editFontSize.value,
                                      fontWeight: color.fontWeight,
                                    ),
                                    onChanged: (text) {
                                      textChange(text);
                                    },
                                    onSubmitted: (text) {
                                      textSubmit(text);
                                    },
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: color.main,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: color.chooser(
                                        darkMode: Offset(5, 5),
                                        lightMode: Offset(-5, -5),
                                      ),
                                      color: color.dark.withOpacity(color.isDarkMode ? 0.5 : 1),
                                      blurRadius: 10,
                                    ),
                                    BoxShadow(
                                      offset: color.chooser(
                                        darkMode: Offset(-5, -5),
                                        lightMode: Offset(5, 5),
                                      ),
                                      color: color.contrast.withOpacity(0.1),
                                      blurRadius: 10,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                    ],
                  ),
                  onKey: (keyEvent) async {
                    if (keyEvent.isKeyPressed(LogicalKeyboardKey.tab) &&
                        edit.editMode.value &&
                        editTextFocusNode.hasPrimaryFocus) {
                      tabKeyHandler();
                    }
                    if (keyEvent.isControlPressed) {
                      if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyE)) {
                        if (!(edit.editMode.value)) {
                          editModeStart();
                        } else {
                          editModeEnd();
                        }
                        edit.editMode.value = !(edit.editMode.value);
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyS)) {
                        if (edit.fileList[edit.activeFile.value]['onDisk']) {
                          saveFilePrepare(edit.fileList[edit.activeFile.value]['path']);
                        } else {
                          Get.to(() => SaveFileScreen(
                                fileName: edit.fileList[edit.activeFile.value]['fileName'],
                                filePath: edit.fileList[edit.activeFile.value]['path'],
                              ));
                        }
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyN)) {
                        Get.to(() => NewFileScreen());
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyF)) {
                        Get.to(() => FileExplorer());
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.equal)) {
                        edit.fontSize.value++;
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.minus)) {
                        edit.fontSize.value--;
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyQ)) {
                        exit(0);
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
                        if (upLineCandidate()) {
                          activeLineDecrement(5);
                        }
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
                        if (downLineCandidate()) {
                          activeLineIncrement(5);
                        }
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyT)) {
                        // Implementation yet to be done for Type Speed Practise Screen.
                      }
                    } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.backspace)) {
                      if (edit.editMode.value) {
                        edit.errorCount.value++;
                        if (backspaceCandidate()) {
                          backspaceLine();
                        }
                      }
                    } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.delete)) {
                      if (edit.editMode.value) {
                        if (deleteNextlineCandidate()) {
                          deleteNewLine();
                        }
                      }
                    } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
                      if (upLineCandidate()) {
                        activeLineDecrement(1);
                      }
                    } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
                      if (downLineCandidate()) {
                        activeLineIncrement(1);
                      }
                    } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.insert)) {
                      // Implementation of custom inserts removed for refactor.
                    } else if (keyEvent.isAltPressed) {
                      if (keyEvent.isKeyPressed(LogicalKeyboardKey.equal)) {
                        edit.editFontSize.value++;
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.minus)) {
                        edit.editFontSize.value--;
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyD)) {
                        color.darkModeChanger();
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
                        previousFile();
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
                        nextFile();
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyJ)) {
                        if (upLineCandidate()) {
                          activeLineDecrement(1);
                        }
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyM)) {
                        if (downLineCandidate()) {
                          activeLineIncrement(1);
                        }
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyI)) {
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyK)) {
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyL)) {}
                    }

                    // Autocompletion of Basic Characters: ' " [ { ( <

                    else if (keyEvent.character == '[') {
                      if (edit.editMode.value) {
                        autoCompleteBasic('[');
                      }
                    } else if (keyEvent.character == '(') {
                      if (edit.editMode.value) {
                        autoCompleteBasic('(');
                      }
                    } else if (keyEvent.character == '{') {
                      if (edit.editMode.value) {
                        autoCompleteBasic('{');
                      }
                    } else if (keyEvent.character == '\'') {
                      if (edit.editMode.value) {
                        autoCompleteBasic('\'');
                      }
                    } else if (keyEvent.character == '"') {
                      if (edit.editMode.value) {
                        autoCompleteBasic('"');
                      }
                    } else if (keyEvent.character == '<') {
                      if (edit.editMode.value) {
                        // Checking to see if there is a selection, since the < and > characters are usually part of expressions.
                        if (textEdit.selection.start != textEdit.selection.end) {
                          autoCompleteBasic('<');
                        }
                      }
                    }

                    // Navigate to the start and end of the document.

                    else if (keyEvent.isKeyPressed(LogicalKeyboardKey.home)) {
                      if (upLineCandidate()) {
                        activeLineDecrement(edit.lineCount -
                            1); // Passing a large value which is one less than the length of the array, so that it will go to the first line
                      }
                    } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.end)) {
                      if (downLineCandidate()) {
                        activeLineIncrement(edit.lineCount -
                            1); // Passing a large value which is one less than the length of the array, so that it will go to the last line
                      }
                    }
                  },
                ),
              ),
              statusBar(mainContext),
            ],
          ),
        ),
      );
    });
  }
}
