import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/formValidationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/models/apiUser.dart';
import 'package:vplus_merchant_app/providers/currentuser_provider.dart';
import 'package:vplus_merchant_app/screens/profile/emailVerify.dart';
import 'package:vplus_merchant_app/styles/regex.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';

class ProfilePage extends StatefulWidget {
  @override
  createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final GlobalKey<FormState> _orgProfileFormKey = GlobalKey<FormState>();

  // manage state of modal progress HUD widget
  bool _isInAsyncCall = false;

  TextEditingController _orgNameCtrl = new TextEditingController();
  TextEditingController _addressCtrl = new TextEditingController();
  TextEditingController _userNameCtrl = new TextEditingController();
  TextEditingController _emailCtrl = new TextEditingController();
  TextEditingController _mobileCtrl = new TextEditingController();

  FormValidateService _formValidateService;

  Helper hlp = Helper();
  ApiUser oldUser;
  ApiUser tempUser;
  bool _isEmailEditable = true;
  bool _isOrgNameEditable = false;
  bool _isAddressEditable = false;
  bool _isMobileEditable = false;
  // FocusNode emailFocusNode;
  // FocusNode mobileFocusNode;
  bool _isSaveButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _formValidateService = FormValidateService(context);
    // emailFocusNode = FocusNode();
    // mobileFocusNode = FocusNode();
    oldUser = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser;
    tempUser = ApiUser.fromJson(oldUser.toJson());
    _orgNameCtrl.text = tempUser.organization != null
        ? tempUser.organization.organizationName
        : '';
    _addressCtrl.text = tempUser.address != null ? tempUser.address : '';
    _userNameCtrl.text = tempUser.username != null ? tempUser.username : '';
    _mobileCtrl.text = tempUser.mobile != null ? tempUser.mobile : '';
    _emailCtrl.text = tempUser.email != null ? tempUser.email : '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    // emailFocusNode.dispose();
    // mobileFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // oldUser = Provider.of<CurrentUserProvider>(context, listen: false)
    //     .getloggedInUser;
    // tempUser = ApiUser.fromJson(oldUser.toJson());
    return SafeArea(
      bottom: false,
      top: true,
      child: Scaffold(
        appBar: CustomAppBar.getAppBar(
          AppLocalizationHelper.of(context)
              .translate('OrganizationProfilePageTitle')
              .toString(),
          false,
          context: context,
          showLogo: false,
        ),
        resizeToAvoidBottomInset: true,
        body: ModalProgressHUD(
          child: SingleChildScrollView(
            child: Container(
              // height: ScreenUtil().setHeight(2400),
              child: buildOrgProfileForm(context),
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

  Widget buildOrgProfileForm(BuildContext context) {
    return Form(
      key: this._orgProfileFormKey,
      child: Padding(
        padding: EdgeInsets.only(
            bottom: ScreenUtil().setSp(120),
            top: ScreenUtil().setSp(80),
            left: ScreenUtil().setSp(120),
            right: ScreenUtil().setSp(120)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            VEmptyView(10),
            TextFieldRow(
              isReadOnly: _isOrgNameEditable,
              textController: _orgNameCtrl,
              inputFormatters: [
                FilteringTextInputFormatter.deny(
                    RegExp(spceialCharactersAllowWhiteSpace)),
              ],
              textGlobalKey: 'organizationName',
              context: context,
              isMandate: true,
              hintText: AppLocalizationHelper.of(context)
                  .translate('OrganizationName'),
              icon: Icon(
                FontAwesomeIcons.building,
                color: Colors.blue,
                size: ScreenUtil().setSp(
                    ScreenHelper.getResponsiveTextFieldFontSize(context)),
              ),
              textValidator: _formValidateService.validateOrgName,
              onChanged: (value) {
                tempUser.organization.organizationName = value;
                tempUser.name = value;
              },
            ).textFieldRow(),
            VEmptyView(40),
            TextFieldRow(
                isReadOnly: _isAddressEditable,
                textController: _addressCtrl,
                textGlobalKey: 'orgAddress',
                context: context,
                isMandate: true,
                // onEditingComplete: () => mobileFocusNode.requestFocus(),
                hintText:
                    AppLocalizationHelper.of(context).translate('Address'),
                icon: Icon(
                  FontAwesomeIcons.home,
                  color: Colors.purple,
                  size: ScreenUtil().setSp(
                      ScreenHelper.getResponsiveTextFieldFontSize(context)),
                ),
                textValidator: _formValidateService.validateOrgAddress,
                onChanged: (value) {
                  tempUser.address = value;
                  tempUser.organization.location = value;
                }).textFieldRow(),
            VEmptyView(40),

            TextFieldRow(
              isReadOnly: true,
              textController: _userNameCtrl,
              textGlobalKey: 'username',
              context: context,
              hintText: AppLocalizationHelper.of(context).translate('UserName'),
              icon: Icon(
                FontAwesomeIcons.user,
                color: Colors.black,
                size: ScreenUtil().setSp(
                    ScreenHelper.getResponsiveTextFieldFontSize(context)),
              ),
              textValidator: _formValidateService.validateUserName,
            ).textFieldRow(),
            VEmptyView(40),

            TextFieldRow(
              isMandate: false,
              isReadOnly: _isMobileEditable,
              textController: _mobileCtrl,
              textGlobalKey: 'mobile',
              context: context,
              // focusNode: mobileFocusNode,
              keyboardType: TextInputType.phone,
              hintText: AppLocalizationHelper.of(context).translate('Mobile'),
              icon: Icon(
                FontAwesomeIcons.mobileAlt,
                color: Colors.blueGrey,
                size: ScreenUtil().setSp(
                    ScreenHelper.getResponsiveTextFieldFontSize(context)),
              ),
              textValidator: _formValidateService.validateOrgMobile,
              onChanged: (value) {
                tempUser.mobile = value;
                tempUser.organization.phone = value;
              },
            ).textFieldRow(),
            VEmptyView(40),

            Column(
              children: [
                TextFieldRow(
                  isReadOnly: _isEmailEditable,
                  textController: _emailCtrl,
                  textGlobalKey: 'email',
                  context: context,
                  // focusNode: emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  hintText: AppLocalizationHelper.of(context)
                      .translate('EmailAddress'),
                  icon: Icon(
                    FontAwesomeIcons.envelope,
                    color: Colors.blueGrey,
                    size: ScreenUtil().setSp(
                        ScreenHelper.getResponsiveTextFieldFontSize(context)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isEmailEditable
                          ? Icons.edit_outlined
                          : Icons.check_outlined,
                    ),
                    onPressed: _toggleEmailEditable,
                    color: Colors.blue,
                  ),
                  textValidator: _formValidateService.validateEmail,
                  onChanged: (value) {
                    tempUser.email = value;
                    tempUser.organization.email = value;
                  },
                ).textFieldRow(),
                Padding(
                  padding: EdgeInsets.only(top: ScreenUtil().setSp(30)),
                  child: Container(
                    constraints:
                        BoxConstraints(minHeight: ScreenUtil().setHeight(120)),
                    child: tempUser.email.isEmpty
                        ? InkWell(
                            child: Text(
                              AppLocalizationHelper.of(context)
                                  .translate('ProfilePageAddEmailNote'),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                  decoration: TextDecoration.underline,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil().setSp(ScreenHelper
                                      .getResponsiveTextBodyFontSize(context))),
                            ),
                            onTap: () {
                              _toggleEmailEditable();
                              // emailFocusNode.requestFocus();
                            },
                          )
                        : tempUser.isEmailVerified ?? false
                            ? null
                            : InkWell(
                                child: Text(
                                  AppLocalizationHelper.of(context)
                                      .translate('ProfilePageVerifyEmailNote'),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                    decoration: TextDecoration.underline,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  _emailChanged(
                                    AppLocalizationHelper.of(context)
                                        .translate('ResentLinkNote'),
                                  );
                                },
                              ),
                  ),
                ),
              ],
            ),

            // ),
            VEmptyView(50),
            Container(
              width: ScreenUtil().setWidth(800),
              // height: ScreenUtil().setHeight(96),
              child: RaisedButton(
                onPressed: _update,
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
                      AppLocalizationHelper.of(context)
                          .translate('SaveProfile'),
                      style: GoogleFonts.lato(
                        fontSize: ScreenUtil().setSp(
                            ScreenHelper.getResponsiveTextBodyFontSize(
                                context)),
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

  _fieldsEditable() {
    setState(() {
      _isOrgNameEditable = !_isOrgNameEditable;
      _isAddressEditable = !_isAddressEditable;
      _isMobileEditable = !_isMobileEditable;
      _isEmailEditable = !_isEmailEditable;
    });
  }

  _toggleEmailEditable() {
    _isSaveButtonPressed = false;
    if (_emailCtrl.text.length == 0 && _isEmailEditable == false) {
      hlp.showToastError(
          AppLocalizationHelper.of(context).translate('EmptyEmailNote'));
      return;
    }
    if (_formValidateService.validateEmail(_emailCtrl.text) != null) {
      hlp.showToastError(_formValidateService.validateEmail(_emailCtrl.text));
      return;
    }
    _fieldsEditable();

    if (oldUser.email != tempUser.email) {
      _emailChanged("tickButton");
    }
  }

  _emailChanged(String buttonEvent) async {
    print(
        '/////////////////////////////different email, need to call api to update email');

    _showLoading();

    if (buttonEvent != "resendLink") {
      bool isUpdateEmail = await callAPIUpdateEmail();
      if (!isUpdateEmail) {
        hlp.showToastError(AppLocalizationHelper.of(context)
            .translate('UpdateEmailFailedNote'));
        _hideLoading();
        return;
      }
    }

    bool isSendVerificationCode = await callAPISendVerificationCode();
    if (!isSendVerificationCode) {
      hlp.showToastError(AppLocalizationHelper.of(context)
          .translate('SendVerficationCodeFailedNote'));
      _hideLoading();
      return;
    }

    AlertMessageDialog(
      content: AppLocalizationHelper.of(context)
          .translate('SuccessfulSendVerficationCodeNote'),
      buttonTitle: AppLocalizationHelper.of(context).translate('Confirm'),
      buttonEvent: _okEventForAlert,
      context: context,
    ).showAlert();

    _hideLoading();
  }

  Future<bool> callAPIUpdateEmail() async {
    bool result = false;
    ////////////call api to update email and change verified to false
    Map<String, dynamic> dataUpdateEmail = {
      "NewEmail": tempUser.email,
    };
    var response = await hlp.postData(
        "api/Organizations/" +
            oldUser.organizationId.toString() +
            "/updateEmail",
        dataUpdateEmail,
        hasAuth: true,
        context: context);
    if (response.isSuccess == true) {
      oldUser.email = tempUser.email;
      oldUser.isEmailVerified = false;
      Provider.of<CurrentUserProvider>(context, listen: false)
          .setCurrentUser(oldUser);

      result = true;
    } else {
      print("errr");
      setState(() {
        tempUser.email = oldUser
            .email; //server response update failed, need to roll the email textformfield back to the old email.
      });
      // hlp.showToastError(hlp.getLastError());
      hlp.showToastError(
          AppLocalizationHelper.of(context).translate('NetworkErrorNote'));
      result = false;
    }

    return result;
  }

  Future<bool> callAPISendVerificationCode() async {
    bool result = false;

    ////////////call api to send verification code
    var response = await hlp.getData(
        "api/Token/confirmemail?email=" + oldUser.email,
        context: context,
        hasAuth: false);

    if (response.isSuccess) {
      result = true;
    } else {
      print("errr");
      // hlp.showToastError(hlp.getLastError());
      hlp.showToastError(
          AppLocalizationHelper.of(context).translate('NetworkErrorNote'));
      result = false;
    }
    return result;
  }

  _okEventForAlert() {
    Navigator.of(context).pop(true);
    pushNewScreen(
      context,
      screen: EmailVerify(),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  Future<void> _update() async {
    _isSaveButtonPressed = true;

    print(
        "///////////////////////////////////Update function here, will call updateProfile web api");
    if (_orgProfileFormKey.currentState.validate()) {
      _orgProfileFormKey.currentState.save();

      // dismiss keyboard during async call
      FocusScope.of(context).requestFocus(new FocusNode());

      _showLoading();

      Helper hlp = new Helper();
      Map<String, dynamic> data = {
        "organizationId": tempUser.organizationId,
        "organizationName": tempUser.organization.organizationName,
        "location": tempUser.address,
        "phone": tempUser.mobile,
      };

      var response = await hlp.putData(
          "api/Organizations/" + tempUser.organizationId.toString(), data,
          context: context);

      if (response.isSuccess) {
        tempUser.isEmailVerified = true;
        Provider.of<CurrentUserProvider>(context, listen: false)
            .setCurrentUser(tempUser);
        Navigator.pushNamed(context, 'StoreList');
        _hideLoading();
        return;
      } else {
        print("errr");
        // hlp.showToastError(hlp.getLastError());
        hlp.showToastError(
            AppLocalizationHelper.of(context).translate('NetworkErrorNote'));
      }
      _hideLoading();
    }
  }

  _showLoading() {
    // start the modal progress HUD
    setState(() {
      _isInAsyncCall = true;
    });
  }

  _hideLoading() {
    // start the modal progress HUD
    setState(() {
      _isInAsyncCall = false;
    });
  }
}
