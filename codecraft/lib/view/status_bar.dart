import 'package:flutter/material.dart';
import '../main.dart';
import '../functions.dart';

/// The Status Bar of the Application.
Widget statusBar(BuildContext mainContext) {
  return Container(
    height: MediaQuery.of(mainContext).size.height * 0.03,
    width: MediaQuery.of(mainContext).size.width,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: [
              Text(
                'codecraft',
                style: TextStyle(
                  color: colorController.bgColorContrast.value,
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                ' - Aldrin Mathew',
                style: TextStyle(
                  color: colorController.bgColorContrast.value,
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Icon(
              Icons.keyboard,
              size: 18,
              color: colorController.bgColorContrast.value,
            ),
            SizedBox(
              width: 5,
            ),
            Icon(
              (colorController.isDarkMode.value) ? (Icons.lightbulb_outline) : (Icons.lightbulb),
              size: 13,
              color: colorController.bgColorContrast.value,
            ),
          ],
        ),
        Text(
          (editController.fileList[editController.activeFile.value]['endOfLine'] == 'system')
              ? (editController.endOfLine.value)
              : ((editController.fileList[editController.activeFile.value]['endOfLine'] !=
                      editController.endOfLine.value)
                  ? (editController.fileList[editController.activeFile.value]['endOfLine'] +
                      ' | ' +
                      editController.endOfLine.value)
                  : (editController.endOfLine.value)),
          style: TextStyle(
            color: colorController.bgColorContrast.value,
            fontFamily: fontFamily,
            fontWeight: FontWeight.normal,
            fontSize: 12,
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
  );
}
