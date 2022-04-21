import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/styles/color.dart';

class DriverOrderFilterBar extends StatelessWidget {
  final List<DriverListTypeButton> orderTypeButton;

  DriverOrderFilterBar({this.orderTypeButton});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeHelper.widthMultiplier * 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: orderTypeButton.map((e) => e.getButton(context)).toList(),
      ),
    );
  }
}

enum DriverOrderFilterType {
  MyOrder,
  ReadyForPickOrder,
  CompletedOrders
}

class DriverListTypeButton {
  DriverOrderFilterType isSelectedType;
  DriverOrderFilterType buttonType;
  Function buttonEvent;

  DriverListTypeButton({this.isSelectedType, this.buttonType, this.buttonEvent});

  Widget getButton(BuildContext context) {
    return Expanded(
      flex: 5,
      child: Padding(
        padding: EdgeInsets.all(SizeHelper.textMultiplier * 1),
        child: ElevatedButton(
          onPressed: buttonEvent,
          style: ElevatedButton.styleFrom(
            primary:
            isSelectedType == buttonType ? appThemeColor : greyoutAreaColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                buttonType == DriverOrderFilterType.MyOrder
                    ? "${AppLocalizationHelper.of(context).translate("MyOrder")}"
                    : buttonType == DriverOrderFilterType.ReadyForPickOrder
                    ? "${AppLocalizationHelper.of(context).translate("PickOrder")}"
                    : "${AppLocalizationHelper.of(context).translate("CompletedOrders")}",
                style: GoogleFonts.lato(
                  fontSize: 1.5 * SizeHelper.textMultiplier,
                  fontWeight: isSelectedType == buttonType
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isSelectedType == buttonType
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
