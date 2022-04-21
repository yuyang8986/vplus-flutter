import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus/providers/current_order_provider.dart';

import 'bottom_bar_shopping_cart_listtile.dart';

class TableShoppingCartListview extends StatefulWidget {
  final ScrollController scrollController;
  TableShoppingCartListview({this.scrollController});

  @override
  _TableShoppingCartListviewState createState() =>
      _TableShoppingCartListviewState();
}

class _TableShoppingCartListviewState extends State<TableShoppingCartListview> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentOrderProvider>(
      builder: (ctx, p, w) {
        var order = p.getOrder;
        if (order?.userItems == null || order?.userItems?.length == 0) {
          return Container();
        }
        return ListView(
          controller: widget.scrollController,
          children: order.userItems
              .map((e) => TableShoppingCartListTile(orderItem: e))
              .toList(),
        );
      },
    );
  }
}
