// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:vplus/helper/screenHelper.dart';
// import 'package:vplus/models/Order.dart';
// import 'package:vplus/providers/current_order_provider.dart';
// import 'package:vplus/widgets/custom_dialog.dart';

// const int ORDER_EXPIRE_TIMEOUT = 300; //seconds
// const int POPUP_EXPIRE_TIMEOUT = 10; //seconds

// void showOrderTimeoutDialog(BuildContext context) {
//   bool hasRenewed = false;
//   bool hasOrderSubmitted =
//       Provider.of<CurrentOrderProvider>(context, listen: false)
//           .getHasOrderSubmitted();
//   // delay for popup
//   Future.delayed(Duration(seconds: POPUP_EXPIRE_TIMEOUT), () async {
//     if (hasRenewed == false) {
//       // no order placed. Delete the order and pop out.
//       Order order =
//           Provider.of<CurrentOrderProvider>(context, listen: false).getOrder;
//       await Provider.of<CurrentOrderProvider>(context, listen: false)
//           .deleteOrder(order.userOrderId, context);
//       // pop the timeout dialog itself first
//       Navigator.pop(context);
//       // pop all widgets, until to the home page
//       Navigator.popUntil(context, (Route route) {
//         return (route?.settings?.name == "/") ? true : false;
//       });
//     }
//   });
//   // main dialog
//   if (hasOrderSubmitted) {
//     hasRenewed = true;
//     return;
//   } else {
//     showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return CustomDialog(
//               title: "Attention",
//               insideButtonList: [
//                 CustomDialogInsideButton(
//                     buttonName: "I'm here!",
//                     buttonEvent: () {
//                       hasRenewed = true;
//                       Navigator.of(context).pop();
//                     })
//               ],
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Center(
//                     child: Text(
//                       "Your order is about to expire due to the inactivity.",
//                       style: GoogleFonts.lato(
//                           fontSize: ScreenUtil().setSp(
//                               (ScreenHelper.isLandScape(context))
//                                   ? SizeHelper.textMultiplier * 1.5
//                                   : SizeHelper.textMultiplier * 8)),
//                     ),
//                   ),
//                   Center(
//                     child: Text(
//                       "Please click the button below to continue your order.",
//                       style: GoogleFonts.lato(
//                           fontSize: ScreenUtil().setSp(
//                               (ScreenHelper.isLandScape(context))
//                                   ? SizeHelper.textMultiplier * 1.5
//                                   : SizeHelper.textMultiplier * 8)),
//                     ),
//                   ),
//                 ],
//               ));
//         });
//   }
// }
