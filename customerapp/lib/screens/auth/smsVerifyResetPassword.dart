import 'dart:typed_data';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:vplus/helper/helper.dart';
import 'package:vplus/widgets/appBar.dart';

class SmsVerifyResetPasswordScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SmsVerifyResetPasswordcreenState();
}

class SmsVerifyResetPasswordcreenState
    extends State<SmsVerifyResetPasswordScreen> {
  static const double _topSectionTopPadding = 50.0;
  static const double _topSectionBottomPadding = 20.0;
  static const double _topSectionHeight = 50.0;
  bool isloading = false;
  // String phoneNumber;
  String smsCode;
  String verificationCode;
  bool validated;
  Helper hlp = Helper();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  GlobalKey globalKey = new GlobalKey();
  String _dataString = "";
  String _inputErrorText;
  TextEditingController _textController = TextEditingController(text: "+61");
  bool showQR;
  var data;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBarWithBackButtonAndTitleOnly(
          context, "Verify Your Number"),
      body: _contentWidget(),
    );
  }

  @override
  void initState() {
    super.initState();
    //_textController = TextEditingController();
  }

  Future<void> _submit() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout = (String verId) {
      this.verificationCode = verId;
      setState(() {
        isloading = false;
      });
    };

    final PhoneCodeSent phoneCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationCode = verId;
      smsCodeDialog(context).then((value) {});
    };

    final Null Function(AuthCredential user) phoneVerificationCompleted =
        (AuthCredential user) {
      setState(() {
        isloading = false;
      });
    };

    final PhoneVerificationFailed phoneVerificationFailed =
        (FirebaseAuthException exception) {
      setState(() {
        isloading = false;
      });
      hlp.showToastError("Unexpected Error happend, verification failed: " +
          exception.message);
      print("${exception.message}");
    };
    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: _textController.text,
        timeout: const Duration(seconds: 5),
        verificationCompleted: phoneVerificationCompleted,
        verificationFailed: phoneVerificationFailed,
        codeSent: phoneCodeSent,
        codeAutoRetrievalTimeout: autoRetrievalTimeout);
  }

  Future<bool> smsCodeDialog(BuildContext context) {
    setState(() {
      isloading = false;
    });
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enter Code"),
            content: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                autofocus: true,
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  this.smsCode = value;
                },
              ),
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Back")),
              FlatButton(
                child: Text("Verify"),
                onPressed: () {
                  //Navigator.pop(context);
                  setState(() {
                    isloading = true;
                  });
                  var _cre = PhoneAuthProvider.credential(
                      verificationId: this.verificationCode,
                      smsCode: this.smsCode);
                  _firebaseAuth
                      .signInWithCredential(_cre)
                      .then((UserCredential reseult) {
                    //print("Success");
                    //
                    Navigator.pushNamed(context, "newPasswordFormPage",
                        arguments: _textController.text);
                  }).catchError((e) {
                    setState(() {
                      isloading = false;
                    });
                    hlp.showToastError("Invalid Code!");
                  });

                  // var user = await _firebaseAuth.currentUser();
                  // if (user != null) {
                  //   hlp.showToastSuccess("Phone is verified!");
                  // } else {
                  //   Navigator.of(context).pop();
                  //   hlp.showToastError("Phone verifiication failed!");
                  //   // signIn();
                  // }
                },
              )
            ],
          );
        });
  }

  _contentWidget() {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return ModalProgressHUD(
      inAsyncCall: isloading,
      child: Container(
        color: const Color(0xFFFFFFFF),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: _topSectionTopPadding,
                left: 50.0,
                right: 10.0,
                bottom: _topSectionBottomPadding,
              ),
              child: Container(
                height: _topSectionHeight,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: _textController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: "Enter your mobile number",
                          errorText: _inputErrorText,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: RaisedButton(
                        elevation: 4,
                        onPressed: () {
                          setState(() {
                            isloading = true;
                          });
                          _submit();
                        },
                        textColor: Colors.white,
                        color: Color(0xff5352ec),
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: SizedBox(
                          child: Text(
                            'Get Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 70,
            ),
            // RaisedButton(
            //   elevation: 4,
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            //   textColor: Colors.white,
            //   color: Color(0xff5352ec),
            //   padding: const EdgeInsets.all(10),
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(5),
            //   ),
            //   child: SizedBox(
            //     child: Text(
            //       'BACK',
            //       style: TextStyle(
            //         fontSize: 16,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
