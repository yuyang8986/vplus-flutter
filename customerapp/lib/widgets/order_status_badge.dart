import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/order_helper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/Order.dart';

class OrderStatusBadge extends StatelessWidget {
  UserOrderStatus orderStatus;
  bool isPaid;
  OrderStatusBadge({Key key, @required this.orderStatus, @required this.isPaid }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(5, 0, 10, 15),
      width: 20 * SizeHelper.widthMultiplier,
      color: OrderHelper.getOrderStatusColor(orderStatus), //Container color
      child: Center(
        child: Text( !isPaid? "${AppLocalizationHelper.of(context).translate("Not Paid")}":
            "${AppLocalizationHelper.of(context).translate(OrderHelper.getOrderStatusText(orderStatus))}",
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
