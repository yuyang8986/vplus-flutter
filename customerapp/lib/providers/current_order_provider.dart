import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/helper/order_helper.dart';
import 'package:vplus/models/Order.dart';
import 'package:vplus/models/OrderItem.dart';
import 'package:vplus/models/campaign.dart';
import 'package:vplus/models/fees.dart';
import 'package:vplus/models/menuAddOn.dart';
import 'package:vplus/models/menuAddOnOption.dart';
import 'package:vplus/models/menuItem.dart';
import 'package:vplus/models/store.dart';
import 'package:vplus/models/userOrderItemAddOn.dart';
import 'package:vplus/providers/order_list_provider.dart';

import 'current_store_provider.dart';
import 'groceries_item_provider.dart';

class CurrentOrderProvider with ChangeNotifier {
  List<MenuAddOnOption> menuAddOnOptionList;
  MenuAddOn menuAddOn;
  MenuItem menuItem;
  OrderItem selectedOrderItem;
  Order order;
  Order placedOrder;
  // Store currentStore;
  bool hasOrderSubmittedThisSession = false;
  bool isDeliveryOrder = false;
  List<Fees> fees;
  //Fees deliveryFee;
  UserOrderItemAddOn userOrderItemAddOn = new UserOrderItemAddOn();

  List<Fees> get getCurrentFees => fees;

  double get getDeliveryDiscount {
    if (!getdeliveryFee.discountMinRequired) {
      return getdeliveryFee.discount;
    } else if (getdeliveryFee.discountMinRequired &&
        order.totalAmount > getdeliveryFee.discountMinSpend) {
      return getdeliveryFee.discount;
    }

    return 0;
  }

  addOrderItem(OrderItem orderItem) {
    order.userItems.add(orderItem);
    order.totalAmount += orderItem.price;
    order.userOrderStatus = order.userOrderStatus ?? UserOrderStatus.Started;
    order.numberOfItems += orderItem.quantity;
    notifyListeners();
  }

  updateOrderItem(OrderItem newOrderItem) {
    int quantity = newOrderItem.quantity;
    double price = calculateItemPrice(newOrderItem);
    int orderItemIndex = order.userItems.indexWhere((orderItem) =>
        orderItem.menuItem.menuItemId == newOrderItem.menuItem.menuItemId);

    order.userItems[orderItemIndex].quantity = quantity;
    order.userItems[orderItemIndex].isTakeAway = newOrderItem.isTakeAway;
    order.userItems[orderItemIndex].price = price;
    order.numberOfItems +=
        (quantity - order.userItems[orderItemIndex].quantity);
    notifyListeners();
  }

  countOrderItemNumbers() {
    int totalNumber = 0;
    if (order?.userItems == null) return 0;
    order.userItems.forEach((orderItem) => totalNumber += orderItem.quantity);
    return totalNumber;
  }

  Future<bool> getFees(BuildContext context) async {
    var hlp = Helper();
    fees = [];
    var response =
        await hlp.getData("api/payment/fees", context: context, hasAuth: true);
    if (response.isSuccess) {
      for (int i = 0; i < response.data.length; i++) {
        Fees fee = Fees.fromJson(response.data[i]);
        fees.add(fee);
      }
      notifyListeners();
    }
    return response.isSuccess;
  }

  get getdeliveryFee => getCurrentFees == null || getCurrentFees.length == 0
      ? null
      : getCurrentFees?.firstWhere((element) => element.feesType == 0);

  bool checkIfItemInOrder(MenuItem menuItem) {
    if (order?.userItems == null) return false;
    if ((order.userItems.firstWhere(
            (userItems) => userItems.menuItem.menuItemId == menuItem.menuItemId,
            orElse: () => null)) !=
        null) {
      return true;
    } else {
      return false;
    }
  }

  set setDiscount(discount){
    order.discount = discount;
  }

  removeOrderItem(OrderItem orderItem) {
    order.userItems.removeWhere(
        (item) => item.menuItem.menuItemId == orderItem.menuItem.menuItemId);
    order.numberOfItems -= orderItem.quantity;
    order.totalAmount -= orderItem.price;
    notifyListeners();
  }

  Future getExistingPlacedOrderFromAPI(BuildContext context) async {
    var helper = Helper();
    var response = await helper.getData(
        "api/menu/userOrders/" + placedOrder.userOrderId.toString(),
        context: context,
        hasAuth: true);
    if (response.isSuccess) {
      placedOrder = Order.fromJson(response.data);
      notifyListeners();
    }
  }

