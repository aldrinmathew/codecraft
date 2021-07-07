import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import './main.dart';
import 'package:codecraft/view/save_file.dart';
import 'package:codecraft/model/syntax.dart';

void editModeStart() {
  textEdit = TextEditingController(
    text: edit.activeLine,
  );
  editTextFocusNode.requestFocus();
  editModeTimer.onExecute.add(StopWatchExecute.start);
}

void editModeEnd() {
  textEdit = TextEditingController(text: '');
  editTextFocusNode.unfocus();
  homeViewFocusNode.requestFocus();
  editModeTimer.onExecute.add(StopWatchExecute.stop);
}

void textChange(String text) {
  if (edit.characterChange.value < 10) {
    edit.characterChange.value++;
  } else {
    edit.characterChange.value = 0;
    autosave();
  }
  String alphanumeric = "ABCDEFGHIJKLMNOPQRSTUVW0123456789abcdefghijklmnopqrstuvwxyz";
  if (text.length != 0 && (textEdit.selection.start != 0)) {
    int cursorPosition = textEdit.selection.start;
    String lastCharacter = text.substring(cursorPosition - 1, cursorPosition);
    if (!(alphanumeric.contains(lastCharacter))) {
      if (edit.isAlphaNum.value) {
        edit.wordCount.value++;
        edit.isAlphaNum.value = false;
      }
    } else {
      edit.isAlphaNum.value = true;
    }
  }
  if (edit.cacheText.value.length < text.length) {
    edit.characterCount.value++;
  }
  edit.cacheText.value = text;
  edit.activeLine = edit.cacheText.value;
  edit.fileList[edit.activeFile.value]['saved'] = false;
}

void textSubmit(String text) {
  edit.wordCount.value++;
  if (textEdit.selection.start == textEdit.selection.end) {
    if (textEdit.selection.start == textEdit.text.length) {
      edit.activeLine = text;
      edit.insertContent(
        index: edit.activeLineIndex + 1,
        content: '',
      );
      edit.activeLineIndex += 1;
      textEdit = TextEditingController(text: edit.activeLine);
      edit.cacheText.value = textEdit.text;
      textEdit.selection = TextSelection.collapsed(offset: textEdit.text.length);
      editTextFocusNode.requestFocus();
    } else {
      String textStart = textEdit.text.substring(0, textEdit.selection.start);
      String textEnd = textEdit.text.substring(textEdit.selection.start);
      edit.activeLine = textStart;
      edit.insertContent(
        index: edit.activeLineIndex + 1,
        content: textEnd,
      );
      edit.activeLineIndex += 1;
      textEdit = TextEditingController(
          text: edit.fileContent[edit.activeFile.value]['content']![edit.activeLineIndex]);
      edit.cacheText.value = textEdit.text;
      textEdit.selection = TextSelection.collapsed(offset: 0);
      editTextFocusNode.requestFocus();
    }
  } else {
    String textStart = textEdit.text.substring(0, textEdit.selection.start);
    String textEnd = textEdit.text.substring(textEdit.selection.end);
    edit.activeLine = textStart;
    edit.insertContent(
      index: edit.activeLineIndex + 1,
      content: textEnd,
    );
    edit.activeLineIndex += 1;
    textEdit = TextEditingController(
        text: edit.fileContent[edit.activeFile.value]['content']![edit.activeLineIndex]);
    edit.cacheText.value = textEdit.text;
    textEdit.selection = TextSelection.collapsed(offset: 0);
    editTextFocusNode.requestFocus();
  }
  edit.fileList[edit.activeFile.value]['saved'] = false;
}

String lineNumber(int i) {
  return ((i + 1).toString() + '  ');
}

