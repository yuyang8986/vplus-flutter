import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/OrderWithStore.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/providers/order_list_provider.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/screens/order_list/order_detail/order_detail_screen.dart';
import 'package:vplus/screens/order_list/order_list_list_tile.dart';

class OrderListListView extends StatefulWidget {
  OrderListListView({Key key}) : super(key: key);
  _OrderListListViewState createState() => _OrderListListViewState();
}

class _OrderListListViewState extends State<OrderListListView> {
  bool isActive;
  List<OrderWithStore> orderList;
  int userId;
  int pageNumber;
  ScrollController listViewController;
  bool isLoading;
  @override
  void initState() {
    super.initState();
    userId = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser
        .userId;
    isActive =
        Provider.of<OrderListProvider>(context, listen: false).getIsActive;
    isLoading = false;
    pageNumber = 1;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        isLoading = true;
      });
      await Provider.of<OrderListProvider>(context, listen: false)
          .getOrderListByUserId(context, userId, pageNumber);
      setState(() {
        isLoading = false;
      });
    });
    listViewController = new ScrollController();
    initScrollController(listViewController);
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Consumer<OrderListProvider>(
        builder: (ctx, p, w) {
          orderList = (isActive) ? p.getActiveOrderList : p.getHistoryOrderList;
          return Container(
            child: (orderList == null || orderList.isEmpty)
                ? Container()
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
                                child: OrderListListTile(
                                  order: orderWithStore,
                                  onPressed: () async {
                                    p.setSelectedOrderWithStore =
                                        orderWithStore;
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
          hasNextPage = Provider.of<OrderListProvider>(context, listen: false)
              .getHasNextPage;
          if (hasNextPage) {
            pageNumber += 1;
            await Provider.of<OrderListProvider>(context, listen: false)
                .getOrderListByUserId(context, userId, pageNumber);
          }
          setState(() {
            isLoading = false;
          });
        } else {
          // at top, maybe pull to refresh
          await Provider.of<OrderListProvider>(context, listen: false)
              .getOrderListByUserId(context, userId, 1);
        }
      }
    });
  }
}
