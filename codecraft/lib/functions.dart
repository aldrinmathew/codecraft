import 'dart:io';

import 'package:codecraft/view/save_file.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  if (editController.characterChange.value < 10) {
    editController.characterChange.value++;
  } else {
    editController.characterChange.value = 0;
    autosave();
  }
  print(text.length);
  String alphanumeric = "ABCDEFGHIJKLMNOPQRSTUVW0123456789abcdefghijklmnopqrstuvwxyz";
  if (text.length != 0 && (textEditControl.selection.start != 0)) {
    int cursorPosition = textEditControl.selection.start;
    String lastCharacter = text.substring(cursorPosition - 1, cursorPosition);
    if (!(alphanumeric.contains(lastCharacter))) {
      if (editController.isAlphaNum.value) {
        editController.wordCount.value++;
        editController.isAlphaNum.value = false;
      }
    } else {
      editController.isAlphaNum.value = true;
    }
  }
  if (editController.cacheText.value.length < text.length) {
    editController.characterCount.value++;
  }
  editController.cacheText.value = text;
  editController.fileContent[editController.activeFile.value]['content']
          [editController.fileList[editController.activeFile.value]['activeLine']] =
      editController.cacheText.value;
  editController.fileList[editController.activeFile.value]['saved'] = false;
}

