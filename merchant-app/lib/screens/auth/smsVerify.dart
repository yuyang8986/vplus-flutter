import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/models/apiUser.dart' as userModel;
import 'package:vplus_merchant_app/providers/currentuser_provider.dart';
import 'package:vplus_merchant_app/widgets/customAppBar.dart';

class SmsVerifyScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SmsVerifycreenState();
}

class SmsVerifycreenState extends State<SmsVerifyScreen> {
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
  TextEditingController _textController;
  bool showQR;
  var data;
  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;
    _textController.text = data["Mobile"];
    return ModalProgressHUD(
      inAsyncCall: isloading,
      child: Scaffold(
        appBar: CustomAppBar.getAppBarWithBackButtonAndTitleOnly(
            context, "Verify Phone"),
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
      hlp.showToastError(
          "${AppLocalizationHelper.of(context).translate('UnexceptedErrorWhenVerifySMS')}: " +
              exception.message);
      print("${exception.message}");
    };
    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: _textController.text,
        timeout: const Duration(seconds: 15),
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
            title: Text(
                "${AppLocalizationHelper.of(context).translate('EnterSMSCodeNote')}",
                style: GoogleFonts.lato()),
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
                  child: Text(
                    "${AppLocalizationHelper.of(context).translate('Cancel')}",
                    style: GoogleFonts.lato(),
                  )),
              FlatButton(
                child: Text(
                    "${AppLocalizationHelper.of(context).translate('Verify')}",
                    style: GoogleFonts.lato()),
                onPressed: () async {
                  //Navigator.pop(context);
                  setState(() {
                    isloading = true;
                  });
                  var _cre = PhoneAuthProvider.credential(
                      verificationId: this.verificationCode,
                      smsCode: this.smsCode);
                  _firebaseAuth.signInWithCredential(_cre).then((reseult) {
                    //print("Success");
                    //
                    hlp
                        .postData("api/token/Registration", data,
                            context: context)
                        .then((response) {
                      if (response.data != null && response.isSuccess) {
                        var user = userModel.ApiUser.fromJson(response.data);
                        Provider.of<CurrentUserProvider>(context)
                            .setCurrentUser(user);
                        hlp.showToastSuccess(
                            "${AppLocalizationHelper.of(context).translate('SuccessfulVerifedMobileNumberAlert')}");
                        Navigator.pushNamed(context, 'HomePage');
                        setState(() {
                          isloading = false;
                        });
                        return;
                      } else {
                        print("errr");
                        setState(() {
                          isloading = false;
                        });
                        // hlp.showToastError(hlp.getLastError());
                        hlp.showToastError(
                            "${AppLocalizationHelper.of(context).translate('VerficationSMSFailedAlert')}");
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    });
                  }).catchError((e) {
                    setState(() {
                      isloading = false;
                    });
                    print(e);
                    hlp.showToastError(
                        "${AppLocalizationHelper.of(context).translate('InvalidSMSCodeAlert')}");
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
              ),
            ],
          );
        });
  }

  _contentWidget() {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Container(
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
                      readOnly: true,
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
                          'Get Code',
                          style: GoogleFonts.lato(
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
        ],
      ),
    );
  }
}
