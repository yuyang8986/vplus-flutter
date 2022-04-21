import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus/helper/order_helper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/OrderItem.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/widgets/components.dart';

class OrderStatusListTile extends StatelessWidget {
  final OrderItem orderItem;

  OrderStatusListTile({this.orderItem});

  @override
  Widget build(BuildContext context) {
    orderItem.userOrderItemAddOnReceipt =
        Provider.of<CurrentOrderProvider>(context, listen: false)
            .getAddOnReceiptFromBackend(this.orderItem);
    return Container(
      child: ListTile(
        title: Container(
            margin: EdgeInsets.all(SizeHelper.textMultiplier * 0.5),
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SquareFadeInImage(orderItem.menuItem.imageUrl),
                      Column(
                        children: [
                          Container(
                            width: ScreenUtil().setWidth(360),
                            child: Text(
                              orderItem.menuItem.menuItemName,
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold,
                                fontSize: SizeHelper.textMultiplier * 2.5,
                                decoration: getOrderItemDecoration(orderItem),
                                color: getTextColor(orderItem),
                              ),
                            ),
                          ),
                          (orderItem.userOrderItemAddOnReceipt == null ||
                                  orderItem.userOrderItemAddOnReceipt.length ==
                                      0)
                              ? Container()
                              : Container(
                                  width: ScreenUtil().setWidth(360),
                                  child: getAddOnReceipt(
                                      orderItem.userOrderItemAddOnReceipt,
                                      context)),
                        ],
                      ),
                      Container(
                        child: Text(
                          'X ${orderItem.quantity}',
                          style: GoogleFonts.lato(
                            fontSize: SizeHelper.textMultiplier * 2,
                            decoration: getOrderItemDecoration(orderItem),
                            color: getTextColor(orderItem),
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          '\$${orderItem.price.toStringAsFixed(2)}',
                          style: GoogleFonts.lato(
                            fontSize: SizeHelper.textMultiplier * 2.2,
                            decoration: getOrderItemDecoration(orderItem),
                            color: getTextColor(orderItem),
                          ),
                        ),
                      ),
                    ]),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                )
              ],
            )),
      ),
    );
  }

  Color getTextColor(OrderItem orderItem) {
    /// for some order item status (eg: cancel return),
    /// the text color is in red
    return (orderItem.itemStatus == ItemStatus.Cancelled ||
            orderItem.itemStatus == ItemStatus.Returned)
        ? OrderHelper.getOrderItemStatusColor(orderItem.itemStatus)
        : Colors.black;
  }

  TextDecoration getOrderItemDecoration(OrderItem orderItem) {
    /// for some order item status (eg: cancel return),
    /// show a delete line through the order item text
    return orderItem.itemStatus == ItemStatus.Cancelled
        ? TextDecoration.lineThrough
        : TextDecoration.none;
  }

  Widget getAddOnReceipt(List<String> strings, BuildContext context) {
    return new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: strings
            .map((item) => new Text(item,
                style:
                    GoogleFonts.lato(fontSize: SizeHelper.textMultiplier * 2)))
            .toList());
  }
}
