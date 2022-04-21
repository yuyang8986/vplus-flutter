// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
// import 'package:vplus_merchant_app/styles/color.dart';
// import 'package:vplus_merchant_app/widgets/custom_dialog.dart';

// class PermissionHelper {
//   static Future<void> requestSpecificPermission(
//       Permission permission, BuildContext context) async {
//     List<String> permissions = [
//       "Vplus require this permission",
//       permission.toString()
//     ];
//     await showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return alertWindow(context, permissions);
//         });
//   }

//   static Future<bool> checkSpecificPermission(Permission permission) async {
//     var status = await permission.status;

//     if (status != PermissionStatus.granted) {
//       return false;
//     }
//     return true;
//   }

//   // check whether a permission have been granted
//   static Future<void> checkMissingPermission(BuildContext context) async {
//     List<String> permissions = ["Vplus require the following permissions"];

//     var status = await Permission.camera.status;
//     if (status != PermissionStatus.granted) {
//       permissions.add(Permission.camera.toString());
//     }

//     status = await Permission.notification.status;
//     if (status != PermissionStatus.granted) {
//       permissions.add(Permission.notification.toString());
//     }

//     status = await Permission.photos.status;
//     if (status != PermissionStatus.granted) {
//       permissions.add(Permission.photos.toString());
//     }

//     if (Platform.isAndroid) {
//       status = await Permission.storage.status;
//       if (status != PermissionStatus.granted) {
//         permissions.add(Permission.storage.toString());
//       }
//     }

//     if (permissions.length > 1)
//       await showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return alertWindow(context, permissions);
//           });
//   }

//   static Future<void> requestPermission() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.camera,
//       Permission.photos,
//       Permission.notification,
//       if (Platform.isAndroid) Permission.storage,
//     ].request();
//   }

//   //TODO: create alert window when permission denied
//   static Widget alertWindow(BuildContext context, List<String> permissions) {
//     return CustomDialog(
//       title: "Request Permission",
//       insideButtonList: [
//         CustomDialogInsideButton(
//             buttonName: "Cancel",
//             buttonColor: Colors.grey,
//             buttonEvent: () {
//               Navigator.pop(context);
//             }),
//         CustomDialogInsideButton(
//             buttonName: "Grant",
//             buttonColor: appThemeColor,
//             buttonEvent: () {
//               Navigator.pop(context);
//               openAppSettings();
//             }),
//       ],
//       child: Container(
//         child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: permissions
//                 .map(
//                   (item) => Center(
//                     child: Text(
//                       item,
//                       // textAlign: TextAlign.center,
//                       style: GoogleFonts.lato(
//                           fontWeight: FontWeight.normal,
//                           color: Colors.black,
//                           height: 2,
//                           textStyle: GoogleFonts.lato(
//                             fontSize: SizeHelper.isMobilePortrait
//                                 ? 2 * SizeHelper.textMultiplier
//                                 : (SizeHelper.isPortrait)
//                                     ? 3 * SizeHelper.textMultiplier
//                                     : 2.5 * SizeHelper.textMultiplier,
//                           )),
//                     ),
//                   ),
//                 )
//                 .toList()),
//       ),
//     );
//   }
// }
