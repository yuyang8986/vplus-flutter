import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:vplus/helper/apiHelper.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/paymentHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/user.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/providers/payment_provider.dart';
import 'package:vplus/screens/order/payment/default_payment_method_list_tile.dart';
import 'package:vplus/widgets/appBar.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/widgets/emptyView.dart';

class PaymentManageScreen extends StatefulWidget {
  PaymentManageScreen({Key key}) : super(key: key);
  _PaymentManageScreenState createState() => _PaymentManageScreenState();
}

class _PaymentManageScreenState extends State<PaymentManageScreen> {
  bool isLoading;
  Helper hlp;

  @override
  void initState() {
    super.initState();
    isLoading = false;
    hlp = new Helper();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBarWithBackButtonAndTitleOnly(
          context, "${AppLocalizationHelper.of(context).translate("Manage Payment")} "),
      resizeToAvoidBottomInset: true,
      body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Consumer<CurrentUserProvider>(
            builder: (ctx, p, w) {
              User user = p.getloggedInUser;
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.all(SizeHelper.widthMultiplier * 5),
                  child: Column(
                    children: [
                      Text(
                        "${AppLocalizationHelper.of(context).translate("CurrentMethod")} ",
                        style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                      ),
                      VEmptyView(20),
                      DefaultPaymentMethodListTile(
                          userPaymentMethod: user.userPaymentMethod,
                          onSelected: () async {
                            popUpCardDialogAndUpdatePaymentInfo(
                                context, user.userId);
                          }),
                      VEmptyView(50),
                      RoundedVplusLongButton(
                          callBack: () async {
                            popUpCardDialogAndUpdatePaymentInfo(
                                context, user.userId);
                          },
                          text: (user.userPaymentMethod == null)
                              ? "${AppLocalizationHelper.of(context).translate("CardAdd")} "
                              : "${AppLocalizationHelper.of(context).translate("CardUpdate")} ")
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }

  void popUpCardDialogAndUpdatePaymentInfo(
      BuildContext context, int userId) async {
    setState(() {
      isLoading = true;
    });
    PaymentMethod newPaymentMethod =
        await PaymentHelper().changePaymentMethod();
    // print(newPaymentMethod);
    if (newPaymentMethod != null) {
      bool hasUpdatedCard = false;
      hasUpdatedCard =
          await Provider.of<PaymentProvider>(context, listen: false)
              .updateCardSourceToAPI(context, newPaymentMethod.id);
      if (hasUpdatedCard) {
        hlp.showToastSuccess("New card has been updated");
        await Provider.of<CurrentUserProvider>(context, listen: false)
            .updateCustomerInfoByUserId(context, userId);
      }
    }
    setState(() {
      isLoading = false;
    });
  }
}
