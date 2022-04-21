import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/widgets/custom_dialog.dart';

class ReadOnlyDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomDialog(
        title:
            AppLocalizationHelper.of(context).translate('ReadOnlyDialogTitle'),
        insideButtonList: [
          CustomDialogInsideButton(
              buttonName:
                  AppLocalizationHelper.of(context).translate('Confirm'),
              buttonEvent: () {
                Navigator.of(context).pop();
              })
        ],
        child: Text(
            AppLocalizationHelper.of(context)
                .translate('ReadOnlyDialogContent'),
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: ScreenHelper.isLandScape(context)
                  ? 2 * SizeHelper.textMultiplier
                  : 2 * SizeHelper.textMultiplier,
            )));
    ;
  }
}
