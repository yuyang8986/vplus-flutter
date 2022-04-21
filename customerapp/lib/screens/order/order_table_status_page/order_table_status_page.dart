import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/DateTimeHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/ExtraOrder.dart';
import 'package:vplus/models/Order.dart';
import 'package:vplus/models/OrderItem.dart';
import 'package:vplus/providers/current_order_provider.dart';

import 'order_status_listview.dart';

class OrderTableStatusPage extends StatefulWidget {
  Order userOrder;

  @override
  State<StatefulWidget> createState() {
    return OrderTableStatusPageState();
  }
}

class OrderTableStatusPageState extends State<OrderTableStatusPage> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // SignalrHelper.initOrderTableOrderStatusContext(context);
    // SignalrHelper.atOrderTableStatusPage = true;
    super.initState();
  }

  @override
  void dispose() {
    // SignalrHelper.atOrderTableStatusPage = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentOrderProvider>(builder: (context, p, w) {
      widget.userOrder = p.getPlacedOrder;
      if (widget.userOrder == null) {
        return Container();
      } else {
        return _showSingleOrder(widget.userOrder, context);
      }
    });
  }

  Future _reflashEvent(context) async {
    await Provider.of<CurrentOrderProvider>(context, listen: false)
        .getExistingPlacedOrderFromAPI(context);
  }

  double getTotalAmount(Order order) {
    double result = 0;
    if (order != null) {
      if (order.userItems != null && order.userItems.length > 0) {
        order.userItems.forEach((item) {
          if (item.itemStatus != ItemStatus.Returned &&
              item.itemStatus != ItemStatus.Cancelled &&
              item.itemStatus != ItemStatus.Voided) {
            if (item.price != null) result += item.price;
          }
        });
      }
      if (order.userExtraOrders != null && order.userExtraOrders.length > 0) {
        order.userExtraOrders.forEach((extraOrder) {
          if (extraOrder.userItems != null && extraOrder.userItems.length > 0) {
            extraOrder.userItems.forEach((item) {
              if (item.itemStatus != ItemStatus.Returned &&
                  item.itemStatus != ItemStatus.Cancelled &&
                  item.itemStatus != ItemStatus.Voided) {
                if (item.price != null) result += item.price;
              }
            });
          }
        });
      }
      return result;
    }
  }

  Widget _showSingleOrder(Order o, BuildContext context) {
    return o?.userOrderId == null
        ? Container()
        : Container(
            margin: EdgeInsets.fromLTRB(20, 20, 20, 60),
            padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Number: ${o.userOrderId}',
                          style: GoogleFonts.lato(
                              fontSize: SizeHelper.isMobilePortrait
                                  ? 2 * SizeHelper.textMultiplier
                                  : 2 * SizeHelper.textMultiplier,
                              fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.cached,
                            color: Colors.black,
                            size: SizeHelper.isMobilePortrait
                                ? 2.5 * SizeHelper.textMultiplier
                                : 2 * SizeHelper.textMultiplier,
                          ),
                          onPressed: () async {
                            await _reflashEvent(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  if (o.userExtraOrders != null && o.userExtraOrders.isNotEmpty)
                    ListView.builder(
                      controller: scrollController,
                      shrinkWrap: true,
                      reverse: true,
                      itemCount: o.userExtraOrders.length,
                      itemBuilder: (ctx, index) {
                        return _showSingleExtraOrder(
                            o.userExtraOrders[index], context);
                      },
                    ),
                  _getTitle(
                      'Order',
                      DateTimeHelper.parseDateTimeToDateHHMM(
                          o.orderCreateDateTimeUTC.toLocal()),
                      context),
                  (o.note != null && o.note.isNotEmpty)
                      ? orderNote(o.note)
                      : Container(),
                  OrderStatusListView(o.userItems,
                      scrollController: scrollController),
                  Divider(
                    thickness: 2,
                    height: 2,
                  ),
                  Padding(
                    padding: EdgeInsets.all(ScreenUtil().setSp(50)),
                    child: Center(
                      child: Text(
                        'Total: \$' + '${getTotalAmount(o).toStringAsFixed(2)}',
                        style: GoogleFonts.lato(
                            fontSize: SizeHelper.isMobilePortrait
                                ? 3.5 * SizeHelper.textMultiplier
                                : 2 * SizeHelper.textMultiplier,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ));
  }

  Widget _getTitle(String title, String datetime, BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(80),
      color: Color(0xffe3e8ef),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setSp(20)),
            child: Text(
              title + ': ',
              style: GoogleFonts.lato(
                  fontSize: SizeHelper.isMobilePortrait
                      ? 2 * SizeHelper.textMultiplier
                      : 2 * SizeHelper.textMultiplier,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            datetime,
            style: GoogleFonts.lato(
              fontSize: SizeHelper.isMobilePortrait
                  ? 2 * SizeHelper.textMultiplier
                  : 2 * SizeHelper.textMultiplier,
            ),
          ),
        ],
      ),
    );
  }

  Widget orderNote(String note) {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setSp(20)),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.all(
            Radius.circular(10.0) //                 <--- border radius here
            ),
        color: Color(0xFFFFE2E2),
        // color: color,
      ),
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setSp(10)),
        child: Text(
          'Note: ${note}',
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: SizeHelper.isMobilePortrait
                ? 1.5 * SizeHelper.textMultiplier
                : 2 * SizeHelper.textMultiplier,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }

  Widget _showSingleExtraOrder(ExtraOrder e, BuildContext context) {
    return Container(
      child: Column(
        children: [
          _getTitle(
              'Extra Order',
              DateTimeHelper.parseDateTimeToDateHHMM(
                  e.orderCreateDateTimeUTC.toLocal()),
              context),
          (e.note != null && e.note.isNotEmpty)
              ? orderNote(e.note)
              : Container(),
          OrderStatusListView(e.userItems, scrollController: scrollController),
        ],
      ),
    );
  }
}
