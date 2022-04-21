import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appConfigHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/permissionHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/helpers/stringHelper.dart';
import 'package:vplus_merchant_app/models/store.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/screens/qr/qr_type_bar.dart';
import 'package:vplus_merchant_app/styles/color.dart';
import 'package:vplus_merchant_app/styles/regex.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:vplus_merchant_app/widgets/custom_dialog.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:vplus_merchant_app/widgets/order_type_bar.dart';

/// generateQR page and save to phone gallery
/// QR url format:
/// https://www.vplus.com.au/#/order?storeId={{131}}&isTakeAway={{false}}&tableNumber={{111}}
/// tableNumber: optional, string (takeaway order has no table number, which could be null)
/// storeId: mandatory, int
/// isTakeAway: mandatory, boolean (flag true for TA, false for dineIn)
/// ref: https://github.com/GIS-Global/vplus-merchant-app/wiki/QR-code-format

class QRGenerator extends StatefulWidget {
  @override
  _QRGeneratorState createState() => _QRGeneratorState();
}

class _QRGeneratorState extends State<QRGenerator> {
  Function buttonEvent;
  String tableNumber;
  String url;
  Store store;
  QRButtonType _selectedType;
  int storeId;
  RenderRepaintBoundary boundary;

  // bool generateQR = false;
  GlobalKey _globalKey = new GlobalKey();
  TextEditingController _tableNumberController;

  bool isUser;
  bool isTakeAway;
  bool inAsyncCall;