Widget spacingLineNumber() {
  if (edit.activeLineIndex > 1000) {
    return SizedBox(
      width: 20,
    );
  } else {
    if (edit.activeLineIndex > 100) {
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
  if (edit.activeLineIndex >=
      (MediaQuery.of(mainContext).size.height / (3.5 * edit.fontSize.value))) {
    return (edit.activeLineIndex -
        (MediaQuery.of(mainContext).size.height ~/ (3.5 * edit.fontSize.value)));
  } else {
    return 0;
  }
}

///
bool upperSectionloopCandidate(BuildContext mainContext, int i) {
  if (edit.editMode.value) {
    if (i < edit.activeLineIndex) {
      return true;
    } else {
      return false;
    }
  } else {
    if (i <= edit.activeLineIndex) {
      return true;
    } else {
      return false;
    }
  }
}

/// Checks if the Active line is the last line in the file, in which case the lower section is not valid and doesn't have to displayed.
bool lowerSectionValidity() {
  if (edit.editMode.value &&
      (edit.activeLineIndex != (edit.fileContent[edit.activeFile.value]['content']!.length - 1))) {
    return true;
  } else {
    return false;
  }
}

/// This determines the lines that should appear in the lower section. Adjusts the Line Count on display based on the height of the application window and the global font size.
bool lowerSectionLoopCandidate(BuildContext mainContext, int i) {
  if (edit.fileContent[edit.activeFile.value]['content']!.length - edit.activeLineIndex >
      (MediaQuery.of(mainContext).size.height / (3.5 * edit.fontSize.value))) {
    if (i <
        edit.activeLineIndex +
            (MediaQuery.of(mainContext).size.height / (3.5 * edit.fontSize.value))) {
      return true;
    } else {
      return false;
    }
  } else {
    if (i < edit.fileContent[edit.activeFile.value]['content']!.length) {
      return true;
    } else {
      return false;
    }
  }
}

int readIndex = 0;

/// Content of each line that is iterated over. One of the most important elements in the application, takes just a lot of lines, now that parse tree is generated.
List<InlineSpan> lineContent(int i) {
  String indentation = '';
  String alpha = 'ABCDEFGHIJKLMNOPQRSTUVWabcdefghijklmnopqrstuvwxyz_';
  String alphanumeric = 'ABCDEFGHIJKLMNOPQRSTUVW0123456789abcdefghijklmnopqrstuvwxyz_';
  String lineContent = edit.fileContent[edit.activeFile.value]['content']![i];
  List<InlineSpan> returnSpan = [];
  for (int j = 0; j < lineContent.length; j++) {
    if (lineContent[j] == '\t') {
      indentation = '';
      for (int t = 0; t < edit.tabSpace.value - (j % edit.tabSpace.value); t++) {
        indentation += ' ';
      }
      returnSpan.add(TextSpan(
        text: indentation,
        style: highlightHandler(edit.fileList[edit.activeFile.value]['syntax'], lineContent[j]),
      ));
    } else if (ruleCheck(
            edit.fileList[edit.activeFile.value]['syntax'], lineContent.substring(j)) !=
        -1) {
      int ruleIndex = ruleCheck(
        edit.fileList[edit.activeFile.value]['syntax'],
        lineContent[j],
      );
      Map<String, dynamic> rule = ruleLanguage(
        edit.fileList[edit.activeFile.value]['syntax'],
        ruleIndex,
      );
      List<InlineSpan> temporarySpans = ruleHandler(rule, j, lineContent);
      returnSpan.addAll(temporarySpans);
      j = readIndex;
      if (!(j < lineContent.length)) {
        j = lineContent.length - 1;
      }
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
        style: highlightHandler(edit.fileList[edit.activeFile.value]['syntax'], text),
      ));
      if (k <= lineContent.length) {
        j = k - 1;
      } else {
        j = lineContent.length - 1;
      }
      continue;
    } else {
      returnSpan.add(TextSpan(
        text: lineContent[j],
        style: highlightHandler(edit.fileList[edit.activeFile.value]['syntax'], lineContent[j]),
      ));
    }
  }
  return returnSpan;
}

String text = '';

