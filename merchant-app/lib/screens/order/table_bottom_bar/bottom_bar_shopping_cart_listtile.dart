import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/OrderItem.dart';
import 'package:vplus_merchant_app/providers/current_order_provider.dart';
import 'package:vplus_merchant_app/screens/order/table_bottom_bar/bottom_bar_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/styles/font.dart';
import 'package:vplus_merchant_app/widgets/itemCounter.dart';

class TableShoppingCartListTile extends StatefulWidget {
  OrderItem orderItem;
  ScrollController _controller;
  TableShoppingCartListTile({this.orderItem});
  int itemQuantity;

  @override
  _TableShoppingCartListTileState createState() =>
      _TableShoppingCartListTileState();
}

class _TableShoppingCartListTileState extends State<TableShoppingCartListTile> {
  @override
  void initState() {
    widget._controller = ScrollController();
    widget._controller.addListener(_scrollListener);
    widget.itemQuantity = widget.orderItem.quantity;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    widget.itemQuantity = widget.orderItem.quantity;
    super.didChangeDependencies();
  }

  Widget getAddOnReceipt(List<String> strings, BuildContext context) {
    return new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: strings
            .map((item) => new Text(item,
                style: GoogleFonts.lato(
                    fontSize: ScreenHelper.isLandScape(context)
                        ? SizeHelper.textMultiplier * 2
                        : shoppingCartAddOnReceiptTextSize)))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // key: ValueKey(menuItem.menuItemId),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ScreenUtil().setSp(0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(1, 1), // changes position of shadow
          ),
        ],
        // border: Border.all(
        //   color: Colors.grey,
        //   width: ScreenUtil().setSp(1),
        // ),
      ),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: ScreenHelper.isLandScape(context)
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    (widget.orderItem.isTakeAway)
                        ? '${widget.orderItem.menuItem.menuItemName} ${AppLocalizationHelper.of(context).translate('TakeAway')}'
                        : '${widget.orderItem.menuItem.menuItemName}',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(
                          ScreenHelper.isLandScape(context)
                              ? SizeHelper.heightMultiplier * 2
                              : 40),
                    ),
                  ),
                ),
                // show addon receipt if exists
                (widget.orderItem.userOrderItemAddOnReceipt == null ||
                        widget.orderItem.userOrderItemAddOnReceipt.length == 0)
                    ? Container()
                    : Container(
                        // width: ScreenUtil().setWidth(400),
                        constraints: BoxConstraints(
                          maxWidth: ScreenUtil().setWidth(600),
                          // maxHeight: ScreenUtil().setHeight(widget.orderItem
                          //         .userOrderItemAddOnReceipt.length *
                          //     100.0),
                        ),
                        child: getAddOnReceipt(
                            widget.orderItem.userOrderItemAddOnReceipt,
                            context),
                      ),
              ],
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '\$${widget.orderItem.price.toStringAsFixed(2)}',
                  style: GoogleFonts.lato(
                      fontSize: ScreenUtil().setSp(
                          ScreenHelper.isLandScape(context)
                              ? SizeHelper.textMultiplier * 2
                              : 40)),
                ),
                ItemCounter(
                  initNumber: widget.orderItem.quantity,
                  counterCallback: (v) {
                    // var price = Provider.of<CurrentOrderProvider>(context,
                    //         listen: false)
                    //     .calculateItemPrice(widget.orderItem);
                    setState(() {
                      widget.orderItem.quantity = v;
                      widget.orderItem.price =
                          Provider.of<CurrentOrderProvider>(context,
                                  listen: false)
                              .calculateItemPrice(widget.orderItem);
                      if (v == 0) {
                        Provider.of<CurrentOrderProvider>(context,
                                listen: false)
                            .removeOrderItem(widget.orderItem);
                        int remainingItems = Provider.of<CurrentOrderProvider>(
                                context,
                                listen: false)
                            .countOrderItemNumbers();

                        //if shopping cart is empty close the panel
                        if (remainingItems == 0) {
                          PanelController panelController =
                              Provider.of<BottomBarEventProvider>(context,
                                      listen: false)
                                  .getPanelController;
                          panelController.close();
                        }
                      }
                    });
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getListTileButton(IconData iconData, {Function callback}) {
    return ButtonTheme(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minWidth: ScreenUtil().setWidth(20), //wraps child's width
      height: ScreenUtil().setWidth(70), //wraps child's height
      child: FlatButton(
        onPressed: () {
          callback();
        },
        child: Icon(
          iconData,
          color: BottomBarUtils.getThemeColor(),
        ),
      ),
    );
  }

  _scrollListener() {
    if (widget._controller.offset >=
            widget._controller.position.maxScrollExtent &&
        !widget._controller.position.outOfRange) {
      setState(() {});
    }
    if (widget._controller.offset <=
            widget._controller.position.minScrollExtent &&
        !widget._controller.position.outOfRange) {
      setState(() {});
    }
  }
}
