import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/OrderItem.dart';

import 'order_status_listtile.dart';

class OrderStatusListView extends StatelessWidget {
  final ScrollController scrollController;
  final List<OrderItem> orderItems;
  OrderStatusListView(this.orderItems, {this.scrollController});

  @override
  Widget build(BuildContext context) {
    // return Consumer<CurrentOrderProvider>(
    //   builder: (ctx, p, w) {
    //     var order = p.getOrder;
    //     if (order.orderItem == null || order.orderItem.length == 0) {
    //       return Container();
    //     }
    //     return
    //
    //       ListView(
    //       controller: widget.scrollController,
    //       children: order.orderItem
    //           .map((e) => TableShoppingCartListTile(orderItem: e))
    //           .toList(),
    //     );
    //   },
    // );

    return Container(
      // physics: ScrollPhysics(),
      // padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
      // controller: scrollController,
      child: ListView.builder(
        shrinkWrap: true,
        primary: false,
        reverse: true,
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
        // physics: NeverScrollableScrollPhysics(),
        itemCount: orderItems.length,
        itemBuilder: (ctx, index) {
          return OrderStatusListTile(orderItems[index]);
        },
      ),
    );
  }
}
