import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/DateTimeHelper.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/models/Order.dart';
import 'package:vplus/models/user.dart';
import 'package:vplus/providers/current_menu_provider.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/providers/current_store_provider.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'order_tables_page.dart';

class OrderTablesInitPage extends StatefulWidget {
  final String tableNumber;
  final int storeId;
  final bool isTakeAway;
  final String userOrderId;

  OrderTablesInitPage(
      this.storeId, this.tableNumber, this.isTakeAway, this.userOrderId);

  @override
  _OrderTablesInitPageState createState() => _OrderTablesInitPageState();
}

class _OrderTablesInitPageState extends State<OrderTablesInitPage> {
  CurrentOrderProvider _orderProviderInstance;
  String takeAwayIdShortcut;
  bool _isInAsyncCall = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<bool> initOrder() async {
    setState(() {
      _isInAsyncCall = true;
    });

    User user = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser;

    var menu = await Provider.of<CurrentMenuProvider>(context, listen: false)
        .getMenuFromAPI(context, widget.storeId);
    await Provider.of<CurrentStoreProvider>(context, listen: false)
        .getSingleStoreById(context, menu.storeId);
    await _orderProviderInstance.initOrder(
        context,
        menu.storeMenuId,
        widget.isTakeAway
            ? _orderProviderInstance.generateTakeAwayId()
            : widget
                .tableNumber, // temporoary use TA to distinguish takeaway orders
        OrderType.QR.index,
        user.userId);

    try {
      // for takeaway order
      if (widget.isTakeAway &&
          _orderProviderInstance.checkIsQRTakeAwayOrder()) {
        // currently using table number for takeaway id
        takeAwayIdShortcut = _orderProviderInstance.getOrder.table;
        _orderProviderInstance.setOrderTakeAwayId(takeAwayIdShortcut);
      }
      // check if its an exist order
      else if (_orderProviderInstance.getOrder.table == null) {
        /// if dineIn order has no table number, it should be an exist order
        /// need to get the exist order by order id.
        int orderId = _orderProviderInstance.getOrder.userOrderId;
        await _orderProviderInstance.getOrderByOrderId(context, orderId);
        print(_orderProviderInstance.getOrder);
      }
    } catch (e) {
      setState(() {
        _isInAsyncCall = false;
      });
      print(e.toString());
      return false;
    }

    setState(() {
      _isInAsyncCall = false;
    });
    return true;
  }

  Future navigatorToNextPage() async {
    if (widget.userOrderId != null) {
      var helper = Helper();
      var response = await helper.getData(
          "api/menu/userOrders/" + widget.userOrderId,
          context: context,
          hasAuth: true);
      if (response.isSuccess) {
        Order order = Order.fromJson(response.data);
        if (DateTimeHelper.checkOrderNotCompleted(
            order.orderCompleteDateTimeUTC.toString())) {
          bool isSuccess = await initOrder();

          // pushNewScreen(
          //   context,
          //   screen: OrderTablesPage(
          //     widget.storeId,
          //     widget.tableNumber,
          //     widget.isTakeAway,
          //   ),
          //   withNavBar: false,
          //   pageTransitionAnimation: PageTransitionAnimation.cupertino,
          // );

          if (isSuccess) {
            Navigator.of(context, rootNavigator: false).push(
              MaterialPageRoute(
                  builder: (context) => OrderTablesPage(
                        widget.storeId,
                        widget.tableNumber,
                        widget.isTakeAway,
                      )),
            );
          } else {
            Navigator.popUntil(context, (Route route) {
              return (route?.settings?.name == "/") ? true : false;
            });
          }
        }
        // if order is completed go back to home page
        else {
          Navigator.popUntil(context, (Route route) {
            return (route?.settings?.name == "/") ? true : false;
          });
        }
      }
      // when response failed go back to home page
      else {
        Navigator.popUntil(context, (Route route) {
          return (route?.settings?.name == "/") ? true : false;
        });
      }
    } else {
      await initOrder();

      if (_orderProviderInstance.getOrder != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OrderTablesPage(
                    widget.storeId,
                    widget.tableNumber,
                    widget.isTakeAway,
                  )),
        );
      } else {
        Navigator.popUntil(context, (Route route) {
          return (route?.settings?.name == "/") ? true : false;
        });
      }
    }
  }

  @override
  void initState() {
    _orderProviderInstance =
        Provider.of<CurrentOrderProvider>(context, listen: false);

    // if user entered another table before, clear previous order data
    if (_orderProviderInstance.getOrder != null) {
      _orderProviderInstance.clearOrder();
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await navigatorToNextPage();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        inAsyncCall: _isInAsyncCall,
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
        child: Container());
  }
}
