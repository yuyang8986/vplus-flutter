import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/packageInfo.dart';
import 'package:vplus/helper/sizeHelper.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/screens/account/accountInfo.dart';
import 'package:vplus/screens/account/payment_manage.dart';
import 'package:vplus/screens/auth/signin.dart';
import 'package:vplus/screens/home/home.dart';
import 'package:vplus/screens/stores/StoreOrderPage/storeOrderPage.dart';
import 'package:vplus/screens/stores/storeListPage.dart';
import 'package:vplus/language_setting/languageSettingPage.dart';
import 'package:vplus/screens/welcome.dart';
import 'package:vplus/widgets/emptyView.dart';

class CustomAppBar {
  static getAppBar(String title, bool showProfile,
      {dynamic argument,
      Function callBack,
      BuildContext context,
      bool showLeftBackButton = false,
      bool showLeftHomeButton = false}) {
    return AppBar(
        automaticallyImplyLeading: false,
        // systemOverlayStyle: SystemUiOverlayStyle(
        //     statusBarColor: Colors.white, statusBarBrightness: Brightness.dark),
        backgroundColor: Colors.white,
        // brightness: Brightness.light,
        centerTitle: true,
        elevation: .5,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
                flex: 2,
                child: Container(child: Builder(builder: (ctx) {
                  if (showLeftBackButton)
                    return leftGoBackButton(context);
                  else if (showLeftHomeButton)
                    return leftGoHomeButton(context);
                  else
                    return leftVplusLogo(context);
                }))),
            Flexible(
              flex: 11,
              child: Center(
                child: Text(
                  title,
                  style: GoogleFonts.lato(
                      textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: SizeHelper.textMultiplier * 2.5,
                          fontWeight: FontWeight.w900)),
                ),
              ),
            ),
            Flexible(
                flex: 3,
                child: showProfile
                    ? showRightButton(
                        context,
                        Icon(
                          Icons.person_outline,
                          color: Colors.blueGrey,
                        ))
                    : Container())
          ],
        ));
  }

  static signUpButton(BuildContext context) {
    return Text("Signup",
        style: GoogleFonts.lato(
            textStyle: TextStyle(
                color: Colors.white,
                fontSize: SizeHelper.textMultiplier * 2,
                fontWeight: FontWeight.w900)));
  }

  static getAppBarWithBackButtonAndTitleOnly(BuildContext context, String title,
      {Function callBack}) {
    return AppBar(
      centerTitle: true,
      leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            if (callBack != null) {
              callBack();
            } else
              Navigator.pop(context);
          }),
      backgroundColor: Colors.white,
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.palanquinDark(
            textStyle: TextStyle(color: Colors.black, fontSize: 20)),
      ),
    );
  }

  static getAppBarWithoutTitle(String title) {
    return AppBar(
      centerTitle: false,
      backgroundColor: Colors.white,
      elevation: 2,
      title: Text(
        'sss',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }

  static Widget leftVplusLogo(BuildContext context) {
    return GestureDetector(
      child: Image.asset(
        'assets/images/logo-small.png',
        fit: BoxFit.contain,
        height: 32,
        width: 48,
      ),
      onTap: () async {
        await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text(
                  "${AppLocalizationHelper.of(context).translate("About Vplus")}",
                  textAlign: TextAlign.center,
                ),
                content: Container(
                  height: ScreenUtil().setHeight(980),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          launch("https://www.vplus.com.au/privacy");
                        },
                        child: Text(
                            "${AppLocalizationHelper.of(context).translate("Privacy Policy")}"),
                      ),
                      VEmptyView(40),
                      GestureDetector(
                        onTap: () {
                          launch("https://www.vplus.com.au/terms");
                        },
                        child: Text(
                            "${AppLocalizationHelper.of(context).translate("Terms")}"),
                      ),
                      VEmptyView(40),
                      Text(
                          "${AppLocalizationHelper.of(context).translate("App Version")}" +
                              " " +
                              packageInfo.version),
                      VEmptyView(40),
                      Text("Support:"),
                      VEmptyView(40),
                      Text("support@vplus.com.au"),
                      VEmptyView(40),
                      Text("+61410955639"),
                      VEmptyView(40),
                      Text("Wechant: vplus_au"),
                      VEmptyView(40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RaisedButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pop('dialog');
                            },
                            child: Text(
                                "${AppLocalizationHelper.of(context).translate("Close")}"),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  static Widget leftGoBackButton(BuildContext context) {
    return GestureDetector(
      child: Icon(Icons.arrow_back,
          size: SizeHelper.textMultiplier * 3.5, color: Colors.black),
      onTap: () async {
        Navigator.pop(context);
      },
    );
  }

  static Widget leftGoHomeButton(BuildContext context) {
    // pop back to the home page
    return GestureDetector(
      child: Icon(Icons.arrow_back,
          size: SizeHelper.textMultiplier * 3.5, color: Colors.black),
      onTap: () {
        // if (Navigator.of(context).widget.pages.last.name ==
        //     'PaymentSuccessPage') {
        //   Navigator.pushReplacementNamed(context, 'HomePage');
        // } else {}
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (ctx) => HomeScreen()));
      },
    );
  }

  static List<PopupMenuEntry<Object>> customerPopupMenu(BuildContext context) {
    var list = List<PopupMenuEntry<Object>>();
    list.add(
      PopupMenuItem(
        value: 1,
        child: Text(
          "${AppLocalizationHelper.of(context).translate("Profile")}",
          style: GoogleFonts.lato(fontSize: 2.5 * SizeHelper.textMultiplier),
        ),
      ),
    );
    list.add(
      PopupMenuItem(
        value: 2,
        child: Text(
          "${AppLocalizationHelper.of(context).translate("Manage Payment")}",
          style: GoogleFonts.lato(fontSize: 2.5 * SizeHelper.textMultiplier),
        ),
      ),
    );
    // list.add(
    //   PopupMenuItem(
    //     value: 3,
    //     child: Text(
    //       "${AppLocalizationHelper.of(context).translate("Language Setting")}",
    //       style: GoogleFonts.lato(fontSize: 2.5 * SizeHelper.textMultiplier),
    //     ),
    //   ),
    // );

    return list;
  }

  static void customerPopupMenuSelectedEvent(
      int value, BuildContext context) async {
    // TODO need refactor
    var profilePageArgument =
        Provider.of<CurrentUserProvider>(context, listen: false)
            .getloggedInUser;
    var profilePageCallback = () {
      // setState(() {
      Provider.of<CurrentUserProvider>(context, listen: false).setCurrentUser(
          Provider.of<CurrentUserProvider>(context, listen: false)
              .getloggedInUser);
      // });
    };
    // TODO need refactor
    if (value == 1) {
      pushNewScreen(
        context,
        // screen: ProfilePage(argument, callBack),
        screen: ProfilePage(profilePageArgument, profilePageCallback),
        withNavBar: false, // OPTIONAL VALUE. True by default.
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    } else if (value == 2) {
      pushNewScreen(
        context,
        screen: PaymentManageScreen(),
        withNavBar: false, // OPTIONAL VALUE. True by default.
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    }
    //  else if (value == 3) {
    //   pushNewScreen(
    //     context,
    //     screen: LanguageSettingPage(),
    //     withNavBar: false, // OPTIONAL VALUE. True by default.
    //     pageTransitionAnimation: PageTransitionAnimation.cupertino,
    //   );
    //   print(value);
    // }
  }

  static Widget showRightButton(BuildContext context, Widget rightButtonIcon) {
    return Container(
      height: 4.5 * SizeHelper.heightMultiplier,
      width: 10 * SizeHelper.widthMultiplier,
      child: PopupMenuButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        itemBuilder: (context) => CustomAppBar.customerPopupMenu(context),
        onCanceled: () {},
        onSelected: (value) {
          customerPopupMenuSelectedEvent(value, context);
        },
        child: rightButtonIcon,
        offset: Offset(0, ScreenUtil().setHeight(130)),
      ),
    );
  }
}
