import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/models/apiUser.dart';
import 'package:vplus_merchant_app/providers/currentuser_provider.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:vplus_merchant_app/helpers/formValidationHelper.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class EmailVerify extends StatefulWidget {
  @override
  _EmailVerifyState createState() => _EmailVerifyState();
}

class _EmailVerifyState extends State<EmailVerify> {
  ApiUser user;
  final verifyFormKey = GlobalKey<FormState>();
  StreamController<ErrorAnimationType> errorController;
  TextEditingController verifyCodeController = TextEditingController();
  FormValidateService _formValidateService;
  Helper hlp = new Helper();
  bool _isInAsyncCall = false;

  @override
  void initState() {
    _formValidateService = FormValidateService(context);
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser;

    return SafeArea(
      bottom: false,
      top: true,
      child: Scaffold(
        appBar: CustomAppBar.getAppBar(
            "${AppLocalizationHelper.of(context).translate('OrganizationProfilePageTitle')}",
            false,
            context: context,
            showLogo: false),
        resizeToAvoidBottomInset: true,
        body: ModalProgressHUD(
          child: SingleChildScrollView(
            child: buildVerifyForm(context),
          ),
          inAsyncCall: _isInAsyncCall,
          // demo of some additional parameters
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
        ),
      ),
    );
  }

  buildVerifyForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setSp(100)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          VEmptyView(20),
          Container(
            constraints: BoxConstraints(minHeight: ScreenUtil().setHeight(140)),
            child: Text(
              "${AppLocalizationHelper.of(context).translate('EmailVerification')}",
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil().setSp(60),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setHeight(40)),
            child: Container(
              constraints:
                  BoxConstraints(minHeight: ScreenUtil().setHeight(140)),
              child: TextFormField(
                textAlign: TextAlign.center,
                initialValue: user.organization.organizationName,
                enabled: false,
                decoration: CustomTextBox(
                  context: context,
                  isEditable: false,
                ).getTextboxDecoration(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setHeight(40)),
            child: Container(
              constraints:
                  BoxConstraints(minHeight: ScreenUtil().setHeight(140)),
              child: TextFormField(
                textAlign: TextAlign.center,
                initialValue: user.email,
                enabled: false,
                decoration: CustomTextBox(
                  context: context,
                  isEditable: false,
                ).getTextboxDecoration(),
              ),
            ),
          ),
          VEmptyView(20),
          Form(
            key: verifyFormKey,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                child: PinCodeTextField(
                  appContext: context,
                  pastedTextStyle: GoogleFonts.lato(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                  length: 6,
                  obscureText: false,
                  obscuringCharacter: '*',
                  autoFocus: true,
                  animationType: AnimationType.fade,
                  validator: _formValidateService.validateEmailVerificationCode,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: ScreenUtil().setWidth(100),
                    fieldWidth: ScreenUtil().setWidth(100),
                    inactiveFillColor: Colors.white,
                    inactiveColor: Colors.grey,
                  ),
                  cursorColor: Colors.black,
                  //animationDuration: Duration(milliseconds: 300),
                  textStyle: GoogleFonts.lato(fontSize: ScreenUtil().setSp(70)),
                  backgroundColor: Color(0xFFfafafa),
                  enableActiveFill: true,
                  errorAnimationController: errorController,
                  controller: verifyCodeController,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                  ],
                  boxShadows: [
                    BoxShadow(
                      offset: Offset(0, 1),
                      color: Colors.black12,
                      blurRadius: 10,
                    )
                  ],
                  onCompleted: callVerifyEmailCodeAPI,
                  // onTap: () {},
                  onChanged: (value) {},
                  beforeTextPaste: (text) {
                    print("Allowing to paste $text");
                    //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                    //but you can show anything you want here, like your pop up saying wrong paste format or etc
                    return true;
                  },
                )),
          ),
          InkWell(
            child: Text(
              "${AppLocalizationHelper.of(context).translate('ResendCode')}",
              style: GoogleFonts.lato(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              _resendCode(context);
            },
          ),
          VEmptyView(200),
          Container(
            width: ScreenUtil().setWidth(350),
            height: ScreenUtil().setHeight(96),
            child: RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              textColor: Colors.white,
              color: Color.fromRGBO(150, 159, 170, 1),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${AppLocalizationHelper.of(context).translate('Cancel')}',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  callVerifyEmailCodeAPI(String value) async {
    print('///////////////////// call web api check if the code correct');

    setState(() {
      _isInAsyncCall = true;
    });

    var response = await hlp.postData(
        "api/Token/confirmemail?email=" + user.email + "&code=" + value, null,
        context: context);

    if (response.isSuccess) {
      print('Verify successfully');
      user.isEmailVerified = true;
      Provider.of<CurrentUserProvider>(context, listen: false)
          .setCurrentUser(user);
      setState(() {
        _isInAsyncCall = false;
      });
      Navigator.of(context).pop(true);
    } else {
      print('Verify fail');
      setState(() {
        _isInAsyncCall = false;
      });
      AlertMessageDialog(
        title:
            "${AppLocalizationHelper.of(context).translate('EmailVerficationFailedTitle')}",
        content:
            "${AppLocalizationHelper.of(context).translate('EmailVerficationFailedContent')}",
        buttonTitle:
            "${AppLocalizationHelper.of(context).translate('Confirm')}",
        buttonEvent: _alertOKEvent,
        context: context,
      ).showAlert();
    }
  }

  Future<void> _resendCode(BuildContext context) async {
    setState(() {
      _isInAsyncCall = true;
    });
    ////////////call api to send verification code
    var response = await hlp.getData(
        "api/Token/confirmemail?email=" + user.email,
        context: context,
        hasAuth: false);

    if (response.data != null && response.isSuccess) {
      setState(() {
        _isInAsyncCall = false;
      });

      AlertMessageDialog(
        content:
            "${AppLocalizationHelper.of(context).translate('EmailVerficationAlreadySendConent')}",
        buttonTitle:
            "${AppLocalizationHelper.of(context).translate('Confirm')}",
        buttonEvent: () {
          Navigator.of(context).pop(true);
        },
        context: context,
      ).showAlert();
    } else {
      print("errr");
      // hlp.showToastError(hlp.getLastError());
      hlp.showToastError(
          "${AppLocalizationHelper.of(context).translate('NetworkErrorNote')}.");
    }
    setState(() {
      _isInAsyncCall = false;
    });
  }

  _alertOKEvent() {
    Navigator.of(context).pop(true);
    verifyCodeController.text = '';
  }
}
