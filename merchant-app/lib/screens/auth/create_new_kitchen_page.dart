import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/formValidationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/store.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateNewKitchenPage extends StatefulWidget {
  CreateNewKitchenPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CreateNewKitchenPage createState() => _CreateNewKitchenPage();
}

class _CreateNewKitchenPage extends State<CreateNewKitchenPage> {
  // maintains validators and state of form fields
  final GlobalKey<FormState> _createNewKitchenFormKey = GlobalKey<FormState>();

  TextEditingController _usernameCtrl = new TextEditingController();
  TextEditingController _passwordCtrl = new TextEditingController();

  Helper hlp = Helper();
  FormValidateService _formValidateService;

  var _isInAsyncCall = false;
  var _obscureText = true;

  int storeId;

  void _submitKitchen() async {
    if (_createNewKitchenFormKey.currentState.validate()) {
      if (!(_usernameCtrl.text.split('').contains(" ") ||
          _passwordCtrl.text.split('').contains(" "))) {
        if ((_usernameCtrl.text.length >= 2 &&
            _usernameCtrl.text.length <= 25 &&
            _passwordCtrl.text.length >= 6 &&
            _passwordCtrl.text.length <= 25)) {
          _createNewKitchenFormKey.currentState.save();

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
            "StoreKitchenName": _usernameCtrl.text,
            "password": _passwordCtrl.text,
            "storeId": storeId,
          };

          var response = await hlp.postData(
              "api/Token/registration-store-kitchen", data,
              hasAuth: true, context: context);
          if (response.isSuccess && response.data != null) {
            setState(() {
              _isInAsyncCall = false;
            });
            hlp.showToastSuccess(
                "${AppLocalizationHelper.of(context).translate('SuccessfulCreateKitchenAlert')}");
            // update latest store data
            Store updatedStore =
                await Provider.of<CurrentStoresProvider>(context, listen: false)
                    .getSingleStoreById(context, storeId);
            Provider.of<CurrentStoresProvider>(context, listen: false)
                .setUpdatedStore(updatedStore);

            Navigator.of(context).pop();
            return;
          } else {
            print("errr");
            // hlp.showToastError(hlp.getLastError());
            hlp.showToastError(
                "${AppLocalizationHelper.of(context).translate('FailedToCreateKitchenAlert')}");
            setState(() {
              _isInAsyncCall = false;
            });
          }
        } else {
          Helper().showToastError(
              '${AppLocalizationHelper.of(context).translate('InvalidUserNamePasswordWhenCreateKitchen')}');
        }
      } else {
        Helper().showToastError(
            '${AppLocalizationHelper.of(context).translate('InvalidInputContainWhiteSpaceAlert')}');
      }
    }
  }

  @override
  void initState() {
    _formValidateService = FormValidateService(context);
    storeId = Provider.of<CurrentStoresProvider>(context, listen: false)
        .getSelectedStore
        .storeId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: true,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar.getAppBar(
            "${AppLocalizationHelper.of(context).translate('ManageKitchen')}",
            false,
            showLogo: false,
            context: context),
        body: ModalProgressHUD(
          inAsyncCall: _isInAsyncCall,
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
          child: Container(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: ScreenUtil().setSp(40)),
                      child: Padding(
                        padding: EdgeInsets.only(top: ScreenUtil().setSp(20)),
                        child: Text(
                          '${AppLocalizationHelper.of(context).translate('CreateKitchenAccount')}',
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(
                                ScreenHelper.getResponsiveTitleFontSize(
                                    context)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(bottom: ScreenUtil().setHeight(100)),
                      child: Column(
                        children: [
                          signupKitchenForm(context),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: ScreenUtil().setWidth(580),
                                    height: ScreenUtil().setHeight(120),
                                    child: RaisedButton(
                                      onPressed: _submitKitchen,
                                      textColor: Colors.white,
                                      color: Color(0xff5352ec),
                                      // padding: const EdgeInsets.symmetric(
                                      // vertical: 5, horizontal: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${AppLocalizationHelper.of(context).translate('Confirm')}',
                                            // textAlign: TextAlign.center,
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.bold,
                                              fontSize: ScreenHelper
                                                      .isLandScape(context)
                                                  ? 27
                                                  : SizeHelper.textMultiplier *
                                                      3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        //bottomNavigationBar: Footer(),
      ),
    );
  }

  Widget signupKitchenForm(BuildContext context) {
    // final TextTheme textTheme = Theme.of(context).textTheme;
    // run the validators on reload to process async results

    return Form(
        key: this._createNewKitchenFormKey,
        child: Container(
          width: ScreenUtil().setWidth(800),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextFormField(
                controller: _usernameCtrl,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
                ],
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                keyboardType: TextInputType.text,
                //validator: FormValidateService().validateUserName,
                decoration: CustomTextBox(
                  context: context,
                  mandate: true,
                  hint:
                      '${AppLocalizationHelper.of(context).translate('UserName')}',
                  icon: Icon(
                    FontAwesomeIcons.user,
                    color: Colors.black,
                    size: ScreenUtil().setSp(30),
                  ),
                ).getTextboxDecoration(),
              ),
              VEmptyView(100),
              TextFormField(
                controller: _passwordCtrl,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp("\\s")),
                ],
                textInputAction: TextInputAction.send,
                obscureText: _obscureText ? true : false,
                decoration: CustomTextBox(
                  context: context,
                  hint:
                      "${AppLocalizationHelper.of(context).translate('Password')}",
                  icon: Icon(
                    FontAwesomeIcons.lock,
                    color: Colors.yellow[700],
                    size: ScreenUtil().setSp(30),
                  ),
                  mandate: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordStatus,
                    color: Colors.black,
                  ),
                ).getTextboxDecoration(),
                validator: _formValidateService.validatePassword,
              ),
              VEmptyView(40),
            ],
          ),
        ));
  }

  _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
