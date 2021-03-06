import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:codecraft/main.dart';
import 'package:codecraft/functions.dart';

class NewFileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: colorController.bgColor.value,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'New File',
              style: TextStyle(
                color: colorController.bgColorContrast.value.withOpacity(0.5),
                fontFamily: fontFamily,
                fontSize: editController.fontSize.value * 2,
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
                      color: colorController.bgColorContrast.value.withOpacity(0.5),
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
                        cursorWidth: editController.editFontSize.value / 1.7,
                        cursorColor: colorController.bgColorContrast.value,
                        cursorHeight: 37,
                        style: TextStyle(
                          color: colorController.bgColorContrast.value,
                          fontFamily: fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: editController.fontSize.value * 2,
                        ),
                        decoration: null,
                        onSubmitted: (filename) {
                          createNewFile(filename);
                          Get.back();
                          editController.activeFile.value += 1;
                        },
                      ),
                      decoration: BoxDecoration(
                        color: colorController.bgColor.value,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            offset: (colorController.isDarkMode.value)
                                ? (Offset(5, 5))
                                : (Offset(-5, -5)),
                            color: colorController.contrastExtreme.value
                                .withOpacity((colorController.isDarkMode.value) ? 0.5 : 1),
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
