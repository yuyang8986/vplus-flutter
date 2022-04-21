import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appConfigHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/current_orderStatus_provider.dart';
import 'package:vplus_merchant_app/providers/current_order_provider.dart';
import 'package:vplus_merchant_app/providers/kds_provider.dart';
import 'package:vplus_merchant_app/providers/orderlist_provider.dart';
import 'package:vplus_merchant_app/providers/printer_order_list_provider.dart';

import 'fcmHelper.dart';

class SignalrHelper {
  static const String submitOrderEvent = "submitOrder";
  static const String extraOrderEvent = "extraOrder";
  static const String resetOrderEvent = "resetOrder";
  static const String initOrderEvent = "initOrder";
  static const String payOrderEvent = "payOrder";
  static const String cancelOrderEvent = "cancelOrder";
  static const String returnOrderEvent = "returnOrder";
  static const String confirmOrderEvent = "confirmOrder";
  static const String serveOrderEvent = "serveOrder";
  static const String readyOrderEvent = "readyOrder";

  static BuildContext orderListPageContext;
  static BuildContext orderTablesPageContext;
  static BuildContext orderStatusPageContext;
  static BuildContext printerPreviewContext;
  static BuildContext orderTableOrderStatusPageContext;

  static String currentViewingOrder;
  static bool isInPrinterPreview;

  static bool atOrderTableStatusPage = false;
  static bool atKDSPage = false;

  static initOrderListPageContext(BuildContext buildContext) {
    orderListPageContext = buildContext;
  }

  static initOrderTableContext(BuildContext buildContext) {
    orderTablesPageContext = buildContext;
  }

  static initOrderStatusContext(BuildContext buildContext) {
    orderStatusPageContext = buildContext;
  }

  static initPrinterPreviewContext(BuildContext buildContext) {
    printerPreviewContext = buildContext;
  }

  static initOrderTableOrderStatusContext(BuildContext buildContext) {
    orderTableOrderStatusPageContext = buildContext;
  }

  static setIsInPrinterPreviewPage(bool inPreviewPage) {
    isInPrinterPreview = inPreviewPage;
  }
  //prod
  //final String serverUrl = "http://13.238.247.236/orderHub";

  //local
  //static const String serverUrl = "https://10.0.2.2:44382/orderHub";

  //test
  // static const String serverUrl = "http://13.54.163.1/orderHub";

  static String serverUrl = AppConfigHelper.getSignalrUrl;

  static HubConnection hubConnection;

  bool connectionIsOpen;
  int storeMenuId;

  static Future registerDevice(storeId, context) async {
    //connectionId is for SignalR
    var helper = Helper();
    var data = {
      "deviceToken": FCMHelper.token,
      "storeId": storeId,
      "connectionId": SignalrHelper.hubConnection?.connectionId
    };

    var response = await helper.postData("api/storeDevice/register", data,
        context: context);

    if (!response.isSuccess) {
      print("Store device Init failed");
    }
  }

  static Future<void> openHubConnection(BuildContext context) async {
    return;
    hubConnection = HubConnectionBuilder()
        .withUrl(
            serverUrl,
            HttpConnectionOptions(
              logging: (level, message) => print(message),
            ))
        //.withAutomaticReconnect()
        .build();
    hubConnection.serverTimeoutInMilliseconds = 30000000000;
    hubConnection.keepAliveIntervalInMilliseconds = 1500000;

    await hubConnection.start();

    hubConnection.on('NewOrder', (message) async {
      await onSignalRMessage(message, context);
    });

    hubConnection.onclose((exception) {
      print("hub closed");
    });

    hubConnection.onreconnected((exception) {
      print("hub onreconnected");
    });

    hubConnection.onreconnecting((exception) {
      print("hub onreconnecting");
    });
  }