  @override
  void initState() {
    store = Provider.of<CurrentStoresProvider>(context, listen: false)
        .getStore(context);
    storeId = store.storeId;
    //init
    _selectedType = QRButtonType.DineIn;
    isUser = true;
    isTakeAway = false;
    _tableNumberController = new TextEditingController();
    url = AppConfigHelper.getQrUrl;
    inAsyncCall = false;

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _tableNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _qrScreenKey = GlobalKey<FormState>();
    ScreenUtil.init(context,
        width: 1080, height: 1920, allowFontScaling: false);

    return SafeArea(
      bottom: false,
      top: true,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: CustomAppBar.getAppBar(
          '${AppLocalizationHelper.of(context).translate('QR Generator')}',
          true,
          showLogo: true,
          context: context,
          screenPage: CustomAppBar.storeMainPage,
          rightButtonIcon: store.logoUrl == null
              ? Container(
                  width: ScreenUtil().setWidth(70),
                  height: ScreenUtil().setHeight(70),
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: CircleAvatar(
                    child: Text(
                      store.storeName.substring(0, 1),
                      style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(
                              ScreenHelper.getResponsiveTitleFontSize(
                                  context))),
                    ),
                    backgroundColor: Color(
                        int.tryParse(store.backgroundColorHex) ??
                            Colors.grey.value),
                  ))
              : Container(
                  width: ScreenUtil().setWidth(70),
                  height: ScreenUtil().setHeight(70),
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(store.logoUrl),
                    backgroundColor: Color(
                        int.tryParse(store.backgroundColorHex) ??
                            Colors.grey.value),
                  ),
                ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: inAsyncCall,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setSp(40),
                  vertical: ScreenUtil().setSp(20)),
              child: Container(
                alignment: Alignment.topCenter,
                child: Column(
                  children: <Widget>[
                    QRTypeBar(
                      qrTypeButton: QRButtonType.values.map((e) {
                        return QRTypeButton(
                          isSelectedType: _selectedType,
                          buttonType: e,
                          buttonEvent: () {
                            setState(() {
                              _selectedType = e;
                              // update value
                              isTakeAway =
                                  (e == QRButtonType.TakeAway) ? true : false;
                              // remove table number if take away
                              if (e == QRButtonType.TakeAway) {
                                tableNumber = null;
                                _tableNumberController.text = '';
                              }
                              updateURL();
                            });
                          },
                        );
                      }).toList(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setHeight(30)),
                      child: (_selectedType == QRButtonType.DineIn)
                          ? tableNumberTextBox()
                          : VEmptyView(ScreenHelper.isLandScape(context)
                              ? 10 * SizeHelper.widthMultiplier
                              : 10 * SizeHelper.widthMultiplier),
                    ),
                    qrPoster(),
                    SizedBox(
                      height: SizeHelper.isMobilePortrait
                          ? 1.5 * SizeHelper.textMultiplier
                          : 2 * SizeHelper.textMultiplier,
                    ),
                    saveGalleryButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget tableNumberTextBox() {
    return Column(
      children: [
        Text(
          '${AppLocalizationHelper.of(context).translate('Table Name')}',
          style: GoogleFonts.lato(
            fontSize: SizeHelper.isMobilePortrait
                ? 2 * SizeHelper.textMultiplier
                : 3 * SizeHelper.textMultiplier,
            fontWeight: FontWeight.bold,
          ),
        ),
        VEmptyView(10),
        Center(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtil().setSp(11)),
                border: Border.all(
                  color: Colors.grey,
                  width: ScreenUtil().setSp(1),
                )),
            height: SizeHelper.isMobilePortrait
                ? 5 * SizeHelper.heightMultiplier
                : (SizeHelper.isPortrait)
                    ? 10 * SizeHelper.widthMultiplier
                    : 8 * SizeHelper.widthMultiplier,
            width: SizeHelper.isMobilePortrait
                ? 40 * SizeHelper.heightMultiplier
                : (SizeHelper.isPortrait)
                    ? 50 * SizeHelper.widthMultiplier
                    : 50 * SizeHelper.widthMultiplier,
            child: Center(
              child: TextField(
                textAlign: TextAlign.center,
                controller: _tableNumberController,
                decoration: InputDecoration(
                  hintText:
                      '${AppLocalizationHelper.of(context).translate('EmptyTableNameNote')}',
                  border: InputBorder.none,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(spceialCharactersNotAllowWhiteSpace)),
                ],
                style: GoogleFonts.lato(
                  fontSize: SizeHelper.isMobilePortrait
                      ? 2 * SizeHelper.textMultiplier
                      : (SizeHelper.isPortrait)
                          ? 2.5 * SizeHelper.textMultiplier
                          : 2 * SizeHelper.textMultiplier,
                ),
                onSubmitted: (v) {
                  if (v.length > 0) {
                    tableNumber = v;
                    updateURL();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget qrPoster() {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        height: (ScreenHelper.isLandScape(context))
            ? 85 * SizeHelper.widthMultiplier
            : SizeHelper.isMobilePortrait
                ? 48 * SizeHelper.heightMultiplier
                : 80 * SizeHelper.widthMultiplier,
        width: SizeHelper.isMobilePortrait
            ? 65 * SizeHelper.widthMultiplier
            : 55 * SizeHelper.heightMultiplier,
        child: DecoratedBox(
          child: Container(
            margin: EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    showStoreLogo(store),
                    WEmptyView(20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.storeName,
                          style: GoogleFonts.lato(
                              fontSize: ScreenUtil().setSp(
                                SizeHelper.isMobilePortrait
                                    ? 6 * SizeHelper.textMultiplier
                                    : 4 * SizeHelper.textMultiplier,
                              ),
                              fontWeight: FontWeight.bold),
                        ),
                        // Text(
                        //   store.location,
                        //   style: GoogleFonts.lato(
                        //       fontSize: ScreenUtil().setSp(
                        //         SizeHelper.isMobilePortrait
                        //             ? 4 * SizeHelper.textMultiplier
                        //             : 2 * SizeHelper.textMultiplier,
                        //       ),
                        //       fontWeight: FontWeight.bold),
                        // ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: SizeHelper.isMobilePortrait
                      ? 0.1 * SizeHelper.heightMultiplier
                      : 2 * SizeHelper.widthMultiplier,
                ),
                if (_selectedType == QRButtonType.TakeAway)
                  Center(
                      child: Text(
                    "${AppLocalizationHelper.of(context).translate('TakeAway')}",
                    style: GoogleFonts.lato(
                      fontSize: SizeHelper.isMobilePortrait
                          ? 2 * SizeHelper.textMultiplier
                          : 3 * SizeHelper.textMultiplier,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                Center(
                  child: (tableNumber == null)
                      ? Container()
                      : Text(
                          "${AppLocalizationHelper.of(context).translate('Table Name')}: " +
                              tableNumber,
                          style: GoogleFonts.lato(
                            fontSize: SizeHelper.isMobilePortrait
                                ? 2 * SizeHelper.textMultiplier
                                : 3 * SizeHelper.textMultiplier,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                SizedBox(
                  height: SizeHelper.isMobilePortrait
                      ? 0.1 * SizeHelper.heightMultiplier
                      : 0.1 * SizeHelper.widthMultiplier,
                ),
                Text(
                  "${AppLocalizationHelper.of(context).translate('ScanAndOrder')}",
                  style: GoogleFonts.lato(
                    fontSize: SizeHelper.isMobilePortrait
                        ? 2 * SizeHelper.textMultiplier
                        : 3 * SizeHelper.textMultiplier,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: SizeHelper.isMobilePortrait
                      ? 0.1 * SizeHelper.heightMultiplier
                      : 0.1 * SizeHelper.widthMultiplier,
                ),
                Container(
                  height: (ScreenHelper.isLandScape(context))
                      ? 30 * SizeHelper.widthMultiplier
                      : SizeHelper.isMobilePortrait
                          ? 20 * SizeHelper.heightMultiplier
                          : 20 * SizeHelper.widthMultiplier,
                  width: SizeHelper.isMobilePortrait
                      ? 40 * SizeHelper.widthMultiplier
                      : 35 * SizeHelper.heightMultiplier,
                  child: Center(
                    child: QrImage(
                      // embeddedImage: NetworkImage(
                      //   "https://avatars1.githubusercontent.com/u/41328571?s=280&v=4",
                      // ),
                      data: url,
                    ),
                  ),
                ),
                //banner
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          0,
                          0,
                          (SizeHelper.isMobilePortrait)
                              ? 8 * SizeHelper.imageSizeMultiplier
                              : 8 * SizeHelper.imageSizeMultiplier,
                          0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset(
                            'assets/images/vm-icon-round.jpg',
                            fit: BoxFit.contain,
                            height: SizeHelper.isMobilePortrait
                                ? 8 * SizeHelper.imageSizeMultiplier
                                : 5 * SizeHelper.imageSizeMultiplier,
                            width: SizeHelper.isMobilePortrait
                                ? 8 * SizeHelper.imageSizeMultiplier
                                : 5 * SizeHelper.imageSizeMultiplier,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      // height: SizeHelper.isMobilePortrait
                      //     ? 8 * SizeHelper.imageSizeMultiplier
                      //     : (SizeHelper.isPortrait)
                      //         ? 10 * SizeHelper.imageSizeMultiplier
                      //         : 20 * SizeHelper.imageSizeMultiplier,
                      // width: SizeHelper.isMobilePortrait
                      //     ? 30 * SizeHelper.imageSizeMultiplier
                      //     : (SizeHelper.isPortrait)
                      //         ? 23 * SizeHelper.imageSizeMultiplier
                      //         : 50 * SizeHelper.imageSizeMultiplier,
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Support:",
                            style: GoogleFonts.lato(
                              fontSize: SizeHelper.isMobilePortrait
                                  ? 1.5 * SizeHelper.textMultiplier
                                  : 2 * SizeHelper.textMultiplier,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("www.vplus.com.au",
                              style: GoogleFonts.lato(
                                fontSize: SizeHelper.isMobilePortrait
                                    ? 1.5 * SizeHelper.textMultiplier
                                    : 2 * SizeHelper.textMultiplier,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: qrPosterBackgroundColor,
          ),
        ),
      ),
    );
  }

  Widget showStoreLogo(Store store) {
    return Stack(
      children: [
        Container(
          width: ScreenHelper.isLandScape(context)
              ? 20 * SizeHelper.imageSizeMultiplier
              : ScreenHelper.isLargeScreen(context)
                  ? 25
                  : 60,
          height: ScreenHelper.isLandScape(context)
              ? 20 * SizeHelper.imageSizeMultiplier
              : ScreenHelper.isLargeScreen(context)
                  ? 20
                  : 60,
          decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.all(Radius.circular(ScreenUtil().setSp(14)))),
          child: store.logoUrl == null
              ? CircleAvatar(
                  child: Text(
                    store.storeName.substring(0, 1),
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: SizeHelper.isMobilePortrait
                          ? 3 * SizeHelper.textMultiplier
                          : 5 * SizeHelper.textMultiplier,
                    ),
                  ),
                  backgroundColor: appThemeColor,
                )
              : SquareFadeInImage(store.logoUrl),
        ),
      ],
    );
  }

  Widget saveGalleryButton() {
    return ButtonTheme(
      minWidth: 190.0,
      child: RaisedButton(
        onPressed: () {
          _capturePng();
        },
        child: Text(
          '${AppLocalizationHelper.of(context).translate('SaveToGallery')}',
          style: GoogleFonts.lato(
            fontSize: SizeHelper.isMobilePortrait
                ? 2 * SizeHelper.textMultiplier
                : (SizeHelper.isPortrait)
                    ? 2.5 * SizeHelper.textMultiplier
                    : 2 * SizeHelper.textMultiplier,
          ),
        ),
        textColor: Colors.white,
        color: appThemeColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }

  Future<Uint8List> _capturePng() async {
    setState(() {
      inAsyncCall = true;
    });
    // try {
    print('capturePng now');
    RenderRepaintBoundary boundary =
        _globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var pngBytes = byteData.buffer.asUint8List();

    //create a temp dir for image
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String fullPath =
        '$dir/${store.storeCode}_${DateTime.now().millisecond}.png';
    File capturedFile = File(fullPath);
    // save image data to temp dir
    await capturedFile.writeAsBytes(pngBytes);
    print("image path: " + capturedFile.path);
    // stop the loading indicator before the OS permission dialog pops up.
    setState(() {
      inAsyncCall = false;
    });

    // bool hasPermission = (Platform.isAndroid)
    //     ? await PermissionHelper.checkSpecificPermission(Permission.storage)
    //     : await PermissionHelper.checkSpecificPermission(Permission.photos);
    //  if (hasPermission) {
    // save image to gallery
    await GallerySaver.saveImage(capturedFile.path).then((isSuccess) {
      if (isSuccess) {
        setState(() => {
              Helper().showToastSuccess(
                  '${AppLocalizationHelper.of(context).translate('SuccessfulSavedImageAlert')}')
            });
      } else {
        setState(() => {
              Helper().showToastError(
                  '${AppLocalizationHelper.of(context).translate('FailedSaveImageAlert')}')
            });
      }
    });
    // }
    // else {
    //   // await PermissionHelper.requestSpecificPermission(
    //   //     Permission.photos, context);
    // }
    //  }
    // catch (e) {
    //   print(e);
    //   Helper().showToastError(
    //       '${AppLocalizationHelper.of(context).translate('FailedSaveImageAlert')}');
    // } finally {
    //   setState(() {
    //     inAsyncCall = false;
    //   });
    // }
  }

  void updateURL() {
    url =
        "${AppConfigHelper.getQrUrl}/#/order?storeId=$storeId&isTakeAway=$isTakeAway&tableNumber=$tableNumber";
    print("Current URL: " + url);
  }
}
