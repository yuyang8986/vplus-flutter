import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/formValidationHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/permissionHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/apiUser.dart';
import 'package:vplus_merchant_app/providers/currentuser_provider.dart';
import 'package:vplus_merchant_app/styles/font.dart';
import 'package:vplus_merchant_app/styles/regex.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignInPage createState() => _SignInPage();
}

class _SignInPage extends State<SignInPage> {
  // maintains validators and state of form fields
  final GlobalKey<FormState> _signInAdminFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _signInStaffFormKey = GlobalKey<FormState>();

  TextEditingController _usernameCtrl = new TextEditingController();
  TextEditingController _passwordCtrl = new TextEditingController();
  TextEditingController _storeCodeCtrl = new TextEditingController();

  Helper hlp = Helper();
  FormValidateService _formValidateService;

  var _isInAsyncCall = false;
  var _obscureText = true;
  // var _isAdminVisible = true;

  ApiUserRole selectedTab;

  @override
  void initState() {
    selectedTab = ApiUserRole.OrganizationAdmin;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // await PermissionHelper.requestPermission();
    });

    _formValidateService = FormValidateService(context);

    super.initState();
  }

  void _submitAdmin() async {
    if (_signInAdminFormKey.currentState.validate()) {
      _signInAdminFormKey.currentState.save();

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
        "UserName": _usernameCtrl.text,
        "Password": _passwordCtrl.text,
      };

      var response =
          await hlp.postData("api/token/Authenticate", data, context: context);
      if (response.isSuccess && response.data != null) {
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
            "${AppLocalizationHelper.of(context).translate('IncorrectUserNameOrPasswordAlert')}");
      }
      setState(() {
        _isInAsyncCall = false;
      });
    }
  }

  void _submitStaff() async {
    if (_signInStaffFormKey.currentState.validate()) {
      _signInStaffFormKey.currentState.save();

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
        "UserName": _usernameCtrl.text,
        "Password": _passwordCtrl.text,
        "StoreCode": _storeCodeCtrl.text,
      };

      var response =
          await hlp.postData("api/token/Authenticate", data, context: context);
      if (response.data != null && response.isSuccess) {
        ApiUser apiUser = ApiUser.fromJson(response.data);
        Provider.of<CurrentUserProvider>(context, listen: false)
            .setCurrentUser(apiUser);
        Navigator.pushNamed(context, 'HomePage');
        setState(() {
          _isInAsyncCall = false;
        });
        return;
      } else {
        print("errr");
        // hlp.showToastError(hlp.getLastError());
        hlp.showToastError(
            "${AppLocalizationHelper.of(context).translate('IncorrectUserNameOrPasswordAlert')}");
      }
      setState(() {
        _isInAsyncCall = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: 1080, height: 1920, allowFontScaling: false);
    ScreenHelper.lockOrientation(context);

    return SafeArea(
      bottom: false,
      top: true,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar.getAppBar(
            "${AppLocalizationHelper.of(context).translate("Login")}", false,
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
                      margin: EdgeInsets.only(bottom: ScreenUtil().setSp(20)),
                      child: Padding(
                        padding: EdgeInsets.only(top: ScreenUtil().setSp(0)),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(bottom: ScreenUtil().setHeight(120)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setSelectedTab(ApiUserRole.OrganizationAdmin);
                                },
                                child: SizedBox(
                                  width: ScreenUtil().setWidth(200),
                                  child: Container(
                                    child: Text(
                                      '${AppLocalizationHelper.of(context).translate("Admin")}',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.lato(
                                        fontSize: ScreenUtil().setSp(
                                            ScreenHelper.isLargeScreen(context)
                                                ? largeScreenTitleFontSize
                                                : phoneScreenTitleFontSize),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              VEmptyView(10),
                              SizedBox(
                                  width: ScreenUtil().setWidth(150),
                                  height: ScreenUtil().setHeight(12),
                                  child: selectedTab ==
                                          ApiUserRole.OrganizationAdmin
                                      ? ColoredBox(
                                          color: Color(0xff24A56A),
                                        )
                                      : null)
                            ],
                          ),
                          VEmptyView(50),
                          Column(children: [
                            InkWell(
                              onTap: () {
                                setSelectedTab(ApiUserRole.OrganizationStaff);
                              },
                              child: SizedBox(
                                width: ScreenUtil().setWidth(150),
                                child: Container(
                                  child: Text(
                                    "${AppLocalizationHelper.of(context).translate("Staff")}",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(
                                      fontSize: ScreenUtil().setSp(ScreenHelper
                                          .getResponsiveTitleFontSize(context)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            VEmptyView(10),
                            SizedBox(
                                width: ScreenUtil().setWidth(180),
                                height: ScreenUtil().setHeight(12),
                                child:
                                    selectedTab == ApiUserRole.OrganizationStaff
                                        ? ColoredBox(
                                            color: Color(0xff24A56A),
                                          )
                                        : null)
                          ]),
                          VEmptyView(50),
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setSelectedTab(ApiUserRole.StoreKitchen);
                                },
                                child: SizedBox(
                                  width: ScreenUtil().setWidth(200),
                                  child: Container(
                                    child: Text(
                                      '${AppLocalizationHelper.of(context).translate("Kitchen")}',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.lato(
                                        fontSize: ScreenUtil().setSp(
                                            ScreenHelper.isLargeScreen(context)
                                                ? largeScreenTitleFontSize
                                                : phoneScreenTitleFontSize),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              VEmptyView(10),
                              SizedBox(
                                  width: ScreenUtil().setWidth(150),
                                  height: ScreenUtil().setHeight(12),
                                  child: selectedTab == ApiUserRole.StoreKitchen
                                      ? ColoredBox(
                                          color: Color(0xff24A56A),
                                        )
                                      : null)
                            ],
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: selectedTab == ApiUserRole.OrganizationAdmin,
                      child: Column(
                        children: [
                          buildSignInAdminForm(context),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: ScreenUtil().setWidth(580),
                                    height: ScreenUtil().setHeight(130),
                                    child: RaisedButton(
                                      onPressed: _submitAdmin,
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
                                            "${AppLocalizationHelper.of(context).translate('Login')}",
                                            // textAlign: TextAlign.center,
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.bold,
                                              fontSize: ScreenHelper
                                                      .isLandScape(context)
                                                  ? 2 *
                                                      SizeHelper.textMultiplier
                                                  : 3 *
                                                      SizeHelper.textMultiplier,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              VEmptyView(20),
                              Container(
                                alignment: Alignment.center,
                                child: FlatButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, "SignupPage");
                                  },
                                  child: Text(
                                    "${AppLocalizationHelper.of(context).translate('Sign Up')}",
                                    // textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(
                                      fontWeight: FontWeight.bold,
                                      // decoration: TextDecoration.underline,
                                      fontSize:
                                          ScreenHelper.isLandScape(context)
                                              ? 2 * SizeHelper.textMultiplier
                                              : 3 * SizeHelper.textMultiplier,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    // for staff and kitchen acct
                    Visibility(
                      visible: selectedTab != ApiUserRole.OrganizationAdmin,
                      child: Column(
                        children: [
                          buildSignInStaffForm(context),
                          Padding(
                            padding:
                                EdgeInsets.only(top: ScreenUtil().setSp(100)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: ScreenUtil().setWidth(580),
                                      height: ScreenUtil().setHeight(130),
                                      child: RaisedButton(
                                        onPressed: _submitStaff,
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
                                              "${AppLocalizationHelper.of(context).translate('Login')}",
                                              // textAlign: TextAlign.center,
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    ScreenHelper.isLandScape(
                                                            context)
                                                        ? 2 *
                                                            SizeHelper
                                                                .textMultiplier
                                                        : 3 *
                                                            SizeHelper
                                                                .textMultiplier,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                VEmptyView(
                                  10,
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
            ),
          ),
        ),
        //bottomNavigationBar: Footer(),
      ),
    );
  }

  Widget buildSignInAdminForm(BuildContext context) {
    // final TextTheme textTheme = Theme.of(context).textTheme;
    // run the validators on reload to process async results

    return Form(
        key: this._signInAdminFormKey,
        child: Container(
          width: ScreenUtil().setWidth(700),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextFormField(
                style:
                    GoogleFonts.lato(fontSize: 2 * SizeHelper.textMultiplier),
                controller: _usernameCtrl,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
                ],
                textInputAction: TextInputAction.next,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                keyboardType: TextInputType.text,
                validator: FormValidateService(context).validateUserName,
                decoration: CustomTextBox(
                  context: context,
                  mandate: true,
                  hint:
                      "${AppLocalizationHelper.of(context).translate("UserName")}",
                  icon: Icon(
                    FontAwesomeIcons.user,
                    color: Colors.black,
                    size: ScreenHelper.isLandScape(context)
                        ? 2 * SizeHelper.textMultiplier
                        : 3 * SizeHelper.textMultiplier,
                  ),
                ).getTextboxDecoration(),
              ),
              VEmptyView(60),
              TextFormField(
                style: GoogleFonts.lato(
                    fontSize: ScreenUtil().setSp(
                        ScreenHelper.getResponsiveTextFieldFontSize(context))),
                controller: _passwordCtrl,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp("[\\s]")),
                ],
                textInputAction: TextInputAction.send,
                obscureText: _obscureText ? true : false,
                decoration: CustomTextBox(
                  context: context,
                  hint:
                      "${AppLocalizationHelper.of(context).translate("Password")}",
                  icon: Icon(
                    FontAwesomeIcons.lock,
                    color: Colors.yellow[700],
                    size: ScreenHelper.isLandScape(context)
                        ? 2 * SizeHelper.textMultiplier
                        : 3 * SizeHelper.textMultiplier,
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
              //VEmptyView(150)
              // Container(
              //   margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(200)),
              //   alignment: Alignment.topLeft,
              //   child: InkWell(
              //     onTap: () async {
              //       Navigator.pushNamed(context, "resetpassword");
              //     },
              //     child: Column(
              //       children: [
              //         VEmptyView(ScreenUtil().setHeight(90)),
              //         Padding(
              //           padding:
              //               EdgeInsets.only(left: ScreenUtil().setWidth(30)),
              //           child: Text(
              //             'Forgot Password?',
              //             style: TextStyle(
              //               color: Colors.grey,
              //               fontSize: ScreenUtil().setSp(26),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // add another padding to fix the login button position between tabs
              VEmptyView(50),
            ],
          ),
        ));
  }

  Widget buildSignInStaffForm(BuildContext context) {
    // final TextTheme textTheme = Theme.of(context).textTheme;
    // run the validators on reload to process async results

    return Form(
      key: this._signInStaffFormKey,
      child: Container(
        width: ScreenUtil().setWidth(700),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextFormField(
              style: GoogleFonts.lato(
                  fontSize: ScreenUtil().setSp(
                      ScreenHelper.getResponsiveTextFieldFontSize(context))),
              controller: _storeCodeCtrl,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp("\\s")),
              ],
              textInputAction: TextInputAction.next,
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
              keyboardType: TextInputType.text,
              validator: FormValidateService(context).validateStoreCode,
              decoration: CustomTextBox(
                context: context,
                mandate: true,
                hint:
                    "${AppLocalizationHelper.of(context).translate('StoreCode')}",
                icon: Icon(FontAwesomeIcons.store,
                    color: Colors.black,
                    size: ScreenHelper.isLandScape(context)
                        ? 2 * SizeHelper.textMultiplier
                        : 3 * SizeHelper.imageSizeMultiplier),
              ).getTextboxDecoration(),
            ),
            VEmptyView(30),
            TextFormField(
              style: GoogleFonts.lato(
                  fontSize: ScreenUtil().setSp(
                      ScreenHelper.getResponsiveTextFieldFontSize(context))),
              controller: _usernameCtrl,
              textInputAction: TextInputAction.next,
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp("\\s")),
              ],
              //validator: FormValidateService().validateUserName,
              decoration: CustomTextBox(
                context: context,
                mandate: true,
                hint:
                    "${AppLocalizationHelper.of(context).translate('UserName')}",
                icon: Icon(
                  FontAwesomeIcons.user,
                  color: Colors.black,
                  size: ScreenHelper.isLandScape(context)
                      ? 2 * SizeHelper.textMultiplier
                      : 3 * SizeHelper.imageSizeMultiplier,
                ),
              ).getTextboxDecoration(),
            ),
            VEmptyView(
              30,
            ),
            TextFormField(
              style: GoogleFonts.lato(
                  fontSize: ScreenUtil().setSp(
                      ScreenHelper.getResponsiveTextFieldFontSize(context))),
              controller: _passwordCtrl,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp("\\s")),
              ],
              key: Key('password'),
              textInputAction: TextInputAction.next,
              onEditingComplete: () {
                FocusScope.of(context).nextFocus();
              },
              obscureText: _obscureText ? true : false,
              decoration: CustomTextBox(
                context: context,
                hint:
                    "${AppLocalizationHelper.of(context).translate('Password')}",
                icon: Icon(FontAwesomeIcons.lock,
                    color: Colors.yellow[700],
                    size: ScreenHelper.isLandScape(context)
                        ? 2 * SizeHelper.textMultiplier
                        : 3 * SizeHelper.imageSizeMultiplier),
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
            // VEmptyView(
            //   10,
            //),
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

  setSelectedTab(ApiUserRole role) {
    setState(() {
      selectedTab = role;
    });
  }
}
