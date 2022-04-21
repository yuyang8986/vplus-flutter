import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/screenHelper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/models/user.dart';
import 'package:vplus/screens/stores/supermarketListPage.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/helper/formValidationService.dart';
import 'package:vplus/helper/helper.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/widgets/appBar.dart';
import 'package:vplus/widgets/emptyView.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignInPage createState() => _SignInPage();
}

class _SignInPage extends State<SignInPage> {
  String txtPassword = "";
  String txtMobile = "+61";
  Helper hlp = Helper();
  bool islogging = false;

  var _obscureText = true;
  // Text('Anonymous',
  //                             textAlign: TextAlign.center,
  //                             style: TextStyle(
  //                               fontWeight: FontWeight.bold,
  //                               // decoration: TextDecoration.underline,
  //                               fontSize: SizeHelper.textMultiplier * 2,
  //                             )),
  var isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: CustomAppBar.getAppBar('', false),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
                top: 0,
                left: 0,
                child: Image.asset(
                  "assets/images/signup_top.png",
                  width: SizeHelper.widthMultiplier * 20,
                )),
            ModalProgressHUD(
              inAsyncCall: isLoading,
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(
                      vertical: SizeHelper.widthMultiplier * 5,
                      horizontal: SizeHelper.widthMultiplier * 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      VEmptyView(100),
                      Image.asset(
                        "assets/images/logo-small.png",
                        width: SizeHelper.widthMultiplier * 20,
                      ),
                      VEmptyView(100),
                      Text(
                        'Your Grocery Needs. Vplus to your door',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: SizeHelper.textMultiplier * 3.5,
                        ),
                      ),
                      // Container(
                      //   margin: EdgeInsets.only(bottom: 30),
                      //   child: Text(
                      //     'LOGIN',
                      //     style: TextStyle(
                      //       fontWeight: FontWeight.bold,
                      //       fontSize: SizeHelper.textMultiplier * 2.5,
                      //     ),
                      //   ),
                      // ),
                      VEmptyView(200),
                      !islogging
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: SizeHelper.widthMultiplier * 120,
                                  child: RaisedButton(
                                    key: Key('loginPageLoginButton'),
                                    elevation: 4,
                                    onPressed: () {
                                      setState(() {
                                        islogging = true;
                                      });
                                    },
                                    textColor: Colors.white,
                                    color: Color(0xff5352ec),
                                    padding: EdgeInsets.symmetric(
                                        vertical: SizeHelper.textMultiplier * 2,
                                        horizontal:
                                            SizeHelper.textMultiplier * 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: SizedBox(
                                      child: Text(
                                        'Sign Up in 10 secs For Best Experience',
                                        style: TextStyle(
                                          fontSize:
                                              SizeHelper.textMultiplier * 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                VEmptyView(40),
                                Text('Sign Up for Limited Time Offers:',
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            SizeHelper.textMultiplier * 2)),
                                VEmptyView(20),
                                Text('\$1 Deliver To Your Door Now',
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            SizeHelper.textMultiplier * 2)),
                                Text('Get Up To\$12 Off For Your Orders',
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            SizeHelper.textMultiplier * 2)),
                                Text(
                                    'More Than 2,000 Items To Shop and Updating',
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            SizeHelper.textMultiplier * 2)),
                                VEmptyView(70),
                                Container(
                                  width: SizeHelper.widthMultiplier * 120,
                                  child: RaisedButton(
                                    key: Key('checkGoodies'),
                                    elevation: 4,
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (ctx) =>
                                                  SupermarketListPage()));
                                    },
                                    textColor: Colors.white,
                                    color: Colors.grey,
                                    padding: EdgeInsets.symmetric(
                                        vertical: SizeHelper.textMultiplier * 2,
                                        horizontal:
                                            SizeHelper.textMultiplier * 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: SizedBox(
                                      child: Text(
                                        'Check the goodies first',
                                        style: TextStyle(
                                          fontSize:
                                              SizeHelper.textMultiplier * 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                    height: SizeHelper.heightMultiplier * 8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          ScreenUtil().setSp(40)),
                                      color: appThemeColor.withOpacity(.1),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: ScreenUtil().setSp(3),
                                      ),
                                    ),
                                    child: IntlPhoneField(
                                      // maxLength: 12,
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        hintText: 'Phone Number',
                                        hintStyle: GoogleFonts.lato(
                                            color: Colors.black),
                                        border: InputBorder.none,
                                        icon: Icon(
                                          Icons.phone,
                                          color: generalColor,
                                        ),
                                      ),
                                      initialCountryCode: 'AU',
                                      onChanged: (value) {
                                        setState(() {
                                          txtMobile =
                                              value.completeNumber.toString();
                                          print(txtMobile);
                                        });
                                      },
                                    )),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  height: SizeHelper.heightMultiplier * 8,
                                  margin: EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        ScreenUtil().setSp(40)),
                                    color: appThemeColor.withOpacity(.1),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: ScreenUtil().setSp(3),
                                    ),
                                  ),
                                  child: TextFormField(
                                    key: Key('loginPasswordInput'),
                                    initialValue: txtPassword,
                                    textInputAction: TextInputAction.send,
                                    onEditingComplete: () {
                                      FocusScope.of(context).unfocus();
                                      checkValidations();
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        txtPassword = value;
                                      });
                                    },
                                    obscureText: _obscureText ? true : false,
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      hintText:
                                          '                                 Password',
                                      hintStyle:
                                          GoogleFonts.lato(color: Colors.black),
                                      focusColor: appThemeColor,
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: appThemeColor,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureText
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: _togglePasswordStatus,
                                        color: appThemeColor,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            ScreenUtil().setSp(40)),
                                        borderSide: BorderSide(
                                          color: borderColor,
                                          width: 1.0,
                                        ),
                                      ),
                                      focusedBorder: new OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            ScreenUtil().setSp(40)),
                                        borderSide: BorderSide(
                                          width: 1.0,
                                          color: generalColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  alignment: Alignment.centerLeft,
                                  child: FlatButton(
                                    onPressed: () async {
                                      Navigator.pushNamed(
                                          context, "resetpassword");
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                      !islogging
                          ? Container()
                          : Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    loginButton(),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: FlatButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, "SignupPage");
                                    },
                                    child: Text(
                                      'SIGN UP',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        // decoration: TextDecoration.underline,
                                        fontSize: SizeHelper.textMultiplier * 2,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                right: 0,
                child: Image.asset(
                  "assets/images/login_bottom.png",
                  width: SizeHelper.widthMultiplier * 20,
                )),
          ],
        ),
      ),
    );
  }

  Expanded loginButton() {
    return Expanded(
      child: RaisedButton(
        key: Key('loginPageLoginButton'),
        elevation: 4,
        onPressed: () {
          checkValidations();
        },
        textColor: Colors.white,
        color: Color(0xff5352ec),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: SizedBox(
          child: Text(
            'LOGIN',
            style: TextStyle(
              fontSize: SizeHelper.textMultiplier * 2,
            ),
          ),
        ),
      ),
    );
  }

  void checkValidations() {
    // Navigator.pushNamed(context, 'HomePage');

    // return;

    if (txtMobile.length <= 3) {
      hlp.showToastError('Please enter Mobile');
      return;
    }
    if (txtPassword.isEmpty) {
      hlp.showToastError('Please enter Password');
      return;
    }

    setState(() {
      isLoading = true;
    });
    // Navigator.pushNamed(context, 'HomePage');
    loginUser();
  }

  void loginUser() async {
    Map<String, dynamic> data = {
      "Username": txtMobile.toString(),
      "Password": txtPassword.toString(),
    };

    Map<String, dynamic> userMap =
        await hlp.postData("api/token/Authenticate", data, context: context);
    if (userMap != null) {
      var user = User.fromJson(userMap);
      Provider.of<CurrentUserProvider>(context, listen: false)
          .setCurrentUser(user);
      // get user details
      await Provider.of<CurrentUserProvider>(context, listen: false)
          .updateCustomerInfoByUserId(context, user.userId);
      Navigator.pushNamed(context, 'HomePage');
      setState(() {
        isLoading = false;
      });
      return;
    } else {
      print("errr");
      hlp.showToastError("Invalid Mobile Number / Password");
    }
    setState(() {
      isLoading = false;
    });
  }

  _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