  Future getOrderByOrderId(BuildContext context, int orderId) async {
    var helper = Helper();
    var response = await helper.getData(
        "api/menu/userOrders/" + orderId.toString(),
        context: context,
        hasAuth: true);
    if (response.isSuccess) {
      order = Order.fromJson(response.data);
      // update the placed order
      if (order.userOrderStatus != UserOrderStatus.Started) {
        placedOrder = Order.fromJson(response.data);
        order.numberOfItems = 0;
        cleanOrderItem();
      }
      notifyListeners();
    }
  }

  Order get getOrder {
    // init();
    return order;
  }

  Order getOrderWithDiscountApplied(BuildContext context) {
    // calculate discount after click place order
    Order orderWithDiscount = order;

    var store = Provider.of<CurrentStoreProvider>(context, listen: false)
        .getCurrentStore;
    if (store == null) {
      store = Provider.of<OrderListProvider>(context, listen: false)
          .getSelectedOrderWithStore
          ?.store;
    }

    var menu =
        Provider.of<GroceriesItemProvider>(context, listen: false).getStoreMenu;
    if (store == null && menu != null) {
      Provider.of<CurrentStoreProvider>(context, listen: false)
          .getSingleStoreById(context, menu.storeId);
    }
    Campaign campaign = store?.campaign;
    if (campaign != null && orderWithDiscount.userItems.isNotEmpty) {
      orderWithDiscount = OrderHelper.applyCampaignDiscountToOrder(
          context, orderWithDiscount, campaign);
    } else {
      orderWithDiscount.discount = 0;
    }
    return orderWithDiscount;
  }

  void setOrder(Order inputOrder) {
    order = inputOrder;
    notifyListeners();
  }

  void setOrderWithoutNotify(Order inputOrder) {
    order = inputOrder;
  }

  Order get getPlacedOrder {
    return placedOrder;
  }

  void clearOrder() {
    placedOrder = null;
    order = null;
    //notifyListeners();
  }

  cleanOrderItem() {
    order?.userItems = [];
    notifyListeners();
  }

  double getTotal() {
    double total = 0;
    order.userItems.forEach((e) {
      total = total + e.price;
    });
    order.totalAmount = total;
    return total;
  }

  Future<Order> initOrder(BuildContext context, int storeMenuId,
      String tableName, int orderType, int userId) async {
    var hlp = Helper();
    try {
      Map<String, dynamic> data = {
        "storeMenuId": storeMenuId,
        "table": tableName,
        "orderType": orderType,
        "userId": userId
      };
      print("init order request: " + data.toString());

      var response = await hlp.postData("api/Menu/userOrders/init", data,
          context: context, hasAuth: true);

      if (response.isSuccess) {
        order = Order.fromJson(response.data);
        // init data for frontend
        order.numberOfItems ??= 0;
        // add order to active order
        // await Provider.of<OrderListProvider>(context, listen: false)
        //     .insertOrderToActiveOrderList(order);

        // await Provider.of<OrderListProvider>(context, listen: false)
        //     .insertOrderToActiveOrderList(order);
        // var signalr = SignalrHelper();
        // // var storeId = Provider.of<CurrentStoresProvider>(context, listen: false)
        // //     .getStoreId(context);
        // await signalr.sendUserOrder(
        //     SignalrHelper.initOrderEvent, storeId, order.userOrderId);

        notifyListeners();
        return order;
      } else if (response.isSuccess == false) {
        // get exist order id from error message
        String errorMessage = response.data["message"];
        int existOrderId =
            int.parse(errorMessage.replaceAll(RegExp('[^0-9]'), ''));
        order = new Order();
        order.userOrderId = existOrderId;
        order.orderType = OrderType.values[orderType];
        notifyListeners();
        return order;
      } else {
        hlp.showToastError("Failed to initialize the table, please try again.");
        return null;
      }
    } catch (e) {
      print("Failed to initialize the table: " + e.toString());
      hlp.showToastError("Failed to initialize the table: " + e.toString());
      return null;
    }
  }

  void updateOrderStatus(BuildContext context, Order order) {
    // Provider.of<OrderListProvider>(context, listen: false)
    //     .getActiveOrderList()
    //     .forEach((element) {
    //   if (element.userOrderId == order.userOrderId) {
    //     element.userOrderStatus = UserOrderStatus.InProgress;
    //     element.paymentStatus = OrderPaymentStatus.AwaitingPayment;
    //     element.paymentSuccessful = false;
    //     return;
    //   }
    // });
  }

