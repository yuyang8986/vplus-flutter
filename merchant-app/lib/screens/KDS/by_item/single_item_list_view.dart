import 'package:flutter/material.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/OrderItemPrint.dart';
import 'package:vplus_merchant_app/screens/KDS/by_item/flavored_item_list_tile.dart';
import 'package:vplus_merchant_app/screens/KDS/by_item/list_tile_item_header.dart';
import 'package:vplus_merchant_app/styles/color.dart';

class KDSByItemListView extends StatelessWidget {
  final OrderItemPrint orderItem;
  KDSByItemListView({this.orderItem});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          SizeHelper.textMultiplier * 1,
        ),
        border: Border.all(
          color: cornerRadiusContainerBorderColor,
          width: SizeHelper.widthMultiplier * 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          KDSByItemListTileItemHeader(
            orderItem: orderItem,
          ),
          // flavored item
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              primary: false,
              physics: ScrollPhysics(),
              padding: EdgeInsets.symmetric(
                  horizontal: SizeHelper.widthMultiplier * 1),
              itemCount: orderItem.flavoredItems.length,
              itemBuilder: (ctx, index) {
                FlavoredOrderItem flavoredItem = orderItem.flavoredItems[index];
                return KDSByItemFlavoredItem(flavoredItem: flavoredItem);
              },
            ),
          ),
        ],
      ),
    );
  }
}
