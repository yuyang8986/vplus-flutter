// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:vplus_merchant_app/helpers/signalrHelper.dart';
// import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
// import 'package:vplus_merchant_app/models/Order.dart';
// import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
// import 'package:vplus_merchant_app/providers/orderlist_provider.dart';
// import 'package:vplus_merchant_app/widgets/emptyView.dart';
// import 'package:vplus_merchant_app/widgets/network_error.dart';

// import 'table_listtile.dart';

// class TableListView extends StatefulWidget {
//   TableListView({
//     Key key,
//     this.isTakeaway,
//   }) : super(key: key);
//   final bool isTakeaway;

//   @override
//   _TableListView createState() => _TableListView();
// }

// class _TableListView extends State<TableListView> {
//   bool isTakeaway;
//   ScrollController _controller = new ScrollController();
//   int storeMenuId;
//   Future _getOrderListFromAPIFuture;

//   int pageNumber = 1;
//   List<Order> activeOrders;

//   @override
//   void initState() {
//     storeMenuId =
//         Provider.of<CurrentMenuProvider>(context, listen: false).getStoreMenuId;
//     _getOrderListFromAPIFuture =
//         Provider.of<OrderListProvider>(context, listen: false)
//             .getOrderListFromAPI(context, storeMenuId, true, pageNumber);
//     // init FCM
//     // FCMHelper.initOrderTableContext(context);
//     SignalrHelper.initOrderTableContext(context);
//     //init scroll
//     // scrollLazyLoad(_controller);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     isTakeaway = this.widget.isTakeaway;

//     return FutureBuilder(
//         future: _getOrderListFromAPIFuture,
//         builder: (context, asyncData) {
//           if (asyncData.connectionState != ConnectionState.done) {
//             return _listViewLoadingLayer();
//           }

//           if (asyncData.hasError) {
//             return NetErrorWidget(callback: null);
//           }
//           return _tableListViewContent();
//         });
//   }

//   Widget _tableListViewContent() {
//     return Consumer<OrderListProvider>(builder: (context, p, w) {
//       // get updated order list and split into dineIn & TakeAway
//       p.splitOrderTypeFromAllOrders();
//       activeOrders = (isTakeaway == true)
//           ? p.getTakeAwayOrderList()
//           : p.getDineInOrderList();

//       return (activeOrders == null || activeOrders.isEmpty)
//           ? Container(
//               height: ScreenUtil().setHeight(1150),
//               child: Center(
//                 child: Text('No active orders, a fresh start!',
//                     style: GoogleFonts.lato(
//                         textStyle: GoogleFonts.lato(
//                       fontSize: ScreenUtil().setSp(SizeHelper.isMobilePortrait
//                           ? 5 * SizeHelper.textMultiplier
//                           : 2 * SizeHelper.textMultiplier),
//                     ))),
//               ),
//             )
//           : Container(
//               // height: ScreenUtil().setHeight(1150),
//               height: SizeHelper.isMobilePortrait
//                   ? 75 * SizeHelper.heightMultiplier
//                   : (SizeHelper.isPortrait)
//                       ? 100 * SizeHelper.widthMultiplier
//                       : 150 * SizeHelper.widthMultiplier,
//               // width:SizeHelper.isMobilePortrait?30*SizeHelper.widthMultiplier:(SizeHelper.isPortrait)?10*SizeHelper.heightMultiplier:100*SizeHelper.heightMultiplier,
//               child: GridView.builder(
//                 controller: _controller,
//                 shrinkWrap: true,
//                 padding: EdgeInsets.only(
//                     left: ScreenUtil().setWidth(30),
//                     right: ScreenUtil().setWidth(30),
//                     bottom: ScreenUtil().setHeight(360)),
//                 itemCount: activeOrders.length,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: (SizeHelper.isPortrait) ? 3 : 5,
//                     mainAxisSpacing: ScreenUtil().setHeight(30),
//                     crossAxisSpacing: ScreenUtil().setWidth(30),
//                     childAspectRatio: (SizeHelper.isPortrait)
//                         ? 0.9
//                         : SizeHelper.heightMultiplier * 0.06),
//                 itemBuilder: (context, index) {
//                   Widget tile;
//                   Order currentOrder = activeOrders[index];
//                   if (!isTakeaway) {
//                     tile = TableListTile(
//                       order: currentOrder,
//                       hasOrder: (currentOrder.userItems != null &&
//                           currentOrder.userItems.isNotEmpty),
//                       isTakeaway: false,
//                     );
//                   } else {
//                     tile = TableListTile(
//                       order: currentOrder,
//                       hasOrder: (currentOrder.userItems != null &&
//                           currentOrder.userItems.isNotEmpty),
//                       isTakeaway: true,
//                     );
//                   }
//                   return tile;
//                 },
//               ),
//             );
//     });
//   }

//   // scrollLazyLoad(ScrollController _controller) {
//   //   // Setup the listener.
//   //   _controller.addListener(() async {
//   //     if (_controller.position.atEdge) {
//   //       if (_controller.position.pixels == 0) {
//   //         print('Table Page Top');
//   //         // You're at the top.
//   //         // currentPage = Provider.of<OrderListProvider>(context, listen: false)
//   //         //     .getCurrentActivePage();
//   //         // int storeMenuId;
//   //         // storeMenuId = Provider.of<CurrentMenuProvider>(context, listen: false)
//   //         //     .getSelectedCategoryId;
//   //         // await Provider.of<OrderListProvider>(context, listen: false)
//   //         //     .getOrderListFromAPI(context, storeMenuId, true, currentPage);
//   //       } else {
//   //         bool hasNextPage;
//   //         int currentPage;
//   //         // You're at the bottom.

//   //         currentPage = Provider.of<OrderListProvider>(context, listen: false)
//   //             .getCurrentActivePage();
//   //         hasNextPage = Provider.of<OrderListProvider>(context, listen: false)
//   //             .getHasNextActivePage();

//   //         if (hasNextPage) {
//   //           currentPage += 1;
//   //           pageNumber = currentPage;

//   //           int storeMenuId;
//   //           storeMenuId =
//   //               Provider.of<CurrentMenuProvider>(context, listen: false)
//   //                   .getStoreMenuId;
//   //           await Provider.of<OrderListProvider>(context, listen: false)
//   //               .getOrderListFromAPI(context, storeMenuId, true, pageNumber);
//   //         }
//   //       }
//   //     }
//   //   });
//   // }

//   Widget _listViewLoadingLayer() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         VEmptyView(200),
//         CircularProgressIndicator(),
//       ],
//     );
//   }
// }
