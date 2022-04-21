import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/formValidationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/storeBusinessType.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/providers/currentuser_provider.dart';
import 'package:vplus_merchant_app/widgets/address_search.dart';
import 'package:vplus_merchant_app/widgets/background_color_select.dart';
import 'package:vplus_merchant_app/widgets/business_type_select.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:vplus_merchant_app/widgets/pic_selection.dart';

import '../../helpers/screenHelper.dart';
import '../../helpers/sizeHelper.dart';

class StoreConfig extends StatefulWidget {
  @override
  _StoreConfigState createState() => _StoreConfigState();
}

class _StoreConfigState extends State<StoreConfig> {
  // manage state of modal progress HUD widget
  bool _isInAsyncCall = false;

  final GlobalKey<FormState> _createStoreKey = GlobalKey<FormState>();

  TextEditingController _storeNameCtrl = new TextEditingController();

  String storeAddress;
  List<StoreBusinessType> businessTypes;
  List<int> businessTypeIds;
  String backgroundColor;
  String image64; //base64
  String storeCoord;

  Helper hlp = Helper();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: true,
      child: Scaffold(
        //resizeToAvoidBottomInset: true,
        appBar: CustomAppBar.getAppBar(
            AppLocalizationHelper.of(context).translate('SetUp'), true,
            showLogo: false, context: context),
        body: ModalProgressHUD(
          child: SingleChildScrollView(
            child: Container(
              // height: ScreenUtil().setHeight(2400),
              child: buildStoreConfigForm(context),
            ),
          ),
          inAsyncCall: _isInAsyncCall,
          // demo of some additional parameters
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget buildStoreConfigForm(BuildContext context) {
    return Form(
      key: _createStoreKey,
      child: Padding(
        padding: EdgeInsets.only(
            left: ScreenUtil().setSp(100), right: ScreenUtil().setSp(100)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // VEmptyView(10),
            // Text(
            //   '',
            //   style: GoogleFonts.lato(
            //       fontWeight: FontWeight.w900,
            //       fontSize: ScreenUtil().setSp(40)),
            // ),
            VEmptyView(30),
            TextFormField(
              textAlign: TextAlign.center,
              controller: _storeNameCtrl,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.next,
              validator: FormValidateService(context).validateStoreName,
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
              decoration: CustomTextBox(
                context: context,
                mandate: true,
                hint: AppLocalizationHelper.of(context).translate('StoreName'),
              ).getTextboxDecoration(),
            ),
            VEmptyView(40),
            AddressSearch((addr, coord) {
              setState(() {
                storeAddress = addr;
                storeCoord = coord;
              });
            }),
            VEmptyView(40),
            BusinessTypeSelection((v) {
              setState(() {
                businessTypes = v;
                // get all of the ids from StoreBusinessType list
                businessTypeIds = [];
                for (StoreBusinessType type in businessTypes) {
                  businessTypeIds.add(type.storeBusinessCatTypeId);
                }
              });
            }),
            VEmptyView(40),
            BackgroundColorSelection((v) {
              setState(() {
                backgroundColor = v;
              });
            }),
            VEmptyView(40),
            PicSelection(
              (v) {
                setState(() {
                  image64 = v;
                });
              },
              componentHeight: ScreenHelper.isLandScape(context) ? 330 : 260,
              isComponentBorder: true,
              picFlex: 2,
              isChildCirclePic: true,
              childHeight: ScreenHelper.isLandScape(context) ? 280 : 200,
              childWidth: ScreenHelper.isLandScape(context) ? 170 : 300,
              child: Center(
                child: Text(
                  AppLocalizationHelper.of(context).translate("LogoLabel"),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      textStyle: GoogleFonts.lato(color: Colors.grey[500]),
                      fontWeight: FontWeight.w700,
                      fontSize: SizeHelper.textMultiplier *
                          (ScreenHelper.isLandScape(context) ? 2 : 2)),
                ),
              ),
            ),
            VEmptyView(40),
            Container(
              width: double.infinity,
              height: ScreenUtil().setHeight(150),
              child: RaisedButton(
                onPressed: () {
                  _submitForm();
                },
                textColor: Colors.white,
                color: Color(0xff5352ec),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizationHelper.of(context).translate("Confirm"),
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeHelper.textMultiplier * 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            VEmptyView(100)
          ],
        ),
      ),
    );
  }

  bool _validationCheck() {
    // do all user input validation check
    // return true for PASS validator
    bool validateResult = true;

    if (_createStoreKey.currentState.validate()) {
      _createStoreKey.currentState.save();
    } else {
      validateResult = false;
    }

    if (storeAddress == null || storeAddress == ' ') {
      validateResult = false;
      hlp.showToastError(
          "${AppLocalizationHelper.of(context).translate('EmptyStoreAddressAlert')}");
    }

    /// Currently the business type is optional
    /// Do NOT validate the business type
    // if (businessTypeIds == null) {
    //   validateResult = false;
    //   hlp.showToastError("Please select a store business type");
    // }

    // // at least one cuisine is required for Food & Beverage type
    // var catNames =
    //     (List<StoreBusinessType>.from(businessTypes)).map((e) => e.catName);
    // if (catNames.first == "Food & Beverage" && catNames.length == 1) {
    //   hlp.showToastError("Please select at least one cuisine type");
    // }

    if (backgroundColor == null) {
      validateResult = false;
      hlp.showToastError(
          "${AppLocalizationHelper.of(context).translate('EmptyBackgroundColorAlert')}");
    }

    // Logo is optional, can be empty
    // if (image64 == null) {
    //   validateResult = false;
    // }
    return validateResult;
  }

  Future<void> _submitForm() async {
    if (_validationCheck()) {
      // dismiss keyboard during async call
      FocusScope.of(context).requestFocus(new FocusNode());

      // start the modal progress HUD
      setState(() {
        _isInAsyncCall = true;
      });

      // Simulate a service call
      //call web api

      Helper hlp = new Helper();
      Map<String, dynamic> data = {
        "storeName": _storeNameCtrl.text,
        "location": storeAddress,
        "coordinates": storeCoord,
        "storeBusinessCatIds": businessTypeIds ?? [2],
        "backgroundColorHex": backgroundColor,
        "organizationId":
            Provider.of<CurrentUserProvider>(context, listen: false)
                .getloggedInUser
                .organizationId,
        "logoImage": image64,
      };

      var response = await hlp.postData("api/stores", data,
          context: context, hasAuth: true);
      if (response.data != null && response.isSuccess) {
        var initResponse = await hlp.postData(
            "api/Menu/${response.data['storeId'] as int}", null,
            context: context, hasAuth: true);
        if (initResponse.isSuccess) {
          print('Successful');
        } else {
          hlp.showToastError(
              "${AppLocalizationHelper.of(context).translate('FailedToCreateMenuInfoNote')}");
        }
        await Provider.of<CurrentStoresProvider>(context, listen: false)
            .getStoreFromAPI(context);
        Navigator.pushNamed(context, "StoreList");
        setState(() {
          _isInAsyncCall = false;
        });
        return;
      } else {
        // hlp.showToastError(hlp.getLastError());
        hlp.showToastError(
            "${AppLocalizationHelper.of(context).translate('NetworkErrorNote')}");
      }
      setState(() {
        _isInAsyncCall = false;
      });
    } else {
      // not passed the validation check
      // hlp.showToastError("Please finish the inputs before confirm.");
    }
  }
}
