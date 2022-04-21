import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/fcmHelper.dart';
import 'package:vplus_merchant_app/helpers/printerHelper.dart';
import 'package:vplus_merchant_app/helpers/signalrHelper.dart';

import 'current_stores_provider.dart';
import 'currentuser_provider.dart';

class HomeScreenProvider with ChangeNotifier {
  HomeScreenProvider(context) {
    _currentStoreId =
        Provider.of<CurrentUserProvider>(context, listen: false).isAdmin()
            ? Provider.of<CurrentStoresProvider>(context, listen: false)
                .getSelectedStore
                .storeId
            : Provider.of<CurrentUserProvider>(context, listen: false)
                .getloggedInUser
                .storeId;
  }

  get getCurrentStoreId => _currentStoreId;
  int _currentStoreId;

  initHomeScreen(context) async {
    var helper = Helper();
    await SignalrHelper.openHubConnection(context);
    await FCMHelper.init(context);
    //connectionId is for SignalR
    var data = {
      "deviceToken": FCMHelper.token,
      "storeId": getCurrentStoreId,
      "connectionId": SignalrHelper.hubConnection?.connectionId
    };

    var response = await helper.postData("api/storeDevice/register", data,
        context: context);

    if (!response.isSuccess) {
      print("Store device Init failed");
    }

    await Provider.of<CurrentStoresProvider>(context, listen: false)
        .getSingleStoreById(context, getCurrentStoreId);
  }
}
