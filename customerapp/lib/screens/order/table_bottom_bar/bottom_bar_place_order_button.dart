import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/order_helper.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/Order.dart';
import 'package:vplus/models/campaign.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/providers/current_store_provider.dart';
import 'package:vplus/widgets/custom_dialog.dart';
import 'package:vplus/widgets/emptyView.dart';
import 'bottom_bar_order_confirmation.dart';
import 'bottom_bar_utils.dart';
import 'package:provider/provider.dart';

class TablePlaceOrderButton extends StatelessWidget {
  final bool isStoreOrdering;

  TablePlaceOrderButton({this.isStoreOrdering});

  final bool isCartEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentOrderProvider>(
      builder: (ctx, p, w) {
        var order = p.getOrderWithDiscountApplied(context);
        bool hasOrderSubmitted = p.getHasOrderSubmitted();
        double orderPrice = p.getTotal();

        if (order.userItems == null || order.userItems.length == 0) {
          // user side show pay button
          return _getBotton(ctx, true,
              isQROrderNotPaid: (order.orderType == OrderType.QR &&
                  (order.userOrderStatus == UserOrderStatus.Started)),
              hasOrderSubmitted: hasOrderSubmitted);
        } else {
          return _getBotton(ctx, false,
              isQROrderNotPaid: (order.orderType == OrderType.QR &&
                  (order.userOrderStatus == UserOrderStatus.Started)),
              orderPrice: orderPrice,
              hasOrderSubmitted: hasOrderSubmitted);
        }
      },
    );
  }

  Widget _getBotton(BuildContext context, bool isCartEmpty,
      {bool isQROrderNotPaid = false,
      double orderPrice,
      bool hasOrderSubmitted}) {
    PanelController panelController =
        Provider.of<BottomBarEventProvider>(context).getPanelController;
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: Container(
            // constraints: BoxConstraints(
            //     maxHeight: ScreenUtil().setHeight(
            //         ScreenHelper.isLandScape(context)
            //             ? SizeHelper.heightMultiplier * 9
            //             : SizeHelper.heightMultiplier * 16.5)),
            decoration: BoxDecoration(
              borderRadius: BottomBarUtils.bottomBarPlaceOrderRadius(),
              color: isCartEmpty ? Color(0xff969faa) : Color(0xff5352ec),
            ),
            child: FlatButton(
              onPressed: () {
                if (!isCartEmpty) {
                  panelController.close();
                  showDialog(
                    builder: (context) => TableOrderConfirmation(
                      isStoreOrdering: this.isStoreOrdering,
                    ),
                    context: (context),
                  );
                } else {
                  //TODO popup a dialog ask for order
                }
              },
              child: Text(
                (isQROrderNotPaid == true) ? "${AppLocalizationHelper.of(context).translate("Add Order")}" : "${AppLocalizationHelper.of(context).translate("Place Order")}",
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: _getFontSize(context),
                ),
              ),
            ),
          ),
        ),
        // (isQROrderNotPaid == true && isCartEmpty == false)
        (hasOrderSubmitted)
            ? (isStoreOrdering == false)
                ? Expanded(
                    flex: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BottomBarUtils.bottomBarPlaceOrderRadius(),
                        color: Colors.orange,
                      ),
                      child: FlatButton(
                        onPressed: () {
                          panelController.close();
                          _showPayAtCounterDialog(context);
                        },
                        child: Text(
                          (orderPrice == null)
                              ? 'Pay'
                              : 'Pay: \$${orderPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: _getFontSize(context),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container()
            : Container()
      ],
    );
  }

  _showPayAtCounterDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            insideButtonList: [
              CustomDialogInsideButton(
                  buttonName: "Okay",
                  buttonEvent: () {
                    Navigator.of(context).pop();
                  })
            ],
            child: Column(
              children: [
                Text('Please make the payment at counter',
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                VEmptyView(ScreenUtil().setSp(100)),
                Text('Thank you',
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold))
              ],
            ),
          );
        });
  }

  num _getFontSize(BuildContext context) {
    return ScreenUtil().setSp(
        ScreenHelper.isLandScape(context) ? SizeHelper.textMultiplier * 2 : 35);
  }
}
