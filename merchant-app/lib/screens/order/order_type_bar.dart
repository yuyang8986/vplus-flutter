import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';

class MenuListTypeBar extends StatelessWidget {
  final List<ListTypeButton> menuListTypeButton;

  MenuListTypeBar({this.menuListTypeButton});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: menuListTypeButton.map((e) => e.getButton(context)).toList(),
      ),
    );
  }
}

enum ListButtonType {
  Order,
  OrderStatus,
}

class ListTypeButton {
  ListButtonType isSelectedType;
  ListButtonType buttonType;
  Function buttonEvent;

  ListTypeButton({this.isSelectedType, this.buttonType, this.buttonEvent});

  Widget getButton(BuildContext context) {
    return Expanded(
      flex: 5,
      child: Padding(
        padding: EdgeInsets.all(
          ScreenUtil().setWidth(2),
        ),
        child: RaisedButton(
          onPressed: buttonEvent,
          textColor: isSelectedType == buttonType ? Colors.white : Colors.black,
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
                buttonType == ListButtonType.OrderStatus
                    ? AppLocalizationHelper.of(context)
                        .translate("Order Status")
                    : AppLocalizationHelper.of(context).translate(
                        "${buttonType.toString()?.split('.')?.elementAt(1)}"),
                style: GoogleFonts.lato(
                  fontSize: SizeHelper.isMobilePortrait
                      ? 2 * SizeHelper.textMultiplier
                      : 3 * SizeHelper.textMultiplier,
                  fontWeight: isSelectedType == buttonType
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
