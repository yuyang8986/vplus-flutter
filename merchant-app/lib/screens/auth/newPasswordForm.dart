import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';

class NewPasswordFormPage extends StatefulWidget {
  NewPasswordFormPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NewPasswordFormPage createState() => _NewPasswordFormPage();
}

class _NewPasswordFormPage extends State<NewPasswordFormPage> {
  String txtPassword = "";
  String txtPassword2 = "";
  String phone;
  Helper hlp = Helper();
  var _obscureText = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    phone = ModalRoute.of(context).settings.arguments;
    return SafeArea(
      bottom: false,
      top: true,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar.getAppBar('', false),
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Container(
            child: SingleChildScrollView(
              child: Container(
                padding:
                    EdgeInsets.only(top: 20, left: 40, right: 40, bottom: 40),
                child: Column(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          '${AppLocalizationHelper.of(context).translate('EnterNewPasswordNote')}',
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(height: 30),
                        // Container(
                        //   margin: EdgeInsets.only(top: 20, bottom: 30),
                        //   child: Text(
                        //     'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer porttitor dolor at tellus feugiat, vitae auctor lorem eleifend',
                        //     textAlign: TextAlign.center,
                        //     style: TextStyle(fontSize: 16),
                        //   ),
                        // ),
                        Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: TextFormField(
                                onEditingComplete: () {
                                  FocusScope.of(context).unfocus();
                                  checkValidations();
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
                                  hintText:
                                      '${AppLocalizationHelper.of(context).translate('Password')}',
                                  focusColor: generalColor,
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: generalColor,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility
                                          : Icons.visibility_off,
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
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: TextFormField(
                                onEditingComplete: () {
                                  FocusScope.of(context).unfocus();
                                  checkValidations();
                                },
                                initialValue: txtPassword2,
                                keyboardType: TextInputType.text,
                                //obscureText: true,
                                onChanged: (value) {
                                  setState(() {
                                    txtPassword2 = value;
                                  });
                                },
                                obscureText: _obscureText ? true : false,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  hintText:
                                      '${AppLocalizationHelper.of(context).translate('ConfirmPassword')}',
                                  focusColor: generalColor,
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: generalColor,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility
                                          : Icons.visibility_off,
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
                              ),
                            ),
                            Text(
                              "${AppLocalizationHelper.of(context).translate('PasswordInvalidLengthNote')}",
                              style: GoogleFonts.lato(),
                            )
                          ],
                        )
                      ],
                    ),
                    Container(
                      height: 100,
                      margin: EdgeInsets.only(top: 30),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: RaisedButton(
                                  elevation: 4,
                                  onPressed: () {
                                    checkValidations();
                                  },
                                  textColor: Colors.white,
                                  color: Color(0xff5352ec),
                                  padding: const EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: SizedBox(
                                    child: Text(
                                      '${AppLocalizationHelper.of(context).translate('Submit')}',
                                      style: GoogleFonts.lato(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: RaisedButton(
                                  elevation: 4,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  textColor: Colors.black,
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: SizedBox(
                                    child: Text(
                                      '${AppLocalizationHelper.of(context).translate('Cancel')}',
                                      style: GoogleFonts.lato(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            color: Colors.black,
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

  _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void checkValidations() {
    if (txtPassword.isEmpty) {
      hlp.showToastError(
          '${AppLocalizationHelper.of(context).translate('PasswordEmptyNote')}');
      return;
    }

    if (txtPassword.length < 7 || txtPassword.length > 20) {
      hlp.showToastError(
          '${AppLocalizationHelper.of(context).translate('PasswordInvalidLengthNote')}');
      return;
    }

    submit();
  }

  Future<void> submit() async {
    if (txtPassword != txtPassword2) {
      hlp.showToastError(
          "${AppLocalizationHelper.of(context).translate('PasswordNotMatchAlert')}");
      return;
    }
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> data = {
      "Mobile": phone,
      "Password": txtPassword.trim(),
    };

    hlp
        .postData("api/token/ResetPasswordMobile", data, context: context)
        .then((user) {
      if (user != null) {
        //hlp.setLoggedInUser(user);
        hlp.showToastSuccess("Password Updated!");
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        print("errr");
        // setState(() {
        //   isloading = false;
        // });
        // hlp.showToastError(hlp.getLastError());
        hlp.showToastError(
            "${AppLocalizationHelper.of(context).translate('FailedUpdatePasswordNote')}");
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }).catchError((e) {
      print(e);
      // hlp.showToastError(e);
    });

    // Navigator.pushNamed(context, 'HomePage');
  }
}
