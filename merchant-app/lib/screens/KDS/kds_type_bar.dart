import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';

class KDSTypeBar extends StatelessWidget {
  final List<ListTypeButton> kdsTypeButton;

  KDSTypeBar({this.kdsTypeButton});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeHelper.widthMultiplier * 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: kdsTypeButton.map((e) => e.getButton(context)).toList(),
      ),
    );
  }
}

enum KDSType {
  ByOrder,
  ByItem,
}

class ListTypeButton {
  KDSType isSelectedType;
  KDSType buttonType;
  Function buttonEvent;

  ListTypeButton({this.isSelectedType, this.buttonType, this.buttonEvent});

  Widget getButton(BuildContext context) {
    return Expanded(
      flex: 5,
      child: Padding(
        padding: EdgeInsets.all(SizeHelper.textMultiplier * 1),
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
                buttonType == KDSType.ByItem
                    ? "${AppLocalizationHelper.of(context).translate('KDSByItem')}"
                    : "${AppLocalizationHelper.of(context).translate('KDSByOrder')}",
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
