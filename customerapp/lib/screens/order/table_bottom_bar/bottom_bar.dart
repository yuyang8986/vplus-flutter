import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/models/Order.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/widgets/emptyView.dart';
import 'bottom_bar_place_order_button.dart';
import 'bottom_bar_price_label.dart';
import 'bottom_bar_utils.dart';

class TableBottomBar extends StatelessWidget {
  final bool isStoreOrdering;

  TableBottomBar({this.isStoreOrdering});

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
            children: (order?.orderType == OrderType.QR &&
                    (order?.userOrderStatus == UserOrderStatus.Started))
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
                      child:TablePlaceOrderButton(
                          isStoreOrdering: this.isStoreOrdering
                     )),
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
                      flex: ScreenHelper.isLandScape(context) ? 2 : 5,
                      child:TablePlaceOrderButton(
                          isStoreOrdering: this.isStoreOrdering
                      ),
                    ),
                  ]),
      );
    });
  }
}
