import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus/helper/paymentHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/userPaymentMethod.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/widgets/emptyView.dart';

class DefaultPaymentMethodListTile extends StatelessWidget {
  final UserPaymentMethod userPaymentMethod;
  final Function onSelected;

  DefaultPaymentMethodListTile(
      {Key key, this.userPaymentMethod, this.onSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected,
      child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtil().setSp(20)),
            border: Border.all(
              color: borderColor,
              width: ScreenUtil().setSp(5),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.all(SizeHelper.textMultiplier * 1.5),
                child: Icon(
                  Icons.credit_card,
                  color: appThemeColor,
                ),
              ),
              Text(
                  (userPaymentMethod == null)
                      ? "* Please complete your payment info"
                      : PaymentHelper.showCardInfo(userPaymentMethod),
                  style: GoogleFonts.lato(
                      fontSize: SizeHelper.textMultiplier * 2)),
          if (userPaymentMethod != null) WEmptyView(100),
                 if (userPaymentMethod != null) Text("Change",
                  style: GoogleFonts.lato(
                      fontSize: SizeHelper.textMultiplier * 2.2,
                      fontWeight: FontWeight.w400))
            ],
          )),
    );
  }
}
