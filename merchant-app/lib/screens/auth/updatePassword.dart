import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/providers/currentuser_provider.dart';
import 'package:vplus_merchant_app/styles/regex.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vplus_merchant_app/helpers/formValidationHelper.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdatePasswordPage extends StatefulWidget {
  @override
  _UpdatePasswordPage createState() => _UpdatePasswordPage();
}

class _UpdatePasswordPage extends State<UpdatePasswordPage> {
  final GlobalKey<FormState> _updatePasswordFormKey = GlobalKey<FormState>();

  String _currentPassword = "";
  String _newPassword = "";
  TextEditingController _currentEmailCtrl = new TextEditingController();
  TextEditingController _newEmailCtrl = new TextEditingController();
  Helper hlp = Helper();
  bool _obscureCurrentPasswordText = true;
  bool _obscureNewPasswordText = true;
  bool _isInAsyncCall = false;
  FormValidateService _formValidateService;
  FocusNode _newPasswordFocusNode;

  @override
  void initState() {
    super.initState();
    _newPasswordFocusNode = FocusNode();
    _formValidateService = FormValidateService(context);
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    _newPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: true,
      child: Scaffold(
        appBar: CustomAppBar.getAppBar(
          AppLocalizationHelper.of(context).translate('UpdatePassword'),
          false,
          context: context,
          showLogo: false,
        ),
        resizeToAvoidBottomInset: true,
        body: ModalProgressHUD(
          child: SingleChildScrollView(
            child: Container(
              height: ScreenUtil().setHeight(ScreenHelper.isLandScape(context)
                  ? SizeHelper.heightMultiplier * 140
                  : 1200),
              child: buildUpdatePasswordForm(context),
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

  Widget buildUpdatePasswordForm(BuildContext context) {
    return Form(
      key: this._updatePasswordFormKey,
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setSp(120)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            VEmptyView(50),
            TextFieldRow(
              textController: _currentEmailCtrl,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp("[\\s]")),
              ],
              textGlobalKey: 'CurrentPassword',
              context: context,
              isMandate: true,
              obscureText: _obscureCurrentPasswordText,
              hintText: AppLocalizationHelper.of(context)
                  .translate('CurrentPassword'),
              onEditingComplete: () => _newPasswordFocusNode.requestFocus(),
              icon: Icon(
                FontAwesomeIcons.lock,
                color: Colors.yellow[700],
                size: ScreenHelper.isLandScape(context)
                    ? SizeHelper.imageSizeMultiplier * 3
                    : 50,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureCurrentPasswordText
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureCurrentPasswordText = !_obscureCurrentPasswordText;
                  });
                },
                color: Colors.black,
              ),
              textValidator: _formValidateService.validatePassword,
              onChanged: (value) {
                _currentPassword = value;
              },
            ).textFieldRow(),
            //VEmptyView(10),
            Column(
              children: [
                TextFieldRow(
                  textController: _newEmailCtrl,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp("[\\s]")),
                  ],
                  textGlobalKey: 'NewPassword',
                  context: context,
                  isMandate: true,
                  obscureText: _obscureNewPasswordText,
                  focusNode: _newPasswordFocusNode,
                  hintText: AppLocalizationHelper.of(context)
                      .translate('NewPassword'),
                  icon: Icon(
                    FontAwesomeIcons.lock,
                    color: Colors.yellow[700],
                    size: ScreenHelper.isLandScape(context)
                        ? SizeHelper.imageSizeMultiplier * 3
                        : 50,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPasswordText
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPasswordText = !_obscureNewPasswordText;
                      });
                    },
                    color: Colors.black,
                  ),
                  textValidator: _formValidateService.validatePassword,
                  onChanged: (value) {
                    _newPassword = value;
                  },
                ).textFieldRow(),
                Padding(
                  padding: EdgeInsets.only(top: ScreenUtil().setSp(30)),
                  child: Container(
                    constraints:
                        BoxConstraints(minHeight: ScreenUtil().setHeight(120)),
                    child: Text(
                      AppLocalizationHelper.of(context)
                          .translate('PasswordReminderNote'),
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            VEmptyView(20),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    textColor: Colors.white,
                    color: Color.fromRGBO(150, 159, 170, 1),
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizationHelper.of(context).translate('Cancel'),
                          // textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                WEmptyView(50),
                Expanded(
                  flex: 3,
                  child: RaisedButton(
                    onPressed: updatePassword,
                    textColor: Colors.white,
                    color: Color(0xff5352ec),
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizationHelper.of(context)
                              .translate('Confirm'),
                          // textAlign: TextAlign.center,
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
          ],
        ),
      ),
    );
  }

  focusOnNewPassword() {
    _newPasswordFocusNode.requestFocus();
  }

  Future<void> updatePassword() async {
    if (_updatePasswordFormKey.currentState.validate()) {
      _updatePasswordFormKey.currentState.save();

      // dismiss keyboard during async call
      FocusScope.of(context).requestFocus(new FocusNode());

      setState(() {
        _isInAsyncCall = true;
      });
      Map<String, dynamic> data = {
        "Email": Provider.of<CurrentUserProvider>(context, listen: false)
            .getloggedInUser
            .email,
        "CurrentPassword": _currentPassword.trim(),
        "NewPassword": _newPassword.trim()
      };

      var response = await hlp.postData(
        "api/Token/update-password",
        data,
        hasAuth: true,
        context: context,
      );
      if (response.isSuccess == true && response.data == null) {
        // hlp.setLoggedInUser(result);
        // Navigator.pushNamed(context, 'HomePage');
        setState(() {
          _isInAsyncCall = false;
        });
        hlp.showToastSuccess(AppLocalizationHelper.of(context)
            .translate("SuccessfulUpdatePasswordNote"));
        Navigator.pop(context);
        return;
      } else {
        print("errr");
        // hlp.showToastError(hlp.getLastError());
        hlp.showToastSuccess(AppLocalizationHelper.of(context)
            .translate("FailedUpdatePasswordNote"));
      }
      setState(() {
        _isInAsyncCall = false;
      });
    }
  }
}
