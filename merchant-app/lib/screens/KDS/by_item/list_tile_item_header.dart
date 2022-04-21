import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/OrderItemPrint.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/styles/font.dart';
import 'package:vplus_merchant_app/widgets/components.dart';

class KDSByItemListTileItemHeader extends StatelessWidget {
  final OrderItemPrint orderItem;
  KDSByItemListTileItemHeader({this.orderItem});
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
              Text(orderItem.menuItemName,
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: kdsItemHeaderFontSize)),
              Text("Quantity: x${orderItem.quantity}",
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
