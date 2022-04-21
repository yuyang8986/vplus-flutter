import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/Order.dart';
import 'package:vplus_merchant_app/models/OrderItem.dart';
import 'package:vplus_merchant_app/providers/current_order_provider.dart';
import 'package:vplus_merchant_app/providers/current_printer_provider.dart';
import 'package:vplus_merchant_app/screens/order/table_bottom_bar/bottom_bar_utils.dart';
import 'package:vplus_merchant_app/widgets/custom_dialog.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/screens/order/table_bottom_bar/bottom_bar_order_confirmation_listtile.dart';

class TableOrderConfirmation extends StatefulWidget {
  @override
  _TableOrderConfirmationState createState() => _TableOrderConfirmationState();
}

class _TableOrderConfirmationState extends State<TableOrderConfirmation> {
  ScrollController scrollController1 = ScrollController();
  TextEditingController _extraOrderNoteCtl = TextEditingController();
  TextEditingController _orderNoteCtl = TextEditingController();
  List<Widget> extraOrderList;
  List<Widget> orderList;
  Order userorder;
  bool isloading = false;
  @override
  void initState() {
    userorder =
        Provider.of<CurrentOrderProvider>(context, listen: false).getOrder;
    super.initState();
    _initWidget();
  }

  @override
  Widget build(BuildContext context) {
    // return isloading
    //     ? Container()
    //     :
    return ModalProgressHUD(
      inAsyncCall: isloading,
      child: CustomDialog(
        child: _getPopupBody(),
        insideButtonList: [
          CustomDialogInsideCancelButton(callBack: () {
            Navigator.pop(context);
          }),
          CustomDialogInsideButton(
            buttonName: AppLocalizationHelper.of(context).translate('Confirm'),
            buttonEvent: () async {
              _confirmEvent();
            },
          ),
        ],
      ),
    );
  }

  Widget _getPopupBody() {
    return Consumer<CurrentOrderProvider>(builder: (ctx, p, w) {
      userorder = p.getOrder;
      int numberOfItems = p.countOrderItemNumbers();
      double orderPrice = p.getTotal();
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: ScreenUtil().setHeight(ScreenHelper.isLandScape(context)
                  ? 10 * SizeHelper.widthMultiplier
                  : 30),
            ),
            child: Text(
              AppLocalizationHelper.of(context).translate('OrderConfirmation'),
              style: GoogleFonts.lato(
                fontSize: ScreenHelper.isLandScape(context)
                    ? SizeHelper.textMultiplier * 2.5.toDouble()
                    : SizeHelper.textMultiplier * 2.5.toDouble(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(
            height: 2,
            thickness: 2,
          ),
          if (ScreenHelper.isLandScape(context))
            VEmptyView(2 * SizeHelper.heightMultiplier),
          Container(
            // constraints: BoxConstraints(
            //     maxHeight:
            //         ScreenUtil().setSp(3000 * userorder.userItems.length)),
            child: SingleChildScrollView(
              controller: scrollController1,
              child: Column(
                children: [
                  // _getTitle('Extra Order'),
                  // ListView(
                  //   controller: scrollController1,
                  //   shrinkWrap: true,
                  //   children: extraOrderList,
                  // ),
                  // _getNoteTextField(_extraOrderNoteCtl),
                  // _getTotalRow('Sub-total: ', 1, 18.50),
                  // _getTitle('Order'),
                  Container(
                    child: ListView.builder(
                        controller: scrollController1,
                        shrinkWrap: true,
                        itemCount: userorder.userItems.length,
                        itemBuilder: (ctx, index) {
                          OrderItem orderItem = userorder.userItems[index];
                          return TableOrderConfirmationListTile(
                            orderItem: orderItem,
                          );
                        }),
                  ),
                  _getNoteTextField(_orderNoteCtl),
                  _getTotalRow(
                      '${AppLocalizationHelper.of(context).translate('SubTotal')}: ',
                      numberOfItems,
                      orderPrice),
                ],
              ),
            ),
          ),
          _getTotalRow(
              '${AppLocalizationHelper.of(context).translate('Total')}: ',
              numberOfItems,
              orderPrice),
        ],
      );
    });
  }

