import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/widgets/custom_dialog.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'bottom_bar_utils.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/screens/order/table_bottom_bar/bottom_bar_order_confirmation.dart';
import 'package:vplus_merchant_app/providers/current_order_provider.dart';

class TablePlaceOrderButton extends StatelessWidget {
  final bool isCartEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentOrderProvider>(
      builder: (ctx, p, w) {
        var order = p.getOrder;
        double orderPrice = p.getTotal();
        if (order.userItems == null || order.userItems.length == 0) {
          // user side show pay button
          return _getBotton(ctx, true,
              isQROrderNotPaid: (order.orderType == OrderType.QR &&
                  (order.userOrderStatus == UserOrderStatus.Started)));
        } else {
          return _getBotton(ctx, false,
              isQROrderNotPaid: (order.orderType == OrderType.QR &&
                  (order.userOrderStatus == UserOrderStatus.Started)),
              orderPrice: orderPrice);
        }
      },
    );
  }

  Widget _getBotton(BuildContext context, bool isCartEmpty,
      {bool isQROrderNotPaid = false, double orderPrice}) {
    PanelController panelController =
        Provider.of<BottomBarEventProvider>(context).getPanelController;
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BottomBarUtils.bottomBarPlaceOrderRadius(),
              color: isCartEmpty ? Color(0xff969faa) : Color(0xff5352ec),
            ),
            child: FlatButton(
              onPressed: () {
                if (!isCartEmpty) {
                  panelController.close();
                  showDialog(
                    context: (context),
                    builder: (context) => TableOrderConfirmation(),
                  );
                } else {
                  //TODO popup a dialog ask for order
                }
              },
              child: Text(
                (isQROrderNotPaid == true)
                    ? AppLocalizationHelper.of(context).translate('Add Order')
                    : AppLocalizationHelper.of(context)
                        .translate('Place Order'),
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: _getFontSize(context),
                ),
              ),
            ),
          ),
        ),
        (isQROrderNotPaid == true && isCartEmpty == false)
            ? Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BottomBarUtils.bottomBarPlaceOrderRadius(),
                    color: Colors.orange,
                  ),
                  child: FlatButton(
                    onPressed: () {
                      panelController.close();
                      _showPayAtCounterDialog(context);
                    },
                    child: Text(
                      'Pay: \$${orderPrice.toStringAsFixed(2)}',
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
                VEmptyView(100),
                Text('Thanks you',
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold))
              ],
            ),
          );
        });
  }

  double _getFontSize(BuildContext context) {
    return ScreenHelper.isLandScape(context)
        ? SizeHelper.heightMultiplier * 3
        : SizeHelper.heightMultiplier * 2;
  }
}
