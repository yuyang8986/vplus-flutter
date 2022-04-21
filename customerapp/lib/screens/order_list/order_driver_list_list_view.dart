import 'package:flutter/cupertino.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/OrderWithStore.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/providers/driver_order_list_provider.dart';
import 'package:vplus/providers/order_list_provider.dart';
import 'package:vplus/screens/order_list/order_driver_list_list_tile.dart';

import 'order_detail/order_detail_screen.dart';
import 'order_list_list_view.dart';

class OrderDriverListListView extends StatefulWidget {
  OrderDriverListListView({Key key}) : super(key: key);
  _OrderDriverListListViewState createState() =>
      _OrderDriverListListViewState();
}

class _OrderDriverListListViewState extends State<OrderDriverListListView> {
  String isActive;
  List<OrderWithStore> orderList;
  int driverId;
  int pageNumber;
  ScrollController listViewController;
  bool isLoading;
  @override
  void initState() {
    super.initState();
    driverId = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser
        .driverId;
    isActive = Provider.of<DriverOrderListProvider>(context, listen: false)
        .getIsActive;
    isLoading = false;
    pageNumber = 1;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // setState(() {
      //   isLoading = true;
      // });
      await Provider.of<DriverOrderListProvider>(context, listen: false)
          .getOrderListByDriverId(context, driverId, pageNumber);
      // setState(() {
      //   isLoading = false;
      // });
    });
    listViewController = new ScrollController();
    initScrollController(listViewController);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Consumer<DriverOrderListProvider>(
        builder: (ctx, p, w) {
          orderList = (isActive == "1")
              ? p.deliveringOrderList
              : (isActive == "2")
                  ? p.allAvailableOrderList
                  : p.deliveredOrderList;
          return Container(
            child: (orderList == null || orderList.isEmpty)
                ? Container(child: Text("There are no orders nearby"))
                : SingleChildScrollView(
                    controller: listViewController,
                    child: Column(
                      children: <Widget>[
                        ListView.builder(
                            itemCount: orderList.length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (ctx, idx) {
                              OrderWithStore orderWithStore = orderList[idx];
                              return Padding(
                                padding:
                                    EdgeInsets.all(SizeHelper.heightMultiplier),
                                child: OrderDriverListListTile(
                                  order: orderWithStore,
                                  onPressed: () async {
                                    p.setSelectedOrderWithStore =
                                        orderWithStore;
                                    Provider.of<OrderListProvider>(context,
                                            listen: false)
                                        .setSelectedOrderWithStore = orderWithStore;
                                    pushNewScreen(context,
                                        screen: OrderDetailScreen(),
                                        withNavBar: false);
                                  },
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  // Future<void> _onRefresh() async {
  //   await Provider.of<OrderListProvider>(context, listen: false)
  //       .getOrderListByUserId(context, userId, pageNumber);
  //   return;
  // }

  Future<void> initScrollController(ScrollController _controller) async {
    _controller.addListener(() async {
      if (_controller.position.atEdge) {
        if (_controller.position.pixels != 0) {
          bool hasNextPage;
          setState(() {
            isLoading = true;
          });
          hasNextPage =
              Provider.of<DriverOrderListProvider>(context, listen: false)
                  .getHasNextPage;
          if (hasNextPage) {
            pageNumber += 1;
            await Provider.of<DriverOrderListProvider>(context, listen: false)
                .getOrderListByDriverId(context, driverId, pageNumber);
          }
          setState(() {
            isLoading = false;
          });
        } else {
          // at top, maybe pull to refresh
          await Provider.of<DriverOrderListProvider>(context, listen: false)
              .getOrderListByDriverId(context, driverId, 1);
        }
      }
    });
  }
}
