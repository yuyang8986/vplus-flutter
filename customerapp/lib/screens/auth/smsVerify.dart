import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/helper.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/screens/auth/initUserPassword.dart';
import 'package:vplus/widgets/appBar.dart';
import 'package:vplus/widgets/emptyView.dart';

class SmsVerifyScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SmsVerifycreenState();
}

class SmsVerifycreenState extends State<SmsVerifyScreen> {
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
  TextEditingController _textController;
  bool showQR;
  var data;
  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;
    _textController.text = data["mobile"];
    return ModalProgressHUD(
      inAsyncCall: isloading,
      child: Scaffold(
        appBar: CustomAppBar.getAppBarWithBackButtonAndTitleOnly(
            context, "Phone Verification"),
        body: _contentWidget(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  Future<void> _submit() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout = (String verId) {
      this.verificationCode = verId;
    };

    final PhoneCodeSent phoneCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationCode = verId;
      smsCodeDialog(context).then((value) {});
    };

    final Null Function(AuthCredential user) phoneVerificationCompleted =
        (AuthCredential user) {};

    final PhoneVerificationFailed phoneVerificationFailed =
        (FirebaseAuthException exception) {
      setState(() {
        isloading = false;
      });
      hlp.showToastError("Verification Failed, pleasae try again");
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
                  child: Text("Cancel")),
              FlatButton(
                child: Text("Verify"),
                onPressed: () async {
                  //Navigator.pop(context);
                  setState(() {
                    isloading = true;
                  });
                  try {
                    var _cre = PhoneAuthProvider.credential(
                        verificationId: this.verificationCode,
                        smsCode: this.smsCode);
                    UserCredential result =
                        await _firebaseAuth.signInWithCredential(_cre);
                    setState(() {
                      isloading = false;
                    });
                    if (result != null)
                      Provider.of<CurrentUserProvider>(context, listen: false)
                          .setSignUpMobileNumber = data["mobile"];
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => InitUserPassword()));
                  } catch (e) {
                    setState(() {
                      isloading = false;
                    });
                    Helper().showToastError("Verification Failed");
                  }
                },
              ),
            ],
          );
        });
  }

  _contentWidget() {
    return Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            VEmptyView(200),
            Text(
              'Please verify your phone number',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: SizeHelper.textMultiplier * 2,
              ),
            ),
            VEmptyView(100),
            Container(
              width: SizeHelper.widthMultiplier * 50,
              child: TextField(
                textAlign: TextAlign.center,
                controller: _textController,
                keyboardType: TextInputType.phone,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Enter your mobile number",
                  errorText: _inputErrorText,
                ),
              ),
            ),
            VEmptyView(100),
            RaisedButton(
              elevation: 4,
              onPressed: () async {
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
                  'Send Me Code',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
