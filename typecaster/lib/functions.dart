import 'package:flutter/material.dart';

import './main.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

void editModeStart() {
  textEditControl = TextEditingController(
      text: editController.fileContent[editController.activeFile.value]['content']
          [editController.fileList[editController.activeFile.value]['activeLine']]);
  editTextFocusNode.requestFocus();
  editModeTimer.onExecute.add(StopWatchExecute.start);
}

void editModeEnd() {
  textEditControl = TextEditingController(text: '');
  editTextFocusNode.unfocus();
  homeViewFocusNode.requestFocus();
  editModeTimer.onExecute.add(StopWatchExecute.stop);
}

void textChange(String text) {
  editController.cacheText.value = text;
  editController.fileContent[editController.activeFile.value]['content']
          [editController.fileList[editController.activeFile.value]['activeLine']] =
      editController.cacheText.value;
}

void textSubmit(String text) {
  if (textEditControl.selection.start == textEditControl.selection.end) {
    if (textEditControl.selection.start == textEditControl.text.length) {
      editController.fileContent[editController.activeFile.value]['content']
          [editController.fileList[editController.activeFile.value]['activeLine']] = text;
      editController.fileContent[editController.activeFile.value]['content']
          .insert(editController.fileList[editController.activeFile.value]['activeLine'] + 1, '');
      editController.fileList[editController.activeFile.value]['activeLine'] += 1;
      textEditControl = TextEditingController(
          text: editController.fileContent[editController.activeFile.value]['content']
              [editController.fileList[editController.activeFile.value]['activeLine']]);
      editController.cacheText.value = textEditControl.text;
      textEditControl.selection = TextSelection(
          baseOffset: textEditControl.text.length, extentOffset: textEditControl.text.length);
      editTextFocusNode.requestFocus();
    } else {
      String textStart = textEditControl.text.substring(0, textEditControl.selection.start);
      String textEnd = textEditControl.text.substring(textEditControl.selection.start);
      editController.fileContent[editController.activeFile.value]['content']
          [editController.fileList[editController.activeFile.value]['activeLine']] = textStart;
      editController.fileContent[editController.activeFile.value]['content'].insert(
          editController.fileList[editController.activeFile.value]['activeLine'] + 1, textEnd);
      editController.fileList[editController.activeFile.value]['activeLine'] += 1;
      textEditControl = TextEditingController(
          text: editController.fileContent[editController.activeFile.value]['content']
              [editController.fileList[editController.activeFile.value]['activeLine']]);
      editController.cacheText.value = textEditControl.text;
      textEditControl.selection = TextSelection(baseOffset: 0, extentOffset: 0);
      editTextFocusNode.requestFocus();
    }
  } else {
    String textStart = textEditControl.text.substring(0, textEditControl.selection.start);
    String textEnd = textEditControl.text.substring(textEditControl.selection.end);
    editController.fileContent[editController.activeFile.value]['content']
        [editController.fileList[editController.activeFile.value]['activeLine']] = textStart;
    editController.fileContent[editController.activeFile.value]['content'].insert(
        editController.fileList[editController.activeFile.value]['activeLine'] + 1, textEnd);
    editController.fileList[editController.activeFile.value]['activeLine'] += 1;
    textEditControl = TextEditingController(
        text: editController.fileContent[editController.activeFile.value]['content']
            [editController.fileList[editController.activeFile.value]['activeLine']]);
    editController.cacheText.value = textEditControl.text;
    textEditControl.selection = TextSelection(baseOffset: 0, extentOffset: 0);
    editTextFocusNode.requestFocus();
  }
}

String lineNumber(int i) {
  return ((i + 1).toString() + '  ');
}

Widget spacingLineNumber() {
  if (editController.fileList[editController.activeFile.value]['activeLine'] > 1000) {
    return SizedBox(
      width: 20,
    );
  } else {
    if (editController.fileList[editController.activeFile.value]['activeLine'] > 100) {
      return SizedBox(
        width: 10,
      );
    } else {
      return SizedBox(
        width: 5,
      );
    }
  }
}

///
int upperSectionLoopInitializer(BuildContext mainContext) {
  if (editController.fileList[editController.activeFile.value]['activeLine'] >=
      (MediaQuery.of(mainContext).size.height / (3.5 * editController.fontSize.value))) {
    return (editController.fileList[editController.activeFile.value]['activeLine'] -
        (MediaQuery.of(mainContext).size.height ~/ (3.5 * editController.fontSize.value)));
  } else {
    return 0;
  }
}

