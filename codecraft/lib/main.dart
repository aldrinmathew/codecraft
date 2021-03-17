import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:intl/intl.dart';
import 'package:codecraft/view/status_bar.dart';
import 'package:codecraft/view/new_file.dart';
import 'package:codecraft/view/save_file.dart';
import 'package:codecraft/view/file_explorer.dart';
import 'package:codecraft/controller/global_controller.dart';
import 'package:codecraft/functions.dart';
import 'package:codecraft/controller/color_controller.dart';
import 'package:codecraft/controller/edit_controller.dart';

Directory directory;
Directory codecraftDirectory;
Directory autosaveDirectory;
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
        editController.activeFile.value++;
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

  editController.fileList[editController.activeFile.value]['path'] = directory.path;

  if (Platform.isWindows) {
    editController.endOfLine.value = '\r\n';
  } else {
    editController.endOfLine.value = '\n';
  }

  runApp(CodeCraft());
}

String fontFamily = "FiraCode";
ColorController colorController = ColorController();
EditController editController = EditController();
GlobalController globalController = GlobalController();
TextEditingController textEditControl;
FocusNode editTextFocusNode;
FocusNode homeViewFocusNode;
StopWatchTimer editModeTimer = StopWatchTimer(
  onChange: (value) {
    String displayTime = StopWatchTimer.getDisplayTime(value);
    editController.editModeTime.value = displayTime;
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
        primarySwatch: colorController.appStyleColor,
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
    backgroundColor: colorController.bgColor.value,
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
    textEditControl = TextEditingController(text: '');
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
            for (int i = 0; i < editController.fileList.length; i++)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Row(
                        children: [
                          if (editController.activeFile.value == i)
                            Icon(
                              Icons.file_present,
                              size: 15,
                              color: colorController.bgColorContrast.value.withOpacity(
                                  (editController.activeFile.value == i) ? (0.5) : (0.3)),
                            ),
                          Text(
                            (editController.fileList[i]['extension'] == '')
                                ? (editController.fileList[i]['fileName'])
                                : (editController.fileList[i]['fileName'] +
                                    '.' +
                                    editController.fileList[i]['extension']),
                            style: TextStyle(
                              color: colorController.bgColorContrast.value.withOpacity(
                                  (editController.activeFile.value == i) ? (0.8) : (0.5)),
                              fontFamily: fontFamily,
                              fontWeight: (editController.activeFile.value == i)
                                  ? (FontWeight.bold)
                                  : (FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: colorController.bgColor.value,
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          if (editController.activeFile.value == i)
                            BoxShadow(
                              blurRadius: 3,
                              color: colorController.bgColorContrast.value.withOpacity(0.1),
                              offset: (colorController.isDarkMode.value)
                                  ? (Offset(-3, -3))
                                  : (Offset(3, 3)),
                            ),
                          if (editController.activeFile.value == i)
                            BoxShadow(
                              blurRadius: 3,
                              color: colorController.contrastExtreme.value
                                  .withOpacity((colorController.isDarkMode.value) ? (0.2) : (0.8)),
                              offset: (colorController.isDarkMode.value)
                                  ? (Offset(3, 3))
                                  : (Offset(-3, -3)),
                            )
                        ],
                      ),
                    ),
                    if (!(editController.fileList[i]['saved']))
                      Positioned(
                        top: 0.0,
                        right: 0.0,
                        child: Icon(
                          Icons.circle,
                          size: 12,
                          color: colorController.bgColorContrast.value,
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
                        (editController.editFontSize.value / 20))) /
                2,
            width: MediaQuery.of(mainContext).size.width,
            child: ((editController.fileList[editController.activeFile.value]['activeLine']) != 0)
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
                                          color: colorController.bgColorContrast.value
                                              .withOpacity(0.5),
                                          fontFamily: fontFamily,
                                          fontSize: editController.fontSize.value,
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
                                          color: colorController.bgColorContrast.value
                                              .withOpacity(0.8),
                                          fontFamily: globalController.displayFont.value,
                                          fontWeight: (colorController.isDarkMode.value)
                                              ? (FontWeight.normal)
                                              : (FontWeight.w500),
                                          fontSize: editController.fontSize.value,
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
        if (editController.editMode.value)
          Container(
            height: MediaQuery.of(mainContext).size.height *
                0.06 *
                (editController.editFontSize.value / 20),
          ),
        Expanded(
          child: (lowerSectionValidity())
              ? (Container(
                  padding: EdgeInsets.only(top: 25, bottom: 20),
                  alignment: Alignment.topCenter,
                  height: (MediaQuery.of(mainContext).size.height -
                          (MediaQuery.of(mainContext).size.height *
                              0.06 *
                              (editController.editFontSize.value / 20))) /
                      2,
                  width: MediaQuery.of(mainContext).size.width,
                  child: FittedBox(
                    child: ClipRRect(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = editController.fileList[editController.activeFile.value]
                                      ['activeLine'] +
                                  1;
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
                                          color: colorController.bgColorContrast.value
                                              .withOpacity(0.5),
                                          fontFamily: fontFamily,
                                          fontSize: editController.fontSize.value,
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
                                          color: colorController.bgColorContrast.value
                                              .withOpacity(0.8),
                                          fontFamily: globalController.displayFont.value,
                                          fontWeight: (colorController.isDarkMode.value)
                                              ? (FontWeight.normal)
                                              : (FontWeight.w500),
                                          fontSize: editController.fontSize.value,
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
        backgroundColor: colorController.bgColor.value,
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
                      if (editController.editMode.value) editPanel(mainContext),
                      if (editController.editMode.value)
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(mainContext).size.width * 0.9,
                                  height: (MediaQuery.of(mainContext).size.height *
                                      0.06 *
                                      (editController.editFontSize.value / 20)),
                                  child: TextField(
                                    focusNode: editTextFocusNode,
                                    controller: textEditControl,
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    autofocus: false,
                                    cursorWidth: editController.editFontSize.value / 1.5,
                                    cursorColor: colorController.bgColorContrast.value,
                                    cursorHeight: editController.editFontSize.value * 1.4,
                                    enableInteractiveSelection: true,
                                    decoration: null,
                                    style: TextStyle(
                                      color: colorController.bgColorContrast.value,
                                      fontFamily: fontFamily,
                                      fontSize: editController.editFontSize.value,
                                      fontWeight: (colorController.isDarkMode.value)
                                          ? (FontWeight.normal)
                                          : (FontWeight.w500),
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
                                  color: colorController.bgColor.value,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: (colorController.isDarkMode.value)
                                          ? (Offset(5, 5))
                                          : (Offset(-5, -5)),
                                      color: colorController.contrastExtreme.value.withOpacity(
                                          (colorController.isDarkMode.value) ? 0.5 : 1),
                                      blurRadius: 10,
                                    ),
                                    BoxShadow(
                                      offset: (colorController.isDarkMode.value)
                                          ? (Offset(-5, -5))
                                          : (Offset(5, 5)),
                                      color: colorController.bgColorContrast.value.withOpacity(0.1),
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
                        editController.editMode.value &&
                        editTextFocusNode.hasPrimaryFocus) {
                      tabKeyHandler();
                    }
                    if (keyEvent.isControlPressed) {
                      if (keyEvent.isKeyPressed(LogicalKeyboardKey.space)) {
                        if (!(editController.editMode.value)) {
                          editModeStart();
                        } else {
                          editModeEnd();
                        }
                        editController.editMode.value = !(editController.editMode.value);
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyS)) {
                        if (editController.fileList[editController.activeFile.value]['onDisk']) {
                          saveFilePrepare(editController.fileList[editController.activeFile.value]['path']);
                        } else {
                          Get.to(() => SaveFileScreen(
                                fileName: editController.fileList[editController.activeFile.value]
                                    ['fileName'],
                                filePath: editController.fileList[editController.activeFile.value]
                                    ['path'],
                              ));
                        }
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyN)) {
                        Get.to(() => NewFileScreen());
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyF)) {
                        Get.to(() => FileExplorer());
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.equal)) {
                        editController.fontSize.value++;
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.minus)) {
                        editController.fontSize.value--;
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
                      if (editController.editMode.value) {
                        editController.errorCount.value++;
                        if (backspaceCandidate()) {
                          backspaceLine();
                        }
                      }
                    } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.delete)) {
                      if (editController.editMode.value) {
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
                        editController.editFontSize.value++;
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.minus)) {
                        editController.editFontSize.value--;
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyD)) {
                        colorController.darkModeChanger();
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
                      if (editController.editMode.value) {
                        autoCompleteBasic('[');
                      }
                    } else if (keyEvent.character == '(') {
                      if (editController.editMode.value) {
                        autoCompleteBasic('(');
                      }
                    } else if (keyEvent.character == '{') {
                      if (editController.editMode.value) {
                        autoCompleteBasic('{');
                      }
                    } else if (keyEvent.character == '\'') {
                      if (editController.editMode.value) {
                        autoCompleteBasic('\'');
                      }
                    } else if (keyEvent.character == '"') {
                      if (editController.editMode.value) {
                        autoCompleteBasic('"');
                      }
                    } else if (keyEvent.character == '<') {
                      if (editController.editMode.value) {
                        // Checking to see if there is a selection, since the < and > characters are usually part of expressions.
                        if (textEditControl.selection.start != textEditControl.selection.end) {
                          autoCompleteBasic('<');
                        }
                      }
                    }

                    // Navigate to the start and end of the document.

                    else if (keyEvent.isKeyPressed(LogicalKeyboardKey.home)) {
                      if (upLineCandidate()) {
                        activeLineDecrement(editController
                                .fileContent[editController.activeFile.value]['content'].length -
                            1); // Passing a large value which is one less than the length of the array, so that it will go to the first line
                      }
                    } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.end)) {
                      if (downLineCandidate()) {
                        activeLineIncrement(editController
                                .fileContent[editController.activeFile.value]['content'].length -
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