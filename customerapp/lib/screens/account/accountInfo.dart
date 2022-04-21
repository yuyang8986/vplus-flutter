import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/models/user.dart';
import 'package:vplus/screens/welcome.dart';
import 'package:vplus/styles/color.dart';
import 'package:vplus/widgets/appBar.dart';
import 'package:vplus/widgets/components.dart';
import 'package:vplus/helper/formValidationService.dart';
import 'package:vplus/helper/helper.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/screens/auth/updatePassword.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage(this.user, this.callBack, {Key key, this.title})
      : super(key: key);

  final String title;
  User user;
  Function callBack;

  @override
  createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String txtName;
  String txtPhone;
  String txtEmail;
  String txtAddress;
  int userId;
  Helper hlp;
  User user;
  bool isLoading;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    txtName = user.name;
    txtPhone = user.mobile;
    txtEmail = user.email;
    txtAddress = user.address;
    userId = user.userId;
    hlp = Helper();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          CustomAppBar.getAppBarWithBackButtonAndTitleOnly(context, "${AppLocalizationHelper.of(context).translate("Profile")} "),
      resizeToAvoidBottomInset: true,
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Container(
          child: SingleChildScrollView(
            child: Container(
              padding:
                  EdgeInsets.only(top: 20, left: 40, right: 40, bottom: 40),
              child: Column(
                children: <Widget>[
                  profileForm(),
                  Container(
                    //height: 120,
                    margin: EdgeInsets.only(top: ScreenUtil().setHeight(30)),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: RaisedButton(
                                elevation: 4,
                                onPressed: () {
                                  checkValidations();
                                  widget.callBack();
                                },
                                textColor: Colors.white,
                                color: Color(0xff5352ec),
                                padding: const EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: SizedBox(
                                  child: Text(
                                    "${AppLocalizationHelper.of(context).translate("UpdateProfile")} ",
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(35),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ScreenUtil().setHeight(80)),
                        Row(
                          children: [
                            Expanded(
                              child: RaisedButton(
                                elevation: 4,
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (ctx) {
                                    return UpdatePasswordPage();
                                  }));
                                  //  widget.callBack();
                                  //Navigator.pop(context);
                                },
                                textColor: Colors.black,
                                color: Colors.white,
                                padding: const EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: SizedBox(
                                  child: Text(
                                    "${AppLocalizationHelper.of(context).translate("UpdatePassword")} ",
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(32),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: RaisedButton(
                                elevation: 4,
                                onPressed: () {
                                  Helper.logout();
                                  Phoenix.rebirth(context);
                                  Navigator.of(context).pushAndRemoveUntil(
                                    CupertinoPageRoute(
                                      builder: (BuildContext context) {
                                        return WelcomeScreen();
                                      },
                                    ),
                                    (_) => false,
                                  );
                                },
                                textColor: Colors.white,
                                color: Colors.grey,
                                padding: const EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: SizedBox(
                                  child: Text(
                                    "${AppLocalizationHelper.of(context).translate("LogOut")} ",
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(35),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  Widget profileForm() {
    return Column(
      children: <Widget>[
        SizedBox(height: 30),
        Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: TextFormField(
                initialValue: txtName,
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  FocusScope.of(context).nextFocus();
                },
                onChanged: (value) {
                  setState(() {
                    txtName = value.trim();
                  });
                },
                decoration: CustomTextBox(
                  icon: Icon(
                    Icons.perm_identity,
                    color: generalColor,
                  ),
                  context: context,
                ).getTextboxDecoration(),
              ),
            ),
            Container(
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setSp(20)),
                  // color: Color(0xffe6e6e6),
                  border: Border.all(
                    color: Color(0xffe6e6e6),
                    width: ScreenUtil().setSp(5),
                  ),
                ),
                child: IntlPhoneField(
                  // maxLength: 12,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "${AppLocalizationHelper.of(context).translate("PhoneNumber")} ",
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.phone,
                      color: generalColor,
                    ),
                  ),
                  initialValue: (txtPhone == null)
                      ? "$txtPhone"
                      : "${txtPhone.substring(3)}",
                  initialCountryCode: 'AU',
                  onChanged: (value) {
                    setState(() {
                      txtPhone = value.completeNumber.toString();
                      print(txtPhone);
                    });
                  },
                )),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: TextFormField(
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                  checkValidations();
                },
                initialValue: txtEmail,
                keyboardType: TextInputType.emailAddress,
                //obscureText: true,
                onChanged: (value) {
                  setState(() {
                    txtEmail = value;
                  });
                },
                //obscureText: _obscureText ? true : false,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  hintText: "${AppLocalizationHelper.of(context).translate("EmailInfo")} ",
                  focusColor: generalColor,
                  prefixIcon: Icon(
                    Icons.email,
                    color: generalColor,
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
                initialValue: txtAddress,
                keyboardType: TextInputType.text,
                //obscureText: true,
                onChanged: (value) {
                  setState(() {
                    txtAddress = value;
                  });
                },
                //obscureText: _obscureText ? true : false,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  hintText: 'Address (Optional)',
                  focusColor: generalColor,
                  prefixIcon: Icon(
                    Icons.location_on,
                    color: generalColor,
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
          ],
        )
      ],
    );
  }

  void checkValidations() {
    if (txtName == '') {
      hlp.showToastError('Please enter Name');
      return;
    }
    if (txtPhone == '') {
      hlp.showToastError('Please enter Phone Number');
      return;
    }
    update();
  }

  Future<void> update() async {
    print(txtPhone);
    if (FormValidateService().validateMobile(txtPhone)?.isNotEmpty ?? false) {
      hlp.showToastError("Phone format is not valid!");
      return;
    }

    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> data = {
      "Email": txtEmail?.trim() ?? "",
      "Phone": txtPhone.trim(),
      "UserName": txtName.trim(),
      "Address": txtAddress?.trim() ?? ""
    };

    Map userMap = await hlp.putData("api/users" + "/" + userId.toString(), data,
        context: context);
    User user = User.fromJson(userMap);
    if (user != null) {
      Provider.of<CurrentUserProvider>(context, listen: false)
          .setCurrentUser(user);
      setState(() {
        isLoading = false;
      });
      hlp.showToastSuccess("Infomation Updated");
      return;
    } else {
      print("errr");
      hlp.showToastError(hlp.getLastError());
    }
    setState(() {
      isLoading = false;
    });

    // Navigator.pushNamed(context, 'HomePage');
  }
}
