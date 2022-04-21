import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vplus_merchant_app/models/OrderItem.dart';
import 'package:vplus_merchant_app/screens/printer/print_by_order_listtile.dart';

class PrintByOrderListView extends StatelessWidget {
  final ScrollController scrollController;
  final List<OrderItem> orderItems;
  PrintByOrderListView(this.orderItems, {this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        primary: false,
        reverse: true,
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
        itemCount: orderItems.length,
        itemBuilder: (ctx, index) {
          // return PrintByOrderListTile(orderItems[index]);
        },
      ),
    );
  }
}
