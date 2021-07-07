import 'package:flutter/material.dart';

import '../../main.dart';
import '../../globals.dart';

List<Map<String, dynamic>> gitignoreRules = [
  {
    'element': '#',
    'rule': 'till',
    'count': 'end',
    'include': true,
    'separate': [],
    'range': 'full'
  },
];

TextStyle gitignoreHighlight(String token) {
  TextStyle highlightStyle = TextStyle(
      color: color.contrast.withOpacity(0.7),
      fontWeight: (color.isDarkMode) ? (FontWeight.normal) : (FontWeight.w500),
      fontFamily: fontFamily,
      fontStyle: FontStyle.normal,
      fontFamilyFallback: [fontFamily]);
  if (token.substring(0, 1) == '#') {
    highlightStyle = highlightStyle.copyWith(
      color: color.contrast.withOpacity(0.4),
      fontStyle: FontStyle.italic,
    );
  } else {
    highlightStyle = highlightStyle.copyWith(
      color: Color.fromRGBO(255, 120, 100, 1.0),
      fontWeight: FontWeight.bold,
    );
  }
  return highlightStyle;
}
