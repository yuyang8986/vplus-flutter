import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/date_time_helper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/models/OrderItem.dart';
import 'package:vplus_merchant_app/providers/current_order_provider.dart';
import 'package:vplus_merchant_app/screens/KDS/by_order/list_tile.dart';
import 'package:vplus_merchant_app/screens/KDS/by_order/list_tile_order_header.dart';
import 'package:vplus_merchant_app/styles/color.dart';

class KDSByOrderListView extends StatelessWidget {
  final Order order;
  KDSByOrderListView({this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          SizeHelper.textMultiplier * 1,
        ),
        border: Border.all(
          color: cornerRadiusContainerBorderColor,
          width: SizeHelper.widthMultiplier * 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KDSByOrderListTileHeader(
            orderItem: order,
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(vertical: SizeHelper.heightMultiplier * 1),
            child: Text(
              "Order time: ${DateTimeHelper.parseDateTimeToDateHHMM(order.orderCreateDateTimeUTC.toLocal())}",
              style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.textMultiplier * 1.5),
            ),
          ),
          if (order.note != null && order.note.length > 0)
            orderNote(context, order.note),
          Divider(
            color: cornerRadiusContainerBorderColor,
          ),
          Expanded(
            child: ListView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: order.userItems.length,
              itemBuilder: (ctx, index) {
                OrderItem orderItem = order.userItems[index];
                return KDSByOrderListTile(
                  orderItem: orderItem,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget orderNote(BuildContext context, String note) {
    return Container(
      margin: EdgeInsets.all(SizeHelper.textMultiplier * 0.5),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        color: orderNoteBackgroundColor,
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeHelper.textMultiplier * 0.5),
        child: Text(
          '${AppLocalizationHelper.of(context).translate('Note')}: $note',
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: SizeHelper.textMultiplier * 1.5,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }
}
