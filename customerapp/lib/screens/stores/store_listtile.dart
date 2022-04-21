import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/estimatedTimeHelper.dart';
import 'package:vplus/helper/order_helper.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/Order.dart';
import 'package:vplus/models/store.dart';
import 'package:vplus/screens/stores/store_campaign_badge.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/widgets/emptyView.dart';
import 'package:vplus/widgets/order_status_badge.dart';

class StoreListTile extends StatelessWidget {
  final Store store;
  final Order order;
  bool showCampaignInfo;

  StoreListTile(
      {Key key, @required this.store, this.showCampaignInfo = true, this.order})
      : super(key: key);

  deliveryInfo(order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VEmptyView(20),
        Text("Delivery Address:",
            style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: SizeHelper.textMultiplier * 2)),
        Text(
            "${order.userAddress?.unitNo ?? ''}  " +
                "${order.userAddress?.streetNo ?? ''} " +
                "${order.userAddress?.streetName ?? ''} " +
                "\n${order.userAddress?.city ?? ''} " +
                "${order.userAddress?.postCode ?? ''}",
            style: GoogleFonts.lato(fontSize: SizeHelper.textMultiplier * 2)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      child: ListTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     //StoreLogoOrBackground(store: store),
            //     VEmptyView(50),
            //     order == null?Container():  OrderStatusBadge(orderStatus: order.userOrderStatus, isPaid: order.isPaid)
            //   ],
            // ),
            // WEmptyView(10),
            Container(
              // margin: EdgeInsets.only(
              //     left: ScreenHelper.isLandScape(context)
              //         ? 10
              //         : SizeHelper.widthMultiplier * 2),
              child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text("${store.storeName}",
                    //     style: GoogleFonts.lato(
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: ScreenHelper.isLandScape(context)
                    //             ? SizeHelper.textMultiplier * 3
                    //             : SizeHelper.textMultiplier * 2)),
                    // Text(
                    //     "${(store.storeBusinessCategories?.length ?? 0) > 0 ? store.storeBusinessCategories?.first?.catName : "Food"}  - \$\$",
                    //     style: GoogleFonts.lato(
                    //         fontStyle: FontStyle.italic,
                    //         fontWeight: FontWeight.normal)),
                    order?.userAddress != null
                        ? deliveryInfo(order)
                        : Container(),
                    // store.distance != null
                    //     ? Container(
                    //         constraints: BoxConstraints(
                    //           maxWidth: SizeHelper.widthMultiplier * 45,
                    //         ),
                    //         child: Text(
                    //             (store.distance != null)
                    //                 ? (store.distance < 1)
                    //                     ? "${(store.distance * 1000).toStringAsFixed(2)} m"
                    //                     : "${store.distance.toStringAsFixed(2)} km"
                    //                 : "",
                    //             style: GoogleFonts.lato(
                    //                 fontStyle: FontStyle.italic,
                    //                 fontWeight: FontWeight.normal)),
                    //       )
                    //     : Container(),
                    // Container(
                    //   constraints: BoxConstraints(
                    //     maxWidth: SizeHelper.widthMultiplier * 45,
                    //   ),
                    //   child: Text(
                    //       EstimatedTimeHelper.generateEstimatedDistance(
                    //           store.distance),
                    //       style: GoogleFonts.lato(
                    //           fontStyle: FontStyle.italic,
                    //           fontWeight: FontWeight.normal)),
                    // ),
                    VEmptyView(50),
                    Text(
                        "Status: " +
                            OrderHelper.getOrderStatusText(
                                order.userOrderStatus),
                        style: GoogleFonts.lato(
                            color: OrderHelper.getOrderStatusColor(
                                order.userOrderStatus))),
                    VEmptyView(50),
                    Container(
                        child: (order.orderCreateDateTimeUTC.hour < 19)
                            ? Text(
                                "Estimated delivery time: ${order.orderCreateDateTimeUTC.year}-${order.orderCreateDateTimeUTC.month}-${order.orderCreateDateTimeUTC.day + 1}")
                            : Text(
                                "Estimated delivery time: ${order.orderCreateDateTimeUTC.year}-${order.orderCreateDateTimeUTC.month}-${order.orderCreateDateTimeUTC.day + 2}")),
                    order != null
                        ? Text(
                            "${AppLocalizationHelper.of(context).translate("Total")} " +
                                "\$${(order.totalAmount - order.discount).toStringAsFixed(2)}",
                            style: GoogleFonts.lato())
                        : Container(),
                  ]),
            ),
            // WEmptyView(50),
            // store.campaign != null && showCampaignInfo
            //     ? StoreCampaignBadge(campaign: store.campaign)
            //     : Container(),
          ],
        ),
      ),
    );
  }
}
