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

bool upLineCandidate() {
  if (editController.editMode.value &&
      editController.fileList[editController.activeFile.value]['activeLine'] > 0) {
    return true;
  } else {
    return false;
  }
}

bool downLineCandidate() {
  if (editController.editMode.value &&
      editController.fileList[editController.activeFile.value]['activeLine'] <
          editController.fileContent[editController.activeFile.value]['content'].length - 1) {
    return true;
  } else {
    return false;
  }
}

void activeLineDecrement() {
  editController.fileList[editController.activeFile.value]['activeLine'] -= 1;
  textEditControl = TextEditingController(
      text: editController.fileContent[editController.activeFile.value]['content']
          [editController.fileList[editController.activeFile.value]['activeLine']]);
  textEditControl.selection = TextSelection(
      baseOffset: textEditControl.text.length, extentOffset: textEditControl.text.length);
}

void activeLineIncrement() {
  editController.fileList[editController.activeFile.value]['activeLine'] += 1;
  textEditControl = TextEditingController(
      text: editController.fileContent[editController.activeFile.value]['content']
          [editController.fileList[editController.activeFile.value]['activeLine']]);
  textEditControl.selection = TextSelection(
      baseOffset: textEditControl.text.length, extentOffset: textEditControl.text.length);
}

bool deleteNewlineCandidate() {
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

bool backspaceCandidate() {
  if (((textEditControl.selection.start == 0) && (textEditControl.selection.end == 0)) &&
      (editController.fileContent[editController.activeFile.value]['content'].length > 1) &&
      (editController.fileList[editController.activeFile.value]['activeLine'] != 0)) {
    return true;
  } else {
    return false;
  }
}

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
