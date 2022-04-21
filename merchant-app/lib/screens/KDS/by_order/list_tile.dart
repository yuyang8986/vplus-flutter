import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/kdsHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/OrderItem.dart';
import 'package:vplus_merchant_app/providers/kds_provider.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/styles/font.dart';
import 'package:vplus_merchant_app/widgets/components.dart';

class KDSByOrderListTile extends StatelessWidget {
  final OrderItem orderItem;
  KDSByOrderListTile({this.orderItem});
  final double foneSize = SizeHelper.textMultiplier * 1.2;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: SizeHelper.textMultiplier),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(orderItem.menuItem.menuItemName,
                  style: GoogleFonts.lato(fontSize: foneSize)),
              Text("x${orderItem.quantity}",
                  style: GoogleFonts.lato(fontSize: foneSize)),
              RoundedSelectButton(
                  "${AppLocalizationHelper.of(context).translate('KDSReadyButton')}",
                  () async {
                await KDSHelper.setItemReady(
                    context, orderItem.userOrderItemId, orderItem.userOrderId);
              },
                  backgroundColor: confirmButtonBackgroundColor,
                  textColor: Colors.white),
            ],
          ),
          showAddOnReceipt(context),
        ],
      ),
    );
  }

  Widget showAddOnReceipt(BuildContext context) {
    return Container(
      // width: SizeHelper.widthMultiplier * 10,
      // show addon recetipt
      child: (orderItem.userOrderItemAddOnReceipt != null &&
              orderItem.userOrderItemAddOnReceipt.isNotEmpty)
          ? ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: orderItem.userOrderItemAddOnReceipt.length,
              itemBuilder: (context, index) {
                return Text(
                  orderItem.userOrderItemAddOnReceipt[index],
                  style: GoogleFonts.lato(
                      fontSize: kdsAddOnReceiptFontSize,
                      fontWeight: FontWeight.bold),
                );
              },
            )
          : Text(
              "${AppLocalizationHelper.of(context).translate('PrintPreviewPageNoAddOnNote')}",
              style: GoogleFonts.lato(
                  fontSize: kdsAddOnReceiptFontSize,
                  fontWeight: FontWeight.bold),
            ),
    );
  }
}
