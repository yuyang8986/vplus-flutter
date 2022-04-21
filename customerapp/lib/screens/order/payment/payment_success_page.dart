import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/Order.dart';
import 'package:vplus/models/store.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/providers/current_store_provider.dart';
import 'package:vplus/screens/home/home.dart';
import 'package:vplus/screens/order/order_table_status_page/order_status_listview.dart';
import 'package:vplus/screens/order_list/order_detail/order_detail_screen.dart';
import 'package:vplus/screens/order_list/order_list_screen.dart';
import 'package:vplus/screens/stores/store_listtile.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/appBar.dart';
import 'package:vplus/widgets/emptyView.dart';
import 'package:vplus/widgets/order_status_badge.dart';

class PaymentSuccessPage extends StatefulWidget {
  PaymentSuccessPage({Key key}) : super(key: key);

  _PaymentSuccessPageState createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  Store store;
  Order order;

  @override
  void initState() {
    super.initState();
    store = Provider.of<CurrentStoreProvider>(context, listen: false)
        .getCurrentStore;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar.getAppBar('Payment Success', false,
            context: context, showLeftHomeButton: true),
        body: Consumer<CurrentOrderProvider>(builder: (ctx, p, w) {
          order = p.getPlacedOrder;
          return Column(
            children: [
              paymentSuccessSign(),
              orderPickupInformation(),
             // paymentStoreHeader(),
              orderItemList(),
              orderSummary(),
            ],
          );
        }),
      ),
    );
  }

  Widget paymentSuccessSign() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding:
                EdgeInsets.symmetric(vertical: SizeHelper.heightMultiplier * 2),
            child: Icon(
              Icons.check_circle,
              size: SizeHelper.textMultiplier * 12,
              color: confirmButtonBackgroundColor,
            ),
          ),
          // Text("Order paid successfully!",
          //     style: GoogleFonts.lato(fontSize: SizeHelper.textMultiplier * 3)),
        ],
      ),
    );
  }

  Widget orderPickupInformation() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Order No: ${order.userOrderId}",
              style: GoogleFonts.lato(fontSize: SizeHelper.textMultiplier * 3)),
          VEmptyView(30),
          Text("Order Time: ${order.orderCreateDateTimeUTC.year}-${order.orderCreateDateTimeUTC.month}-${order.orderCreateDateTimeUTC.day} ${order.orderCreateDateTimeUTC.hour}:${order.orderCreateDateTimeUTC.minute}",
              style: GoogleFonts.lato(fontSize: SizeHelper.textMultiplier * 2)),
          VEmptyView(30),
          Container(
              child:
              (order.orderCreateDateTimeUTC.hour <19)
                  ?Text(
                  "(Your order will be delivered on ${order.orderCreateDateTimeUTC.year}-${order.orderCreateDateTimeUTC.month}-${order.orderCreateDateTimeUTC.day+1} :)"
              ):Text(
                  "(Your order will be delivered on ${order.orderCreateDateTimeUTC.year}-${order.orderCreateDateTimeUTC.month}-${order.orderCreateDateTimeUTC.day+2} :)"
              )
          ),
          VEmptyView(30),
          InkWell(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(
                  builder: (BuildContext context) {
                    return HomeScreen(
                      initTab: HomeScreenTabs.Orders,
                    );
                  },
                ),
                (_) => false,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: cornerRadiusContainerBorderColor),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(SizeHelper.textMultiplier * 1.7),
                child: Text("View my order status",
                    style: GoogleFonts.lato(
                        fontSize: SizeHelper.textMultiplier * 2.5,
                        fontWeight: FontWeight.w900)),
              ),
            ),
          ),
          Divider(thickness: 2,)
          // Center(
          //   child: Padding(
          //     padding: EdgeInsets.all(SizeHelper.widthMultiplier * 3),
          //     child: Text(
          //         "Please provide your order number at the counter for collecting your order.",
          //         style: GoogleFonts.lato(
          //             fontSize: SizeHelper.textMultiplier * 2)),
          //   ),
          // )
        ],
      ),
    );
  }

  Widget paymentStoreHeader() {
    return Container(
      height: SizeHelper.heightMultiplier * 15,
      color: Colors.white,
      // width: double.infinity,
      child: Row(
        children: [
          Flexible(
            flex: 9,
            child: StoreListTile(
              store: store,
              showCampaignInfo: false,
            ),
          ),
          // Column(
          //     children: [
          //       Icon(Icons.refresh),
          //       Padding(
          //         padding: EdgeInsets.all(SizeHelper.textMultiplier * 1.5),
          //         child: OrderStatusBadge(
          //           orderStatus: order.userOrderStatus,
          //         ),
          //       )
          //     ],
          //   ),
        ],
      ),
    );
  }

  Widget orderItemList() {
    return Expanded(
      child: Container(
        color: Colors.white,
        width: double.infinity,
        child: OrderStatusListView(
          order.userItems,
        ),
      ),
    );
  }

  Widget orderSummary() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: SizeHelper.widthMultiplier * 3,
            vertical: SizeHelper.heightMultiplier * 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("Discount: \$${order.discount.toStringAsFixed(2)}",
                style:
                    GoogleFonts.lato(fontSize: SizeHelper.textMultiplier * 2)),
            Text("Total: \$${(order.totalAmount - order.discount).toStringAsFixed(2)}",
                style:
                    GoogleFonts.lato(fontSize: SizeHelper.textMultiplier * 2)),
          ],
        ),
      ),
    );
  }
}
