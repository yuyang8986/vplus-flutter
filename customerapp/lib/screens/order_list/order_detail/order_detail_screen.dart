import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/DateTimeHelper.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/Order.dart';
import 'package:vplus/models/OrderItem.dart';
import 'package:vplus/models/OrderWithStore.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/providers/current_store_provider.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/providers/order_list_provider.dart';
import 'package:vplus/screens/order/order_table_status_page/order_status_listtile.dart';
import 'package:vplus/screens/order/payment/payment_confirm_page.dart';
import 'package:vplus/screens/stores/store_listtile.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/appBar.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/widgets/emptyView.dart';

class OrderDetailScreen extends StatefulWidget {
  OrderDetailScreen({Key key}) : super(key: key);
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderWithStore orderWithStore;
  bool isLoading;
  int userId;
  @override
  void initState() {
    super.initState();
    isLoading = false;
    orderWithStore = Provider.of<OrderListProvider>(context, listen: false)
        .getSelectedOrderWithStore;
    userId = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser
        .userId;
    // Provider.of<CurrentStoreProvider>(context, listen: false).setCurrentStore =
    //     orderWithStore.store;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        isLoading = true;
      });
      await Provider.of<CurrentOrderProvider>(context, listen: false)
          .getOrderByOrderId(context, orderWithStore.order.userOrderId);
      orderWithStore.order =
          Provider.of<CurrentOrderProvider>(context, listen: false).getOrder;
      Provider.of<OrderListProvider>(context, listen: false)
          .setSelectedOrderWithStore = orderWithStore;
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar.getAppBar(
            "${AppLocalizationHelper.of(context).translate("ORDER")}" +
                " ${orderWithStore.order.userOrderId}",
            false,
            context: context,
            showLeftBackButton: true),
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(SizeHelper.heightMultiplier * 1.3),
              child: Column(
                children: [
                  StoreListTile(
                    store: orderWithStore.store,
                    order: orderWithStore.order,
                  ),
                  orderDateTimeInfo(),
                  orderItemListView(),
                  orderSummary(orderWithStore.order),
                  orderOperationButton(orderWithStore.order),
                ],
              ),
            ),
          ),
        ));
  }

  Widget orderDateTimeInfo() {
    return Card(
      child: Container(
        padding: EdgeInsets.all(5),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //     "${AppLocalizationHelper.of(context).translate("OrderTime")}" +
            //         " ${DateTimeHelper.parseDateTimeToDateHHMM(orderWithStore.order.orderCreateDateTimeUTC.toLocal())}",
            //     style:
            //         GoogleFonts.lato(fontSize: SizeHelper.textMultiplier * 2)),
            // Text(
            //     "${AppLocalizationHelper.of(context).translate("TotalAmount")}" +
            //         " \$${orderWithStore.order.totalAmount.toStringAsFixed(2)}",
            //     style:
            //         GoogleFonts.lato(fontSize: SizeHelper.textMultiplier * 2)),
            // VEmptyView(50),
            // Text("Delivery Address:",
            //     style: GoogleFonts.lato(
            //         fontWeight: FontWeight.bold,
            //         fontSize: SizeHelper.textMultiplier * 2.5)),
            // Text(
            //     "${orderWithStore.order.userAddress?.unitNo ?? ''}  " +
            //         "${orderWithStore.order.userAddress?.streetNo ?? ''} " +
            //         "${orderWithStore.order.userAddress?.streetName ?? ''} " +
            //         "\n${orderWithStore.order.userAddress?.city ?? ''} " +
            //         "${orderWithStore.order.userAddress?.postCode ?? ''}",
            //     style:
            //         GoogleFonts.lato(fontSize: SizeHelper.textMultiplier * 2)),
          ],
        ),
      ),
    );
  }

  Widget orderItemListView() {
    return Consumer<CurrentOrderProvider>(builder: (ctx, p, w) {
      List<OrderItem> orderItems = p.getPlacedOrder?.userItems;
      return (orderItems == null || orderItems.isEmpty)
          ? Container()
          : Expanded(
              child: Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: orderItems.length,
                    itemBuilder: (ctx, idx) {
                      OrderItem orderItem = orderItems[idx];
                      return OrderStatusListTile(orderItem: orderItem);
                    }),
              ),
            );
    });
  }

  Widget orderOperationButton(Order order) {
    return Column(
        children: order.userOrderStatus == UserOrderStatus.Cancelled
            ? [Container()]
            : determineOperationButton(order));
  }

  Widget orderSummary(
    Order order,
  ) {
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
            Text(
                "${AppLocalizationHelper.of(context).translate("Discount")} " +
                    "\$${order.discount.toStringAsFixed(2)}",
                style: GoogleFonts.lato(
                    fontSize: SizeHelper.textMultiplier * 2.5)),
            Text(
                "Delivery Fee: " +
                    "\$${order.deliveryFee?.toStringAsFixed(2) ?? 0}",
                style: GoogleFonts.lato(
                    fontSize: SizeHelper.textMultiplier * 2.5)),
            Text(
                "${AppLocalizationHelper.of(context).translate("Total")} " +
                    "\$${(order.totalAmount - order.discount).toStringAsFixed(2)}",
                style: GoogleFonts.lato(
                    fontSize: SizeHelper.textMultiplier * 2.5)),
          ],
        ),
      ),
    );
  }

  List<Widget> determineOperationButton(Order order) {
    if (order.orderType == OrderType.Delivery &&
        order.userOrderStatus != UserOrderStatus.Delivered)
      return <Widget>[Container()];
    switch (order.userOrderStatus) {
      case UserOrderStatus.Ready:
        return <Widget>[
          RoundedVplusLongButton(
              callBack: () async {
                bool hasCompleted = false;
                setState(() {
                  isLoading = true;
                });
                hasCompleted = await Provider.of<CurrentOrderProvider>(context,
                        listen: false)
                    .resetTable(context, order.userOrderId);
                setState(() {
                  isLoading = false;
                });
                if (hasCompleted) {
                  Provider.of<OrderListProvider>(context, listen: false)
                      .addOrderWithStoreToHistory(orderWithStore);
                  Helper().showToastSuccess(
                      "${AppLocalizationHelper.of(context).translate("OrderCompleted")}");
                  Navigator.pop(context);
                }
              },
              text:
                  "${AppLocalizationHelper.of(context).translate("Complete")}")
        ];
        break;
      case UserOrderStatus.Delivered:
        return <Widget>[
          RoundedVplusLongButton(
              callBack: () async {
                bool hasCompleted = false;
                setState(() {
                  isLoading = true;
                });
                hasCompleted = await Provider.of<CurrentOrderProvider>(context,
                        listen: false)
                    .resetTable(context, order.userOrderId);
                setState(() {
                  isLoading = false;
                });
                if (hasCompleted) {
                  Provider.of<OrderListProvider>(context, listen: false)
                      .addOrderWithStoreToHistory(orderWithStore);
                  Helper().showToastSuccess(
                      "${AppLocalizationHelper.of(context).translate("OrderCompleted")}");
                  Navigator.pop(context);
                }
              },
              text:
                  "${AppLocalizationHelper.of(context).translate("Complete")}")
        ];
        break;
      case UserOrderStatus.AwaitingConfirmation:
        if (!order.isPaid) {
          return <Widget>[
            RoundedVplusLongButton(
                callBack: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) => PaymentConfirmPage()));
                },
                text: "${AppLocalizationHelper.of(context).translate("Pay")}"),
            // RoundedVplusLongButton(
            //   callBack: () async {
            //     bool hasCancelled = await Provider.of<CurrentOrderProvider>(
            //             context,
            //             listen: false)
            //         .cancelOrder(order.userOrderId, context);
            //     if (hasCancelled != null && hasCancelled) {
            //       Helper().showToastSuccess("Order cancelled");
            //       Provider.of<OrderListProvider>(context, listen: false)
            //           .addOrderWithStoreToHistory(orderWithStore);
            //       Navigator.pop(context);
            //     }
            //   },
            //   text: "Cancel",
            //   color: cancelledColor,
            // ),
          ];
        } else {
          return <Widget>[Container()];
        }
        break;
      default:
        return <Widget>[Container()];
    }
  }
}
