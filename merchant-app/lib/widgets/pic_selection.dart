import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:vplus_merchant_app/helpers/permissionHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vplus_merchant_app/widgets/custom_dialog.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';

// child:
// Column(
// mainAxisAlignment: MainAxisAlignment.center,
// crossAxisAlignment: CrossAxisAlignment.center,
// children: [
// Text(
// 'Upload',
// style: TextStyle(
// color: Colors.black,
// fontSize: ScreenUtil().setSp(50)),
// ),
// Text(
// 'Image',
// style: TextStyle(
// color: Colors.black,
// fontSize: ScreenUtil().setSp(50)),
// ),
// ])

class PicSelection extends StatefulWidget {
  final Function onSelectCallBack;
  double componentHeight;
  bool isComponentBorder;
  int picFlex;
  Widget child;
  bool isChildCirclePic;
  double childHeight;
  double childWidth;
  static bool isSelectingPic = false;

  PicSelection(
    this.onSelectCallBack, {
    this.componentHeight,
    this.isComponentBorder,
    this.picFlex,
    this.child,
    this.isChildCirclePic,
    this.childHeight,
    this.childWidth,
  });

  @override
  _PicSelection createState() => _PicSelection();
}

class _PicSelection extends State<PicSelection> {
  File _image;
  dynamic _imageWidget;
  String image64;

  Future getImage(ImgSource source, BuildContext context) async {
    PicSelection.isSelectingPic = true;
    File isPickImage = await pickImage(source, context);
    if (isPickImage == null) {
      return;
    }

    File isCropImage = await cropImage(isPickImage);
    if (isCropImage == null) {
      return;
    }

    _image = isCropImage;
    _imageWidget = widget.isChildCirclePic
        ? CircleAvatar(
            backgroundImage: FileImage(_image),
          )
        : ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            child: Image.file(
              _image,
              fit: BoxFit.cover,
              width: ScreenUtil().setWidth(widget.childWidth),
              height: ScreenUtil().setHeight(widget.childHeight),
            ),
          );
    // convert to base64, add = to fit format
    image64 = base64Encode(_image.readAsBytesSync());
    widget.onSelectCallBack(image64);

    setState(() {
      image64 = image64;
      _image = _image;
    });
  }

  Future customPickImage() async {
    ImagePicker imagePicker = new ImagePicker();
    return await showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return CustomDialog(
          outsideButtonList: [
            CustomDialogOutsideButton(
                isCloseButton: true,
                buttonEvent: () {
                  Navigator.of(context).pop();
                }),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              InkWell(
                onTap: () async {
                  // bool hasPermission = (Platform.isAndroid)
                  //     ? await PermissionHelper.checkSpecificPermission(
                  //         Permission.storage)
                  //     : await PermissionHelper.checkSpecificPermission(
                  //         Permission.photos);
                  // if (hasPermission) {
                  imagePicker
                      .getImage(
                    source: ImageSource.gallery,
                  )
                      .then((image) {
                    Navigator.pop(context, image);
                  });
                }
                // else {
                //   await PermissionHelper.requestSpecificPermission(
                //       Permission.photos, context);
                // }
                // },,
                ,
                child: Container(
                  child: ListTile(
                    title: Text("Gallery"),
                    leading: Icon(
                      Icons.perm_media,
                      color: Color(0xff5352ec),
                    ),
                  ),
                ),
              ),
              Container(
                width: 200,
                height: 1,
                color: Colors.black12,
              ),
              InkWell(
                onTap: () async {
                  // bool hasPermission =
                  //     await PermissionHelper.checkSpecificPermission(
                  //         Permission.camera);

                  // if (hasPermission) {
                  imagePicker
                      .getImage(
                    source: ImageSource.camera,
                  )
                      .then((image) {
                    Navigator.pop(context, image);
                  });
                  // } else {
                  //   await PermissionHelper.requestSpecificPermission(
                  //       Permission.camera, context);
                  // }
                },
                child: Container(
                  // margin: EdgeInsets.only(left: 15),
                  child: ListTile(
                    title: Text("Camera"),
                    leading: Icon(
                      Icons.camera_alt,
                      color: Color(0xff5352ec),
                      size: ScreenHelper.isLandScape(context)
                          ? SizeHelper.textMultiplier * 2.7
                          : SizeHelper.textMultiplier * 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File> pickImage(ImgSource source, BuildContext context) async {
    final pickedFile = await customPickImage();

    if (pickedFile != null) {
      // _image = File(pickedFile.path);
      return File(pickedFile.path);
    } else {
      print('No image selected.');
      return null;
    }
  }

  Future<File> cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        // compress image
        compressQuality: 90,
        maxWidth: 256,
        maxHeight: 256,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: ' ',
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.grey[800],
            activeControlsWidgetColor: Color(0xff5352EC),
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      return croppedFile;
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _imageWidget = widget.child;
  }

  @override
  void dispose() {
    /// temporary set this flag when dispose the widget
    /// used to avoid restart app issue.
    PicSelection.isSelectingPic = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        logoInputField(context),
      ],
    );
  }

  Widget logoInputField(BuildContext context) {
    var inkWell = InkWell(
      onTap: () async {
        await getImage(ImgSource.Both, context);
      },
      child: Container(
        height: ScreenUtil().setHeight(widget.componentHeight),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: widget.isComponentBorder
              ? Border.all(
                  color: borderColor,
                  width: 2.0,
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: (ScreenHelper.isLandScape(context))
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          children: [
            if (!ScreenHelper.isLandScape(context))
              Expanded(
                flex: 1,
                child: Container(),
              ),
            Expanded(
              flex: (ScreenHelper.isLandScape(context)) ? 0 : widget.picFlex,
              child: Row(
                children: [
                  Container(
                    height: ScreenUtil().setHeight(widget.childHeight),
                    width: ScreenUtil().setWidth(widget.childWidth),
                    decoration: BoxDecoration(
                      borderRadius: widget.isChildCirclePic
                          ? null
                          : BorderRadius.all(Radius.circular(10.0)),
                      shape: widget.isChildCirclePic
                          ? BoxShape.circle
                          : BoxShape.rectangle,
                      border: Border.all(
                        color: borderColor,
                        width: 2.0,
                      ),
                    ),
                    child: _imageWidget,
                  ),
                  Expanded(
                    flex: (ScreenHelper.isLandScape(context)) ? 0 : 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(
                              ScreenHelper.isLandScape(context)
                                  ? 8
                                  : ScreenUtil().setWidth(
                                      SizeHelper.imageSizeMultiplier * 5)),
                          child: Icon(
                            Icons.camera_alt,
                            size: ScreenHelper.isLargeScreen(context)
                                ? SizeHelper.imageSizeMultiplier * 4
                                : SizeHelper.imageSizeMultiplier * 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return inkWell;
  }
}
