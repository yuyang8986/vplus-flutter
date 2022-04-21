import 'package:audioplayers/audio_cache.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/signalrHelper.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/current_orderStatus_provider.dart';
import 'package:vplus_merchant_app/providers/current_order_provider.dart';
import 'package:vplus_merchant_app/providers/orderlist_provider.dart';
import 'package:vplus_merchant_app/widgets/android_top_notification.dart';

class FCMHelper {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static String token;

  static BuildContext orderListPageContext;
  static BuildContext orderTablesPageContext;

  // static initOrderListPageContext(BuildContext buildContext) {
  //   orderListPageContext = buildContext;
  // }

  // static initOrderTableContext(BuildContext buildContext) {
  //   orderTablesPageContext = buildContext;
  // }

  static init(BuildContext context) async {
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        print("onMessage: ${message.data}");
        AudioCache player = new AudioCache();
        var lan =  await AppLocalizationHelper.of(context)?.getCurrentLanguageCode()??'en';
        var alarmAudioPath = lan == 'zh'? "sounds/VplusNotifyChinese.m4a":"sounds/notification.mp3";
        await player.play(alarmAudioPath, isNotification: true);

        showOverlayNotification((_) {
          return TopNotication(message.data);
        }, duration: Duration(milliseconds: 5000));

        int storeMenuId;
        storeMenuId = Provider.of<CurrentMenuProvider>(context, listen: false)
            .getStoreMenuId;
        await Provider.of<OrderListProvider>(context, listen: false)
            .getOrderListFromAPI(context, storeMenuId, true, 1);
        Order currentOrderOnOrderListPage;
        currentOrderOnOrderListPage =
            Provider.of<Current_OrderStatus_Provider>(context, listen: false)
                .getOrder();
        // QR order use FCM to do update
        if (currentOrderOnOrderListPage?.orderType == OrderType.QR) {
          /// if user is currently viewing the order
          /// update order status
          if (currentOrderOnOrderListPage != null) {
            await Provider.of<Current_OrderStatus_Provider>(context,
                    listen: false)
                .updateCurrentOrderFromAPI(context,
                    currentOrderOnOrderListPage?.userOrderId.toString(), true);
          }
          // update printer preview page
          SignalrHelper.updatePrinterPreviewPage(storeMenuId);
        }
      },
      // onLaunch: (Map<String, dynamic> message) async {
      //   print("onLaunch: $message");
      // },
      // onResume: (Map<String, dynamic> message) async {
      //   print("onResume: $message");
      // },
    );

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
}
