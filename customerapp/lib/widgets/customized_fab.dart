import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FabItem {
  String itemLabel;
  IconData itemIcon;
  VoidCallback onTap;

  FabItem({this.itemLabel, this.itemIcon, this.onTap});
}

Color backGroundColor = Color(0xff5352ec);
int labelWidth = 300;

/// This widget is used to create a FAB(A floating action button) which contains
/// speed dial (popup sub icons). A FabItem is needed to create this widget.
/// FabItem contains label and icon.
/// design ref:
/// https://material.io/components/buttons-floating-action-button#types-of-transitions

class CustomFAB extends StatefulWidget {
  final List<FabItem> fabItems;

  const CustomFAB({Key key, @required this.fabItems}) : super(key: key);

  @override
  _CustomFABState createState() => _CustomFABState();
}

class _CustomFABState extends State<CustomFAB> with TickerProviderStateMixin {
  AnimationController _fabController;
  List<FabItem> fabItems;
  @override
  void initState() {
    fabItems = this.widget.fabItems;
    _fabController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: new List.generate(fabItems.length, (int index) {
        Widget child = new Container(
          height: ScreenUtil().setHeight(170),
          // width: ScreenUtil().setWidth(570),
          alignment: FractionalOffset.topCenter,
          child: new ScaleTransition(
            scale: new CurvedAnimation(
              parent: _fabController,
              curve: new Interval(0.0, 1.0 - index / fabItems.length / 2.0,
                  curve: Curves.easeOut),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    width: ScreenUtil().setWidth(labelWidth),
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                    ),
                    child: Text(
                      fabItems[index].itemLabel,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(color: Colors.black),
                    )),
                FloatingActionButton(
                  heroTag: null,
                  tooltip: fabItems[index].itemLabel,
                  backgroundColor: backGroundColor,
                  mini: true,
                  child:
                      new Icon(fabItems[index].itemIcon, color: Colors.white),
                  onPressed: fabItems[index].onTap,
                ),
                Container(
                  width: ScreenUtil().setWidth(labelWidth),
                )
              ],
            ),
          ),
        );
        return child;
      }).toList()
        ..add(
          new FloatingActionButton(
            heroTag: null,
            backgroundColor: backGroundColor,
            foregroundColor: Colors.white,
            child: new AnimatedBuilder(
              animation: _fabController,
              builder: (BuildContext context, Widget child) {
                return new Transform(
                  transform: new Matrix4.rotationZ(
                      _fabController.value * 0.5 * math.pi),
                  alignment: FractionalOffset.center,
                  child: new Icon(
                    _fabController.isDismissed ? Icons.widgets : Icons.close,
                  ),
                );
              },
            ),
            onPressed: () {
              if (_fabController.isDismissed) {
                _fabController.forward();
              } else {
                _fabController.reverse();
              }
            },
          ),
        ),
    );
  }
}

/// code snippest:

// final List<FabItem> fabItems = [
//   FabItem(
//     itemLabel: 'Reset all tables',
//     itemIcon: Icons.exit_to_app,
//     onTap: () {
//       print('reset');
//     },
//   ),
//   FabItem(
//     itemLabel: 'Print orders by item',
//     itemIcon: Icons.print,
//     onTap: () {
//       print('print');
//     },
//   )
// ];
///////////////////in build function////////////////////////
//  Scaffold(
//       appBar: CustomAppBar.getAppBar(...),
//       body: Container( ... ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: CustomFAB(
//         fabItems: fabItems,
//       ),
//     );