void textSubmit(String text) {
  editController.wordCount.value++;
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
      textEditControl.selection = TextSelection.collapsed(offset: textEditControl.text.length);
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
      textEditControl.selection = TextSelection.collapsed(offset: 0);
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
    textEditControl.selection = TextSelection.collapsed(offset: 0);
    editTextFocusNode.requestFocus();
  }
  editController.fileList[editController.activeFile.value]['saved'] = false;
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
            (MediaQuery.of(mainContext).size.height / (3.5 * editController.fontSize.value))) {
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

/// Content of each line that is iterated over. One of the most important elements in the application, takes just a lot of lines, now that parse tree is generated.
List<InlineSpan> lineContent(int i) {
  String indentation = '';
  String alpha = 'ABCDEFGHIJKLMNOPQRSTUVWabcdefghijklmnopqrstuvwxyz_';
  String alphanumeric = 'ABCDEFGHIJKLMNOPQRSTUVW0123456789abcdefghijklmnopqrstuvwxyz_';
  String lineContent = editController.fileContent[editController.activeFile.value]['content'][i];
  List<InlineSpan> returnSpan = [];
  for (int j = 0; j < lineContent.length; j++) {
    if (lineContent[j] == '\t') {
      indentation = '';
      for (int t = 0;
          t < editController.tabSpace.value - (j % editController.tabSpace.value);
          t++) {
        indentation += ' ';
      }
      returnSpan.add(TextSpan(
        text: indentation,
      ));
    } else if (alpha.contains(lineContent[j])) {
      String text = '';
      int k;
      for (k = j;
          (k != lineContent.length) ? (alphanumeric.contains(lineContent[k])) : (false);
          k++) {
        text += lineContent[k];
      }
      returnSpan.add(TextSpan(
        text: text,
      ));
      j = k - 1;
      continue;
    } else {
      returnSpan.add(TextSpan(
        text: lineContent[j],
      ));
    }
  }
  return returnSpan;
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

/// Changes the active Line to the previous lines based on the decrement factor and changes the value of the editable text.
void activeLineDecrement(int decrementFactor) {
  int cursorPosition = textEditControl.selection.start;
  if ((editController.fileList[editController.activeFile.value]['activeLine'] - decrementFactor) >=
      0) {
    editController.fileList[editController.activeFile.value]['activeLine'] -= decrementFactor;
  } else {
    editController.fileList[editController.activeFile.value]['activeLine'] = 0;
  }
  textEditControl = TextEditingController(
      text: editController.fileContent[editController.activeFile.value]['content']
          [editController.fileList[editController.activeFile.value]['activeLine']]);

  //Done to prevent cursor position index errors, and to retain cursor position of the previous line.
  if (textEditControl.text.length < cursorPosition) {
    textEditControl.selection = TextSelection.collapsed(offset: textEditControl.text.length);
  } else {
    textEditControl.selection = TextSelection.collapsed(offset: cursorPosition);
  }
}

/// Changes the active Line to the next line and changes the value of the editable text.
void activeLineIncrement(int incrementFactor) {
  int cursorPosition = textEditControl.selection.start;
  if ((editController.fileList[editController.activeFile.value]['activeLine'] + incrementFactor) <
      editController.fileContent[editController.activeFile.value]['content'].length) {
    editController.fileList[editController.activeFile.value]['activeLine'] += incrementFactor;
  } else {
    editController.fileList[editController.activeFile.value]['activeLine'] =
        editController.fileContent[editController.activeFile.value]['content'].length - 1;
  }
  textEditControl = TextEditingController(
      text: editController.fileContent[editController.activeFile.value]['content']
          [editController.fileList[editController.activeFile.value]['activeLine']]);

  //Done to prevent cursor position index errors, and to retain cursor position of the previous line.
  if (textEditControl.text.length < cursorPosition) {
    textEditControl.selection = TextSelection.collapsed(offset: textEditControl.text.length);
  } else {
    textEditControl.selection = TextSelection.collapsed(offset: cursorPosition);
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
  textEditControl.selection = TextSelection.collapsed(offset: originalExtent);
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
  textEditControl.selection = TextSelection.collapsed(offset: previousExtent);
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

void endOfLineChange() {
  if (editController.endOfLine.value == 'LF') {
    editController.endOfLine.value = 'CRLF';
  } else {
    editController.endOfLine.value = 'LF';
  }
}

void fileendOfLineChange(String eol) {
  editController.fileList[editController.activeFile.value]['endOfLine'] = eol;
}

void createNewFile({String fileName, String filePath = ''}) {
  String fileExtension = '';
  if (fileName != '') {
    if (fileName.contains('.')) {
      fileExtension = fileName.split('.')[fileName.split('.').length - 1];
      fileName = fileName.substring(0, fileName.length - fileExtension.length - 1);
    }
  }
  int fileID = editController.fileList[editController.fileList.length - 1]['fileID'] + 1;
  Map<String, dynamic> newFile = {
    'fileID': fileID,
    'fileName': fileName,
    'extension': fileExtension,
    'activeLine': 0,
    'path': filePath,
    'endOfLine': 'system',
    'encoding': 'UTF-8',
    'onDisk': false,
    'saved': true,
  };
  Map<String, List<String>> newFileContent = {
    'content': [
      '',
    ],
  };
  editController.fileList.insert(editController.activeFile.value + 1, newFile);
  editController.fileContent.insert(editController.activeFile.value + 1, newFileContent);
  editController.cacheText.value = '';
  textEditControl = TextEditingController(text: editController.cacheText.value);
}

String readFile(File openFile) {
  Map<String, String> readErrorCodes = {
    'ER-READ-1': 'The File encoding is not supported. Read failed.',
  };
  editController.fileList[editController.activeFile.value]['onDisk'] = true;
  try {
    editController.fileContent[editController.activeFile.value]['content'] =
        openFile.readAsLinesSync();
  } catch (error) {
    editController.activeFile.value--;
    editController.fileContent.removeAt(editController.activeFile.value + 1);
    if(error.toString().contains("Failed to decode data using encoding")) {
      return readErrorCodes['ER-READ-1'];
    } else {
      return error.toString();
    }
  }
  editController.fileList[editController.activeFile.value]['activeLine'] = 0;
  return '';
}

void previousFile() {
  if (editController.activeFile.value > 0) {
    editController.activeFile.value--;
    editController.cacheText.value = editController.fileContent[editController.activeFile.value]
        ['content'][editController.fileList[editController.activeFile.value]['activeLine']];
    textEditControl = TextEditingController(text: editController.cacheText.value);
    editTextFocusNode.requestFocus();
    textEditControl.selection = TextSelection.collapsed(offset: textEditControl.text.length);
  }
}

void nextFile() {
  if (editController.activeFile.value < editController.fileList.length - 1) {
    editController.activeFile.value++;
    editController.cacheText.value = editController.fileContent[editController.activeFile.value]
        ['content'][editController.fileList[editController.activeFile.value]['activeLine']];
    textEditControl = TextEditingController(text: editController.cacheText.value);
    editTextFocusNode.requestFocus();
    textEditControl.selection = TextSelection.collapsed(offset: textEditControl.text.length);
  }
}

void saveFilePrepare() {
  File saveFile;
  if (editController.fileList[editController.activeFile.value]['extension'] != '') {
    saveFile = File(directory.path +
        editController.fileList[editController.activeFile.value]['fileName'] +
        '.' +
        editController.fileList[editController.activeFile.value]['extension']);
  } else {
    saveFile =
        File(directory.path + editController.fileList[editController.activeFile.value]['fileName']);
  }
  saveFileWrite(saveFile);
  editController.fileList[editController.activeFile.value]['saved'] = true;
}

void saveFileWrite(File saveFile) {
  String fileContent = '';
  for (int i = 0;
      i < editController.fileContent[editController.activeFile.value]['content'].length;
      i++) {
    fileContent += (editController.fileContent[editController.activeFile.value]['content'][i]);
    if (editController.fileList[editController.activeFile.value]['endOfLine'] == 'system') {
      if (i !=
          (editController.fileContent[editController.activeFile.value]['content'].length - 1)) {
        if (editController.endOfLine.value == 'LF') {
          fileContent += '\n';
        } else {
          fileContent += '\r\n';
        }
      }
    } else {
      if (editController.fileList[editController.activeFile.value]['endOfLine'] == 'LF') {
        if (i !=
            (editController.fileContent[editController.activeFile.value]['content'].length - 1)) {
          if (editController.fileList[editController.activeFile.value]['endOfLine'] == 'LF') {
            fileContent += '\n';
          } else {
            fileContent += '\r\n';
          }
        }
      }
    }
  }
  saveFile.writeAsString(fileContent, mode: FileMode.write);
}

void saveNewFile() {
  String fileExtension = '';
  if (saveController.saveFileName.value.contains('.')) {
    List<String> fileNameContent = saveController.saveFileName.value.split('.');
    saveController.saveFileName.value = '';
    for (int i = 0; i < (fileNameContent.length - 1); i++) {
      saveController.saveFileName.value += fileNameContent[i];
    }
    fileExtension = fileNameContent[fileNameContent.length - 1];
  }
  File saveFile;
  if (fileExtension != '') {
    saveFile = File(saveController.saveFilePath.value +
        saveController.saveFileName.value +
        '.' +
        fileExtension);
  } else {
    saveFile = File(saveController.saveFilePath.value + saveController.saveFileName.value);
  }
  saveFileWrite(saveFile);
  editController.fileList[editController.activeFile.value]['fileName'] =
      saveController.saveFileName.value;
  editController.fileList[editController.activeFile.value]['extension'] = fileExtension;
  editController.fileList[editController.activeFile.value]['path'] =
      saveController.saveFilePath.value;
  editController.fileList[editController.activeFile.value]['onDisk'] = true;
  editController.fileList[editController.activeFile.value]['saved'] = true;
}

void autosave() {
  File saveFile;
  if (editController.fileList[editController.activeFile.value]['extension'] != '') {
    saveFile = File(directory.path +
        '.codecraft/autosave/' +
        editController.fileList[editController.activeFile.value]['fileName'] +
        '_autosave' +
        '.' +
        editController.fileList[editController.activeFile.value]['extension']);
    saveFile.create(recursive: true);
  } else {
    saveFile = File(directory.path +
        '.codecraft/autosave/' +
        editController.fileList[editController.activeFile.value]['fileName'] +
        '_autosave');
    saveFile.create(recursive: true);
  }
  String fileContent = '';
  for (int i = 0;
      i < editController.fileContent[editController.activeFile.value]['content'].length;
      i++) {
    fileContent += (editController.fileContent[editController.activeFile.value]['content'][i]);
    if (editController.fileList[editController.activeFile.value]['endOfLine'] == 'system') {
      if (i !=
          (editController.fileContent[editController.activeFile.value]['content'].length - 1)) {
        if (editController.endOfLine.value == 'LF') {
          fileContent += '\n';
        } else {
          fileContent += '\r\n';
        }
      }
    } else {
      if (editController.fileList[editController.activeFile.value]['endOfLine'] == 'LF') {
        if (i !=
            (editController.fileContent[editController.activeFile.value]['content'].length - 1)) {
          if (editController.fileList[editController.activeFile.value]['endOfLine'] == 'LF') {
            fileContent += '\n';
          } else {
            fileContent += '\r\n';
          }
        }
      }
    }
  }
  saveFile.writeAsString(fileContent, mode: FileMode.write);
  editController.fileList[editController.activeFile.value]['saved'] = true;
}

void tabKeyHandler() {
  String text = textEditControl.text;
  int cursorStart = textEditControl.selection.start;
  int cursorEnd = textEditControl.selection.end;
  editTextFocusNode.unfocus();
  editTextFocusNode.requestFocus();
  textEditControl = TextEditingController(
      text: text.substring(0, cursorStart) + '\t' + text.substring(cursorEnd));
  editController.cacheText.value = text;
  editController.fileContent[editController.activeFile.value]['content']
          [editController.fileList[editController.activeFile.value]['activeLine']] =
      editController.cacheText.value;
  editController.fileList[editController.activeFile.value]['saved'] = false;
  textEditControl.selection = TextSelection.collapsed(offset: cursorEnd + 1);
}

void autoCompleteBasic(String character) {
  Map<String, String> characterMapping = {
    '[': ']',
    '(': ')',
    '{': '}',
    '"': '"',
    '\'': '\'',
    '<': '>'
  };
  int cursorStart = textEditControl.selection.start;
  int cursorEnd = textEditControl.selection.end;
  String text = textEditControl.text;
  textEditControl = TextEditingController(
      text: text.substring(0, cursorStart) +
          character +
          text.substring(cursorStart, cursorEnd) +
          characterMapping[character] +
          text.substring(cursorEnd));
  editController.cacheText.value = textEditControl.text;
  editController.fileContent[editController.activeFile.value]['content']
          [editController.fileList[editController.activeFile.value]['activeLine']] =
      editController.cacheText.value;
  textEditControl.selection =
      TextSelection(baseOffset: cursorStart + 1, extentOffset: cursorEnd + 1);
}

void addCurrentTime() {
  DateFormat dateFormat = DateFormat.jms('en_US');
  String dateTime = dateFormat.format(DateTime.now());
  String text = textEditControl.text;
  int offset;
  int offsetEnd;
  if (textEditControl.selection.start == textEditControl.selection.end) {
    offset = textEditControl.selection.start;
    text = text.substring(0, offset) + dateTime + text.substring(offset);
  } else {
    offset = textEditControl.selection.start;
    offsetEnd = textEditControl.selection.end;
    text = text.substring(0, offset) + dateTime + text.substring(offsetEnd);
  }
  textEditControl = TextEditingController(text: text);
  if (textEditControl.selection.start != textEditControl.selection.end) {
    textEditControl.selection =
        TextSelection(baseOffset: offset, extentOffset: offset + dateTime.length);
  } else {
    textEditControl.selection = TextSelection.collapsed(offset: offset + dateTime.length);
  }
  editTextFocusNode.requestFocus();
}
