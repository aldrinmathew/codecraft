import 'package:flutter/material.dart';

import '../globals.dart';
import '../main.dart';
import '../model/syntax/gitignore.dart';
import '../model/syntax/dart.dart';

TextStyle highlightHandler(String language, String token) {
  if (language == 'dart') {
    return dartHighlight(token);
  } else if (language == 'gitignore') {
    return gitignoreHighlight(token);
  } else {
    return TextStyle(
      color: color.contrast,
      fontFamily: fontFamily,
      fontFamilyFallback: [fontFamily],
      fontSize: edit.fontSize.value,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal,
    );
  }
}

int ruleCheck(String language, String element) {
  if (language == 'dart') {
    for (int i = 0; i < dartRules.length; i++) {
      if (dartRules[i]['element'].length <= element.length) {
        if (dartRules[i]['element'] == element.substring(0, dartRules[i]['element'].length)) {
          return i;
        }
      }
    }
  } else if (language == 'gitignore') {
    for (int i = 0; i < gitignoreRules.length; i++) {
      if (gitignoreRules[i]['element'].length <= element.length) {
        if (gitignoreRules[i]['element'] ==
            element.substring(0, gitignoreRules[i]['element'].length)) {
          return i;
        }
      }
    }
  }
  return -1;
}

Map<String, dynamic> ruleLanguage(String language, int index) {
  if (language == 'dart') {
    return dartRules[index];
  } else if (language == 'gitignore') {
    return gitignoreRules[index];
  } else {
    return {};
  }
}