  Future<bool> submitOrder(BuildContext context, Order order) async {
    var hlp = Helper();
    var response;

    Map<String, dynamic> data = order.toJson();

    // for user app, no extra order needed
    response = await hlp.putData("api/Menu/userOrders/submit", data,
        context: context, hasAuth: true);

    if (response.isSuccess) {
      // get latest order status after submit
      var resp = await hlp.getData(
          "api/menu/userOrders/" + order.userOrderId.toString(),
          context: context,
          hasAuth: true);
      if (resp.isSuccess) {
        var data = Order.fromJson(resp.data);
        placedOrder = data;

        cleanOrderItem();

        updateOrderStatus(context, placedOrder);

        // var signalr = SignalrHelper();
        // var storeId = Provider.of<CurrentStoresProvider>(context, listen: false)
        //     .getStoreId(context);
        // await signalr.sendUserOrder(
        //     SignalrHelper.submitOrderEvent, storeId, placedOrder.userOrderId);

        notifyListeners();
        return true;
      } else {
        hlp.showToastError("Failed to submit the order, please try again.");
        return false;
      }
    }
  }

  Future<bool> resetTable(
    BuildContext context,
    int orderId,
  ) async {
    var hlp = Helper();

    var response = await hlp.putData(
        "api/Menu/userOrders/$orderId/resetTable", null,
        context: context, hasAuth: true);

    if (response.isSuccess) {
      order = new Order();
      notifyListeners();
      return true;
    } else {
      hlp.showToastError("Failed to complete the order, please try again.");
      return false;
    }
  }

  sendOrderNotification(
      String table, String userOrderId, BuildContext context) async {
    var hlp = Helper();
    var data = {"table": table, "userOrderId": userOrderId};
    await hlp.postData("api/notification", data, context: context);
  }

  double calculateAddOnPrice(OrderItem orderItem) {
    double totalPrice = 0;

    if (orderItem.menuItem?.menuAddOns != null) {
      for (int i = 0; i < orderItem.menuItem.menuAddOns?.length; i++) {
        // each addon
        double currentAddOnPrice = 0;
        for (int j = 0;
            j < orderItem.menuItem.menuAddOns[i].menuAddOnOptions.length;
            j++) {
          // each addon option
          var currentOption =
              orderItem.menuItem.menuAddOns[i].menuAddOnOptions[j];
          if (currentOption.isSelected == true) {
            currentAddOnPrice = calculateSingleOptionPrice(
                currentOption, orderItem.menuItem.price);
            totalPrice += currentAddOnPrice;
          }
        }
      }
    }
    return totalPrice;
  }

  double calculateSingleOptionPrice(
      MenuAddOnOption option, double menuItemPrice) {
    double price;
    //calculate price
    if (option.extraCostOptionViewModel.extraCostType == 2) {
      // fixed price
      price = option.extraCostOptionViewModel.fixedAmount;
    } else if (option.extraCostOptionViewModel.extraCostType == 1) {
      //percentage
      price =
          ((option.extraCostOptionViewModel.percent * 0.01) * menuItemPrice);
    } else {
      //free
      price = 0;
    }
    return price;
  }

  List<String> getAddOnReceipt(OrderItem orderItem) {
    List<String> selectedAddOnReceipt = new List<String>();

    for (int i = 0; i < orderItem.menuItem.menuAddOns.length; i++) {
      // each addon
      bool hasSelectedAddOn = false;
      String currentAddOnList =
          '${orderItem.menuItem.menuAddOns[i].menuAddOnName}:\n';

      for (int j = 0;
          j < orderItem.menuItem.menuAddOns[i].menuAddOnOptions.length;
          j++) {
        // each addon option
        var currentOption =
            orderItem.menuItem.menuAddOns[i].menuAddOnOptions[j];

        if (currentOption.isSelected == true) {
          hasSelectedAddOn = true;
          double currentAddOnPrice = calculateSingleOptionPrice(
              currentOption, orderItem.menuItem.price);
          currentAddOnList +=
              '${currentOption.optionName}(\$${currentAddOnPrice.toStringAsFixed(2)})\n';
        }
      }
      // append value if any data in this addon
      if (hasSelectedAddOn == true) {
        selectedAddOnReceipt.add(currentAddOnList);
      }
    }
    return selectedAddOnReceipt;
  }

  List<String> getAddOnReceiptFromBackend(OrderItem orderItem,
      {bool showPrice = true}) {
    // This function is used to get the add on description
    // from the backend, backend gives the `userOrderItemAddOns` list
    // TODO should aggregate with the `getAddOnReceipt` function

    List<String> selectedAddOnReceipt = new List<String>();

    for (int i = 0; i < orderItem.userOrderItemAddOns.length; i++) {
      // each addon
      String currentAddOnList =
          '${orderItem.userOrderItemAddOns[i].userOrderItemAddOnName}:';
      for (int j = 0;
          j < orderItem.userOrderItemAddOns[i].menuAddOnOptions.length;
          j++) {
        // each addon option
        var currentOption =
            orderItem.userOrderItemAddOns[i].menuAddOnOptions[j];
        if (showPrice == true) {
          double currentAddOnPrice = calculateSingleOptionPrice(
              currentOption, orderItem.menuItem.price);
          currentAddOnList +=
              '\n${currentOption.optionName}(\$${currentAddOnPrice.toStringAsFixed(2)}) ';
        } else {
          // do not show price, just addon option
          currentAddOnList += '\n${currentOption.optionName} ';
        }
      }
      selectedAddOnReceipt.add(currentAddOnList);
    }
    return selectedAddOnReceipt;
  }