  static onSignalRMessage(message, context) async {
    return;
    int storeMenuId;
    print("signalR msg:" + message.toString());
    //Helper().showToastSuccess("Signalr received");
    //init value
    String userOrderId = message[0]["userOrderId"].toString();
    String eventType = message[0]["eventType"].toString();
    storeMenuId =
        Provider.of<CurrentMenuProvider>(context, listen: false).getStoreMenuId;
    switch (eventType) {
      case "submitOrder":
        await _submitOrderEvent(context, storeMenuId, userOrderId);
        break;
      case "payOrder":
      case "cancelOrder":
      case "returnOrder":
      case "confirmOrder":
        await _confirmOrderEvent(context, storeMenuId, userOrderId);
        break;
      case "serveOrder":
        await _serveOrderEvent(context, storeMenuId, userOrderId);
        break;
      case "initOrder":
        await _initOrderEvent(context, storeMenuId, userOrderId);
        break;
      case 'resetOrder':
        await _resetOrderEvent(context, storeMenuId, userOrderId);
        break;
      case "readyOrder":
        await _readyOrderEvent(context, storeMenuId, userOrderId);
        break;
    }
  }

  Future<void> sendUserOrder(
      String eventType, int storeId, int userOrderId) async {
    //TODO if QR then need to add this back
    // try {
    //   if (hubConnection.state != HubConnectionState.connected) {
    //     await hubConnection.start();
    //   }
    //   await hubConnection
    //       .invoke('NewOrder', args: [eventType, storeId, userOrderId]);
    //      } catch (e) {
    // }
  }

  bool checkConnectionIsOpen() {
    return this.connectionIsOpen;
  }

  static void updatePrinterPreviewPage(int storeMenuId) async {
    // update printer preview page
    if (isInPrinterPreview != null) {
      if (isInPrinterPreview) {
        if (printerPreviewContext != null) {
          await Provider.of<PrinterOrderListProvider>(printerPreviewContext,
                  listen: false)
              .allActiveOrderToOrderItemPrint(
                  printerPreviewContext, storeMenuId);
        }
      }
    }
  }

  static Future<void> _submitOrderEvent(
      BuildContext context, int storeMenuId, String userOrderId) async {
    await Provider.of<OrderListProvider>(context, listen: false)
        .getOrderListFromAPI(context, storeMenuId, true, 1);
    // update printer
    updatePrinterPreviewPage(storeMenuId);
    // refresh KDS
    if (atKDSPage) {
      await Provider.of<KDSProvider>(context, listen: false)
          .updateKDSDataFromAPI(context);
    }
    if (Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .getOrder() ==
        null) return;
    if (userOrderId ==
        Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .getOrder()
            .userOrderId
            .toString()) {
      if (orderStatusPageContext != null && !atOrderTableStatusPage) {
        Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .updateCurrentOrderFromAPI(context, userOrderId, true);
      }
      if (atOrderTableStatusPage) {
        if (orderTableOrderStatusPageContext != null) {
          await Provider.of<CurrentOrderProvider>(context, listen: false)
              .getExistingPlacedOrderFromAPI(context);
        }
      }
    }
  }

  static Future<void> _confirmOrderEvent(
      BuildContext context, int storeMenuId, String userOrderId) async {
    // update printer preview list
    updatePrinterPreviewPage(storeMenuId);
    // refresh KDS
    if (atKDSPage) {
      await Provider.of<KDSProvider>(context, listen: false)
          .updateKDSDataFromAPI(context);
    }
    await Provider.of<OrderListProvider>(context, listen: false)
        .getOrderListFromAPI(context, storeMenuId, true, 1);
    if (Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .getOrder() ==
        null) return;
    if (userOrderId ==
        Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .getOrder()
            .userOrderId
            .toString()) {
      if (orderStatusPageContext != null && !atOrderTableStatusPage) {
        await Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .updateCurrentOrderFromAPI(context, userOrderId, true);
      }
      if (atOrderTableStatusPage) {
        if (orderTableOrderStatusPageContext != null) {
          await Provider.of<CurrentOrderProvider>(context, listen: false)
              .getExistingPlacedOrderFromAPI(context);
        }
      }
    }
  }

  static Future<void> _initOrderEvent(
      BuildContext context, int storeMenuId, String userOrderId) async {
    await Provider.of<OrderListProvider>(context, listen: false)
        .getOrderListFromAPI(context, storeMenuId, true, 1);
    if (Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .getOrder() ==
        null) return;
    if (userOrderId ==
        Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .getOrder()
            .userOrderId
            .toString()) {
      if (orderStatusPageContext != null && !atOrderTableStatusPage) {
        await Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .updateCurrentOrderFromAPI(context, userOrderId, true);
      }
      if (atOrderTableStatusPage) {
        if (orderTableOrderStatusPageContext != null) {
          await Provider.of<CurrentOrderProvider>(context, listen: false)
              .getExistingPlacedOrderFromAPI(context);
        }
      }
    }
  }

