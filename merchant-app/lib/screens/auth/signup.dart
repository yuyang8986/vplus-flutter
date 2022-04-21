import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/formValidationHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/apiUser.dart';
import 'package:vplus_merchant_app/providers/currentuser_provider.dart';
import 'package:vplus_merchant_app/styles/font.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPage createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  // maintains validators and state of form fields
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();

  // manage state of modal progress HUD widget
  bool _isInAsyncCall = false;
  bool _passwordObscureText = true;
  bool _obscureText = true;

  TextEditingController _orgNameCtrl = new TextEditingController();
  TextEditingController _addressCtrl = new TextEditingController();
  TextEditingController _userNameCtrl = new TextEditingController();
  TextEditingController _emailCtrl = new TextEditingController();
  TextEditingController _passwordCtrl = new TextEditingController();

  FormValidateService _formValidateService;

  void _showOrHidePassword() {
    setState(() {
      _passwordObscureText = !_passwordObscureText;
    });
  }

  //bool _isSignIn = false;

  void _submit() async {
    if (_signUpFormKey.currentState.validate()) {
      _signUpFormKey.currentState.save();

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
        "Email": _emailCtrl.text,
        "Password": _passwordCtrl.text,
        "OrganizationName": _orgNameCtrl.text,
        "Address": _addressCtrl.text,
        "UserName": _userNameCtrl.text
      };

      var response = await hlp.postData(
          "api/token/registration-organization-admin", data,
          context: context);

      if (response.data != null && response.isSuccess) {
        ApiUser apiUser = ApiUser.fromJson(response.data);

        Provider.of<CurrentUserProvider>(context, listen: false)
            .setCurrentUser(apiUser);
        Navigator.pushNamed(context, 'StoreList');
        setState(() {
          _isInAsyncCall = false;
        });
        return;
      } else {
        print("errr");
        // hlp.showToastError(hlp.getLastError());
        hlp.showToastError(
            "${AppLocalizationHelper.of(context).translate('NetworkErrorNote')}");
      }
      setState(() {
        _isInAsyncCall = false;
      });
    }
  }

  @override
  void initState() {
    _formValidateService = FormValidateService(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: true,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar.getAppBar(
            AppLocalizationHelper.of(context).translate("Sign Up"), false,
            context: context),
        body: ModalProgressHUD(
          child: SingleChildScrollView(
            child: Container(
              // height: ScreenUtil().setHeight(1700),
              child: buildSignUpForm(context),
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

  Widget buildSignUpForm(BuildContext context) {
    // final TextTheme textTheme = Theme.of(context).textTheme;
    // run the validators on reload to process async results
    _signUpFormKey.currentState?.validate();
    return Form(
      key: this._signUpFormKey,
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setSp(70)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // VEmptyView(20),
            Container(
              constraints:
                  BoxConstraints(minHeight: ScreenUtil().setHeight(140)),
              child: TextFormField(
                controller: _orgNameCtrl,
                textAlignVertical: TextAlignVertical.center,
                key: Key('organizationName'),
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  FocusScope.of(context).nextFocus();
                },
                decoration: CustomTextBox(
                  context: context,
                  mandate: true,
                  hint: AppLocalizationHelper.of(context)
                      .translate("OrganizationName"),
                  icon: Icon(
                    FontAwesomeIcons.building,
                    color: Colors.blue,
                    size: ScreenHelper.isLandScape(context)
                            ? customTextBoxIconSizeL
                            : customTextBoxIconSizeP,
                  ),
                ).getTextboxDecoration(),
                validator: _formValidateService.validateOrgName,
              ),
            ),
            VEmptyView(10),
            Container(
              constraints:
                  BoxConstraints(minHeight: ScreenUtil().setHeight(140)),
              child: TextFormField(
                controller: _addressCtrl,
                key: Key('orgAddress'),
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  FocusScope.of(context).nextFocus();
                },
                decoration: CustomTextBox(
                  context: context,
                  mandate: true,
                  hint: AppLocalizationHelper.of(context).translate("Address"),
                  icon: Icon(
                    FontAwesomeIcons.home,
                    color: Colors.purple,
                    size: ScreenHelper.isLandScape(context)
                            ? customTextBoxIconSizeL
                            : customTextBoxIconSizeP,
                  ),
                ).getTextboxDecoration(),
                validator: _formValidateService.validateOrgAddress,
              ),
            ),
            VEmptyView(10),

            Container(
              constraints:
                  BoxConstraints(minHeight: ScreenUtil().setHeight(140)),
              child: TextFormField(
                controller: _userNameCtrl,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
                ],
                key: Key('username'),
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  FocusScope.of(context).nextFocus();
                },
                decoration: CustomTextBox(
                  context: context,
                  mandate: true,
                  hint: AppLocalizationHelper.of(context).translate("UserName"),
                  icon: Icon(
                    FontAwesomeIcons.user,
                    color: Colors.black,
                    size: ScreenHelper.isLandScape(context)
                            ? customTextBoxIconSizeL
                            : customTextBoxIconSizeP,
                  ),
                ).getTextboxDecoration(),
                validator: _formValidateService.validateUserName,
              ),
            ),
            VEmptyView(10),

            Container(
              constraints:
                  BoxConstraints(minHeight: ScreenUtil().setHeight(140)),
              child: TextFormField(
                controller: _emailCtrl,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp("[\\s]")),
                ],
                key: Key('email'),
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  FocusScope.of(context).nextFocus();
                },
                decoration: CustomTextBox(
                  context: context,
                  hint: AppLocalizationHelper.of(context)
                      .translate("EmailAddress"),
                  icon: Icon(
                    FontAwesomeIcons.envelope,
                    color: Colors.blueGrey,
                    size: ScreenHelper.isLandScape(context)
                            ? customTextBoxIconSizeL
                            : customTextBoxIconSizeP,
                  ),
                ).getTextboxDecoration(),
                validator: _formValidateService.validateEmail,
              ),
            ),
            VEmptyView(10),

            Container(
              constraints:
                  BoxConstraints(minHeight: ScreenUtil().setHeight(140)),
              child: Column(
                children: [
                  TextFormField(
                    controller: _passwordCtrl,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp("[\\s]")),
                    ],
                    key: Key('password'),
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () {
                      FocusScope.of(context).nextFocus();
                    },
                    obscureText: _obscureText ? true : false,
                    decoration: CustomTextBox(
                      context: context,
                      hint: AppLocalizationHelper.of(context)
                          .translate("Password"),
                      icon: Icon(
                        FontAwesomeIcons.lock,
                        color: Colors.yellow[700],
                        size: ScreenHelper.isLandScape(context)
                            ? customTextBoxIconSizeL
                            : customTextBoxIconSizeP,
                      ),
                      mandate: true,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: _togglePasswordStatus,
                        color: Colors.black,
                      ),
                    ).getTextboxDecoration(),
                    validator: _formValidateService.validatePassword,
                  ),
                  VEmptyView(10),
                  Text(
                      AppLocalizationHelper.of(context)
                          .translate("PasswordInvalidLengthNote"),
                      style: GoogleFonts.lato(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            VEmptyView(ScreenHelper.isLandScape(context)
                ? SizeHelper.widthMultiplier * 5
                : 300),
            Container(
              width: ScreenUtil().setWidth(800),
              // height: ScreenUtil().setHeight(9),
              child: RaisedButton(
                onPressed: _submit,
                textColor: Colors.white,
                color: Color(0xff5352ec),
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizationHelper.of(context).translate("Confirm"),
                      // textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: ScreenHelper.isLandScape(context)
                            ? largeVplusButtonTextSizeL
                            : largeVplusButtonTextSizeP,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: FlatButton(
                onPressed: () {
                  Navigator.pushNamed(context, "SignInPage");
                },
                child: Text(
                  AppLocalizationHelper.of(context).translate("Back"),
                  // textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    // decoration: TextDecoration.underline,
                    fontSize: ScreenHelper.isLandScape(context)
                        ? SizeHelper.textMultiplier * 3
                        : SizeHelper.imageSizeMultiplier * 3,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