  void _initWidget() {
    //TODO init list here
    extraOrderList = [
      TableOrderConfirmationListTile(),
      TableOrderConfirmationListTile(),
    ];
    orderList = [
      TableOrderConfirmationListTile(),
      TableOrderConfirmationListTile(),
      TableOrderConfirmationListTile(),
      TableOrderConfirmationListTile(),
      TableOrderConfirmationListTile(),
      TableOrderConfirmationListTile(),
      TableOrderConfirmationListTile(),
    ];
  }

  Future _confirmEvent() async {
    userorder.note = _orderNoteCtl.text;
    setState(() {
      isloading = true;
    });
    try {
      await Provider.of<CurrentOrderProvider>(context, listen: false)
          .submitOrder(context, userorder);
      Order printOrder =
          Provider.of<CurrentOrderProvider>(context, listen: false)
              .getPlacedOrder;
      await Provider.of<CurrentPrinterProvider>(context, listen: false)
          .autoPrintOnOrderConfirmed(context, printOrder);

      Navigator.pop(context);
      // Future.delayed(Duration(milliseconds: 500));
      setState(() {
        isloading = false;
      });
      // TODO if QR order
      if (userorder.orderType == OrderType.QR) {
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
                  child: Text('Order placed',
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil().setSp(
                              ScreenHelper.isLandScape(context)
                                  ? SizeHelper.textMultiplier * 3
                                  : 64))));
            });
      } else {
        // for waiter order, go back to order tables page
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      Helper().showToastError(
          "${AppLocalizationHelper.of(context).translate('FailedToSubmitOrderAlert')}");
      setState(() {
        isloading = false;
      });
      print(e);
    }
  }

  Widget _getTitle(String title) {
    return Container(
      height: ScreenUtil().setHeight(ScreenHelper.isLandScape(context)
          ? SizeHelper.widthMultiplier * 8
          : 100),
      color: Colors.white,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ScreenHelper.isLandScape(context)
                    ? 2 * SizeHelper.widthMultiplier
                    : 30),
            child: Text(
              title,
              textAlign: TextAlign.start,
              style: GoogleFonts.lato(
                fontSize: ScreenHelper.isLandScape(context)
                    ? SizeHelper.textMultiplier * 2.5
                    : 40,
                fontWeight: FontWeight.bold,
                color: BottomBarUtils.getThemeColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getNoteTextField(TextEditingController teCtl) {
    return TextField(
      controller: teCtl,
      keyboardType: TextInputType.multiline,
      maxLines: 3,
      decoration: CustomTextBox(
        context: context,
        icon: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setHeight(20),
          ),
          child: Text(
            '${AppLocalizationHelper.of(context).translate('Note')}: ',
            style: GoogleFonts.lato(
                fontSize: ScreenHelper.isLandScape(context)
                    ? 2 * SizeHelper.textMultiplier
                    : 2 * SizeHelper.textMultiplier,
                fontWeight: FontWeight.bold,
                color: Color(0xfff61a36),
                letterSpacing: 1),
          ),
        ),
      ).getTextboxDecoration(),
    );
  }

  Widget _getTotalRow(String title, int quantity, double price) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil().setHeight(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!ScreenHelper.isLandScape(context)) WEmptyView(100),
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: ScreenHelper.isLandScape(context)
                  ? SizeHelper.textMultiplier * 2
                  : 2 * SizeHelper.textMultiplier,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!ScreenHelper.isLandScape(context)) WEmptyView(100),
          Text(
            (ScreenHelper.isLandScape(context))
                ? quantity.toString() + " item(s) \t"
                : quantity.toString(),
            style: GoogleFonts.lato(
              fontSize: ScreenHelper.isLandScape(context)
                  ? SizeHelper.textMultiplier * 2
                  : 2 * SizeHelper.textMultiplier,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!ScreenHelper.isLandScape(context)) WEmptyView(100),
          Text(
            "\$ ${price.toStringAsFixed(2)}",
            style: GoogleFonts.lato(
              fontSize: ScreenHelper.isLandScape(context)
                  ? SizeHelper.textMultiplier * 2
                  : 2 * SizeHelper.textMultiplier,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
