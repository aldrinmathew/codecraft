import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/state_manager.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:typecaster/controller/global_controller.dart';
import '../controller/color_controller.dart';
import '../controller/edit_controller.dart';

void main() {
  runApp(TypeCaster());
}

String fontFamily = "FiraCode";
int globalFontSize = 15;
ColorController colorController = ColorController();
EditController editController = EditController();
GlobalController globalController = GlobalController();

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
                      for (int i = (editController.fileList[editController.activeFile.value]
                                      ['activeLine'] >=
                                  (MediaQuery.of(mainContext).size.height / (3.2 * globalFontSize)))
                              ? (editController.fileList[editController.activeFile.value]
                                      ['activeLine'] -
                                  (MediaQuery.of(mainContext).size.height ~/
                                      (3.2 * globalFontSize)))
                              : (0);
                          (editController.editMode.value)
                              ? (i <
                                  editController.fileList[editController.activeFile.value]
                                      ['activeLine'])
                              : (i <=
                                  editController.fileList[editController.activeFile.value]
                                      ['activeLine']);
                          i++)
                        Container(
                          width: MediaQuery.of(mainContext).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              (editController
                                          .fileContent[editController.activeFile.value]['content']
                                          .length >
                                      1000)
                                  ? (SizedBox(
                                      width: 20,
                                    ))
                                  : ((editController
                                              .fileContent[editController.activeFile.value]
                                                  ['content']
                                              .length >
                                          100)
                                      ? (SizedBox(
                                          width: 10,
                                        ))
                                      : (SizedBox(
                                          width: 5,
                                        ))),
                              Container(
                                padding: EdgeInsets.only(right: 20),
                                width: MediaQuery.of(mainContext).size.width * 0.03,
                                alignment: Alignment.centerRight,
                                child: FittedBox(
                                  child: Text((i + 1).toString() + '  ',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          color: colorController.bgColorContrast.value
                                              .withOpacity(0.5),
                                          fontFamily: fontFamily,
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                          fontStyle: FontStyle.italic)),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(mainContext).size.width * 0.90,
                                child: RichText(
                                  text: TextSpan(
                                    text: editController
                                        .fileContent[editController.activeFile.value]['content'][i],
                                    style: TextStyle(
                                      color: colorController.bgColorContrast.value.withOpacity(0.8),
                                      fontFamily: fontFamily,
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
        if (editController.editMode.value &&
            (editController.fileList[editController.activeFile.value]['activeLine'] !=
                (editController.fileContent[editController.activeFile.value]['content'].length -
                    1)))
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
                      (editController.fileContent[editController.activeFile.value]['content']
                                      .length -
                                  editController.fileList[editController.activeFile.value]
                                      ['activeLine'] >
                              (MediaQuery.of(mainContext).size.height / (3.2 * globalFontSize)))
                          ? (i <
                              editController.fileList[editController.activeFile.value]
                                      ['activeLine'] +
                                  (MediaQuery.of(mainContext).size.height / (3.2 * globalFontSize)))
                          : (i <
                              editController
                                  .fileContent[editController.activeFile.value]['content'].length);
                      i++)
                    Container(
                      width: MediaQuery.of(mainContext).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          (editController.fileList[editController.activeFile.value]['activeLine'] >
                                  1000)
                              ? (SizedBox(
                                  width: 20,
                                ))
                              : ((editController.fileList[editController.activeFile.value]
                                          ['activeLine'] >
                                      100)
                                  ? (SizedBox(
                                      width: 10,
                                    ))
                                  : (SizedBox(
                                      width: 5,
                                    ))),
                          Container(
                            padding: EdgeInsets.only(right: 20),
                            width: MediaQuery.of(mainContext).size.width * 0.03,
                            alignment: Alignment.centerRight,
                            child: FittedBox(
                              child: Text((i + 1).toString() + '  ',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: colorController.bgColorContrast.value.withOpacity(0.5),
                                      fontFamily: fontFamily,
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FontStyle.italic)),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(mainContext).size.width * 0.90,
                            child: RichText(
                              text: TextSpan(
                                text: editController.fileContent[editController.activeFile.value]
                                    ['content'][i],
                                style: TextStyle(
                                  color: colorController.bgColorContrast.value.withOpacity(0.8),
                                  fontFamily: fontFamily,
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
                                    cursorWidth: editController.fontSize.value / 1.8,
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
                                      editController.cacheText.value = text;
                                      editController.fileContent[editController.activeFile.value]
                                              ['content'][
                                          editController.fileList[editController.activeFile.value]
                                              ['activeLine']] = editController.cacheText.value;
                                    },
                                    onSubmitted: (text) {
                                      editController.fileContent[editController.activeFile.value]
                                              ['content'][
                                          editController.fileList[editController.activeFile.value]
                                              ['activeLine']] = text;
                                      editController.fileContent[editController.activeFile.value]
                                              ['content']
                                          .insert(
                                              editController
                                                          .fileList[editController.activeFile.value]
                                                      ['activeLine'] +
                                                  1,
                                              '');
                                      editController.fileList[editController.activeFile.value]
                                          ['activeLine'] += 1;
                                      textEditControl = TextEditingController(
                                          text: editController
                                                  .fileContent[editController.activeFile.value]
                                              ['content'][editController
                                                  .fileList[editController.activeFile.value]
                                              ['activeLine']]);
                                      editController.cacheText.value = textEditControl.text;
                                      editTextFocusNode.requestFocus();
                                      textEditControl.selection = TextSelection(
                                          baseOffset: textEditControl.text.length,
                                          extentOffset: textEditControl.text.length);
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
                          textEditControl = TextEditingController(
                              text: editController.fileContent[editController.activeFile.value]
                                      ['content'][
                                  editController.fileList[editController.activeFile.value]
                                      ['activeLine']]);
                          editTextFocusNode.requestFocus();
                          editModeTimer.onExecute.add(StopWatchExecute.start);
                        } else {
                          textEditControl = TextEditingController(text: '');
                          editTextFocusNode.unfocus();
                          homeViewFocusNode.requestFocus();
                          editModeTimer.onExecute.add(StopWatchExecute.stop);
                        }
                        editController.editMode.value = !(editController.editMode.value);
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyI)) {
                        if (editController.editMode.value &&
                            editController.fileList[editController.activeFile.value]['activeLine'] >
                                0) {
                          editController.fileList[editController.activeFile.value]['activeLine'] -=
                              1;
                          textEditControl = TextEditingController(
                              text: editController.fileContent[editController.activeFile.value]
                                      ['content'][
                                  editController.fileList[editController.activeFile.value]
                                      ['activeLine']]);
                          textEditControl.selection = TextSelection(
                              baseOffset: textEditControl.text.length,
                              extentOffset: textEditControl.text.length);
                        }
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyK)) {
                        if (editController.editMode.value &&
                            editController.fileList[editController.activeFile.value]['activeLine'] <
                                editController
                                        .fileContent[editController.activeFile.value]['content']
                                        .length -
                                    1) {
                          editController.fileList[editController.activeFile.value]['activeLine'] +=
                              1;
                          textEditControl = TextEditingController(
                              text: editController.fileContent[editController.activeFile.value]
                                      ['content'][
                                  editController.fileList[editController.activeFile.value]
                                      ['activeLine']]);
                          textEditControl.selection = TextSelection(
                              baseOffset: textEditControl.text.length,
                              extentOffset: textEditControl.text.length);
                        }
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyQ)) {
                        exit(0);
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyD)) {
                        colorController.darkModeChanger();
                      }
                    } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.backspace)) {
                      if (editController.editMode.value) {
                        if (((textEditControl.selection.start == 0) &&
                                (textEditControl.selection.end == 0)) &&
                            (editController.fileContent[editController.activeFile.value]['content']
                                    .length >
                                1) &&
                            (editController.fileList[editController.activeFile.value]
                                    ['activeLine'] !=
                                0)) {
                          int previousExtent = editController
                              .fileContent[editController.activeFile.value]['content'][
                                  editController.fileList[editController.activeFile.value]
                                          ['activeLine'] -
                                      1]
                              .length;
                          editController.fileList[editController.activeFile.value]['activeLine'] -=
                              1;
                          editTextFocusNode.unfocus();
                          textEditControl = TextEditingController(
                              text: editController.fileContent[editController.activeFile.value]
                                          ['content'][
                                      editController.fileList[editController.activeFile.value]
                                          ['activeLine']] +
                                  editController.fileContent[editController.activeFile.value]
                                      ['content'][editController
                                          .fileList[editController.activeFile.value]['activeLine'] +
                                      1]);
                          editController.cacheText.value = textEditControl.text;
                          editController.fileContent[editController.activeFile.value]['content'][
                              editController.fileList[editController.activeFile.value]
                                  ['activeLine']] = editController.cacheText.value;
                          editController.fileContent[editController.activeFile.value]['content']
                              .removeAt(editController.fileList[editController.activeFile.value]
                                      ['activeLine'] +
                                  1);
                          editTextFocusNode.requestFocus();
                          textEditControl.selection = TextSelection(
                              baseOffset: previousExtent, extentOffset: previousExtent);
                        }
                      }
                    } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.delete)) {
                      if (editController.editMode.value) {
                        print(textEditControl.selection.end);
                        if (((textEditControl.selection.start ==
                                    editController
                                        .fileContent[editController.activeFile.value]['content'][
                                            editController.fileList[editController.activeFile.value]
                                                ['activeLine']]
                                        .length) &&
                                (textEditControl.selection.end ==
                                    editController
                                        .fileContent[editController.activeFile.value]['content'][
                                            editController.fileList[editController.activeFile.value]
                                                ['activeLine']]
                                        .length)) &&
                            (editController.fileContent[editController.activeFile.value]['content']
                                    .length >
                                1) &&
                            (editController.fileList[editController.activeFile.value]['activeLine'] !=
                                (editController.fileContent[editController.activeFile.value]['content'].length - 1))) {
                          int originalExtent = textEditControl.selection.start;
                          editTextFocusNode.unfocus();
                          textEditControl = TextEditingController(
                              text: editController.fileContent[editController.activeFile.value]
                                          ['content'][
                                      editController.fileList[editController.activeFile.value]
                                          ['activeLine']] +
                                  editController.fileContent[editController.activeFile.value]
                                      ['content'][editController
                                          .fileList[editController.activeFile.value]['activeLine'] +
                                      1]);
                          editController.cacheText.value = textEditControl.text;
                          editController.fileContent[editController.activeFile.value]['content'][
                              editController.fileList[editController.activeFile.value]
                                  ['activeLine']] = editController.cacheText.value;
                          editController.fileContent[editController.activeFile.value]['content']
                              .removeAt(editController.fileList[editController.activeFile.value]
                                      ['activeLine'] +
                                  1);
                          editTextFocusNode.requestFocus();
                          textEditControl.selection = TextSelection(
                              baseOffset: originalExtent, extentOffset: originalExtent);
                        }
                      }
                    } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
                      if (editController.editMode.value &&
                          editController.fileList[editController.activeFile.value]['activeLine'] >
                              0) {
                        editController.fileList[editController.activeFile.value]['activeLine'] -= 1;
                        textEditControl = TextEditingController(
                            text: editController.fileContent[editController.activeFile.value]
                                    ['content'][
                                editController.fileList[editController.activeFile.value]
                                    ['activeLine']]);
                        textEditControl.selection = TextSelection(
                            baseOffset: textEditControl.text.length,
                            extentOffset: textEditControl.text.length);
                      }
                    } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
                      if (editController.editMode.value &&
                          editController.fileList[editController.activeFile.value]['activeLine'] <
                              editController.fileContent[editController.activeFile.value]['content']
                                      .length -
                                  1) {
                        editController.fileList[editController.activeFile.value]['activeLine'] += 1;
                        textEditControl = TextEditingController(
                            text: editController.fileContent[editController.activeFile.value]
                                    ['content'][
                                editController.fileList[editController.activeFile.value]
                                    ['activeLine']]);
                        textEditControl.selection = TextSelection(
                            baseOffset: textEditControl.text.length,
                            extentOffset: textEditControl.text.length);
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
                        (editController.editMode.value) ? ('M: Edit') : ('M: Ctrl'),
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
                        (editController.editMode.value)
                            ? ('E ' + editController.editModeTime.value)
                            : ('T ' + globalController.globalTime.value),
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
                              text: (editController
                                          .fileContent[editController.activeFile.value]['content']
                                          .length ==
                                      1)
                                  ? ('${editController.fileContent[editController.activeFile.value]['content'].length} Ln')
                                  : ('${editController.fileContent[editController.activeFile.value]['content'].length} Ln'),
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
                              text: (editController.editMode.value)
                                  ? ((editController
                                              .fileContent[editController.activeFile.value]
                                                  ['content'][editController
                                                          .fileList[editController.activeFile.value]
                                                      ['activeLine']]
                                              .length >
                                          1000)
                                      ? ('${(editController.fileContent[editController.activeFile.value]['content'][editController.fileList[editController.activeFile.value]['activeLine']].length / 1000).toStringAsFixed(1)}k Ch')
                                      : ('${editController.fileContent[editController.activeFile.value]['content'][editController.fileList[editController.activeFile.value]['activeLine']].length} Ch'))
                                  : (editController
                                          .fileContent[editController.activeFile.value]['content'][
                                              editController
                                                      .fileList[editController.activeFile.value]
                                                  ['activeLine']]
                                          .length
                                          .toString() +
                                      ' Ch'),
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
