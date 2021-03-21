import 'package:codecraft/main.dart';
import 'package:flutter/material.dart';

List<Map<String, dynamic>> dartRules = [
  {
    'element': '\'',
    'rule': 'upto',
    'last': '\'',
    'includeLast': true,
    'separate': ['\\'],
    'range': 'full',
  },
  {
    'element': '"',
    'rule': 'upto',
    'last': '"',
    'includeLast': true,
    'separate': ['\\'],
    'range': 'full',
  },
  {
    'element': '\\',
    'rule': 'till',
    'count': 1,
    'include': true,
    'separate': [],
    'range': 'full',
  },
  {
    'element': '//',
    'rule': 'till',
    'count': 'end',
    'include': true,
    'separate': [],
    'range': 'full',
  }
];

TextStyle dartHighlight(String token) {
  TextStyle highlightStyle = TextStyle(
      color: colorController.bgColorContrast.value.withOpacity(0.7),
      fontWeight: (colorController.isDarkMode.value) ? (FontWeight.normal) : (FontWeight.w500),
      fontFamily: fontFamily,
      fontStyle: FontStyle.normal,
      fontFamilyFallback: [fontFamily]);
  String capitalLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String numbers = '0123456789';
  List<String> datatypes = ['int', 'double', 'String', 'bool', 'List', 'var', 'Map', 'dynamic'];
  List<String> keywords = [
    'abstract',
    'async',
    'await',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'external',
    'extends',
    'factory',
    'false',
    'final',
    'finally',
    'for',
    'get',
    'if',
    'implements',
    'import',
    'in',
    'is',
    'library',
    'new',
    'null',
    'operator',
    'part',
    'rethrow',
    'return',
    'set',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'while',
    'with',
    'yield'
  ];
  if (datatypes.contains(token) || (capitalLetters.contains(token.substring(0, 1)))) {
    highlightStyle = highlightStyle.copyWith(color: Color.fromRGBO(0, 150, 255, 1.0));
  } else if (keywords.contains(token)) {
    highlightStyle = highlightStyle.copyWith(color: Color.fromRGBO(255, 90, 80, 1.0));
  } else if ((token.substring(0, 1) == '\'') ||
      (token.substring(token.length - 1, token.length) == '\'') ||
      (token.substring(0, 1) == '"') ||
      (token.substring(token.length - 1, token.length) == '"')) {
    highlightStyle = highlightStyle.copyWith(
      color: Color.fromRGBO(255, 180, 80, 1.0),
    );
  } else if (token.substring(0, 1) == '\\') {
    highlightStyle = highlightStyle.copyWith(
        color: Color.fromRGBO(0, 180, 255, 1.0), fontWeight: FontWeight.bold);
  } else if (numbers.contains(token.substring(0, 1))) {
    highlightStyle = highlightStyle.copyWith(color: Color.fromRGBO(255, 70, 190, 1.0));
  } else if ((token == '(') || (token == ')')) {
    highlightStyle = highlightStyle.copyWith(color: Color.fromRGBO(160, 160, 160, 1.0));
  } else if ((token == '[') || (token == ']')) {
    highlightStyle = highlightStyle.copyWith(color: colorController.bgColorContrast.value);
  } else if ((token == '<') || (token == '>')) {
    highlightStyle = highlightStyle.copyWith(color: Color.fromRGBO(255, 90, 80, 1.0));
  } else if ((token == '+') ||
      (token == '-') ||
      (token == '|') ||
      (token == '=') ||
      (token == '?') ||
      (token == '!')) {
    highlightStyle = highlightStyle.copyWith(color: Color.fromRGBO(255, 90, 80, 1.0));
  }
  return highlightStyle;
}

List<String> dartMatcher(String token) {
  // Basic Datatypes & Classes
  List<String> datatypes = ['int', 'double', 'String', 'bool', 'List', 'var', 'Map', 'dynamic'];
  for (int i = 0; i < datatypes.length; i++) {
    if (token == datatypes[i]) {
      return ['Class', 'BasicDatatype'];
    }
  }

  List<String> keywords = [
    'abstract',
    'as',
    'assert',
    'async',
    'await',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'external',
    'extends',
    'factory',
    'false',
    'final',
    'finally',
    'for',
    'get',
    'if',
    'implements',
    'import',
    'in',
    'is',
    'library',
    'new',
    'null',
    'operator',
    'part',
    'rethrow',
    'return',
    'set',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'while',
    'with',
    'yield'
  ];
  for (int i = 0; i < keywords.length; i++) {
    if (token == keywords[i]) {
      return ['Keyword'];
    }
  }

  if (token.substring(0, 1).toUpperCase() == token.substring(0, 1)) {
    // Classes and Datatypes
    return ['Class', 'Datatype'];
  } else {
    // Variables and Functions
    return ['Variable', 'Function'];
  }
}
