import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/models/Order.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/providers/order_list_provider.dart';
import 'package:vplus/widgets/android_top_notification.dart';

class FCMHelper {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static String token;

  static BuildContext orderListPageContext;
  static BuildContext orderTablesPageContext;

  static init(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("onMessage: $message.data");
      // AudioCache player = new AudioCache();
      // const alarmAudioPath = "sounds/notification.mp3";
      // await player.play(alarmAudioPath);

      showOverlayNotification((_) {
        return TopNotication(message.data);
      }, duration: Duration(milliseconds: 5000));

      // order update logic here
      int orderId = int.parse(message.data["userOrderId"]);
      // update current placed order
      Order order = Provider.of<CurrentOrderProvider>(context, listen: false)
          .getPlacedOrder;
      if (order != null && order.userOrderId == orderId) {
        await Provider.of<CurrentOrderProvider>(context, listen: false)
            .getExistingPlacedOrderFromAPI(context);
      }
      // update active order
      int userId = Provider.of<CurrentUserProvider>(context, listen: false)
          .getloggedInUser
          .userId;
      await Provider.of<OrderListProvider>(context, listen: false)
          .getOrderListByUserId(context, userId, 1);
    });

    await requestPermission();

    token = await _firebaseMessaging.getToken();

    print("device FCM token: " + token);
  }

  static requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
    );
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    // Or do other work.
  }

  static Future registerDevice(userId, context) async {
    var helper = Helper();
    var data = {
      "userId": userId,
      "deviceFCMToken": FCMHelper.token,
    };

    var response = await helper.postData("api/UserDevice/register", data,
        context: context);

    if (!response.isSuccess) {
      print("User device Init failed");
    }
  }
}
