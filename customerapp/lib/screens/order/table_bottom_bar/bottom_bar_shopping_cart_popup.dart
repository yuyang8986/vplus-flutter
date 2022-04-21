import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/widgets/custom_dialog.dart';

import 'bottom_bar.dart';
import 'bottom_bar_shopping_cart_listview.dart';
import 'bottom_bar_utils.dart';

class TableShoppingCartDetails extends StatelessWidget {
  final ScrollController scrollController;
  final bool isStoreOrdering;

  TableShoppingCartDetails({this.scrollController, this.isStoreOrdering});

  @override
  Widget build(BuildContext context) {
    return 
    Provider.of<CurrentUserProvider>(context, listen: false).getloggedInUser 
    == null ?Container():
    _getBottomBarBody(context);
  }

  // (order.orderType == OrderType.QR &&
  //                 (order.userOrderStatus == UserOrderStatus.Started)

  Widget _getBottomBarBody(BuildContext context) {
    int count = Provider.of<CurrentOrderProvider>(context, listen: false)
        .getOrder?.userItems?.length??0;
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: 
                    ScreenHelper.isLandScape(context)
                        ? SizeHelper.heightMultiplier * 9
                        : SizeHelper.heightMultiplier * 6),
            child: TableBottomBar(isStoreOrdering: this.isStoreOrdering),
          ),
          count > 0
              ? ConstrainedBox(
                  constraints:
                      BoxConstraints(maxHeight: ScreenUtil().setHeight(100)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(100),
                        ),
                        child: Text(
                          "${AppLocalizationHelper.of(context).translate("ShoppingCartTitleLabel")}",
                          style: GoogleFonts.lato(
                            color: Color(0xff37424e),
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(
                                ScreenHelper.isLandScape(context)
                                    ? SizeHelper.textMultiplier * 2
                                    : 40),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(70),
                        ),
                        child: FlatButton(
                          onPressed: () {
                            _clearButton(context);
                          },
                          child: Text(
                            "${AppLocalizationHelper.of(context).translate("ShoppingCartClearLabel")}",
                            style: GoogleFonts.lato(
                              color: Color(0xfff61a36),
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(
                                  ScreenHelper.isLandScape(context)
                                      ? SizeHelper.textMultiplier * 2
                                      : 40),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Divider(
                  height: 2,
                  thickness: 2,
                ),
                Expanded(
                  child: TableShoppingCartListview(
                    scrollController: scrollController,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _clearButton(BuildContext context) {
    showDialog(
        builder: (context) => CustomDialog(
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'Are you sure to clear all items?',
                      style: GoogleFonts.lato(),
                    ),
                  ),
                ],
              ),
              insideButtonList: [
                CustomDialogInsideCancelButton(callBack: () {
                  Navigator.pop(context);
                }),
                CustomDialogInsideButton(
                  buttonName: "Confirm",
                  buttonEvent: () {
                    _confirmClearButton(context);
                  },
                ),
              ],
            ),
        context: (context));
  }

  void _confirmClearButton(BuildContext context) {
    //TODO clear all items for the table in provider
    Provider.of<CurrentOrderProvider>(context, listen: false).cleanOrderItem();
    PanelController panelController =
        Provider.of<BottomBarEventProvider>(context, listen: false)
            .getPanelController;
    panelController.close();
    Navigator.pop(context);
  }
}
