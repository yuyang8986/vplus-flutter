import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus/helper/sizeHelper.dart';

import 'emptyView.dart';

class NetErrorWidget extends StatelessWidget {
  final VoidCallback callback;

  NetErrorWidget({@required this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        alignment: Alignment.center,
        height: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.error_outline, size: 200),
            SizedBox(height: 30),
            Container(
              // height: (ScreenHelper.isLandScape(context)
              //     ? MediaQuery.of(context).size.height * 0.55
              //     : MediaQuery.of(context).size.height * 0.55),
              // width: (ScreenHelper.isLandScape(context)
              //     ? MediaQuery.of(context).size.height * 0.85
              //     : MediaQuery.of(context).size.height * 0.86),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Text(
                      "Network Error",
                      style: GoogleFonts.lato(),
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      textColor: Colors.white,
                      color: Color(0xff5352ec),
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Back",
                            style: GoogleFonts.lato(
                              fontSize: SizeHelper.isMobilePortrait
                                  ? 2 * SizeHelper.textMultiplier
                                  : 2 * SizeHelper.textMultiplier,
                              // fontSize: ScreenUtil().setSp(ScreenHelper.isLandScape(context)?MediaQuery.of(context).size.height*0.025:MediaQuery.of(context).size.height*0.025),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
