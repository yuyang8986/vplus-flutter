import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/order_helper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/OrderItem.dart';

class ItemStatusBadge extends StatelessWidget {
  ItemStatus itemStatus;
  ItemStatusBadge({Key key, @required this.itemStatus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 10, 15),
      width: 20 * SizeHelper.widthMultiplier,
      color: OrderHelper.getOrderItemStatusColor(itemStatus), //Container color
      child: Center(
        child: Text(
            "${AppLocalizationHelper.of(context).translate(OrderHelper.getOrderItemStatusText(itemStatus))}",
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
