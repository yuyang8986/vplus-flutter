import 'package:flutter/material.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/store.dart';
import 'package:vplus_merchant_app/widgets/business_type_select.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vplus_merchant_app/helpers/formValidationHelper.dart';
import 'package:vplus_merchant_app/widgets/address_search.dart';
import 'package:vplus_merchant_app/widgets/background_color_select.dart';
import 'package:vplus_merchant_app/models/storeBusinessType.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vplus_merchant_app/widgets/pic_selection.dart';

class StoreProfile extends StatefulWidget {
  @override
  _StoreProfileState createState() => _StoreProfileState();
}

class _StoreProfileState extends State<StoreProfile> {
  bool _isInAsyncCall = false;
  final GlobalKey<FormState> _storeProfileKey = GlobalKey<FormState>();
  TextEditingController _storeNameCtrl = new TextEditingController();
  TextEditingController _storePhoneCtrl = new TextEditingController();
  TextEditingController _storeEmailCtrl = new TextEditingController();
  TextEditingController _storeStoreCodeCtrl = new TextEditingController();

  String storeAddress;
  List<StoreBusinessType> businessTypes;
  List<int> businessTypeIds;
  String backgroundColor;
  String image64; //base64
  String storeCoord;

  Helper hlp = Helper();
  Store store;

