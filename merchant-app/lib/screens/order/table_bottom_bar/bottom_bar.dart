import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/providers/current_order_provider.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:vplus_merchant_app/screens/order/table_bottom_bar/bottom_bar_place_order_button.dart';
import 'package:vplus_merchant_app/screens/order/table_bottom_bar/bottom_bar_price_label.dart';
import 'bottom_bar_utils.dart';

class TableBottomBar extends StatelessWidget {
  @override
  Widget build(
    BuildContext context,
  ) {
    return Consumer<CurrentOrderProvider>(builder: (ctx, p, w) {
      var order = p.getOrder;
      return Container(
        decoration: BoxDecoration(
          borderRadius: BottomBarUtils.bottomBarRadius(),
          color: Color(0xff5A6978),
        ),
        child: Row(
            children: (order.orderType == OrderType.QR &&
                    (order.userOrderStatus == UserOrderStatus.Started))
                ? [
                    Expanded(
                      flex: 2,
                      child: WEmptyView(10),
                    ),
                    Expanded(
                      flex: 3,
                      child: TablePriceLabel(),
                    ),
                    Expanded(
                      flex: 5,
                      child: TablePlaceOrderButton(),
                    ),
                  ]
                : [
                    Expanded(
                      flex: 2,
                      child: WEmptyView(10),
                    ),
                    Expanded(
                      flex: 3,
                      child: TablePriceLabel(),
                    ),
                    Expanded(
                      flex: 2,
                      child: TablePlaceOrderButton(),
                    ),
                  ]),
      );
    });
  }
}
