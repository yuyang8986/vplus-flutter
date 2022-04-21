import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/signalrHelper.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/providers/kds_provider.dart';

class KDSHelper {
  static Future<bool> setItemReady(
      BuildContext context, int orderItemId, int orderId) async {
    bool hasUpdated = await Provider.of<KDSProvider>(context, listen: false)
        .setOrderItemReady(context, [orderItemId]);
    if (hasUpdated) {
      // Helper().showToastSuccess("Update item successfully");
      var signalr = SignalrHelper();
      int storeId = Provider.of<CurrentStoresProvider>(context, listen: false)
          .getStoreId(context);
      await signalr.sendUserOrder(
          SignalrHelper.readyOrderEvent, storeId, orderId);

      await Provider.of<KDSProvider>(context, listen: false)
          .updateKDSDataFromAPI(context);
    } else {
      Helper().showToastError("Update item status failed, please try again");
    }
    return hasUpdated;
  }
}
