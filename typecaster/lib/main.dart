import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/state_manager.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import './controller/global_controller.dart';
import './functions.dart';
import '../controller/color_controller.dart';
import '../controller/edit_controller.dart';

void main() {
  runApp(TypeCaster());
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
  onChangeRawSecond: (value) {
    String displayTime = StopWatchTimer.getDisplayTime(value);
    editController.editModeTime.value = displayTime;
  },
  onChangeRawMinute: (value) {
    String displayTime = StopWatchTimer.getDisplayTime(value);
    editController.editModeTime.value = displayTime;
  },
);
StopWatchTimer globalTimer = StopWatchTimer(
  onChange: (value) {
    String displayTime = StopWatchTimer.getDisplayTime(value);
    globalController.globalTime.value = displayTime;
  },
  onChangeRawSecond: (value) {
    String displayTime = StopWatchTimer.getDisplayTime(value);
    globalController.globalTime.value = displayTime;
  },
  onChangeRawMinute: (value) {
    String displayTime = StopWatchTimer.getDisplayTime(value);
    globalController.globalTime.value = displayTime;
  },
);

class TypeCaster extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Typecaster',
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

  Widget editPanel(BuildContext mainContext) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 20, bottom: 25),
          alignment: Alignment.bottomCenter,
          height: MediaQuery.of(mainContext).size.height * 0.43,
          width: MediaQuery.of(mainContext).size.width,
          child: ((editController.fileList[editController.activeFile.value]['activeLine']) != 0)
              ? FittedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                                      color: colorController.bgColorContrast.value.withOpacity(0.5),
                                      fontFamily: fontFamily,
                                      fontSize: 15,
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
                                    text: lineContent(i),
                                    style: TextStyle(
                                      color: colorController.bgColorContrast.value.withOpacity(0.8),
                                      fontFamily: globalController.displayFont.value,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                )
              : (Container()),
        ),
        if (editController.editMode.value)
          Container(
            height: MediaQuery.of(mainContext).size.height * 0.06,
          ),
        if (lowerSectionValidity())
          Container(
            padding: EdgeInsets.only(top: 25, bottom: 20),
            alignment: Alignment.topCenter,
            height: MediaQuery.of(mainContext).size.height * 0.43,
            width: MediaQuery.of(mainContext).size.width,
            child: FittedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
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
                                  color: colorController.bgColorContrast.value.withOpacity(0.5),
                                  fontFamily: fontFamily,
                                  fontSize: 15,
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
                                text: lineContent(i),
                                style: TextStyle(
                                  color: colorController.bgColorContrast.value.withOpacity(0.8),
                                  fontFamily: globalController.displayFont.value,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15,
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
                      if (editController.editMode.value) editPanel(mainContext),
                      if (editController.editMode.value)
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(mainContext).size.width * 0.9,
                                  height: MediaQuery.of(mainContext).size.height * 0.06,
                                  child: TextField(
                                    focusNode: editTextFocusNode,
                                    controller: textEditControl,
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    autofocus: false,
                                    cursorWidth: editController.fontSize.value / 1.5,
                                    cursorColor: colorController.bgColorContrast.value,
                                    cursorHeight: editController.fontSize.value * 1.4,
                                    enableInteractiveSelection: true,
                                    decoration: null,
                                    style: TextStyle(
                                      color: colorController.bgColorContrast.value,
                                      fontFamily: fontFamily,
                                      fontSize: editController.fontSize.value,
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
                    if (keyEvent.isControlPressed) {
                      if (keyEvent.isKeyPressed(LogicalKeyboardKey.space)) {
                        if (!(editController.editMode.value)) {
                          editModeStart();
                        } else {
                          editModeEnd();
                        }
                        editController.editMode.value = !(editController.editMode.value);
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyI)) {
                        if (upLineCandidate()) {
                          activeLineDecrement();
                        }
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyK)) {
                        if (downLineCandidate()) {
                          activeLineIncrement();
                        }
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyQ)) {
                        exit(0);
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyD)) {
                        colorController.darkModeChanger();
                      }
                    } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.backspace)) {
                      if (editController.editMode.value) {
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
                        activeLineDecrement();
                      }
                    } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
                      if (downLineCandidate()) {
                        activeLineIncrement();
                      }
                    }
                  },
                ),
              ),
              Container(
                height: MediaQuery.of(mainContext).size.height * 0.03,
                width: MediaQuery.of(mainContext).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        'typecaster',
                        style: TextStyle(
                          color: colorController.bgColorContrast.value,
                          fontFamily: fontFamily,
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        modeValue(),
                        style: TextStyle(
                          color: colorController.bgColorContrast.value,
                          fontFamily: fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        modeTimerText(),
                        style: TextStyle(
                          color: colorController.bgColorContrast.value,
                          fontFamily: fontFamily,
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: lineCount(),
                              style: TextStyle(
                                color: colorController.bgColorContrast.value,
                                fontFamily: fontFamily,
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                            TextSpan(
                              text: ' | ',
                              style: TextStyle(
                                color: colorController.bgColorContrast.value,
                                fontFamily: fontFamily,
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                            TextSpan(
                              text: lineCharacterCount(),
                              style: TextStyle(
                                color: colorController.bgColorContrast.value,
                                fontFamily: fontFamily,
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ]),
                        )),
                  ],
                ),
                decoration: BoxDecoration(
                  color: colorController.bgColorContrast.value.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
