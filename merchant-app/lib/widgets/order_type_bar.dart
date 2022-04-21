import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/styles/labelText.dart';

class OrderTypeBar extends StatelessWidget {
  final List<OrderTypeButton> orderTypeButtons;

  OrderTypeBar({this.orderTypeButtons});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: orderTypeButtons.map((e) => e.getButton(context)).toList(),
      ),
    );
  }
}

enum OrderButtonType {
  DineIn,
  TakeAway,
}

class OrderTypeButton {
  OrderButtonType isSelectedType;
  OrderButtonType buttonType;
  Function buttonEvent;

  OrderTypeButton({this.isSelectedType, this.buttonType, this.buttonEvent});

  Widget getButton(BuildContext context) {
    return Expanded(
      flex: 5,
      child: Padding(
        padding: EdgeInsets.all(
          ScreenUtil().setWidth(10),
        ),
        child: Container(
          height: (!ScreenHelper.isLandScape(context))
              ? MediaQuery.of(context).size.width * 0.08
              : MediaQuery.of(context).size.width * 0.035,
          width: (!ScreenHelper.isLandScape(context))
              ? MediaQuery.of(context).size.width * 0.1
              : MediaQuery.of(context).size.width,
          child: RaisedButton(
            onPressed: buttonEvent,
            textColor:
                isSelectedType == buttonType ? Colors.white : Colors.black,
            color:
                isSelectedType == buttonType ? appThemeColor : greyoutAreaColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  // buttonType.toString()?.split('.')?.elementAt(1),
                  (buttonType == OrderButtonType.DineIn)
                      ? AppLocalizationHelper.of(context).translate('Dine In')
                      : AppLocalizationHelper.of(context)
                          .translate('Take-away'),
                  style: GoogleFonts.lato(
                    fontSize: ScreenHelper.isLandScape(context)
                        ? 2 * SizeHelper.textMultiplier
                        : 2 * SizeHelper.textMultiplier,
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