List<InlineSpan> ruleHandler(Map<String, dynamic> rule, int j, String lineContent) {
  if (text == '') {
    text = lineContent[j];
  }
  List<InlineSpan> totalSpans = [];
  if (rule['rule'] == 'upto') {
    String end = rule['last'];
    int k = 0;
    for (k = j + text.length; (k < lineContent.length) ? (lineContent[k] != end) : (false); k++) {
      if (rule['separate'].length != 0) {
        for (int l = 0; l < rule['separate'].length; l++) {
          String separator = rule['separate'][l];
          if (lineContent[k] == separator) {
            if (text != '') {
              totalSpans.add(TextSpan(
                text: text,
                style: highlightHandler(edit.fileList[edit.activeFile.value]['syntax'], text),
              ));
            }
            int newRuleIndex = ruleCheck(
              edit.fileList[edit.activeFile.value]['syntax'],
              separator,
            );
            Map<String, dynamic> newRule = ruleLanguage(
              edit.fileList[edit.activeFile.value]['syntax'],
              newRuleIndex,
            );
            text = separator;
            List<InlineSpan> temporarySpan = ruleHandler(newRule, k, lineContent);
            totalSpans.addAll(temporarySpan);
            k = readIndex;
          } else {
            text += lineContent[k];
          }
        }
      } else {
        text += lineContent[k];
      }
    }
    if (!(k < lineContent.length)) {
      k = lineContent.length - 1;
    }
    if ((lineContent[k] == end) && (rule['includeLast'] == true)) {
      text += lineContent[k];
    }
    if (text != '') {
      totalSpans.add(TextSpan(
        text: text,
        style: highlightHandler(edit.fileList[edit.activeFile.value]['syntax'], text),
      ));
      text = '';
    }
    readIndex = k;
  } else if (rule['rule'] == 'till') {
    int k = 0;
    for (k = j + text.length;
        (rule['count'] == 'end')
            ? (k < lineContent.length)
            : ((k < (k + rule['count'])) && (k < lineContent.length));
        k++) {
      if (rule['separate'].length != 0) {
        for (int l = 0; l < rule['separate'].length; l++) {
          String separator = rule['separate'][l];
          if (lineContent.substring(k, separator.length) == separator) {
            if (text != '') {
              totalSpans.add(TextSpan(
                text: text,
                style: highlightHandler(edit.fileList[edit.activeFile.value]['syntax'], text),
              ));
            }
            int newRuleIndex = ruleCheck(
              edit.fileList[edit.activeFile.value]['syntax'],
              separator,
            );
            Map<String, dynamic> newRule = ruleLanguage(
              edit.fileList[edit.activeFile.value]['syntax'],
              newRuleIndex,
            );
            text = separator;
            List<InlineSpan> temporarySpan = ruleHandler(newRule, k, lineContent);
            totalSpans.addAll(temporarySpan);
            k = readIndex;
          } else {
            if (rule['include'] == true) {
              text += lineContent[k];
            }
          }
        }
      } else {
        if (rule['include'] == true) {
          text += lineContent[k];
        }
      }
    }
    if (text != '') {
      totalSpans.add(TextSpan(
        text: text,
        style: highlightHandler(edit.fileList[edit.activeFile.value]['syntax'], text),
      ));
      text = '';
    }
    readIndex = k;
  }
  return totalSpans;
}

/// Checks if the Active Line can be changed to the previous Line. It can't be changed if the Active Line is the first Line in the file.
bool upLineCandidate() {
  if (edit.editMode.value && edit.activeLineIndex > 0) {
    return true;
  } else {
    return false;
  }
}

/// Checks if the Active Line can be changed to the next Line. It can't be changed if the Active Line is the last line in the file.
bool downLineCandidate() {
  if (edit.editMode.value &&
      edit.activeLineIndex < edit.fileContent[edit.activeFile.value]['content']!.length - 1) {
    return true;
  } else {
    return false;
  }
}

/// Changes the active Line to the previous lines based on the decrement factor and changes the value of the editable text.
void activeLineDecrement(int decrementFactor) {
  int cursorPosition = textEdit.selection.start;
  if ((edit.activeLineIndex - decrementFactor) >= 0) {
    edit.activeLineIndex -= decrementFactor;
  } else {
    edit.activeLineIndex = 0;
  }
  textEdit = TextEditingController(text: edit.activeLine);

  //Done to prevent cursor position index errors, and to retain cursor position of the previous line.
  if (textEdit.text.length < cursorPosition) {
    textEdit.selection = TextSelection.collapsed(offset: textEdit.text.length);
  } else {
    textEdit.selection = TextSelection.collapsed(offset: cursorPosition);
  }
}

