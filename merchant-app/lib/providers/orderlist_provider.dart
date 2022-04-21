import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/date_time_helper.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'current_orderStatus_provider.dart';
import "package:collection/collection.dart";

/// This provider contains all order list related functions.

class OrderListProvider with ChangeNotifier {
  // List<Order> allOrders;

  List<Order> activeOrder;
  List<Order> historyOrder;

  List<Order> dineInOrders;
  List<Order> takeAwayOrders;

  int currentActiveOrderPage = 1;
  bool hasNextActiveOrderPage = true;

  int currentHistoryOrderPage = 1;
  bool hasNextHistoryOrderPage = true;

  bool isOnActiveTab = true;

  List<Map<String, Object>> historyOrderDateTimeMap = [];
  var historyByDateMap;

  // OrderListProvider({
  //   this.activeOrder,
  //   this.historyOrder,
  // });

  bool getHasNextHistoryPage() {
    return this.hasNextHistoryOrderPage;
  }

  bool getHasNextActivePage() {
    return this.hasNextActiveOrderPage;
  }

  int getCurrentHistoryPage() {
    return this.currentHistoryOrderPage;
  }

  int getCurrentActivePage() {
    return this.currentActiveOrderPage;
  }

  Future getOrderListFromAPI(BuildContext context, int storeMenuId,
      bool isActiveOrder, int pageNumber) async {
    try {
      var helper = Helper();
      var response = (isActiveOrder)
          ? await helper.getData(
              'api/Menu/userOrders/$storeMenuId/all?IsActivePage=true&IsMax=true',
              context: context,
              hasAuth: true)
          : await helper.getData(
              'api/Menu/userOrders/${storeMenuId.toString()}/all?isActivePage=${isActiveOrder.toString()}&PageNumber=${pageNumber.toString()}',
              context: context,
              hasAuth: true);

      Map<String, dynamic> header = helper.getResponseHeaderXPag();
      // if (isActiveOrder) {
      //   currentActiveOrderPage = header['CurrentPage'] as int;
      //   hasNextActiveOrderPage = header["HasNext"] as bool;
      //   print(currentActiveOrderPage);
      // } else {
      //   currentHistoryOrderPage = header['CurrentPage'] as int;
      //   hasNextHistoryOrderPage = header["HasNext"] as bool;
      // }
      if (!isActiveOrder) {
        currentHistoryOrderPage = header['CurrentPage'] as int;
        hasNextHistoryOrderPage = header["HasNext"] as bool;
      }

      if (response.isSuccess == true && response.data != null) {
        // allOrders =
        //     List.from(response.data).map((e) => Order.fromJson(e)).toList();

        activeOrder ??= [];
        historyOrder ??= [];

        // bool insert = true;

        // if (!isActiveOrder && historyOrder == null) {
        //   historyOrder = [];
        //   insert = false;
        // }

        // if (!isActiveOrder) {
        //   if (currentHistoryOrderPage != 1) {
        //     insert = false;
        //   }
        // }

        List<int> historyOrderIds;

        if (this.historyOrder != null) {
          historyOrderIds = [];
          historyOrder.forEach((_order) {
            historyOrderIds.add(_order.userOrderId);
          });
        }

        if (isActiveOrder) setActiveOrderList([]);

        for (int i = 0; i < response.data.length; i++) {
          var data = response.data[i];

          Order order = Order.fromJson(data);
          // init parameters for frontend service only
          if (order != null) {
            if (order.paymentMethod == null) {
              order.paymentStatus = OrderPaymentStatus.AwaitingPayment;
            }
            if (order.discount == null) {
              order.discount = 0;
            }
            if (order.paymentSuccessful == null) {
              order.paymentSuccessful = false;
            }

            if (order.itemBeenServed == null) {
              order.itemBeenServed = false;
            }

            Provider.of<Current_OrderStatus_Provider>(context, listen: false)
                .determineOrderStatus(order, isActiveOrder);
            if (isActiveOrder) {
              addActiveOrder(order);
            } else {
              // filter redundant history order
              // addHistoryOrder(order, false);
              if (historyOrderIds != null) {
                if (historyOrderIds.contains(order.userOrderId)) {
                  // update history status
                  this.historyOrder[this.historyOrder.indexOf(order)] = order;
                  // this
                  //     .historyOrder[this.historyOrder.indexOf(order)]
                  //     .paymentStatus = order.paymentStatus;
                } else {
                  addHistoryOrder(order);
                }
              }
            }
          }
          // filter order by order id
          if (isActiveOrder)
            activeOrder = await filterRedundantOrder(activeOrder);
          // if (!isActiveOrder) {
          //   historyOrder = await filterRedundantOrder(historyOrder);
          // }
          await splitOrderTypeFromAllOrders();
        }
      } else {
        if (!response.isSuccess) {
          helper.showToastError(
              'Response Failed, please check your network and try again.');
          return Future.error(null);
        } else if (response.data == null) {
          // helper.showToastError('No Data Found');
        } else {
          // helper.showToastError('Unknown Error');
          return Future.error(null);
        }
      }

      notifyListeners();
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<void> generateNewOrder(
      BuildContext context, String userOrderId, bool isActiveOrder) async {
    bool alreadyExists = false;
    // try call API to get the latest active order
    int storeMenuId;
    storeMenuId =
        Provider.of<CurrentMenuProvider>(context, listen: false).getStoreMenuId;
    await getOrderListFromAPI(context, storeMenuId, isActiveOrder, 1);

    List<Order> activeOrders = getActiveOrderList();
    activeOrders.forEach((element) {
      if (element != null && element.userOrderId.toString() == userOrderId) {
        alreadyExists = true;
      }
    });

    if (!alreadyExists) {
      var helper = Helper();
      var response = await helper.getData('api/Menu/userOrders/$userOrderId',
          context: context, hasAuth: true);

      if (response.isSuccess) {
        print('Generate New Order');
        Order newOrder = Order.fromJson(response.data);

        if (newOrder.paymentMethod == null) {
          newOrder.paymentStatus = OrderPaymentStatus.AwaitingPayment;
        }
        if (newOrder.discount == null) {
          newOrder.discount = 0;
        }
        if (newOrder.paymentSuccessful == null) {
          newOrder.paymentSuccessful = false;
        }
        if (newOrder.itemBeenServed == null) {
          newOrder.itemBeenServed = false;
        }

        Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .determineOrderStatus(newOrder, isActiveOrder);
        addActiveOrder(newOrder);
      } else {
        // helper.showToastError("Genreate New Order From API Failed");
      }
    }

    notifyListeners();
  }

  Future<List<Order>> getHistoryOrdersByDate(
      BuildContext context, String dateTime, int storeMenuId) async {
    var helper = Helper();
    print(dateTime);
    var response = await helper.getData(
        'api/Menu/userOrders/allByDate?ChooseDate=${dateTime}&StoreMenuId=${storeMenuId.toString()}',
        context: context,
        hasAuth: true);
    if (response.isSuccess && response.data != null) {
      List<Order> orders = [];
      for (int i = 0; i < response.data.length; i++) {
        var data = response.data[i];
        Order order = Order.fromJson(data);
        if (order != null) {
          Provider.of<Current_OrderStatus_Provider>(context, listen: false)
              .determineOrderStatus(order, false);
          orders.add(order);
        }
      }
      return orders;
    }
    return [];
  }

  Future splitOrderTypeFromAllOrders() {
    // split the  dine in & takeaway order for the order list.

    if (activeOrder != null && activeOrder.isNotEmpty) {
      var orderMapByType = groupBy(activeOrder, (obj) => obj.orderType);

      dineInOrders = orderMapByType[OrderType.DineIn];
      if (orderMapByType[OrderType.QR] != null) {
        if (dineInOrders == null || dineInOrders.isEmpty == true) {
          dineInOrders = orderMapByType[OrderType.QR];
        } else {
          dineInOrders
              .addAll(orderMapByType[OrderType.QR]); // put QR in dine-in order
        }
      }

      takeAwayOrders = orderMapByType[OrderType.TakeAway];
    } else {
      // no active orders
      dineInOrders = [];
      takeAwayOrders = [];
    }
    // notifyListeners();
  }

  void setActiveOrderList(List<Order> orderList) {
    this.activeOrder = orderList;
    notifyListeners();
  }

  void setHistoryOrderList(List<Order> orderList) {
    this.historyOrder = orderList;
    notifyListeners();
  }

  void setActiveOrderList_OnIndex(int index, Order order) {
    this.activeOrder[index] = order;
    notifyListeners();
  }

  void setHistoryOrderList_OnIndex(int index, Order order) {
    this.historyOrder[index] = order;
    notifyListeners();
  }

  Future addActiveOrder(Order order) async {
    // back end returns data: newest to oldest
    // so add older order to the end of the list
    this.activeOrder.insert(0, order);
    activeOrder = await filterRedundantOrder(activeOrder);
    splitOrderTypeFromAllOrders();
    notifyListeners();
  }

  Future insertOrderToActiveOrderList(Order order) async {
    // add newly created order to active order list
    // always add new order to the top of the list
    this.activeOrder.insert(0, order);
    activeOrder = await filterRedundantOrder(activeOrder);
    await splitOrderTypeFromAllOrders();
    notifyListeners();
  }

  void updateActiveOrder(Order newOrder) {
    activeOrder[activeOrder.indexWhere(
        (order) => order.userOrderId == newOrder.userOrderId)] = newOrder;
    notifyListeners();
  }

  void addHistoryOrder(Order order) {
    if (order != null) {
      if (order.userOrderStatus != null &&
          order.userOrderStatus == UserOrderStatus.InProgress &&
          order.paymentSuccessful != null &&
          order.paymentSuccessful &&
          !order.isAdminReset) {
        order.userOrderStatus = UserOrderStatus.Completed;
        order.paymentStatus = OrderPaymentStatus.Paid;
      }
      if (this.historyOrder != null) {
        if (this.historyOrder.contains(order)) {
          this.historyOrder[this.historyOrder.indexOf(order)] = order;
        } else {
          this.historyOrder.insert(0, order);
        }
      }
      initMaps(order);
      notifyListeners();
    }
  }

  void initMaps(Order order) {
    if (this.historyOrderDateTimeMap == null ||
        this.historyOrderDateTimeMap.length == 0) {
      this.historyOrderDateTimeMap = [];
    }

    if (order.orderCompleteDateTimeUTC.toString().contains('0001-01-01')) {
      order.orderCompleteDateTimeUTC = DateTime.now().toUtc();
    }

    String dateTime = DateTimeHelper.parseDateTimeToDate(
        order.orderCompleteDateTimeUTC.toLocal());

    var data = {
      'order': order,
      'dateTime': dateTime,
      'orderCompleteDateTimeUTC': order.orderCompleteDateTimeUTC,
      'totalPaidAmount': order.totalPaidAmount
    };

    // this.historyOrderDateTimeMap.add(data);

    // if (insert) {
    //   this.historyOrderDateTimeMap.insert(0, data);
    // } else {
    //   this.historyOrderDateTimeMap.add(data);
    // }
    this.historyOrderDateTimeMap.add(data);
    sortHistoryMapByDate();
  }

  Map<dynamic, List<Map<String, Object>>> sortHistoryMapByDate() {
    historyByDateMap =
        groupBy(this.historyOrderDateTimeMap, (obj) => obj['dateTime']);
    // sort all history order by dt
    historyByDateMap.forEach((date, historyOrderList) {
      // sort reversely
      historyOrder.sort((b, a) =>
          a.orderCompleteDateTimeUTC.compareTo(b.orderCompleteDateTimeUTC));
    });
    notifyListeners();
    return historyByDateMap;
  }

  get getHistoryByDateMap => historyByDateMap;

  int getCompleteOrderByDate(
      String dateTime, Map<dynamic, List<Map<String, Object>>> data) {
    int count = 0;
    data[dateTime].forEach((entry) {
      if ((entry['order'] as Order).userOrderStatus ==
          UserOrderStatus.Completed) count += 1;
    });
    return count;
  }

  double getTotalPaidAmountByDate(
      String date, Map<dynamic, List<Map<String, Object>>> newMap) {
    double _totalPaidAmount = 0;
    newMap[date].forEach((entry) {
      if ((entry['order'] as Order).totalPaidAmount != null)
        _totalPaidAmount += (entry['order'] as Order).totalPaidAmount;
    });
    return _totalPaidAmount;
  }

  void removeItemFromActiveOrder(Order order) {
    if (activeOrder != null) {
      activeOrder.remove(order);
      splitOrderTypeFromAllOrders();
      notifyListeners();
    }
  }

  void removeItemFromHistoryOrder(Order order) {
    this.historyOrder.remove(order);
    notifyListeners();
  }

  // void clear_ActiveOrder() {
  //   this.activeOrder.clear();
  //   notifyListeners();
  // }

  // void clear_HistoryOrder() {
  //   this.historyOrder.clear();
  //   notifyListeners();
  // }

  List<Order> getActiveOrderList() {
    return this.activeOrder;
  }

  List<Order> getHistoryOrderList() {
    return this.historyOrder;
  }

  List<Order> getDineInOrderList() {
    return this.dineInOrders;
  }

  List<Order> getTakeAwayOrderList() {
    return this.takeAwayOrders;
  }

  void removeOrderFromDineInOrderList(Order order) {
    this.dineInOrders.remove(order);
    notifyListeners();
  }

  void removeOrderFromTakeAwayOrderList(Order order) {
    this.takeAwayOrders.remove(order);
    notifyListeners();
  }

  Future<List<Order>> filterRedundantOrder(List<Order> orderList) {
    List<Order> uniqueOrderList = [];
    List<int> uniqueOrderId = [];
    orderList.forEach((order) {
      if (order != null) {
        if (!uniqueOrderId.contains(order.userOrderId)) {
          uniqueOrderList.add(order);
          uniqueOrderId.add(order.userOrderId);
          // order exists in uniqueOrderList, but it is empty
          // need to get update to get the submitted order
        } else if (uniqueOrderId.contains(order.userOrderId) &&
            uniqueOrderList[uniqueOrderList.indexWhere(
                    (uOrder) => uOrder.userOrderId == order.userOrderId)]
                .userItems
                .isEmpty) {
          uniqueOrderList[uniqueOrderList.indexWhere(
              (uOrder) => uOrder.userOrderId == order.userOrderId)] = order;
        }
      }
    });

    // print('FILTER:${orderList.length} to ${uniqueOrderList.length}');
    return Future.value(uniqueOrderList);
  }

  clearOrderList() {
    if (this.activeOrder != null) this.activeOrder.clear();
    if (this.historyOrder != null) this.historyOrder.clear();
    if (this.historyOrderDateTimeMap != null)
      this.historyOrderDateTimeMap.clear();
  }

  bool isMenuLocked(BuildContext context) {
    // if store has active order, lock menu to avoid any potential issues
    bool isLocked = false;
    (activeOrder == null || activeOrder.isEmpty)
        ? isLocked = false
        : isLocked = true;
    return isLocked;
  }

  bool get getIsOnActiveTab => isOnActiveTab;

  void setIsOnActiveTab(bool value) {
    isOnActiveTab = value;
  }
}
