// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:provider/provider.dart';
// import 'package:signalr_core/signalr_core.dart';

// import 'apiHelper.dart';

// class SignalrHelper {
//   static const String submitOrderEvent = "submitOrder";
//   static const String extraOrderEvent = "extraOrder";
//   //static const String resetOrderEvent = "resetOrder";
//   static const String initOrderEvent = "initOrder";
//   // static const String payOrderEvent = "payOrder";
//   // static const String cancelOrderEvent = "cancelOrder";
//   // static const String returnOrderEvent = "returnOrder";
//   // static const String confirmOrderEvent = "confirmOrder";
//   // static const String serveOrderEvent = "serveOrder";
//   static BuildContext orderStatusPageContext;
//   static BuildContext orderTableOrderStatusPageContext;

//   // static String currentViewingOrder;

//   static bool atOrderTableStatusPage = false;

//   static initOrderStatusContext(BuildContext buildContext) {
//     orderStatusPageContext = buildContext;
//   }

//   static initOrderTableOrderStatusContext(BuildContext buildContext) {
//     orderTableOrderStatusPageContext = buildContext;
//   }

//   //prod
//   //final String serverUrl = "http://13.238.247.236/orderHub";

//   //local
//   static const String serverUrl = "https://localhost:44382/orderHub";

//   //test
//   //static const String serverUrl = "http://13.54.163.1/orderHub";

//   static HubConnection hubConnection;

//   bool connectionIsOpen;

//   static Future registerDevice(storeId, context) async {
//     //connectionId is for SignalR
//     var helper = Helper();
//     var data = {
//       // "deviceToken": FCMHelper.token,
//       "storeId": storeId,
//       "connectionId": SignalrHelper.hubConnection?.connectionId
//     };

//     var response = await helper.postData("api/storeDevice/register", data,
//         context: context);

//     if (!response.isSuccess) {
//       print("Store device Init failed");
//     }
//   }

//   static Future<void> openHubConnection(BuildContext context) async {
//     hubConnection = HubConnectionBuilder()
//         .withUrl(
//             serverUrl,
//             HttpConnectionOptions(
//               transport: HttpTransportType.webSockets,
//               client: MyClient(),
//               skipNegotiation: true,
//               logging: (level, message) => print(message),
//             ))
//         .withAutomaticReconnect()
//         .build();
//     hubConnection.serverTimeoutInMilliseconds = 30000000000;
//     hubConnection.keepAliveIntervalInMilliseconds = 15000;

//     await hubConnection.start();

//     // hubConnection.on('NewOrder', (message) async {
//     //   //await onSignalRMessage(message, context);
//     // });

//     hubConnection.onclose((exception) {
//       print("hub closed");
//     });

//     hubConnection.onreconnected((exception) {
//       print("hub onreconnected");
//     });

//     hubConnection.onreconnecting((exception) {
//       print("hub onreconnecting");
//     });
//   }

//   // static onSignalRMessage(message, context) async {
//   //   print("signalR msg:" + message.toString());
//   //   Helper().showToastSuccess("Signalr received");
//   //   var userOrderId = message[0]["userOrderId"].toString();
//   //   String eventType = message[0]["eventType"].toString();
//   //   switch (eventType) {
//   //     case "submitOrder":
//   //       int storeMenuId;
//   //       storeMenuId = Provider.of<CurrentMenuProvider>(context, listen: false)
//   //           .getStoreMenuId;
//   //       if (Provider.of<Current_OrderStatus_Provider>(context, listen: false)
//   //               .getOrder() ==
//   //           null) return;
//   //       if (userOrderId ==
//   //           Provider.of<Current_OrderStatus_Provider>(context, listen: false)
//   //               .getOrder()
//   //               .userOrderId
//   //               .toString()) {
//   //         if (orderStatusPageContext != null && !atOrderTableStatusPage) {
//   //           Provider.of<Current_OrderStatus_Provider>(context, listen: false)
//   //               .updateCurrentOrderFromAPI(context, userOrderId, true);
//   //         }
//   //         if (atOrderTableStatusPage) {
//   //           if (orderTableOrderStatusPageContext != null) {
//   //             await Provider.of<CurrentOrderProvider>(context, listen: false)
//   //                 .getExistingPlacedOrderFromAPI(context);
//   //           }
//   //         }
//   //       }
//   //       //}
//   //       break;
//   //     // case "payOrder":
//   //     // case "cancelOrder":
//   //     // case "returnOrder":
//   //     // case "confirmOrder":
//   //     // case "serveOrder":
//   //     case "initOrder":
//   //       int storeMenuId;
//   //       storeMenuId = Provider.of<CurrentMenuProvider>(context, listen: false)
//   //           .getStoreMenuId;
//   //       // await Provider.of<OrderListProvider>(context, listen: false)
//   //       //     .getOrderListFromAPI(context, storeMenuId, true, 1);
//   //       if (Provider.of<Current_OrderStatus_Provider>(context, listen: false)
//   //               .getOrder() ==
//   //           null) return;
//   //       if (userOrderId ==
//   //           Provider.of<Current_OrderStatus_Provider>(context, listen: false)
//   //               .getOrder()
//   //               .userOrderId
//   //               .toString()) {
//   //         if (orderStatusPageContext != null && !atOrderTableStatusPage) {
//   //           await Provider.of<Current_OrderStatus_Provider>(context,
//   //                   listen: false)
//   //               .updateCurrentOrderFromAPI(context, userOrderId, true);
//   //         }
//   //         if (atOrderTableStatusPage) {
//   //           if (orderTableOrderStatusPageContext != null) {
//   //             await Provider.of<CurrentOrderProvider>(context, listen: false)
//   //                 .getExistingPlacedOrderFromAPI(context);
//   //           }
//   //         }
//   //       }
//   //       break;
//   //   }
//   // }

//   Future<void> sendUserOrder(
//       String eventType, int storeId, int userOrderId) async {
//     // if (eventType == 'resetOrder')
//     //   Provider.of<OrderListProvider>(orderListPageContext, listen: false)
//     //       .addHistoryOrder(order, true);
//     try {
//       if (hubConnection.state != HubConnectionState.connected) {
//         await hubConnection.start();
//       }
//       Helper().showToastSuccess("Signalr sending");
//       await hubConnection
//           .invoke('NewOrder', args: [eventType, storeId, userOrderId]);
//       Helper().showToastSuccess("Signalr sent");
//     } catch (e) {
//       Helper().showToastError("Signalr failed to send: " + e.toString());
//     }
//   }

//   bool checkConnectionIsOpen() {
//     return this.connectionIsOpen;
//   }
// }

// class MyClient extends BaseClient {
//   @override
//   Future<StreamedResponse> send(BaseRequest request) {
//     // TODO: implement send
//     throw UnimplementedError();
//   }
// }