/// Changes the active Line to the next line and changes the value of the editable text.
void activeLineIncrement(int incrementFactor) {
  int cursorPosition = textEdit.selection.start;
  if ((edit.activeLineIndex + incrementFactor) <
      edit.fileContent[edit.activeFile.value]['content']!.length) {
    edit.activeLineIndex += incrementFactor;
  } else {
    edit.activeLineIndex = edit.fileContent[edit.activeFile.value]['content']!.length - 1;
  }
  textEdit = TextEditingController(text: edit.activeLine);

  //Done to prevent cursor position index errors, and to retain cursor position of the previous line.
  if (textEdit.text.length < cursorPosition) {
    textEdit.selection = TextSelection.collapsed(offset: textEdit.text.length);
  } else {
    textEdit.selection = TextSelection.collapsed(offset: cursorPosition);
  }
}

/// Checks if the cusor position is at the end, in which case, the next line can be deleted after its content is added to the current line.
/// This will return false if the current line is the last line in the file.
bool deleteNextlineCandidate() {
  if (((textEdit.selection.start ==
              edit.fileContent[edit.activeFile.value]['content']![edit.activeLineIndex].length) &&
          (textEdit.selection.end ==
              edit.fileContent[edit.activeFile.value]['content']![edit.activeLineIndex].length)) &&
      (edit.fileContent[edit.activeFile.value]['content']!.length > 1) &&
      (edit.activeLineIndex != (edit.fileContent[edit.activeFile.value]['content']!.length - 1))) {
    return true;
  } else {
    return false;
  }
}

/// Deletes the next line after copying its contents to the current line.
void deleteNewLine() {
  int originalExtent = textEdit.selection.start;
  editTextFocusNode.unfocus();
  textEdit = TextEditingController(
      text: edit.fileContent[edit.activeFile.value]['content']![edit.activeLineIndex] +
          edit.fileContent[edit.activeFile.value]['content']![edit.activeLineIndex + 1]);
  edit.cacheText.value = textEdit.text;
  edit.activeLine = edit.cacheText.value;
  edit.fileContent[edit.activeFile.value]['content']!.removeAt(edit.activeLineIndex + 1);
  editTextFocusNode.requestFocus();
  textEdit.selection = TextSelection.collapsed(offset: originalExtent);
}

/// Checks if the cusor position is at the start, in which case, the current line can be deleted after its content is added to the previous line.
/// This will return false if the current line is the first line in the file.
bool backspaceCandidate() {
  if (((textEdit.selection.start == 0) && (textEdit.selection.end == 0)) &&
      (edit.fileContent[edit.activeFile.value]['content']!.length > 1) &&
      (edit.activeLineIndex != 0)) {
    return true;
  } else {
    return false;
  }
}

/// Deletes the current line after copying its contents to the previous line.
void backspaceLine() {
  int previousExtent =
      edit.fileContent[edit.activeFile.value]['content']![edit.activeLineIndex - 1].length;
  edit.activeLineIndex -= 1;
  editTextFocusNode.unfocus();
  textEdit = TextEditingController(
      text: edit.fileContent[edit.activeFile.value]['content']![edit.activeLineIndex] +
          edit.fileContent[edit.activeFile.value]['content']![edit.activeLineIndex + 1]);
  edit.cacheText.value = textEdit.text;
  edit.activeLine = edit.cacheText.value;
  edit.fileContent[edit.activeFile.value]['content']!.removeAt(edit.activeLineIndex + 1);
  editTextFocusNode.requestFocus();
  textEdit.selection = TextSelection.collapsed(offset: previousExtent);
}

String modeValue() {
  if (edit.editMode.value) {
    return 'M: Edit';
  } else {
    return 'M: Ctrl';
  }
}

/// Checks if the user is in Edit Mode and returns the appropriate Timer as a String value.
String modeTimerText() {
  if (edit.editMode.value) {
    return ('E ' + edit.editModeTime.value);
  } else {
    return ('T ' + globalController.globalTime.value);
  }
}

/// Returns the number of lines in the current active file.
String lineCount() {
  return (edit.fileContent[edit.activeFile.value]['content']!.length.toString() + ' Ln');
}

/// Returns the number of characters in the current line.
///
/// If the line has more than 1000 characters, say for example 1350, it will be converted to 1.35k format
String lineCharacterCount() {
  if (edit.editMode.value) {
    if (edit.fileContent[edit.activeFile.value]['content']![edit.activeLineIndex].length > 1000) {
      return ((edit.fileContent[edit.activeFile.value]['content']![edit.activeLineIndex].length /
                  1000)
              .toStringAsFixed(1) +
          'k Ch');
    } else {
      return (edit.fileContent[edit.activeFile.value]['content']![edit.activeLineIndex].length
              .toString() +
          ' Ch');
    }
  } else {
    return (edit.fileContent[edit.activeFile.value]['content']![edit.activeLineIndex].length
            .toString() +
        ' Ch');
  }
}

