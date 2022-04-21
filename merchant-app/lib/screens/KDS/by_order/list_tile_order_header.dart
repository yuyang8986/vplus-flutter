import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/providers/current_order_provider.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/styles/font.dart';
import 'package:vplus_merchant_app/widgets/components.dart';

class KDSByOrderListTileHeader extends StatelessWidget {
  final Order orderItem;
  KDSByOrderListTileHeader({this.orderItem});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: greyoutAreaColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  (orderItem.orderType == OrderType.TakeAway)
                      ? "${CurrentOrderProvider().getTakeAwayIdShortcut(orderItem.takeAwayId)}"
                      : "Table:${orderItem.table}",
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: kdsItemHeaderFontSize)),
              Text("Order No.${orderItem.userOrderId}",
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: kdsItemHeaderFontSize)),
            ],
          ),
          RoundedSelectButton(
              "${AppLocalizationHelper.of(context).translate('Print')}", () {}),
        ],
      ),
    );
  }
}
