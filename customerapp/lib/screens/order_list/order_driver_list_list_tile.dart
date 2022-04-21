import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/DateTimeHelper.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/Order.dart';
import 'package:vplus/models/OrderWithStore.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/providers/driver_order_list_provider.dart';
import 'package:vplus/screens/stores/store_listtile.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/driver_order_status_badge.dart';
import 'package:vplus/widgets/emptyView.dart';
import 'package:vplus/widgets/order_status_badge.dart';

class OrderDriverListListTile extends StatelessWidget {
  final OrderWithStore order;
  final Function onPressed;
  OrderDriverListListTile({this.order, this.onPressed});

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    order.order.userOrderStatus == UserOrderStatus.Ready ||
                            order.order.userOrderStatus ==
                                UserOrderStatus.Delivering
                        ? TextButton(
                            onPressed: () async {
                              var hlp = new Helper();
                              var driverId = Provider.of<CurrentUserProvider>(
                                      context,
                                      listen: false)
                                  .getloggedInUser
                                  .driverId;

                              if (order.order.userOrderStatus ==
                                  UserOrderStatus.Ready) {
                                await pickOrder(hlp, driverId, context);
                              } else if (order.order.userOrderStatus ==
                                  UserOrderStatus.Delivering) {
                                await deliveredOrder(hlp, driverId, context);
                              }
                            },
                            child: Text(
                              order.order.userOrderStatus ==
                                      UserOrderStatus.Delivering
                                  ? "Delivered"
                                  : "Pick",
                              style: TextStyle(
                                  fontSize: SizeHelper.textMultiplier * 2.5),
                            ))
                        : Container()
                  ],
                ),
              ],
            )));
  }

  Future pickOrder(Helper hlp, int driverId, BuildContext context) async {
    var res = await hlp.putData(
        "api/menu/userOrders/delivery/${order.order.userOrderId}/assignDriver/$driverId",
        null,
        context: context,
        hasAuth: true);
    if (res.isSuccess) {
      await Provider.of<DriverOrderListProvider>(context, listen: false)
          .getOrderListByDriverId(context, driverId, 1);
    }
  }

  Future deliveredOrder(Helper hlp, int driverId, BuildContext context) async {
    var res = await hlp.putData(
        "api/menu/userOrders/delivery/${order.order.userOrderId}/setDelivered",
        null,
        context: context,
        hasAuth: true);
    if (res.isSuccess) {
      await Provider.of<DriverOrderListProvider>(context, listen: false)
          .getOrderListByDriverId(context, driverId, 1);
    }
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
