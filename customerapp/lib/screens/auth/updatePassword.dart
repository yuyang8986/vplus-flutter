import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/helper/helper.dart';
import 'package:vplus/providers/currentuser_provider.dart';

class UpdatePasswordPage extends StatefulWidget {
  @override
  _UpdatePasswordPage createState() => _UpdatePasswordPage();
}

class _UpdatePasswordPage extends State<UpdatePasswordPage> {
  //String txtName = "";
  //String txtPhone = "+61";
  //String txtEmail = "";
  String txtPassword = "";
  String txtPassword2 = "";
  Helper hlp = Helper();
  var _obscureText = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              // widget.callBack();
              Navigator.pop(context);
            }),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Update Password',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ScreenUtil().setSp(45),
              color: Colors.black),
        ),
      ),
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
                      SizedBox(height: 30),
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
                                hintText: 'Current Password',
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
                                hintText: 'New Password',
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
                          Text("Password must be 7 - 20 characters")
                        ],
                      )
                    ],
                  ),
                  Container(
                    //height: 100,
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
                                    'CONFIRM',
                                    style: TextStyle(
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
    );
  }

  _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void checkValidations() {
    if (txtPassword.isEmpty) {
      hlp.showToastError('Please enter Password');
      return;
    }

    //  if (txtPassword.length < 7 || txtPassword.length > 20) {
    //   hlp.showToastError('Password length must be 7 - 20');
    //   return;
    // }

    if (txtPassword2.length < 7 || txtPassword2.length > 20) {
      hlp.showToastError('Password length must be 7 - 20');
      return;
    }

    if (txtPassword2.isEmpty) {
      hlp.showToastError('Please enter Password');
      return;
    }

    updatePassword();
  }

  Future<void> updatePassword() async {
    // if (txtPassword != txtPassword2) {
    //   hlp.showToastError("Password not match!");
    //   return;
    // }
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> data = {
      "Mobile": Provider.of<CurrentUserProvider>(context, listen: false)
          .getloggedInUser
          .mobile,
      "CurrentPassword": txtPassword.trim(),
      "NewPassword": txtPassword2.trim()
    };

    dynamic result = await hlp.postData(
        "api/token/update-password-mobile", data,
        hasAuth: true, context: context);
    if (result != null) {
      // hlp.setLoggedInUser(result);
      // Navigator.pushNamed(context, 'HomePage');
      setState(() {
        isLoading = false;
      });
      hlp.showToastSuccess("Password Updated!");
      Navigator.pop(context);
      return;
    } else {
      print("errr");
      hlp.showToastError(hlp.getLastError());
    }
    setState(() {
      isLoading = false;
    });
  }
}
