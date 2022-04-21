import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/order_helper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/Order.dart';

class DriverOrderStatusBadge extends StatelessWidget {
  UserOrderStatus driverOrderStatus;
  bool isPaid;
  DriverOrderStatusBadge({Key key, @required this.driverOrderStatus, @required this.isPaid }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(5, 0, 10, 15),
      width: 20 * SizeHelper.widthMultiplier,
      color: OrderHelper.getDriverOrderStatusColor(driverOrderStatus), //Container color
      child: Center(
        child: Text( !isPaid? "${AppLocalizationHelper.of(context).translate("Not Paid")}":
        "${AppLocalizationHelper.of(context).translate(OrderHelper.getDriverOrderStatusText(driverOrderStatus))}",
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: 1.8 * SizeHelper.textMultiplier,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
