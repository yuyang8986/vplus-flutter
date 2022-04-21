import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/appBar.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/helper/formValidationService.dart';
import 'package:vplus/helper/helper.dart';
import 'package:vplus/widgets/emptyView.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPage createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  String txtName = "";
  String txtPhone = "+61";
  String txtEmail = "";
  String txtAddress = "";
  Helper hlp = Helper();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar.getAppBar('Sign up', false),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Container(
          padding: EdgeInsets.only(top: SizeHelper.textMultiplier *10, left: SizeHelper.textMultiplier *5, right: SizeHelper.textMultiplier *5, bottom: SizeHelper.textMultiplier *10),
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                VEmptyView(200),
                Text(
                  'Your Grocery Needs. Vplus to your door',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeHelper.textMultiplier * 3.5,
                  ),
                ),
                VEmptyView(200),
                Container(
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setSp(20)),
                      border: Border.all(
                        color: Color(0xffe6e6e6),
                        width: ScreenUtil().setSp(5),
                      ),
                    ),
                    child: IntlPhoneField(
                      // maxLength: 12,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.phone,
                          color: generalColor,
                        ),
                      ),
                      initialCountryCode: 'AU',
                      onChanged: (value) {
                        setState(() {
                          txtPhone = value.completeNumber.toString();
                          print(txtPhone);
                        });
                      },
                    )),
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
                                signup();
                              },
                              textColor: Colors.white,
                              color: Color(0xff5352ec),
                              padding: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: SizedBox(
                                child: Text(
                                  'SIGN UP',
                                  style: TextStyle(
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
                                  'CANCEL',
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
      //bottomNavigationBar: Footer(),
    );
  }

  Future<void> signup() async {
    if (FormValidateService().validateMobile(txtPhone)?.isNotEmpty ?? false) {
      hlp.showToastError("Phone format is not valid!");
      return;
    }

    Map<String, dynamic> data = {
      "name": null,
      "mobile": txtPhone.trim(),
      "password": null,
      "postCode": null,
    }; // only mobile is mandatory

    Navigator.pushNamed(context, "smsVerify", arguments: data);
  }
}
