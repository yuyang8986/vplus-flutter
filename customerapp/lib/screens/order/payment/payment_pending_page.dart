import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/paymentIntent.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/providers/order_list_provider.dart';
import 'package:vplus/providers/payment_provider.dart';
import 'package:vplus/screens/order/payment/payment_success_page.dart';
import 'package:vplus/widgets/appBar.dart';
import 'package:vplus/widgets/components.dart';

const int ROLLING_FREQ = 1; // rolling api frequency, in seconds
const int ROLLING_TIMEOUT = 10; // timeout, in times

class PaymentPendingPage extends StatefulWidget {
  PaymentPendingPage({Key key}) : super(key: key);
  _PaymentSuccessPageState createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentPendingPage> {
  String paymentIntentId;
  PaymentIntent paymentIntent;
  int count;
  int userId;
  @override
  void initState() {
    super.initState();
    paymentIntentId = Provider.of<PaymentProvider>(context, listen: false)
        .getCurrentPaymentIntent
        .paymentIntentId;
    userId = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser
        .userId;
    // rolling API to get update
    count = 0;
    // checkPaymentProcessed().then((value) {
    //   hasProcessed = value;
    // });
    // Timer.periodic(Duration(seconds: ROLLING_FREQ), (timer) async {
    //   bool hasProcessed = await checkPaymentProcessed();
    //   print("$count, $hasProcessed");
    //   count++;
    //   if (hasProcessed) {
    //     timer.cancel();
    //   }
    //   if (count == ROLLING_TIMEOUT) {
    //     await Provider.of<PaymentProvider>(context, listen: false)
    //         .cancelPaymentIntent(context, paymentIntentId);
    //     timer.cancel();
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar("${AppLocalizationHelper.of(context).translate("Cashier")}", false,
          context: context, showLeftBackButton: false),
      body: Consumer<PaymentProvider>(builder: (ctx, p, w) {
        paymentIntent = p.getCurrentPaymentIntent;
        if (paymentIntent.paymentStatus == PaymentStatus.Success) {
          // payment success logic
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            // update this paid order in order list
            await Provider.of<OrderListProvider>(context, listen: false)
                .getOrderListByUserId(context, userId, 1);
            Navigator.popAndPushNamed(context, "PaymentSuccessPage");
          });
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (paymentIntent.paymentStatus == PaymentStatus.Failed ||
                    count == ROLLING_TIMEOUT)
                ? paymentFailedInformation()
                : paymentLoadingInformation(),
          ],
        );
      }),
    );
  }

  Widget paymentLoadingInformation() {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(SizeHelper.textMultiplier * 4),
            child: Container(
                height: SizeHelper.heightMultiplier * 7,
                width: SizeHelper.heightMultiplier * 7,
                child: CircularProgressIndicator()),
          ),
          Text("${AppLocalizationHelper.of(context).translate("paymentProcessMsg")}",
              style: GoogleFonts.lato(fontSize: SizeHelper.textMultiplier * 2))
        ],
      ),
    );
  }

  Widget paymentFailedInformation() {
    return Center(
      child: Column(
        children: [
          Text("${AppLocalizationHelper.of(context).translate("paymentErrorMsg")}",
              style: GoogleFonts.lato(fontSize: SizeHelper.textMultiplier * 2)),
          Padding(
            padding:
                EdgeInsets.symmetric(vertical: SizeHelper.heightMultiplier * 3),
            child: RoundedVplusLongButton(
              text: "${AppLocalizationHelper.of(context).translate("returnPaymentPage")}",
              callBack: () {
                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
    );
  }

  Future<bool> checkPaymentProcessed() async {
    PaymentIntent paymentIntent;
    paymentIntent = await Provider.of<PaymentProvider>(context, listen: false)
        .getPaymentIntentStatus(context, paymentIntentId);
    return (paymentIntent.paymentStatus == PaymentStatus.NotStarted || paymentIntent.paymentStatus == PaymentStatus.InProgress ||
            paymentIntent.paymentStatus == PaymentStatus.Failed)
        ? true
        : false;
  }
}