void endOfLineChange() {
  if (edit.endOfLine.value == 'LF') {
    edit.endOfLine.value = 'CRLF';
  } else {
    edit.endOfLine.value = 'LF';
  }
}

void fileendOfLineChange(String eol) {
  edit.fileList[edit.activeFile.value]['endOfLine'] = eol;
}

void createNewFile({required String fileName, String filePath = ''}) {
  String fileExtension = '';
  if (fileName != '') {
    if (fileName.contains('.')) {
      fileExtension = fileName.split('.')[fileName.split('.').length - 1];
      fileName = fileName.substring(0, fileName.length - fileExtension.length - 1);
    }
  }
  int fileID = edit.fileList[edit.fileList.length - 1]['fileID'] + 1;
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
    'syntax': fileExtension,
  };
  Map<String, List<String>> newFileContent = {
    'content': [
      '',
    ],
  };
  edit.fileList.insert(edit.activeFile.value + 1, newFile);
  edit.fileContent.insert(edit.activeFile.value + 1, newFileContent);
  edit.cacheText.value = '';
  textEdit = TextEditingController(text: edit.cacheText.value);
}

String readFile(File openFile) {
  Map<String, String> readErrorCodes = {
    'ER-READ-1': 'The File encoding is not supported. Read failed.',
  };
  edit.fileList[edit.activeFile.value]['onDisk'] = true;
  try {
    edit.fileContent[edit.activeFile.value]['content'] = openFile.readAsLinesSync();
  } catch (error) {
    edit.activeFile.value--;
    edit.fileContent.removeAt(edit.activeFile.value + 1);
    if (error.toString().contains("Failed to decode data using encoding")) {
      return readErrorCodes['ER-READ-1']!;
    } else {
      return error.toString();
    }
  }
  edit.activeLineIndex = 0;
  return '';
}

void previousFile() {
  if (edit.activeFile.value > 0) {
    edit.activeFile.value--;
    edit.cacheText.value = edit.fileContent[edit.activeFile.value]['content']![edit.activeLineIndex];
    textEdit = TextEditingController(text: edit.cacheText.value);
    editTextFocusNode.requestFocus();
    textEdit.selection = TextSelection.collapsed(offset: textEdit.text.length);
  }
}

void nextFile() {
  if (edit.activeFile.value < edit.fileList.length - 1) {
    edit.activeFile.value++;
    edit.cacheText.value = edit.fileContent[edit.activeFile.value]['content']![edit.activeLineIndex];
    textEdit = TextEditingController(text: edit.cacheText.value);
    editTextFocusNode.requestFocus();
    textEdit.selection = TextSelection.collapsed(offset: textEdit.text.length);
  }
}

void saveFilePrepare(String path) {
  File saveFile;
  if (edit.fileList[edit.activeFile.value]['extension'] != '') {
    saveFile = File(path +
        edit.fileList[edit.activeFile.value]['fileName'] +
        '.' +
        edit.fileList[edit.activeFile.value]['extension']);
  } else {
    saveFile = File(path + edit.fileList[edit.activeFile.value]['fileName']);
  }
  saveFileWrite(saveFile);
  edit.fileList[edit.activeFile.value]['saved'] = true;
}

