import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus/helper/DateTimeHelper.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/OrderWithStore.dart';
import 'package:vplus/screens/stores/store_listtile.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/emptyView.dart';
import 'package:vplus/widgets/order_status_badge.dart';

class OrderListListTile extends StatelessWidget {
  final OrderWithStore order;
  final Function onPressed;
  OrderListListTile({this.order, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onPressed,
        child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 2.0, color: Colors.grey),
              ),
            ),
            child: Column(
              children: [
                orderHeader(),
                StoreListTile(
                  store: order.store,
                  order: order.order,
                ),
              ],
            )));
  }

  Widget orderStatus(BuildContext context) {
    return Row(
      children: [
        WEmptyView(30),
        OrderStatusBadge(
          orderStatus: order.order.userOrderStatus,
          isPaid: order.order.isPaid,
        ),
        // WEmptyView(20),
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Text(
        //         "${AppLocalizationHelper.of(context).translate("Total")} " +
        //             "\$${order.order.totalAmount.toStringAsFixed(2)}",
        //         style: GoogleFonts.lato()),
        //   ],
        // ),
      ],
    );
  }

  Widget orderHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text("#${order.order.userOrderId}",
          textAlign: TextAlign.start,
          style: GoogleFonts.lato(fontSize: SizeHelper.textMultiplier * 2)),
      Text(
          "${DateTimeHelper.parseDateTimeToDate(order.order.orderCreateDateTimeUTC.toLocal())}",
          textAlign: TextAlign.start,
          style: GoogleFonts.lato(fontSize: SizeHelper.textMultiplier * 2)),
    ]);
  }
}
