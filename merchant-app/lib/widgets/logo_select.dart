/// This logo select is an obsolete widget and no longer used.
/// Please use pic_select instead.

// import 'dart:convert';
// import 'dart:ffi';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:vplus_merchant_app/widgets/components.dart';
// import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';

// class LogoSelection extends StatefulWidget {
//   final Function onSelectCallBack;
//   dynamic initImage;
//   LogoSelection(this.onSelectCallBack, {this.initImage});

//   @override
//   _LogoSelectionState createState() => _LogoSelectionState();
// }

// class _LogoSelectionState extends State<LogoSelection> {
//   File _image;
//   dynamic _imageContainer;
//   String image64;

//   Future getImage(ImgSource source) async {
//     final pickedFile = await ImagePickerGC.pickImage(
//       context: context,
//       source: source,
//       barrierDismissible: true,
//       cameraIcon: Icon(
//         Icons.camera_alt,
//         color: Color(0xff5352ec),
//       ),
//       galleryIcon: Icon(
//         Icons.perm_media,
//         color: Color(0xff5352ec),
//       ),
//     );

//     if (pickedFile != null) {
//       _image = File(pickedFile.path);
//       _imageContainer = CircleAvatar(
//         backgroundImage: FileImage(_image),
//       );
//       // convert to base64, add = to fit format
//       image64 = base64Encode(_image.readAsBytesSync());
//       widget.onSelectCallBack(image64);
//     } else {
//       print('No image selected.');
//     }

//     setState(() {
//       image64 = image64;
//       _image = _image;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     if (widget.initImage != null) _imageContainer = widget.initImage;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         logoInputField(context),
//       ],
//     );
//   }

//   Widget logoInputField(BuildContext context) {
//     var inkWell = InkWell(
//         onTap: () {
//           getImage(ImgSource.Both);
//         },
//         child: Container(
//           height: ScreenUtil().setHeight(_imageContainer == null ? 260 : 180),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10.0),
//             border: widget.initImage == null
//                 ? Border.all(
//                     color: borderColor,
//                     width: 2.0,
//                   )
//                 : null,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 flex: 1,
//                 child: Container(),
//               ),
//               Expanded(
//                 flex: _imageContainer == null ? 1 : 2,
//                 child: Container(
//                   height: ScreenUtil().setHeight(200),
//                   width: ScreenUtil().setHeight(200),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: borderColor,
//                       width: 2.0,
//                     ),
//                     // image: _image != null
//                     //     ? DecorationImage(
//                     //         image: FileImage(_image),
//                     //         fit: BoxFit.cover,
//                     //       )
//                     //     : null,
//                   ),
//                   child: _imageContainer == null
//                       ? Center(
//                           child: Text(
//                             "Logo",
//                             textAlign: TextAlign.center,
//                             style: GoogleFonts.lato(
//                               textStyle:
//                                   GoogleFonts.lato(color: Colors.grey[500]),
//                               fontWeight: FontWeight.w800,
//                               fontSize: ScreenUtil().setSp(38),
//                             ),
//                           ),
//                         )
//                       : _imageContainer,
//                 ),
//               ),
//               Expanded(
//                 flex: 1,
//                 child: Icon(Icons.camera_alt),
//               ),
//             ],
//           ),
//         ));
//     return inkWell;
//   }
// }
