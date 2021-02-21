import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/state_manager.dart';
import 'package:typecaster/controller/color_controller.dart';

void main() {
  runApp(TypeCaster());
}

String fontFamily = "FiraCode";
ColorController colorController = ColorController();

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
  FocusNode homeViewFocusNode;

  void initState() {
    homeViewFocusNode = FocusNode(
      canRequestFocus: true,
      descendantsAreFocusable: true,
    );
    homeViewFocusNode.requestFocus();
    super.initState();
  }

  void dispose() {
    homeViewFocusNode.dispose();
    super.dispose();
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
                height: MediaQuery.of(mainContext).size.height * 0.97,
                width: MediaQuery.of(mainContext).size.width,
                child: RawKeyboardListener(
                  focusNode: homeViewFocusNode,
                  child: Container(),
                  onKey: (keyEvent) {
                    if ((keyEvent.isControlPressed) &&
                        (keyEvent.isKeyPressed(LogicalKeyboardKey.keyD))) {
                      colorController.darkModeChanger();
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
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'typecaster',
                          style: TextStyle(
                            color: colorController.bgColorContrast.value,
                            fontFamily: fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
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
