import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/current_orderStatus_provider.dart';
import 'package:vplus_merchant_app/providers/orderlist_provider.dart';

import 'appLocalizationHelper.dart';

enum TimerType { refreshOrder, confirmOrderReminder }

class TimerHelper {
  static Timer timer;

  static Future<void> refreshOrderTimer(BuildContext context) async {
    int _storeMenuId =
        Provider.of<CurrentMenuProvider>(context, listen: false).getStoreMenuId;
    if (_storeMenuId != null) {
      await Provider.of<OrderListProvider>(context, listen: false)
          .getOrderListFromAPI(context, _storeMenuId, true, 1);
      Order order =
          Provider.of<Current_OrderStatus_Provider>(context, listen: false)
              .getOrder();
      bool isActive = Provider.of<OrderListProvider>(context, listen: false)
          .getIsOnActiveTab;
      if (order != null && isActive) {
        if (!ScreenHelper.isLandScape(context)) {
          Provider.of<Current_OrderStatus_Provider>(context, listen: false)
              .setOrder(context, order, isActive);
        } else {
          Provider.of<Current_OrderStatus_Provider>(context, listen: false)
              .setOrder(context, order, isActive);
        }
      }
    }
  }

  static Future<void> confirmOrderReminder(context) async {
    AudioCache player = new AudioCache();
    var lan =
        await AppLocalizationHelper.of(context)?.getCurrentLanguageCode() ??
            'en';

    var alarmAudioPath = lan == 'zh'
        ? "sounds/VplusNotifyChinese.m4a"
        : "sounds/notification.mp3";

    await player.play(alarmAudioPath, isNotification: true);
  }

  static void initTimer(BuildContext context, TimerType timerType) {
    switch (timerType) {
      case TimerType.confirmOrderReminder:
        timer = Timer.periodic(Duration(minutes: 1), (Timer timer) async {
          try{
            var activeOrders =
              Provider.of<OrderListProvider>(context, listen: false)
                  .getActiveOrderList();
                  if(activeOrders == null) return;
          if (activeOrders.any((element) =>
              element.userOrderStatus == UserOrderStatus.AwaitConfirm)) {
            await confirmOrderReminder(context);
          }
          }
          catch(e){
            
          }
        });
        break;
      default:
    }
  }

  static void cancelTimer() {
    timer.cancel();
  }
}
