// import 'package:badges/badges.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:vpluswebflutter/helpers/screenHelper.dart';
// import 'package:vpluswebflutter/helpers/sizeHelper.dart';
// import 'package:vpluswebflutter/models/Order.dart';
// import 'package:vpluswebflutter/providers/current_orderStatus_provider.dart';
// import 'package:vpluswebflutter/providers/current_order_provider.dart';

// import '../../emptyView.dart';

// class TableListTile extends StatelessWidget {
//   Order order;
//   final bool hasOrder;
//   final bool isTakeaway;
//   TableListTile({
//     this.order,
//     this.hasOrder,
//     this.isTakeaway,
//   });
//   String takeAwayIdShortcut;
//   @override
//   Widget build(BuildContext context) {
//     if (isTakeaway) {
//       takeAwayIdShortcut =
//           Provider.of<CurrentOrderProvider>(context, listen: false)
//               .getTakeAwayIdShortcut(order.takeAwayId);
//     }
//     return Container(
//       height: SizeHelper.isMobilePortrait
//           ? 20 * SizeHelper.heightMultiplier
//           : (SizeHelper.isPortrait)
//               ? 25 * SizeHelper.widthMultiplier
//               : 100 * SizeHelper.widthMultiplier,
//       width: SizeHelper.isMobilePortrait
//           ? 30 * SizeHelper.widthMultiplier
//           : (SizeHelper.isPortrait)
//               ? 10 * SizeHelper.heightMultiplier
//               : 10 * SizeHelper.heightMultiplier,
//       child: Stack(
//         alignment: Alignment.topCenter,
//         children: <Widget>[
//           _getButtonBody(context),
//           !hasOrder
//               ? Positioned(
//                   right: 0,
//                   top: 0,
//                   child: GestureDetector(
//                     onTap: () async {
//                       await closeButton(context);
//                     },
//                     child: Align(
//                       alignment: Alignment.topRight,
//                       child: CircleAvatar(
//                         radius: 14.0,
//                         backgroundColor: Color(0xfff61a36),
//                         child: Icon(
//                           Icons.close,
//                           color: Colors.white, //Color(0xff343f4b),
//                           size: 15,
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//               : Container(),
//         ],
//       ),
//     );
//   }

