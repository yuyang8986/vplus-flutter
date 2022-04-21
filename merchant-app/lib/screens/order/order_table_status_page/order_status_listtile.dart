import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/OrderItem.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/providers/current_order_provider.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/styles/font.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';

// enum UserOrderStatus
// {
//   Started, AwaitingConfirmation, InProgress, Completed, Cancelled, Voided
// }
final List<Color> orderItemStatusColor = [
  // Colors.purple,
  awaitingConfirmationColor,
  preparingColor,
  servedColor,
  cancelledColor,
  returnedColor,
  voidedColor,
  readyColor
];
const List<String> UserOrderStatusString = [
  // "Started",
  "ItemStatusAwaitConfirm",
  "ItemStatusPreparing",
  "ItemStatusServed",
  "ItemStatusCancelled",
  "ItemStatusReturned",
  "ItemStatusVoided",
  "ItemStatusReady"
];

class OrderStatusListTile extends StatelessWidget {
  final OrderItem orderItem;
  ScrollController _receiptScrollController;

  OrderStatusListTile(this.orderItem);

  Widget getAddOnReceipt(List<String> strings, BuildContext context) {
    return new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: strings
            .map((item) => new Text(item,
                style: GoogleFonts.lato(
                    fontSize: shoppingCartAddOnReceiptTextSize)))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    // final orderStatus = orderItem.itemStatus.index;
    orderItem.userOrderItemAddOnReceipt =
        Provider.of<CurrentOrderProvider>(context, listen: false)
            .getAddOnReceiptFromBackend(this.orderItem);
    return Container(
      // key: ValueKey(orderItem.hashCode),
      child: ListTile(
        title: Container(
          margin: EdgeInsets.all(ScreenHelper.isLandScape(context) ? 10 : 0),
          // constraints: BoxConstraints(maxHeight: ScreenUtil().setHeight(200)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${orderItem.menuItem.menuItemName}',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeHelper.isMobilePortrait
                          ? 2 * SizeHelper.textMultiplier
                          : 2 * SizeHelper.textMultiplier,
                      decoration: orderItem.itemStatus == ItemStatus.Returned
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: (orderItem.itemStatus == ItemStatus.Cancelled ||
                              orderItem.itemStatus == ItemStatus.Returned)
                          ? orderItemStatusColor[orderItem.itemStatus.index]
                          : Colors.black,
                    ),
                  ),
                  (orderItem.userOrderItemAddOnReceipt == null ||
                          orderItem.userOrderItemAddOnReceipt.length == 0)
                      ? Container()
                      : Container(
                          width: ScreenUtil().setWidth(240),
                          // height: ScreenUtil().setHeight(150),
                          child: getAddOnReceipt(
                              orderItem.userOrderItemAddOnReceipt, context),
                        )
                ],
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: ScreenHelper.isLandScape(context)
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        'X ${orderItem.quantity}',
                        style: GoogleFonts.lato(
                          fontSize: ScreenUtil().setSp(
                              ScreenHelper.getResponsiveTextBodyFontSize(
                                  context)),
                          decoration:
                              orderItem.itemStatus == ItemStatus.Cancelled
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                          color: (orderItem.itemStatus ==
                                      ItemStatus.Cancelled ||
                                  orderItem.itemStatus == ItemStatus.Returned)
                              ? orderItemStatusColor[orderItem.itemStatus.index]
                              : Colors.black,
                        ),
                      ),
                    ),
                    WEmptyView(ScreenHelper.isLandScape(context)
                        ? SizeHelper.heightMultiplier * 5
                        : SizeHelper.widthMultiplier * 5),
                    Container(
                      child: Text(
                        '\$${orderItem.price.toStringAsFixed(2)}',
                        style: GoogleFonts.lato(
                          fontSize: ScreenUtil().setSp(
                              ScreenHelper.getResponsiveTextBodyFontSize(
                                  context)),
                          decoration:
                              orderItem.itemStatus == ItemStatus.Cancelled
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                          color: (orderItem.itemStatus ==
                                      ItemStatus.Cancelled ||
                                  orderItem.itemStatus == ItemStatus.Returned)
                              ? orderItemStatusColor[orderItem.itemStatus.index]
                              : Colors.black,
                        ),
                      ),
                    ),
                    WEmptyView(ScreenHelper.isLandScape(context)
                        ? SizeHelper.heightMultiplier * 5
                        : SizeHelper.widthMultiplier * 5),
                    Container(
                      height: SizeHelper.isMobilePortrait
                          ? 5 * SizeHelper.heightMultiplier
                          : 5 * SizeHelper.widthMultiplier,
                      width: SizeHelper.isMobilePortrait
                          ? 22 * SizeHelper.widthMultiplier
                          : (SizeHelper.isPortrait)
                              ? 13 * SizeHelper.heightMultiplier
                              : 18 * SizeHelper.heightMultiplier,
                      color: orderItemStatusColor[orderItem.itemStatus.index],
                      child: Center(
                        child: Text(
                          AppLocalizationHelper.of(context).translate(
                              UserOrderStatusString[
                                  orderItem.itemStatus.index]),
                          style: GoogleFonts.lato(
                            fontSize: ScreenUtil().setSp(
                                SizeHelper.isMobilePortrait
                                    ? 4 * SizeHelper.textMultiplier
                                    : 1.5 * SizeHelper.textMultiplier),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ])
            ],
          ),
        ),
      ),
    );
  }
}
