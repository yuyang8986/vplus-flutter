import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';

class MenuListTypeBar extends StatelessWidget {
  final List<MenuListTypeButton> menuListTypeButton;

  MenuListTypeBar({this.menuListTypeButton});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: (!ScreenHelper.isLandScape(context))
      //     ? MediaQuery.of(context).size.width * 0.09
      //     : MediaQuery.of(context).size.width * 5,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              menuListTypeButton.map((e) => e.getButton(context)).toList(),
        ),
      ),
    );
  }
}

enum MenuListButtonType {
  Categories,
  Items,
  AddOns,
}

class MenuListTypeButton {
  MenuListButtonType isSelectedType;
  MenuListButtonType buttonType;
  Function buttonEvent;

  MenuListTypeButton({this.isSelectedType, this.buttonType, this.buttonEvent});

  Widget getButton(BuildContext context) {
    return Expanded(
      flex: 5,
      child: Container(
        height: (!ScreenHelper.isLandScape(context))
            ? MediaQuery.of(context).size.width * 0.10
            : MediaQuery.of(context).size.width * 0.06,
        child: Padding(
          padding: EdgeInsets.all(
            ScreenUtil().setWidth(10),
          ),
          child: RaisedButton(
            onPressed: buttonEvent,
            textColor:
                isSelectedType == buttonType ? Colors.white : Colors.black,
            color: isSelectedType == buttonType
                ? Color(0xff5352ec)
                : Color(0xffdde4ec),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  buttonType == MenuListButtonType.AddOns
                      ? AppLocalizationHelper.of(context).translate('Add-On')
                      : AppLocalizationHelper.of(context).translate(
                          '${buttonType.toString()?.split('.')?.elementAt(1)}'),
                  style: GoogleFonts.lato(
                    fontSize: ScreenUtil().setSp(
                      SizeHelper.isMobilePortrait
                          ? 5 * SizeHelper.textMultiplier
                          : 2 * SizeHelper.textMultiplier,
                    ),
                    fontWeight: isSelectedType == buttonType
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
