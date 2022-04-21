import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/FormValidationService.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/helper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/appBar.dart';
import 'package:vplus/widgets/components.dart';

class InitUserPassword extends StatefulWidget {
  @override
  _InitUserPasswordState createState() => _InitUserPasswordState();
}

class _InitUserPasswordState extends State<InitUserPassword> {
  bool isloading = false;
  bool _obscureText = true;
  String txtPassword = "";
  FormValidateService _validateService;
  final GlobalKey<FormState> _createNewUserPasswdFormKey =
      GlobalKey<FormState>();
  String phoneNumber;

  @override
  void initState() {
    super.initState();
    _validateService = FormValidateService();
    phoneNumber = Provider.of<CurrentUserProvider>(context, listen: false)
        .getSignUpMobileNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBarWithBackButtonAndTitleOnly(
        context,
        'Set password',
        callBack: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
      body: ModalProgressHUD(
        inAsyncCall: isloading,
        child: Column(
          children: [
            setPasswordForm(),
            formButtons(),
          ],
        ),
      ),
    );
  }

  Widget setPasswordForm() {
    return Form(
      key: this._createNewUserPasswdFormKey,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: SizeHelper.widthMultiplier * 2,
                vertical: SizeHelper.heightMultiplier * 2),
            child: TextFormField(
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
              initialValue: txtPassword,
              keyboardType: TextInputType.text,
              //obscureText: true,
              onChanged: (value) {
                setState(() {
                  txtPassword = value;
                });
              },
              obscureText: _obscureText ? true : false,
              decoration: InputDecoration(
                fillColor: Colors.white,
                hintText: 'Password',
                focusColor: generalColor,
                prefixIcon: Icon(
                  Icons.lock,
                  color: generalColor,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: _togglePasswordStatus,
                  color: Colors.black,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: borderColor,
                    width: 1.0,
                  ),
                ),
                focusedBorder: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(5),
                  borderSide: BorderSide(
                    width: 1.0,
                    color: generalColor,
                  ),
                ),
              ),
              validator: _validateService.validatePassword,
            ),
          ),
          Text("Password must be 7 - 20 characters"),
        ],
      ),
    );
  }

  Widget formButtons() {
    return RoundedVplusLongButton(
        callBack: () async {
          setState(() {
            isloading = true;
          });
          if (_createNewUserPasswdFormKey.currentState.validate()) {
            bool isSignupSuccess =
                await Provider.of<CurrentUserProvider>(context, listen: false)
                    .registrationCustomer(context, phoneNumber, txtPassword);
            if (isSignupSuccess) {
              Navigator.pushNamed(context, "${AppLocalizationHelper.of(context).translate('HomePage')}");
            }
          }
          setState(() {
            isloading = false;
          });
        },
        text: "Sign up");
  }

  _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