  double calculateItemPrice(OrderItem orderItem) {
    double singleItemPrice;
    (orderItem.menuItem.hasAddOns == true)
        ? singleItemPrice =
            calculateAddOnPrice(orderItem) + orderItem.menuItem.price
        : singleItemPrice = orderItem.menuItem.price;

    return singleItemPrice * orderItem.quantity;
  }

  double calculateOrderOrignalPrice(Order order) {
    double orderOrigPrice = 0;
    order.userItems
        .forEach((element) => orderOrigPrice += calculateItemPrice(element));
    return orderOrigPrice;
  }

  List<UserOrderItemAddOn> getMenuAddOnOptionIds(OrderItem orderItem) {
    List<UserOrderItemAddOn> userOrderItemAddOns =
        new List<UserOrderItemAddOn>();

    for (int i = 0; i < orderItem.menuItem.menuAddOns.length; i++) {
      // each addon
      UserOrderItemAddOn addOn = new UserOrderItemAddOn();
      addOn.menuAddOnOptionIds = new List<int>();
      for (int j = 0;
          j < orderItem.menuItem.menuAddOns[i].menuAddOnOptions.length;
          j++) {
        // each addon option
        var currentOption =
            orderItem.menuItem.menuAddOns[i].menuAddOnOptions[j];

        if (currentOption.isSelected == true) {
          addOn.menuAddOnOptionIds.add(currentOption.menuAddOnOptionId);
          // menuAddOnOptionIds.add(currentOption.menuAddOnOptionId);
        }
      }
      // add to List if this category is selected.
      if (addOn.menuAddOnOptionIds.isNotEmpty) {
        userOrderItemAddOns.add(addOn);
      }
    }
    return userOrderItemAddOns;
  }

  OrderItem getOrderItemByMenuItemId(int menuItemId) {
    OrderItem orderItem;
    orderItem = order.userItems
        .firstWhere((userItem) => userItem.menuItem.menuItemId == menuItemId);
    return orderItem;
  }

  String getTakeAwayIdShortcut(String takeAwayId) {
    int digitLength = 6;
    String idShortcut =
        "TA" + takeAwayId.substring(takeAwayId.length - digitLength);
    return idShortcut;
  }

  bool checkIsQRTakeAwayOrder() {
    if (order.orderType == OrderType.QR &&
        order.table != null &&
        order.table.length > 2 && // for QR take away order, table name must >2
        order.table.substring(0, 2) == "TA") {
      return true;
    } else if (order.orderType != OrderType.pickup) {
      return true;
    } else {
      return false;
    }
  }

  String generateTakeAwayId() {
    /// this method is used to generate takeaway id for QR order ONLY
    /// Should be dispatched in future versions

    String takeAwayId = "TA";
    String uniqueString =
        DateTime.now().millisecondsSinceEpoch.toString().substring(4, 12);
    takeAwayId += uniqueString;
    return takeAwayId;
  }

  void setOrderTakeAwayId(String takeAwayId) {
    order.takeAwayId = takeAwayId;
  }

  void setHasOrderSubmittedThisSession(bool value) {
    hasOrderSubmittedThisSession = value;
  }

  get getHasOrderSubmittedThisSession => hasOrderSubmittedThisSession;

  bool getHasOrderSubmitted() {
    /// this method is used to check if order has been submitted
    /// it will check submitted order for both this browser session
    /// and the previous.
    bool hasOrderSubmittedPreviously =
        (order.userOrderStatus == UserOrderStatus.Started) ? false : true;
    if (hasOrderSubmittedPreviously || hasOrderSubmittedThisSession) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteOrder(int userOrderId, BuildContext context) async {
    var helper = Helper();
    try {
      var response = await helper.deleteData("api/Menu/userOrders/$userOrderId",
          context: context, hasAuth: true);
      if (response.isSuccess) {
        return true;
      }
    } catch (e) {
      helper.showToastError("Failed to delete order, $e");
      return false;
    }
  }

  Future<bool> cancelOrder(int userOrderId, BuildContext context) async {
    var helper = Helper();
    try {
      var response = await helper.putData(
          "api/Menu/userOrders/$userOrderId/cancel", null,
          context: context, hasAuth: true);
      if (response.isSuccess) {
        return true;
      }
    } catch (e) {
      helper.showToastError("Failed to cancel order, $e");
      return false;
    }
  }

  void setIsDeliveryOrder(bool value) {
    isDeliveryOrder = value;
    notifyListeners();
  }
}
