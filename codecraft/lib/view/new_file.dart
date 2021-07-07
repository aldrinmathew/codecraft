import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../main.dart';
import '../globals.dart';
import '../functions.dart';

FocusNode newFileNameFocusNode = FocusNode(canRequestFocus: true);
TextEditingController newFileNameController = TextEditingController();

class NewFileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: color.main,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'New File',
              style: TextStyle(
                color: color.contrast.withOpacity(0.5),
                fontFamily: fontFamily,
                fontSize: edit.fontSize.value * 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: RawKeyboardListener(
                focusNode: newFileNameFocusNode,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.file_present,
                      size: 40,
                      color: color.contrast.withOpacity(0.5),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Container(
                      height: 70,
                      width: 300,
                      alignment: Alignment.center,
                      child: TextField(
                        controller: newFileNameController,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        autofocus: true,
                        cursorWidth: edit.editFontSize.value / 1.7,
                        cursorColor: color.contrast,
                        cursorHeight: 37,
                        style: TextStyle(
                          color: color.contrast,
                          fontFamily: fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: edit.fontSize.value * 2,
                        ),
                        decoration: null,
                        onSubmitted: (fileName) {
                          createNewFile(fileName: fileName, filePath: '');
                          Get.back();
                          edit.activeFile.value += 1;
                        },
                      ),
                      decoration: BoxDecoration(
                        color: color.main,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            offset: (color.isDarkMode)
                                ? (Offset(5, 5))
                                : (Offset(-5, -5)),
                            color: color.extremeContrast.withOpacity((color.isDarkMode) ? 0.5 : 1),
                            blurRadius: 10,
                          ),
                          BoxShadow(
                            offset: (color.isDarkMode)
                                ? (Offset(-5, -5))
                                : (Offset(5, 5)),
                            color: color.contrast.withOpacity(0.1),
                            blurRadius: 10,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                onKey: (keyEvent) {
                  if (keyEvent.isKeyPressed(LogicalKeyboardKey.escape)) {
                    Get.back();
                  } else if ((keyEvent.isControlPressed)) {
                    if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyN)) {
                      Get.back();
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
