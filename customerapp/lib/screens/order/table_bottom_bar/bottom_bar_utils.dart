import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class BottomBarUtils {
  static BorderRadius bottomBarRadius() {
    return BorderRadius.only(
        topLeft: Radius.circular(5.0), topRight: Radius.circular(5.0));
  }

  static BorderRadius bottomBarPlaceOrderRadius() {
    return BorderRadius.only(topRight: Radius.circular(5.0));
  }

  static Color getThemeColor() {
    return Color(0xff5352ec);
  }
}

class BottomBarEventProvider with ChangeNotifier {
  PanelController _panelController;
  PanelController get getPanelController => _panelController;
  void setPanelController(PanelController controller) {
    _panelController = controller;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print('Bottom Bar Provider disposed');
  }
}
