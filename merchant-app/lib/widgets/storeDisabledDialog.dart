import 'package:flutter/material.dart';
import 'package:vplus_merchant_app/widgets/custom_dialog.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class StoreDisabledDialog extends StatelessWidget {
  /// this widget shows the store disabled dialog.
  /// Not allow user to access the store if store expired
  bool canPopup = false;
  StoreDisabledDialog({
    this.canPopup,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Store Disabled',
      insideButtonList: (canPopup)
          ? [
              CustomDialogInsideButton(
                  buttonName: "Confirm",
                  buttonEvent: () {
                    Navigator.of(context).pop();
                  })
            ]
          : [],
      child: Column(
        children: [
          Text('Your selected store is disabled.', style: GoogleFonts.lato()),
          Text('please contact us to access.', style: GoogleFonts.lato()),
          VEmptyView(50),
          Text('Email: support@vplus.com.au', style: GoogleFonts.lato()),
          Text('Tel: +614 1095 5639', style: GoogleFonts.lato()),
        ],
      ),
    );
  }
}

/// usage:
//  showDialog(
//               context: context,
//               barrierDismissible: false,  // user cannot pop up this dialog
//               builder: (BuildContext context) {
//                 return StoreDisabledDialog(
//                   canPopup: false,    // user cannot pop up this dialog
//                 );
//               });