//   _getButtonBody(BuildContext context) {
//     return Container(
//       // height: ScreenUtil().setHeight((!ScreenHelper.isLandScape(context))?MediaQuery.of(context).size.height * 0.5:MediaQuery.of(context).size.height*0.5),
//       // width: ScreenUtil().setWidth((!ScreenHelper.isLandScape(context))?MediaQuery.of(context).size.width * 0.18:MediaQuery.of(context).size.width*0.0001),
//       constraints: BoxConstraints(
//         //minHeight: ScreenUtil().setHeight(320),
//         maxHeight: SizeHelper.isMobilePortrait
//             ? 20 * SizeHelper.heightMultiplier
//             : (SizeHelper.isPortrait)
//                 ? 25 * SizeHelper.widthMultiplier
//                 : 500 * SizeHelper.widthMultiplier,
//         minWidth: ScreenUtil().setWidth(220),
//       ),
//       margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
// decoration: BoxDecoration(
//   color: Colors.white,
//   borderRadius: BorderRadius.circular(
//     ScreenUtil().setSp(8),
//   ),
//   border: Border.all(
//     color: Colors.grey,
//     width: ScreenUtil().setSp(2),
//   ),
// ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: InkWell(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 // height:SizeHelper.isMobilePortrait?20*SizeHelper.heightMultiplier:(SizeHelper.isPortrait)?25*SizeHelper.widthMultiplier:100*SizeHelper.widthMultiplier,
//                 // width:SizeHelper.isMobilePortrait?30*SizeHelper.widthMultiplier:(SizeHelper.isPortrait)?10*SizeHelper.heightMultiplier:10*SizeHelper.heightMultiplier,
//                 decoration: BoxDecoration(
//                   // color: Color(0xff5352ec),
//                   borderRadius: BorderRadius.circular(
//                     ScreenUtil().setSp(10),
//                   ),
//                   border: hasOrder
//                       ? Border.all(
//                           color: Color(0xff5352ec),
//                           width: ScreenUtil().setSp(2),
//                         )
//                       : Border.all(
//                           color: Colors.white,
//                           width: ScreenUtil().setSp(2),
//                         ),
//                 ),
//                 padding: EdgeInsets.all(ScreenUtil().setSp(2)),
//                 child: Image.asset(
//                   isTakeaway
//                       ? (hasOrder
//                           ? 'assets/images/order/take_away.png'
//                           : 'assets/images/order/take_away_inactive.png')
//                       : (hasOrder
//                           ? 'assets/images/order/dine_in.png'
//                           : 'assets/images/order/dine_in_inactive.png'),
//                   width: ScreenUtil()
//                       .setSp(ScreenHelper.isLandScape(context) ? 60 : 100),
//                   scale: 2,
//                 ),
//               ),
//               VEmptyView(ScreenHelper.isLargeScreen(context) ? 15 : 10),
//               Text(
//                 (isTakeaway == true)
//                     ? '${takeAwayIdShortcut}'
//                     : '${order.table}',
//                 style: GoogleFonts.lato(
//                   fontSize: ScreenUtil().setSp(
//                       ScreenHelper.getResponsiveTextBodyFontSize(context)),
//                   color: Colors.grey,
//                 ),
//               ),
//               VEmptyView(ScreenHelper.isLargeScreen(context) ? 15 : 35),
//               hasOrder
//                   ? ButtonTheme(
//                       padding:
//                           EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
//                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                       minWidth:
//                           ScreenUtil().setWidth(100), //wraps child's width
//                       height: (!ScreenHelper.isLandScape(context))
//                           ? MediaQuery.of(context).size.width * 0.05
//                           : MediaQuery.of(context).size.width *
//                               0.01, //wraps child's height
//                       child: RaisedButton(
//                         onPressed: () => addOrderButton(context),
//                         textColor: Colors.white,
//                         color: Color(0xff5352ec),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(5.0),
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text(
//                               " Add Order ",
//                               style: GoogleFonts.lato(
//                                 fontSize: ScreenUtil().setSp(
//                                     ScreenHelper.getResponsiveTextBodyFontSize(
//                                         context)),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                   : Text(
//                       'Start Order',
//                       style: GoogleFonts.lato(
//                         fontSize: ScreenUtil().setSp(
//                             ScreenHelper.getResponsiveTextBodyFontSize(
//                                 context)),
//                         color: Colors.grey,
//                       ),
//                     ),
//             ],
//           ),
//           onTap: () => (hasOrder == true)
//               ? tableButton(context)
//               : addOrderButton(context),
//         ),
//       ),
//     );
//   }

//   Future closeButton(BuildContext context) async {
//     // delete order when click the top-right red X button

//     await Provider.of<CurrentOrderProvider>(context, listen: false)
//         .deleteOrder(context, order.userOrderId);
//     // remove from frontend list

//     // (isTakeaway == true)
//     //     ? Provider.of<OrderListProvider>(context, listen: false)
//     //         .removeOrderFromTakeAwayOrderList(order)
//     //     : Provider.of<OrderListProvider>(context, listen: false)
//     //         .removeOrderFromDineInOrderList(order);
//   }

//   addOrderButton(BuildContext context) async {
//     Provider.of<Current_OrderStatus_Provider>(context, listen: false)
//         .setOrderStatusType(OrderStatusPageType.tableAddOrder);
//     Provider.of<Current_OrderStatus_Provider>(context, listen: false)
//         .setOrder(context, order, true);
//     await Provider.of<CurrentOrderProvider>(context, listen: false)
//         .getOrderByOrderId(context, order.userOrderId);
//     _toOrderScreen(context);
//   }

//   tableButton(BuildContext context) async {
//     // if (ScreenHelper.isLandScape(context)) {
//     //   Provider.of<Current_OrderStatus_Provider>(context, listen: false)
//     //       .setDisplayAppBar(true);
//     // }
//     Provider.of<Current_OrderStatus_Provider>(context, listen: false)
//         .setOrderStatusType(OrderStatusPageType.tableViewOrder);
//     Provider.of<Current_OrderStatus_Provider>(context, listen: false)
//         .setOrder(context, order, true);
//     Provider.of<Current_OrderStatus_Provider>(context, listen: false)
//         .determineOrderStatus(order, true);
//     // Navigator.of(context, rootNavigator: true)
//     //     .push(MaterialPageRoute(builder: (context) => OrderStatusView()));

//     // (isTakeaway && hasOrder)
//     //     ? print('takeaway - has order - order status')
//     //     : (isTakeaway && !hasOrder)
//     //         ? print('takeaway - no order - order status')
//     //         : (!isTakeaway && hasOrder)
//     //             ? print('Dine in - has order - order status')
//     //             : print('Dine in - no order - order status');
//   }

//   _toOrderScreen(BuildContext context) {
//     // pushNewScreen(
//     //   context,
//     //   screen: OrderTablesPage(),
//     //   withNavBar: false,
//     //   pageTransitionAnimation: PageTransitionAnimation.cupertino,
//     // );
//   }
// }