///
bool upperSectionloopCandidate(BuildContext mainContext, int i) {
  if (editController.editMode.value) {
    if (i < editController.fileList[editController.activeFile.value]['activeLine']) {
      return true;
    } else {
      return false;
    }
  } else {
    if (i <= editController.fileList[editController.activeFile.value]['activeLine']) {
      return true;
    } else {
      return false;
    }
  }
}

/// Checks if the Active line is the last line in the file, in which case the lower section is not valid and doesn't have to displayed.
bool lowerSectionValidity() {
  if (editController.editMode.value &&
      (editController.fileList[editController.activeFile.value]['activeLine'] !=
          (editController.fileContent[editController.activeFile.value]['content'].length - 1))) {
    return true;
  } else {
    return false;
  }
}

/// This determines the lines that should appear in the lower section. Adjusts the Line Count on display based on the height of the application window and the global font size.
bool lowerSectionLoopCandidate(BuildContext mainContext, int i) {
  if (editController.fileContent[editController.activeFile.value]['content'].length -
          editController.fileList[editController.activeFile.value]['activeLine'] >
      (MediaQuery.of(mainContext).size.height / (3.5 * editController.fontSize.value))) {
    if (i <
        editController.fileList[editController.activeFile.value]['activeLine'] +
            (MediaQuery.of(mainContext).size.height /
                (3.5 * editController.fontSize.value))) {
      return true;
    } else {
      return false;
    }
  } else {
    if (i < editController.fileContent[editController.activeFile.value]['content'].length) {
      return true;
    } else {
      return false;
    }
  }
}

/// Content of each line that is iterated over. One of the most important elements in the application, takes just one line.
String lineContent(int i) {
  return editController.fileContent[editController.activeFile.value]['content'][i];
}

/// Checks if the Active Line can be changed to the previous Line. It can't be changed if the Active Line is the first Line in the file.
bool upLineCandidate() {
  if (editController.editMode.value &&
      editController.fileList[editController.activeFile.value]['activeLine'] > 0) {
    return true;
  } else {
    return false;
  }
}

/// Checks if the Active Line can be changed to the next Line. It can't be changed if the Active Line is the last line in the file.
bool downLineCandidate() {
  if (editController.editMode.value &&
      editController.fileList[editController.activeFile.value]['activeLine'] <
          editController.fileContent[editController.activeFile.value]['content'].length - 1) {
    return true;
  } else {
    return false;
  }
}

/// Changes the active Line to the previous line and changes the value of the editable text.
void activeLineDecrement() {
  int cursorPosition = textEditControl.selection.start;
  editController.fileList[editController.activeFile.value]['activeLine'] -= 1;
  textEditControl = TextEditingController(
      text: editController.fileContent[editController.activeFile.value]['content']
          [editController.fileList[editController.activeFile.value]['activeLine']]);

  //Done to prevent cursor position index errors, and to retain cursor position of the previous line.
  if (textEditControl.text.length < cursorPosition) {
    textEditControl.selection = TextSelection(
        baseOffset: textEditControl.text.length, extentOffset: textEditControl.text.length);
  } else {
    textEditControl.selection =
        TextSelection(baseOffset: cursorPosition, extentOffset: cursorPosition);
  }
}

/// Changes the active Line to the next line and changes the value of the editable text.
void activeLineIncrement() {
  int cursorPosition = textEditControl.selection.start;
  editController.fileList[editController.activeFile.value]['activeLine'] += 1;
  textEditControl = TextEditingController(
      text: editController.fileContent[editController.activeFile.value]['content']
          [editController.fileList[editController.activeFile.value]['activeLine']]);

  //Done to prevent cursor position index errors, and to retain cursor position of the previous line.
  if (textEditControl.text.length < cursorPosition) {
    textEditControl.selection = TextSelection(
        baseOffset: textEditControl.text.length, extentOffset: textEditControl.text.length);
  } else {
    textEditControl.selection =
        TextSelection(baseOffset: cursorPosition, extentOffset: cursorPosition);
  }
}

/// Checks if the cusor position is at the end, in which case, the next line can be deleted after its content is added to the current line.
/// This will return false if the current line is the last line in the file.
bool deleteNextlineCandidate() {
  if (((textEditControl.selection.start ==
              editController
                  .fileContent[editController.activeFile.value]['content']
                      [editController.fileList[editController.activeFile.value]['activeLine']]
                  .length) &&
          (textEditControl.selection.end ==
              editController
                  .fileContent[editController.activeFile.value]['content']
                      [editController.fileList[editController.activeFile.value]['activeLine']]
                  .length)) &&
      (editController.fileContent[editController.activeFile.value]['content'].length > 1) &&
      (editController.fileList[editController.activeFile.value]['activeLine'] !=
          (editController.fileContent[editController.activeFile.value]['content'].length - 1))) {
    return true;
  } else {
    return false;
  }
}

