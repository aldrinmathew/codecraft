import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/state_manager.dart';
import '../controller/color_controller.dart';
import '../controller/edit_controller.dart';

void main() {
  runApp(TypeCaster());
}

String fontFamily = "FiraCode";
ColorController colorController = ColorController();
EditController editController = EditController();

class TypeCaster extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Typecaster',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: colorController.appStyleColor,
      ),
      home: HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController textEditControl;
  FocusNode homeViewFocusNode;

  void initState() {
    homeViewFocusNode = FocusNode(
      canRequestFocus: true,
      descendantsAreFocusable: true,
    );
    homeViewFocusNode.requestFocus();
    textEditControl = TextEditingController(text: '');
    super.initState();
  }

  @override
  Widget build(BuildContext mainContext) {
    return Obx(() {
      return Scaffold(
        backgroundColor: colorController.bgColor.value,
        body: Container(
          height: MediaQuery.of(mainContext).size.height,
          width: MediaQuery.of(mainContext).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20),
                height: MediaQuery.of(mainContext).size.height * 0.97,
                width: MediaQuery.of(mainContext).size.width,
                child: RawKeyboardListener(
                  focusNode: homeViewFocusNode,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Card(
                        elevation: 5,
                        color: colorController.bgColor.value,
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(mainContext).size.height * 0.06,
                          child: TextField(
                            controller: textEditControl,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            autofocus: false,
                            cursorWidth: editController.fontSize.value / 1.8,
                            cursorColor: colorController.bgColorContrast.value,
                            cursorHeight: editController.fontSize.value * 1.4,
                            decoration: null,
                            style: TextStyle(
                              color: colorController.bgColorContrast.value,
                              fontFamily: fontFamily,
                              fontSize: editController.fontSize.value,
                              fontWeight: (colorController.isDarkMode.value)
                                  ? (FontWeight.normal)
                                  : (FontWeight.bold),
                            ),
                            onChanged: (text) {
                              editController.cacheText.value = text;
                              editController.fileContent[editController.activeFile.value]
                                  ['content'][editController.fileList[editController.activeFile.value]['activeLine'] - 1] = editController.cacheText.value;
                            },
                            onSubmitted: (text) {},
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      )
                    ],
                  ),
                  onKey: (keyEvent) async {
                    if (keyEvent.isControlPressed) {
                      if (keyEvent.isKeyPressed(LogicalKeyboardKey.space)) {
                        editController.editMode.value = !(editController.editMode.value);
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyO)) {
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyQ)) {
                        exit(0);
                      } else if (keyEvent.isKeyPressed(LogicalKeyboardKey.keyD)) {
                        colorController.darkModeChanger();
                      }
                    }
                  },
                ),
              ),
              Container(
                height: MediaQuery.of(mainContext).size.height * 0.03,
                width: MediaQuery.of(mainContext).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        'typecaster',
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
                      child: Text(
                        (editController.editMode.value) ? ('Edit Mode') : ('Control Mode'),
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
                        (editController.cacheText.value.length < 1000)
                            ? ('${editController.cacheText.value.length} Characters')
                            : ('${(editController.cacheText.value.length / 1000).toStringAsFixed(2)}K Characters'),
                        style: TextStyle(
                          color: colorController.bgColorContrast.value,
                          fontFamily: fontFamily,
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: colorController.bgColorContrast.value.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
