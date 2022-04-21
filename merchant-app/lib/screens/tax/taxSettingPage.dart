import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/store.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/providers/currentuser_provider.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:vplus_merchant_app/widgets/custom_dialog.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';

class TaxSettingPage extends StatefulWidget {
  TaxSettingPage({Key key}) : super(key: key);

  @override
  _TaxSettingPageState createState() => _TaxSettingPageState();
}

class _TaxSettingPageState extends State<TaxSettingPage> {
  Store store;
  final TextEditingController textFiledController = new TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  double taxRate = 0.0;

  editTaxRate() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
              title:
                  '${AppLocalizationHelper.of(context).translate('TaxSettingPageTitle')}',
              insideButtonList: [
                CustomDialogInsideButton(
                    buttonName:
                        "${AppLocalizationHelper.of(context).translate('Cancel')}",
                    buttonColor: Colors.grey,
                    buttonEvent: () {
                      Navigator.pop(context);
                    }),
                CustomDialogInsideButton(
                    buttonName:
                        "${AppLocalizationHelper.of(context).translate('Confirm')}",
                    buttonEvent: () async {
                      var helper = Helper();
                      try {
                        double.parse(textFiledController.text);
                        double newTax = double.parse(textFiledController.text);
                        if (newTax >= 0 && newTax <= 100) {
                          var response = await helper.putData(
                              "api/stores/${store.storeId}/setTax?taxRate=${newTax.toString()}",
                              null,
                              context: context,
                              hasAuth: true);
                          if (response.isSuccess) {
                            setState(() {
                              store.taxRate = newTax;
                              taxRate = newTax;
                            });
                          } else {
                            helper.showToastError(
                                '${AppLocalizationHelper.of(context).translate('UpdateTaxRateFailedAlert')}');
                          }
                        } else {
                          helper.showToastError(
                              '${AppLocalizationHelper.of(context).translate('InvalidTaxRateRangeAlert')}');
                        }
                      } catch (Exception) {
                        helper.showToastError(
                            '${AppLocalizationHelper.of(context).translate('InvalidTaxRateNotNumberAlert')}');
                      }
                      // textFiledController.clear();
                      Navigator.pop(context);
                    }),
              ],
              child: Center(
                child: Form(
                  key: formkey,
                  child: Column(
                    children: [
                      TextField(
                        controller: textFiledController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          hintText:
                              '${AppLocalizationHelper.of(context).translate('EnterTaxSettingNote')}',
                        ),
                        style: GoogleFonts.lato(
                          fontSize: ScreenUtil().setSp(30),
                          fontWeight: FontWeight.normal,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ));
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    textFiledController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    store = Provider.of<CurrentStoresProvider>(context, listen: false)
        .getStore(context);
    if (store != null && store.taxRate != null) taxRate = store.taxRate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: 1080, height: 1920, allowFontScaling: false);
    print('Store Id: ${store.storeId}');
    if (store != null && store.taxRate != null) taxRate = store.taxRate;
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            size: SizeHelper.isMobilePortrait
                ? 3 * SizeHelper.textMultiplier
                : 3 * SizeHelper.textMultiplier,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          '${AppLocalizationHelper.of(context).translate('TaxSettingPageTitle')}',
          style: GoogleFonts.lato(
              fontSize: ScreenUtil().setSp(40),
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[50],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Container(
            padding: EdgeInsets.fromLTRB(
                SizeHelper.isMobilePortrait
                    ? 5 * SizeHelper.heightMultiplier
                    : SizeHelper.isPortrait
                        ? 10 * SizeHelper.heightMultiplier
                        : 10 * SizeHelper.heightMultiplier,
                SizeHelper.isMobilePortrait
                    ? 10 * SizeHelper.heightMultiplier
                    : SizeHelper.isPortrait
                        ? 10 * SizeHelper.heightMultiplier
                        : 10 * SizeHelper.heightMultiplier,
                SizeHelper.isMobilePortrait
                    ? 5 * SizeHelper.heightMultiplier
                    : SizeHelper.isPortrait
                        ? 10 * SizeHelper.heightMultiplier
                        : 10 * SizeHelper.heightMultiplier,
                0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // VEmptyView(ScreenUtil().setHeight(50)),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  '${AppLocalizationHelper.of(context).translate('TaxLabel')}: ',
                                  style: GoogleFonts.lato(
                                      fontSize: SizeHelper.isMobilePortrait
                                          ? 3 * SizeHelper.textMultiplier
                                          : SizeHelper.isPortrait
                                              ? 3 * SizeHelper.textMultiplier
                                              : 3 * SizeHelper.textMultiplier)),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        ScreenUtil().setSp(11)),
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: ScreenUtil().setSp(1),
                                    )),
                                height: SizeHelper.isMobilePortrait
                                    ? 5 * SizeHelper.heightMultiplier
                                    : (SizeHelper.isPortrait)
                                        ? 3.5 * SizeHelper.widthMultiplier
                                        : 5 * SizeHelper.widthMultiplier,
                                width: SizeHelper.isMobilePortrait
                                    ? 30 * SizeHelper.widthMultiplier
                                    : (SizeHelper.isPortrait)
                                        ? 13 * SizeHelper.heightMultiplier
                                        : 10 * SizeHelper.heightMultiplier,
                                child: Center(
                                  child: Text(
                                    taxRate.toStringAsFixed(1) + " %",
                                    style: GoogleFonts.lato(
                                      fontSize: SizeHelper.isMobilePortrait
                                          ? 3 * SizeHelper.textMultiplier
                                          : 2 * SizeHelper.textMultiplier,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            size: ScreenHelper.isLargeScreen(context)
                                ? 30
                                : SizeHelper.imageSizeMultiplier * 5,
                          ),
                          onPressed: () async {
                            await editTaxRate();
                          },
                        ),
                      )
                    ],
                  ),
                ),
                // VEmptyView(ScreenUtil().setHeight(50)),
              ],
            ),
          );
        },
      ),
    );
  }
}
