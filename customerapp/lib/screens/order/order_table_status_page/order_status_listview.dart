import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/models/OrderItem.dart';

import 'order_status_listtile.dart';

class OrderStatusListView extends StatelessWidget {
  final ScrollController scrollController;
  final List<OrderItem> orderItems;
  OrderStatusListView(this.orderItems, {this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      // physics: ScrollPhysics(),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil()
                .setWidth(ScreenHelper.isLandScape(context) ? 20 : 0)),
        // physics: NeverScrollableScrollPhysics(),
        itemCount: orderItems.length,
        itemBuilder: (ctx, index) {
          return OrderStatusListTile(orderItem: orderItems[index]);
        },
      ),
    );
  }
}
