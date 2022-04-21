import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';

enum StoreListButtonType { PickUp, Delivery }

class StoreListTypeBar extends StatelessWidget {
  final List<StoreListTypeButton> storeListTypeButtons;

  StoreListTypeBar({this.storeListTypeButtons});

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.symmetric(
      //     vertical: ScreenHelper.isLandScape(context)
      //         ? 10
      //         : SizeHelper.heightMultiplier * 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: storeListTypeButtons.map((e) => e.getButton()).toList(),
      ),
    );
  }
}

class StoreListTypeButton {
  StoreListButtonType selected;
  StoreListButtonType buttonType;
  Function buttonEvent;

  StoreListTypeButton({this.selected, this.buttonType, this.buttonEvent});

  Widget getButton() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            ScreenUtil().setWidth(10),
            ScreenUtil().setWidth(5),
            ScreenUtil().setWidth(10),
            ScreenUtil().setWidth(5)),
        child: InkWell(
            onTap: this.buttonEvent,
            child: Container(
              constraints: BoxConstraints(
                  minHeight: ScreenUtil().setHeight(80),
                  minWidth: ScreenUtil().setWidth(80)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtil().setSp(20)),
                color: selected == buttonType
                    ? Color(0xff5352ec)
                    : Color(0xffdde4ec),
                border: Border.all(
                  color: Colors.white,
                  width: ScreenUtil().setSp(1),
                ),
              ),
              child: Center(
                child: Text(
                  buttonType == StoreListButtonType.PickUp
                      ? "Pick Up"
                      : "Delivery",
                  style: GoogleFonts.lato(
                    color: selected == buttonType ? Colors.white : Colors.black,
                    fontSize: SizeHelper.isMobilePortrait
                        ? 3 * SizeHelper.textMultiplier
                        : 3 * SizeHelper.textMultiplier,
                    fontWeight: selected == buttonType
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
