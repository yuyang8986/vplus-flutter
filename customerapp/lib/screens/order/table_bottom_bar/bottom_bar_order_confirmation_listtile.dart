import 'package:flutter/material.dart';

import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/OrderItem.dart';
import 'bottom_bar_utils.dart';

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
                      ? SizeHelper.textMultiplier
                      : SizeHelper.textMultiplier * 1.5,
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
        title: Flex(
          direction: Axis.horizontal,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: ScreenHelper.isLandScape(context)
                          ? SizeHelper.heightMultiplier * 15
                          : SizeHelper.widthMultiplier * 35,
                    ),
                    child: Text(
                      (orderItem.isTakeAway)
                          ? '${orderItem.menuItem.menuItemName} (Take away)'
                          : '${orderItem.menuItem.menuItemName}',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenHelper.isLandScape(context)
                            ? SizeHelper.textMultiplier * 2
                            : SizeHelper.textMultiplier * 2,
                      ),
                    ),
                  ),
                  // show addon receipt if exists
                  (orderItem.userOrderItemAddOnReceipt == null ||
                          orderItem.userOrderItemAddOnReceipt.length == 0)
                      ? Container()
                      : Container(
                          child: getAddOnReceipt(
                              orderItem.userOrderItemAddOnReceipt, context)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Text('x${orderItem.quantity}',
                    style: GoogleFonts.lato(
                      fontSize: ScreenHelper.isLandScape(context)
                          ? SizeHelper.textMultiplier * 2
                          : SizeHelper.textMultiplier * 2,
                    )),
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Text('\$${orderItem.price.toStringAsFixed(2)}',
                    style: GoogleFonts.lato(
                      fontSize: ScreenHelper.isLandScape(context)
                          ? SizeHelper.textMultiplier * 2
                          : SizeHelper.textMultiplier * 2,
                    )),
              ),
            ),
          ],
        ),
      ),
      // ),
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
