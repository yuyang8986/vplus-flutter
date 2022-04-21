import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/paymentHelper.dart';
import 'package:vplus/models/paymentIntent.dart';

import 'currentuser_provider.dart';

class PaymentProvider with ChangeNotifier {
  PaymentIntent currentPaymentIntent;

  PaymentIntent get getCurrentPaymentIntent => currentPaymentIntent;

  Future<bool> updateCardSourceToAPI(
      BuildContext context, String source) async {
    var helper = Helper();
    int userId = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser
        .userId;
    var data = {"UserId": userId, "source": source};
    var response = await helper.postData("api/payment/update-card", data,
        context: context, hasAuth: true);
    if (response.isSuccess && response.data != null) {
      return true;
    } else {
      helper.showToastError('Unable to update this card, please try again');
      return false;
    }
  }

  Future<String> initPaymentIntent(BuildContext context, double paymentAmount,
      String description, int storeId, int orderId,String couponCode,
      {String paymentMethodId}) async {
    // init payment intent, return the payment intent id if success
    var helper = Helper();
    int userId = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser
        .userId;
    var data = {
      "amount":
          PaymentHelper.convertAmountToCent(paymentAmount), // measure in cent
      "description": description,
      "quantity": 1,
      "userId": userId,
      "storeId": storeId,
      "userOrderId": orderId,
      "paymentMethodId": paymentMethodId,
      "couponCode": couponCode

    };
    var response = await helper.postData("api/Payment/paymentIntent", data,
        context: context, hasAuth: true);
    if (response.isSuccess && response.data != null) {
      currentPaymentIntent = PaymentIntent.fromJson(response.data);
     // notifyListeners();
      return currentPaymentIntent.paymentIntentId;
    } else {
      helper.showToastError("${AppLocalizationHelper.of(context).translate("submitPaymentError")}");
      return null;
    }
  }

  Future<bool> submitPaymentIntent(
      BuildContext context, String paymentIntentId) async {
    // submit the payment, may take seconds for response.
    // loading indicator is needed for this method.
    var helper = Helper();
    int userId = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser
        .userId;
    var data = {
      "userId": userId,
      "paymentIntentId": paymentIntentId,
    };
    var response = await helper.postData(
        "api/Payment/paymentIntent-confirm", data,
        context: context, hasAuth: true);
    if (response.isSuccess) {
      return true;
    } else {
      // helper.showToastError("${AppLocalizationHelper.of(context).translate("submitPaymentError")}");
      return false;
    }
  }

  Future<PaymentIntent> getPaymentIntentStatus(
      BuildContext context, String paymentIntentId) async {
    var helper = Helper();

    var response = await helper.getData("api/Payment/$paymentIntentId/status",
        context: context, hasAuth: true);
    if (response.isSuccess && response.data != null) {
      currentPaymentIntent = PaymentIntent.fromJson(response.data);
      notifyListeners();
      return currentPaymentIntent;
    } else {
      helper
          .showToastError('Unable to update payment intent, please try again');
      return null;
    }
  }

  Future<bool> cancelPaymentIntent(
      BuildContext context, String paymentIntentId) async {
    var helper = Helper();

    var response = await helper.getData("api/Payment/$paymentIntentId/cancel",
        context: context, hasAuth: true);
    if (response.isSuccess && response.data == true) {
      return true;
    } else {
      helper
          .showToastError('Unable to cancel payment intent, please try again');
      return false;
    }
  }
}
