import 'package:flutter/material.dart';

import 'package:flutter_screenutil/screenutil.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/OrderItem.dart';
import 'package:vplus_merchant_app/screens/order/table_bottom_bar/bottom_bar_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';

class TableOrderConfirmationListTile extends StatelessWidget {
  final OrderItem orderItem;

  TableOrderConfirmationListTile({this.orderItem});

  Widget getAddOnReceipt(List<String> strings, BuildContext context) {
    return new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: strings
            .map((item) => new Text(item,
                style: GoogleFonts.lato(
                  fontSize: ScreenHelper.isLandScape(context)
                      ? SizeHelper.textMultiplier * 1.5
                      : SizeHelper.textMultiplier * 1.7,
                )))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // key: ValueKey(menuItem.menuItemId),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(
      //     ScreenUtil().setSp(0),
      //   ),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.grey.withOpacity(0.5),
      //       spreadRadius: 1,
      //       blurRadius: 3,
      //       offset: Offset(1, 1), // changes position of shadow
      //     ),
      //   ],
      //   // border: Border.all(
      //   //   color: Colors.grey,
      //   //   width: ScreenUtil().setSp(1),
      //   // ),
      // ),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  constraints: BoxConstraints(
                    maxWidth: ScreenUtil().setWidth(
                        ScreenHelper.isLandScape(context)
                            ? SizeHelper.heightMultiplier * 15
                            : SizeHelper.widthMultiplier * 70),
                  ),
                  child: Text(
                    (orderItem.isTakeAway)
                        ? '${orderItem.menuItem.menuItemName} (Take away)'
                        : '${orderItem.menuItem.menuItemName}',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(
                          ScreenHelper.isLandScape(context)
                              ? SizeHelper.textMultiplier * 2
                              : 35),
                    ),
                  ),
                ),
                // show addon receipt if exists
                (orderItem.userOrderItemAddOnReceipt == null ||
                        orderItem.userOrderItemAddOnReceipt.length == 0)
                    ? Container()
                    : Container(
                        // width: ScreenUtil().setWidth(400),
                        constraints: BoxConstraints(
                          maxWidth: ScreenUtil().setWidth(
                              ScreenHelper.isLandScape(context)
                                  ? SizeHelper.heightMultiplier * 17
                                  : 370),
                          // maxHeight: ScreenUtil().setHeight(
                          //     orderItem.userOrderItemAddOnReceipt.length *
                          //         50.0),
                        ),
                        child: getAddOnReceipt(
                            orderItem.userOrderItemAddOnReceipt, context),
                      ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Text('\$19.80'),
                // getListTileButton(Icons.remove_circle_outline),
                Center(
                  child: Text('x${orderItem.quantity}',
                      style: GoogleFonts.lato(
                        fontSize: ScreenUtil().setSp(
                            ScreenHelper.isLandScape(context)
                                ? SizeHelper.textMultiplier * 2
                                : 35),
                      )),
                ),
                WEmptyView(50),
                Center(
                  child: Text('\$${orderItem.price.toStringAsFixed(2)}',
                      style: GoogleFonts.lato(
                        fontSize: ScreenUtil().setSp(
                            ScreenHelper.isLandScape(context)
                                ? SizeHelper.textMultiplier * 2
                                : 35),
                      )),
                ),
                // getListTileButton(Icons.add_circle_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getListTileButton(IconData iconData, {Function callback}) {
    return ButtonTheme(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minWidth: ScreenUtil().setWidth(20), //wraps child's width
      height: ScreenUtil().setWidth(70), //wraps child's height
      child: FlatButton(
        onPressed: () {
          callback();
        },
        child: Icon(
          iconData,
          color: BottomBarUtils.getThemeColor(),
        ),
      ),
    );
  }

  int _countCharactersNumberOfString(List<String> strList) {
    int number = 0;
    strList.forEach((s) => number += s.length);
    return number;
  }
}