void saveFileWrite(File saveFile) {
  String fileContent = '';
  for (int i = 0; i < edit.fileContent[edit.activeFile.value]['content']!.length; i++) {
    fileContent += (edit.fileContent[edit.activeFile.value]['content']![i]);
    if (edit.fileList[edit.activeFile.value]['endOfLine'] == 'system') {
      if (i != (edit.fileContent[edit.activeFile.value]['content']!.length - 1)) {
        if (edit.endOfLine.value == 'LF') {
          fileContent += '\n';
        } else {
          fileContent += '\r\n';
        }
      }
    } else {
      if (edit.fileList[edit.activeFile.value]['endOfLine'] == 'LF') {
        if (i != (edit.fileContent[edit.activeFile.value]['content']!.length - 1)) {
          if (edit.fileList[edit.activeFile.value]['endOfLine'] == 'LF') {
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
  edit.fileList[edit.activeFile.value]['fileName'] = saveController.saveFileName.value;
  edit.fileList[edit.activeFile.value]['extension'] = fileExtension;
  edit.fileList[edit.activeFile.value]['path'] = saveController.saveFilePath.value;
  edit.fileList[edit.activeFile.value]['onDisk'] = true;
  edit.fileList[edit.activeFile.value]['saved'] = true;
}

void autosave() {
  File saveFile;
  if (edit.fileList[edit.activeFile.value]['extension'] != '') {
    saveFile = File(directory.path +
        '.codecraft/autosave/' +
        edit.fileList[edit.activeFile.value]['fileName'] +
        '_autosave' +
        '.' +
        edit.fileList[edit.activeFile.value]['extension']);
    saveFile.create(recursive: true);
  } else {
    saveFile = File(directory.path +
        '.codecraft/autosave/' +
        edit.fileList[edit.activeFile.value]['fileName'] +
        '_autosave');
    saveFile.create(recursive: true);
  }
  String fileContent = '';
  for (int i = 0; i < edit.fileContent[edit.activeFile.value]['content']!.length; i++) {
    fileContent += (edit.fileContent[edit.activeFile.value]['content']![i]);
    if (edit.fileList[edit.activeFile.value]['endOfLine'] == 'system') {
      if (i != (edit.fileContent[edit.activeFile.value]['content']!.length - 1)) {
        if (edit.endOfLine.value == 'LF') {
          fileContent += '\n';
        } else {
          fileContent += '\r\n';
        }
      }
    } else {
      if (edit.fileList[edit.activeFile.value]['endOfLine'] == 'LF') {
        if (i != (edit.fileContent[edit.activeFile.value]['content']!.length - 1)) {
          if (edit.fileList[edit.activeFile.value]['endOfLine'] == 'LF') {
            fileContent += '\n';
          } else {
            fileContent += '\r\n';
          }
        }
      }
    }
  }
  saveFile.writeAsString(fileContent, mode: FileMode.write);
  edit.fileList[edit.activeFile.value]['saved'] = true;
}

void tabKeyHandler() {
  String text = textEdit.text;
  int cursorStart = textEdit.selection.start;
  int cursorEnd = textEdit.selection.end;
  editTextFocusNode.unfocus();
  editTextFocusNode.requestFocus();
  textEdit = TextEditingController(
      text: text.substring(0, cursorStart) + '\t' + text.substring(cursorEnd));
  edit.cacheText.value = text;
  edit.activeLine = edit.cacheText.value;
  edit.fileList[edit.activeFile.value]['saved'] = false;
  textEdit.selection = TextSelection.collapsed(offset: cursorEnd + 1);
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
  int cursorStart = textEdit.selection.start;
  int cursorEnd = textEdit.selection.end;
  String text = textEdit.text;
  textEdit = TextEditingController(
      text: text.substring(0, cursorStart) +
          character +
          text.substring(cursorStart, cursorEnd) +
          characterMapping[character]! +
          text.substring(cursorEnd));
  edit.cacheText.value = textEdit.text;
  edit.activeLine = edit.cacheText.value;
  textEdit.selection = TextSelection(baseOffset: cursorStart + 1, extentOffset: cursorEnd + 1);
}

void addCurrentTime() {
  DateFormat dateFormat = DateFormat.jms('en_US');
  String dateTime = dateFormat.format(DateTime.now());
  String text = textEdit.text;
  int offset;
  int offsetEnd;
  if (textEdit.selection.start == textEdit.selection.end) {
    offset = textEdit.selection.start;
    text = text.substring(0, offset) + dateTime + text.substring(offset);
  } else {
    offset = textEdit.selection.start;
    offsetEnd = textEdit.selection.end;
    text = text.substring(0, offset) + dateTime + text.substring(offsetEnd);
  }
  textEdit = TextEditingController(text: text);
  if (textEdit.selection.start != textEdit.selection.end) {
    textEdit.selection = TextSelection(baseOffset: offset, extentOffset: offset + dateTime.length);
  } else {
    textEdit.selection = TextSelection.collapsed(offset: offset + dateTime.length);
  }
  editTextFocusNode.requestFocus();
}
