import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/widgets/customAlertDialog.dart';

class Modal {
  static showNoInTrinsicAlert(
      Function onPressCallBack, BuildContext context, String title,
      {Widget contentWidget, String content}) {
    // set up the AlertDialog
    showDialog(
        context: context,
        builder: (ctx) {
          return CustomNoIntrinsicAlertDialog(
            content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(title,
                      style: GoogleFonts.lato(
                          textStyle: GoogleFonts.lato(
                              fontSize: ScreenUtil().setSp(45),
                              fontWeight: FontWeight.bold))),
                  content != null ? Text(content) : contentWidget,
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onPressCallBack();
                    },
                    textColor: Colors.white,
                    color: Color(0xff5352ec),
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Okay',
                          // textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
          );
        });
  }
}