  static Future<void> _resetOrderEvent(
      BuildContext context, int storeMenuId, String userOrderId) async {
    // update active order list, and history order list (if user on this tab)
    await Provider.of<OrderListProvider>(context, listen: false)
        .getOrderListFromAPI(context, storeMenuId, true, 1);
    // if user on history order list tab, get the updates
    if (Provider.of<OrderListProvider>(context, listen: false)
            .getIsOnActiveTab ==
        false) {
      await Provider.of<OrderListProvider>(context, listen: false)
          .getOrderListFromAPI(context, storeMenuId, false, 1);
    }

    /// reset by self
    if (Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .getOrder() ==
        null) {
      if ([
        OrderStatusPageType.tableViewOrder,
        OrderStatusPageType.tableAddOrder,
        OrderStatusPageType.orderListPortrait
      ].contains(
          Provider.of<Current_OrderStatus_Provider>(context, listen: false)
              .getOrderStatusType)) {
        resetCurrentOrderAndPopUp(context, userOrderId);
      }
      return;
    }

    /// reset by other device
    else if (userOrderId ==
        Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .getOrder()
            .userOrderId
            .toString()) {
      if ([
        OrderStatusPageType.tableViewOrder,
        OrderStatusPageType.tableAddOrder,
        OrderStatusPageType.orderListPortrait
      ].contains(
          Provider.of<Current_OrderStatus_Provider>(context, listen: false)
              .getOrderStatusType)) {
        // for pages need to pop up
        resetCurrentOrderAndPopUp(context, userOrderId);
        return;
      } else if (Provider.of<Current_OrderStatus_Provider>(context,
                  listen: false)
              .getOrderStatusType ==
          OrderStatusPageType.orderListLandscape) {
        // for pages without pop up
        Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .updateCurrentOrderFromAPI(context, userOrderId, false);
        Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .setIsResetByOtherDevice(true);
      }
    }
  }

  static Future<void> _serveOrderEvent(
      BuildContext context, int storeMenuId, String userOrderId) async {
    // update printer preview list
    updatePrinterPreviewPage(storeMenuId);
    await Provider.of<OrderListProvider>(context, listen: false)
        .getOrderListFromAPI(context, storeMenuId, true, 1);
    if (Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .getOrder() ==
        null) return;
    if (userOrderId ==
        Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .getOrder()
            .userOrderId
            .toString()) {
      if (orderStatusPageContext != null && !atOrderTableStatusPage) {
        await Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .updateCurrentOrderFromAPI(context, userOrderId, true);
      }
      if (atOrderTableStatusPage) {
        if (orderTableOrderStatusPageContext != null) {
          await Provider.of<CurrentOrderProvider>(context, listen: false)
              .getExistingPlacedOrderFromAPI(context);
        }
      }
    }
  }

  static Future<void> _readyOrderEvent(
      BuildContext context, int storeMenuId, String userOrderId) async {
    // // update printer preview list
    updatePrinterPreviewPage(storeMenuId);
    await Provider.of<OrderListProvider>(context, listen: false)
        .getOrderListFromAPI(context, storeMenuId, true, 1);
    if (Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .getOrder() ==
        null) return;
    if (userOrderId ==
        Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .getOrder()
            .userOrderId
            .toString()) {
      if (orderStatusPageContext != null && !atOrderTableStatusPage) {
        await Provider.of<Current_OrderStatus_Provider>(context, listen: false)
            .updateCurrentOrderFromAPI(context, userOrderId, true);
      }
      if (atOrderTableStatusPage) {
        if (orderTableOrderStatusPageContext != null) {
          await Provider.of<CurrentOrderProvider>(context, listen: false)
              .getExistingPlacedOrderFromAPI(context);
        }
      }
    }
  }

  static void resetCurrentOrderAndPopUp(
      BuildContext context, String userOrderId) {
    Provider.of<Current_OrderStatus_Provider>(context, listen: false)
        .updateCurrentOrderFromAPI(context, userOrderId, false);
    Provider.of<Current_OrderStatus_Provider>(context, listen: false)
        .setIsResetByOtherDevice(true);
    Provider.of<Current_OrderStatus_Provider>(context, listen: false)
        .setOrderStatusType(OrderStatusPageType.none);
    Navigator.pop(context);
  }
}