/// Deletes the next line after copying its contents to the current line.
void deleteNewLine() {
  int originalExtent = textEditControl.selection.start;
  editTextFocusNode.unfocus();
  textEditControl = TextEditingController(
      text: editController.fileContent[editController.activeFile.value]['content']
              [editController.fileList[editController.activeFile.value]['activeLine']] +
          editController.fileContent[editController.activeFile.value]['content']
              [editController.fileList[editController.activeFile.value]['activeLine'] + 1]);
  editController.cacheText.value = textEditControl.text;
  editController.fileContent[editController.activeFile.value]['content']
          [editController.fileList[editController.activeFile.value]['activeLine']] =
      editController.cacheText.value;
  editController.fileContent[editController.activeFile.value]['content']
      .removeAt(editController.fileList[editController.activeFile.value]['activeLine'] + 1);
  editTextFocusNode.requestFocus();
  textEditControl.selection =
      TextSelection(baseOffset: originalExtent, extentOffset: originalExtent);
}

/// Checks if the cusor position is at the start, in which case, the current line can be deleted after its content is added to the previous line.
/// This will return false if the current line is the first line in the file.
bool backspaceCandidate() {
  if (((textEditControl.selection.start == 0) && (textEditControl.selection.end == 0)) &&
      (editController.fileContent[editController.activeFile.value]['content'].length > 1) &&
      (editController.fileList[editController.activeFile.value]['activeLine'] != 0)) {
    return true;
  } else {
    return false;
  }
}

/// Deletes the current line after copying its contents to the previous line.
void backspaceLine() {
  int previousExtent = editController
      .fileContent[editController.activeFile.value]['content']
          [editController.fileList[editController.activeFile.value]['activeLine'] - 1]
      .length;
  editController.fileList[editController.activeFile.value]['activeLine'] -= 1;
  editTextFocusNode.unfocus();
  textEditControl = TextEditingController(
      text: editController.fileContent[editController.activeFile.value]['content']
              [editController.fileList[editController.activeFile.value]['activeLine']] +
          editController.fileContent[editController.activeFile.value]['content']
              [editController.fileList[editController.activeFile.value]['activeLine'] + 1]);
  editController.cacheText.value = textEditControl.text;
  editController.fileContent[editController.activeFile.value]['content']
          [editController.fileList[editController.activeFile.value]['activeLine']] =
      editController.cacheText.value;
  editController.fileContent[editController.activeFile.value]['content']
      .removeAt(editController.fileList[editController.activeFile.value]['activeLine'] + 1);
  editTextFocusNode.requestFocus();
  textEditControl.selection =
      TextSelection(baseOffset: previousExtent, extentOffset: previousExtent);
}

String modeValue() {
  if (editController.editMode.value) {
    return 'M: Edit';
  } else {
    return 'M: Ctrl';
  }
}

/// Checks if the user is in Edit Mode and returns the appropriate Timer as a String value.
String modeTimerText() {
  if (editController.editMode.value) {
    return ('E ' + editController.editModeTime.value);
  } else {
    return ('T ' + globalController.globalTime.value);
  }
}

/// Returns the number of lines in the current active file.
String lineCount() {
  return (editController.fileContent[editController.activeFile.value]['content'].length.toString() +
      ' Ln');
}

/// Returns the number of characters in the current line.
///
/// If the line has more than 1000 characters, say for example 1350, it will be converted to 1.35k format
String lineCharacterCount() {
  if (editController.editMode.value) {
    if (editController
            .fileContent[editController.activeFile.value]['content']
                [editController.fileList[editController.activeFile.value]['activeLine']]
            .length >
        1000) {
      return ((editController
                      .fileContent[editController.activeFile.value]['content']
                          [editController.fileList[editController.activeFile.value]['activeLine']]
                      .length /
                  1000)
              .toStringAsFixed(1) +
          'k Ch');
    } else {
      return (editController
              .fileContent[editController.activeFile.value]['content']
                  [editController.fileList[editController.activeFile.value]['activeLine']]
              .length
              .toString() +
          ' Ch');
    }
  } else {
    return (editController
            .fileContent[editController.activeFile.value]['content']
                [editController.fileList[editController.activeFile.value]['activeLine']]
            .length
            .toString() +
        ' Ch');
  }
}