  @override
  void initState() {
    store = Provider.of<CurrentStoresProvider>(context, listen: false)
        .getSelectedStore;
    _storeNameCtrl.text = store.storeName;
    _storePhoneCtrl.text = store.phone;
    _storeEmailCtrl.text = store.email;
    _storeStoreCodeCtrl.text = store.storeCode;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: true,
      child: Scaffold(
        appBar: CustomAppBar.getAppBar(
          "${AppLocalizationHelper.of(context).translate('StoreProfile')}",
          false,
          context: context,
          showLogo: false,
        ),
        resizeToAvoidBottomInset: true,
        body: ModalProgressHUD(
          child: SingleChildScrollView(
            child: Container(
              height: ScreenUtil().setHeight(2400),
              child: buildStoreProfileForm(context),
            ),
          ),
          inAsyncCall: _isInAsyncCall,
          // demo of some additional parameters
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
        ),
        //bottomNavigationBar: Footer(),
      ),
    );
  }

  Widget buildStoreProfileForm(BuildContext context) {
    return Form(
      key: _storeProfileKey,
      child: Padding(
        padding: EdgeInsets.only(
            left: ScreenUtil().setSp(100), right: ScreenUtil().setSp(100)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            VEmptyView(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: BackgroundColorSelection(
                    (v) {
                      setState(() {
                        backgroundColor = v;
                      });
                    },
                    initColorHex: store.backgroundColorHex,
                  ),
                ),
                Expanded(
                  child: PicSelection(
                    (v) {
                      setState(() {
                        image64 = v;
                      });
                    },
                    componentHeight: ScreenUtil()
                        .setSp(ScreenHelper.isLargeScreen(context) ? 380 : 380),
                    isComponentBorder: false,
                    picFlex: 2,
                    isChildCirclePic: true,
                    childHeight: ScreenHelper.isLandScape(context) ? 380 : 180,
                    childWidth: ScreenHelper.isLandScape(context) ? 380 : 180,
                    child: store.logoUrl == null
                        ? CircleAvatar(
                            child: Text(
                              store.storeName.substring(0, 1),
                              style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: ScreenUtil().setSp(100)),
                            ),
                            backgroundColor: Color(
                                int.tryParse(store.backgroundColorHex) ??
                                    Colors.grey.value),
                          )
                        : CircleAvatar(
                            backgroundImage: NetworkImage(store.logoUrl),
                            backgroundColor: Color(
                                int.tryParse(store.backgroundColorHex) ??
                                    Colors.grey.value),
                          ),
                  ),
                ),
              ],
            ),
            VEmptyView(40),
            TextFieldRow(
              textController: _storeNameCtrl,
              textGlobalKey: 'Store Name',
              context: context,
              isMandate: true,
              hintText:
                  "${AppLocalizationHelper.of(context).translate('StoreName')}",
              icon: Icon(
                FontAwesomeIcons.building,
                color: Colors.blue,
                size: ScreenUtil().setSp(40),
              ),
              textValidator: FormValidateService(context).validateStoreName,
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
            ).textFieldRow(),
            VEmptyView(40),
            TextFieldRow(
              textController: _storeStoreCodeCtrl,
              isReadOnly: true,
              textGlobalKey: 'Store Code',
              context: context,
              isMandate: true,
              hintText:
                  "${AppLocalizationHelper.of(context).translate('StoreCode')}",
              icon: Icon(
                FontAwesomeIcons.home,
                color: Colors.purple,
                size: ScreenUtil().setSp(40),
              ),
              textValidator: FormValidateService(context).validateStoreName,
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
            ).textFieldRow(),
            VEmptyView(40),
            AddressSearch(
              (addr, coord) {
                setState(() {
                  storeAddress = addr;
                  storeCoord = coord;
                });
              },
              initValue: store.location,
            ),
            VEmptyView(40),
            BusinessTypeSelection(
              (v) {
                setState(() {
                  businessTypes = v;
                  // get all of the ids from StoreBusinessType list
                  businessTypeIds = [];
                  for (StoreBusinessType type in businessTypes) {
                    businessTypeIds.add(type.storeBusinessCatTypeId);
                  }
                });
              },
              // parentBusType: store.parentCategory,
              initSubBusTypeList: store.storeBusinessCategories,
            ),
            VEmptyView(40),
            TextFieldRow(
              textController: _storePhoneCtrl,
              isReadOnly: false,
              textGlobalKey: 'Store Phone',
              context: context,
              isMandate: false,
              hintText:
                  "${AppLocalizationHelper.of(context).translate('Mobile')}",
              keyboardType: TextInputType.number,
              icon: Icon(
                FontAwesomeIcons.mobileAlt,
                color: Colors.black,
                size: ScreenUtil().setSp(40),
              ),
              textValidator: FormValidateService(context).validateMobile,
            ).textFieldRow(),
            VEmptyView(40),
            TextFieldRow(
              textController: _storeEmailCtrl,
              isReadOnly: false,
              textGlobalKey: 'Store Email',
              context: context,
              isMandate: true,
              keyboardType: TextInputType.emailAddress,
              hintText:
                  "${AppLocalizationHelper.of(context).translate('EmailAddress')}",
              icon: Icon(
                FontAwesomeIcons.envelope,
                color: Colors.purple,
                size: ScreenUtil().setSp(40),
              ),
              textValidator: FormValidateService(context).validateEmail,
            ).textFieldRow(),
            VEmptyView(60),
            Container(
              width: double.infinity,
              height: ScreenUtil()
                  .setHeight(ScreenHelper.isLargeScreen(context) ? 150 : 100),
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
                      '${AppLocalizationHelper.of(context).translate('Confirm')}',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenHelper.isLandScape(context)
                            ? 2 * SizeHelper.textMultiplier
                            : 2 * SizeHelper.textMultiplier,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (storeAddress == null || storeAddress == ' ') {
      // keep the address, do not update
      storeAddress = store.location;
    }
    if (_storeProfileKey.currentState.validate()) {
      _storeProfileKey.currentState.save();

      // dismiss keyboard during async call
      FocusScope.of(context).requestFocus(new FocusNode());

      // start the modal progress HUD
      setState(() {
        _isInAsyncCall = true;
      });
      ////////////call api to update
      bool updateStoreProfile = await callAPIUpdateStoreProfile();
      if (!updateStoreProfile) {
        // hlp.showToastError(hlp.getLastError());
        hlp.showToastError(
            "${AppLocalizationHelper.of(context).translate('NetworkErrorNote')}");
        setState(() {
          _isInAsyncCall = true;
        });
        return;
      }

      await Provider.of<CurrentStoresProvider>(context, listen: false)
          .getStoreFromAPI(context);
      Navigator.of(context).pop();
      setState(() {
        _isInAsyncCall = true;
      });
    }
  }

  Future<bool> callAPIUpdateStoreProfile() async {
    Map<String, dynamic> dataUpdateStoreProfile = {
      "storeId": store.storeId,
      "storeName": _storeNameCtrl.text,
      "logo": image64,
      "backgroundColorHex":
          backgroundColor == null ? store.backgroundColorHex : backgroundColor,
      "location": storeAddress,
      "coordinates": storeCoord,
      "phone": _storePhoneCtrl.text,
      "email": _storeEmailCtrl.text,
      // "storeBusinessCatIds": businessTypeIds == null
      //     ? store.storeBusinessCatIds
      //     : businessTypeIds, //store.storeBusinessCatIds
      "storeBusinessCatIds": businessTypeIds ?? [2],
    };
    var response = await hlp.putData(
        "api/stores/" + store.storeId.toString(), dataUpdateStoreProfile,
        hasAuth: true, context: context);

    return response.isSuccess;
  }
}
