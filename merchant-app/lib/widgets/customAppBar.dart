import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vplus_merchant_app/helpers/apiHelper.dart';
import 'package:vplus_merchant_app/helpers/apiUserHelper.dart';
import 'package:vplus_merchant_app/helpers/appLocalizationHelper.dart';
import 'package:vplus_merchant_app/helpers/packageInfo.dart';
import 'package:vplus_merchant_app/helpers/screenHelper.dart';
import 'package:vplus_merchant_app/helpers/signalrHelper.dart';
import 'package:vplus_merchant_app/helpers/sizeHelper.dart';
import 'package:vplus_merchant_app/models/apiUser.dart';
import 'package:vplus_merchant_app/providers/current_menu_provider.dart';
import 'package:vplus_merchant_app/providers/current_orderStatus_provider.dart';
import 'package:vplus_merchant_app/providers/current_stores_provider.dart';
import 'package:vplus_merchant_app/providers/orderlist_provider.dart';
import 'package:vplus_merchant_app/screens/auth/create_new_kitchen_page.dart';
import 'package:vplus_merchant_app/screens/auth/create_new_staff_page.dart';
import 'package:vplus_merchant_app/screens/campaign/campaign_list_screen.dart';
import 'package:vplus_merchant_app/screens/campaign/store_add_campaign_screen.dart';
import 'package:vplus_merchant_app/screens/langugage_setting/languageSettingPage.dart';
import 'package:vplus_merchant_app/screens/printer/printer_settings_page.dart';
import 'package:vplus_merchant_app/screens/profile/profilePage.dart';
import 'package:provider/provider.dart';
import 'package:vplus_merchant_app/providers/currentuser_provider.dart';
import 'package:vplus_merchant_app/screens/report/report_admin.dart';
import 'package:vplus_merchant_app/screens/store/store_list.dart';
import 'package:vplus_merchant_app/screens/store/store_profile.dart';
import 'package:vplus_merchant_app/screens/store_settings/open_time_setting.dart';
import 'package:vplus_merchant_app/screens/tax/taxSettingPage.dart';
import 'package:vplus_merchant_app/widgets/components.dart';
import 'package:vplus_merchant_app/widgets/emptyView.dart';
import 'package:vplus_merchant_app/screens/auth/updatePassword.dart';

class CustomAppBar {
  static getAppBar(
    String title,
    bool showProfile, {
    dynamic argument,
    Function callBack,
    BuildContext context,
    bool showLogo = true,
    String screenPage,
    Widget rightButtonIcon,
  }) {
    return PreferredSize(
      preferredSize: Size.fromHeight(ScreenHelper.isLandScape(context)
          ? 6 * SizeHelper.heightMultiplier
          : 60),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        flexibleSpace: Container(),
        title: Container(
          padding: EdgeInsets.fromLTRB(
              0,
              ScreenHelper.isLandScape(context)
                  ? 1 * SizeHelper.heightMultiplier
                  : 5,
              0,
              0),
          //height: ScreenUtil().setHeight(100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              showLogo
                  ? CustomAppBar.showLeftLogo(context)
                  : showLeftBack(context),
              showAppBarTitle(title, context),
              showProfile
                  ? showRightButton(context, screenPage, rightButtonIcon)
                  : WEmptyView(170),
            ],
          ),
        ),
      ),
    );
  }

  static const String organizationMainPage = "organizationMainPage";
  static const String storeMainPage = "storeMainPage";
  static const String staffPage = "staffPage";
  static const String kitchenPage = "kitchenPage";
  // static const menuOrganization = [
  //   'Profile',
  //   'Update Password',
  //   'Logout',
  // ];
  // static const menuStoreMainPage = [
  //   'Profile',
  //   'Manage Staff',
  //   'Bank Account',
  //   'Switch Store',
  // ];

  static Widget showRightButton(
      BuildContext context, String screenPage, Widget rightButtonIcon) {
    var widget;
    if (screenPage == organizationMainPage) {
      widget = onOrganizationMainPage(context);
    } else if (screenPage == storeMainPage) {
      widget = onStoreMainPage(context, rightButtonIcon);
    } else if (screenPage == staffPage) {
      widget = onStaffPage(context, rightButtonIcon);
    } else if (screenPage == kitchenPage) {
      widget = onKitchenPage(context);
    } else {
      widget = rightButtonIcon;
    }
    return Expanded(
      flex: 1,
      child: Container(alignment: Alignment.centerRight, child: widget),
    );
  }

  static Widget onStoreMainPage(BuildContext context, Widget rightButtonIcon) {
    return Container(
      height: SizeHelper.isMobilePortrait
          ? 4.5 * SizeHelper.heightMultiplier
          : 5 * SizeHelper.widthMultiplier,
      width: SizeHelper.isMobilePortrait
          ? 10 * SizeHelper.widthMultiplier
          : 5 * SizeHelper.heightMultiplier,
      child: PopupMenuButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        itemBuilder: (context) => CustomAppBar.pupupMenu_StoreMainPage(context),
        onCanceled: () {},
        onSelected: (value) {
          pupupMenu_StoreMainPage_OnSelect(value, context);
        },
        child: rightButtonIcon,
        offset: Offset(0, ScreenUtil().setHeight(130)),
      ),
    );
  }

  static Widget onStaffPage(BuildContext context, Widget rightButtonIcon) {
    return Container(
      height: SizeHelper.isMobilePortrait
          ? 4.5 * SizeHelper.heightMultiplier
          : 5 * SizeHelper.widthMultiplier,
      width: SizeHelper.isMobilePortrait
          ? 10 * SizeHelper.widthMultiplier
          : 10 * SizeHelper.heightMultiplier,
      child: PopupMenuButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        itemBuilder: (context) => CustomAppBar.pupupMenu_StaffPage(context),
        onCanceled: () {},
        onSelected: (value) {
          pupupMenu_StaffPage_OnSelect(value, context);
        },
        child: rightButtonIcon,
        offset: Offset(0, ScreenUtil().setHeight(130)),
      ),
    );
  }

  static Widget onKitchenPage(BuildContext context) {
    return Container(
      height: SizeHelper.isMobilePortrait
          ? 4.5 * SizeHelper.heightMultiplier
          : 5 * SizeHelper.widthMultiplier,
      width: 10 * SizeHelper.heightMultiplier,
      child: PopupMenuButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        itemBuilder: (context) => CustomAppBar.pupupMenu_KitchenPage(context),
        onCanceled: () {},
        onSelected: (value) {
          pupupMenu_KitchenPage_OnSelect(value, context);
        },
        child: Icon(
          Icons.person_outline,
          color: Colors.blueGrey,
          size: SizeHelper.isMobilePortrait
              ? 7 * SizeHelper.imageSizeMultiplier
              : 5 * SizeHelper.imageSizeMultiplier,
        ),
      ),
    );
  }

  static void pupupMenu_StoreMainPage_OnSelect(
      int value, BuildContext context) async {
    if (value == 1) {
      pushNewScreen(context, screen: StoreProfile(), withNavBar: false);
    } else if (value == 2) {
      pushNewScreen(context, screen: CreateNewStaffPage(), withNavBar: false);
    } else if (value == 3) {
      pushNewScreen(context, screen: PrinterSettingsPage(), withNavBar: false);
    } else if (value == 4) {
      // dispose store varibles
      Provider.of<OrderListProvider>(context, listen: false).clearOrderList();
      Provider.of<CurrentMenuProvider>(context, listen: false)
          .resetShownReadOnlyDialog();
      Provider.of<Current_OrderStatus_Provider>(context, listen: false)
          .setOrder(context, null, false);

      await Provider.of<CurrentStoresProvider>(context, listen: false)
          .removeStoreDevice(context);
      try {
        var hive = await Hive.openBox('store');
        await hive.delete('storeId');
      } catch (Exception) {
        print(Exception);
      }
      SignalrHelper.hubConnection?.stop();
      pushNewScreen(context, screen: StoreList(), withNavBar: false);
    } else if (value == 5) {
      print('Open Tax Setting');
      pushNewScreen(context, screen: TaxSettingPage(), withNavBar: false);
    } else if (value == 6) {
      print('Open Langugae Setting');
      pushNewScreen(context, screen: LanguageSettingPage(), withNavBar: false);
    } else if (value == 7) {
      pushNewScreen(context, screen: CreateNewKitchenPage(), withNavBar: false);
    } else if (value == 8) {
      pushNewScreen(context,
          screen: StoreAddCampaignScreen(), withNavBar: false);
    } else if (value == 9) {
      pushNewScreen(context,
          screen: StoreOpenTimeSettings(), withNavBar: false);
    }
  }

  static void pupupMenu_StaffPage_OnSelect(
      int value, BuildContext context) async {
    if (value == 1) {
      pushNewScreen(context, screen: PrinterSettingsPage(), withNavBar: false);
    } else if (value == 2) {
      // dispose store varibles
      await Provider.of<CurrentStoresProvider>(context, listen: false)
          .removeStoreDevice(context);
      Provider.of<OrderListProvider>(context, listen: false).clearOrderList();
      Provider.of<Current_OrderStatus_Provider>(context, listen: false)
          .setOrder(context, null, false);
      SignalrHelper.hubConnection?.stop();
      Helper.logout(context);
    } else if (value == 3) {
      print('Open Langugae Setting');
      pushNewScreen(context, screen: LanguageSettingPage(), withNavBar: false);
    }
  }

  static void pupupMenu_KitchenPage_OnSelect(
      int value, BuildContext context) async {
    print("value:$value");
    if (value == 1) {
      // dispose store varibles
      await Provider.of<CurrentStoresProvider>(context, listen: false)
          .removeStoreDevice(context);
      Provider.of<OrderListProvider>(context, listen: false).clearOrderList();
      Provider.of<Current_OrderStatus_Provider>(context, listen: false)
          .setOrder(context, null, false);
      SignalrHelper.hubConnection?.stop();
      Helper.logout(context);
    }
  }

  static List<PopupMenuEntry<Object>> pupupMenu_StoreMainPage(
      BuildContext context) {
    var list = List<PopupMenuEntry<Object>>();
    list.add(
      PopupMenuItem(
        value: 1,
        child: Text(
          "${AppLocalizationHelper.of(context).translate("Profile")}",
          style: GoogleFonts.lato(
            fontSize: SizeHelper.isMobilePortrait
                ? 2 * SizeHelper.textMultiplier
                : 2 * SizeHelper.textMultiplier,
          ),
        ),
      ),
    );
    list.add(
      PopupMenuItem(
        value: 2,
        child: Text(
          "${AppLocalizationHelper.of(context).translate("ManageStaff")}",
          style: GoogleFonts.lato(
            fontSize: SizeHelper.isMobilePortrait
                ? 2 * SizeHelper.textMultiplier
                : 2 * SizeHelper.textMultiplier,
          ),
        ),
      ),
    );
    list.add(
      PopupMenuItem(
        value: 7,
        child: Text(
          "${AppLocalizationHelper.of(context).translate("ManageKitchen")}",
          style: GoogleFonts.lato(
            fontSize: SizeHelper.isMobilePortrait
                ? 2 * SizeHelper.textMultiplier
                : 2 * SizeHelper.textMultiplier,
          ),
        ),
      ),
    );

    list.add(
      PopupMenuItem(
        value: 5,
        child: Text(
          "${AppLocalizationHelper.of(context).translate("TaxSetting")}",
          style: GoogleFonts.lato(
            fontSize: SizeHelper.isMobilePortrait
                ? 2 * SizeHelper.textMultiplier
                : 2 * SizeHelper.textMultiplier,
          ),
        ),
      ),
    );
    list.add(
      PopupMenuItem(
        value: 3,
        child: Text(
          "${AppLocalizationHelper.of(context).translate("PrinterSetting")}",
          style: GoogleFonts.lato(
            fontSize: SizeHelper.isMobilePortrait
                ? 2 * SizeHelper.textMultiplier
                : 2 * SizeHelper.textMultiplier,
          ),
        ),
      ),
    );
    list.add(
      PopupMenuItem(
        value: 6,
        child: Text(
          "${AppLocalizationHelper.of(context).translate("LanguageSettingLabel")}",
          style: GoogleFonts.lato(
            fontSize: SizeHelper.isMobilePortrait
                ? 2 * SizeHelper.textMultiplier
                : 2 * SizeHelper.textMultiplier,
          ),
        ),
      ),
    );
    list.add(
      PopupMenuItem(
        value: 4,
        child: Text(
          "${AppLocalizationHelper.of(context).translate("SwitchStore")}",
          style: GoogleFonts.lato(
            fontSize: SizeHelper.isMobilePortrait
                ? 2 * SizeHelper.textMultiplier
                : 2 * SizeHelper.textMultiplier,
          ),
        ),
      ),
    );
    list.add(
      PopupMenuItem(
        value: 8,
        child: Text(
          "${AppLocalizationHelper.of(context).translate("AddCampaign")}",
          style: GoogleFonts.lato(
            fontSize: SizeHelper.isMobilePortrait
                ? 2 * SizeHelper.textMultiplier
                : 2 * SizeHelper.textMultiplier,
          ),
        ),
      ),
    );
    list.add(
      PopupMenuItem(
        value: 9,
        child: Text(
          "${AppLocalizationHelper.of(context).translate("OpenTime")}",
          style: GoogleFonts.lato(
            fontSize: SizeHelper.isMobilePortrait
                ? 2 * SizeHelper.textMultiplier
                : 2 * SizeHelper.textMultiplier,
          ),
        ),
      ),
    );
    return list;
  }

  static List<PopupMenuEntry<Object>> pupupMenu_StaffPage(
      BuildContext context) {
    var list = List<PopupMenuEntry<Object>>();
    list.add(
      PopupMenuItem(
        value: 1,
        child: Text(
          "${AppLocalizationHelper.of(context).translate("PrinterSetting")}",
          style: GoogleFonts.lato(
            fontSize: SizeHelper.isMobilePortrait
                ? 1.5 * SizeHelper.textMultiplier
                : 2 * SizeHelper.textMultiplier,
          ),
        ),
      ),
    );
    list.add(
      PopupMenuItem(
        value: 3,
        child: Text(
          "${AppLocalizationHelper.of(context).translate("LanguageSettingLabel")}",
          style: GoogleFonts.lato(
            fontSize: SizeHelper.isMobilePortrait
                ? 2 * SizeHelper.textMultiplier
                : 2 * SizeHelper.textMultiplier,
          ),
        ),
      ),
    );
    list.add(
      PopupMenuItem(
        value: 2,
        child: Text(
          "${AppLocalizationHelper.of(context).translate("Logout")}",
          style: GoogleFonts.lato(
            fontSize: SizeHelper.isMobilePortrait
                ? 1.5 * SizeHelper.textMultiplier
                : 2 * SizeHelper.textMultiplier,
          ),
        ),
      ),
    );
    return list;
  }

  static List<PopupMenuEntry<Object>> pupupMenu_KitchenPage(
      BuildContext context) {
    var list = List<PopupMenuEntry<Object>>();
    list.add(
      PopupMenuItem(
        value: 1,
        child: Text(
          "${AppLocalizationHelper.of(context).translate("Logout")}",
          style: GoogleFonts.lato(
            fontSize: SizeHelper.isMobilePortrait
                ? 1.5 * SizeHelper.textMultiplier
                : 2 * SizeHelper.textMultiplier,
          ),
        ),
      ),
    );
    return list;
  }

  static Widget onOrganizationMainPage(BuildContext context) {
    bool emailVerified = false;
    emailVerified =
        (Provider.of<CurrentUserProvider>(context).getloggedInUser.email !=
                    null &&
                Provider.of<CurrentUserProvider>(context)
                    .getloggedInUser
                    .email
                    .isNotEmpty)
            ? Provider.of<CurrentUserProvider>(context)
                    .getloggedInUser
                    .isEmailVerified
                ? true
                : false
            : false;
    ApiUser user = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser;
    return Container(
      height: SizeHelper.isMobilePortrait
          ? 4.5 * SizeHelper.heightMultiplier
          : 5 * SizeHelper.widthMultiplier,
      width: SizeHelper.isMobilePortrait
          ? 10 * SizeHelper.widthMultiplier
          : 10 * SizeHelper.heightMultiplier,
      child: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          !emailVerified
              ? new Icon(Icons.brightness_1,
                  size: SizeHelper.isMobilePortrait
                      ? 3 * SizeHelper.imageSizeMultiplier
                      : 1.5 * SizeHelper.imageSizeMultiplier,
                  color: Colors.redAccent)
              : Container(),
          PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(1.0),
              ),
            ),
            itemBuilder: (context) => (ApiUserHelper.isSuperAdmin(user))
                ? CustomAppBar.pupupMenuSuperAdminMenu(emailVerified, context)
                : CustomAppBar.pupupMenu_OrganizationMainPage(
                    emailVerified, context),
            onCanceled: () {},
            onSelected: (value) {
              (ApiUserHelper.isSuperAdmin(user))
                  ? pupupMenu_SuperAdminMenu_OnSelect(
                      value, context, emailVerified)
                  : pupupMenu_OrganizationMainPage_OnSelect(
                      value, context, emailVerified);
            },
            icon: Icon(
              Icons.person_outline,
              color: Colors.blueGrey,
              size: SizeHelper.isMobilePortrait
                  ? 7 * SizeHelper.imageSizeMultiplier
                  : 5 * SizeHelper.imageSizeMultiplier,
            ),
            offset: Offset(0, ScreenUtil().setHeight(130)),
          ),
        ],
      ),
    );
  }

  static void pupupMenu_OrganizationMainPage_OnSelect(
      int value, BuildContext context, bool emailVerified) async {
    print("value:$value");
    if (value == 1) {
      pushNewScreen(
        context,
        screen: ProfilePage(),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    } else if (value == 2) {
      if (!emailVerified) {
        AlertMessageDialog(
          content: "Email is required in profile page before updating password",
          buttonTitle: "Okay",
          buttonEvent: () {
            Navigator.of(context).pop(true);
          },
          context: context,
        ).showAlert();
        return;
      }
      pushNewScreen(
        context,
        screen: UpdatePasswordPage(),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    } else if (value == 3) {
      // await Provider.of<CurrentStoresProvider>(context, listen: false)
      //     .removeStoreDevice(context);
      try {
        var hive = await Hive.openBox('store');
        await hive.delete('storeId');
      } catch (Exception) {
        print(Exception);
      }
      Helper.logout(context);
    }
  }

  static List<PopupMenuEntry<Object>> pupupMenu_OrganizationMainPage(
      bool emailVerified, BuildContext context) {
    var list = List<PopupMenuEntry<Object>>();
    list.add(
      PopupMenuItem(
        value: 1,
        child: Row(
          children: [
            Text(
              "${AppLocalizationHelper.of(context).translate("Profile")}",
              style: GoogleFonts.lato(
                fontSize: SizeHelper.isMobilePortrait
                    ? 2 * SizeHelper.textMultiplier
                    : 2 * SizeHelper.textMultiplier,
              ),
            ),
            WEmptyView(20),
            !emailVerified
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.red),
                    alignment: Alignment.topRight,
                    child: Text(
                      '1',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                      ),
                    ))
                : Container(),
          ],
        ),
      ),
    );
    list.add(
      PopupMenuDivider(
        height: ScreenUtil().setHeight(20),
      ),
    );
    list.add(PopupMenuItem(
      value: 2,
      child: Text(
        "${AppLocalizationHelper.of(context).translate("UpdatePassword")}",
        style: GoogleFonts.lato(
          fontSize: SizeHelper.isMobilePortrait
              ? 2 * SizeHelper.textMultiplier
              : 2 * SizeHelper.textMultiplier,
        ),
      ),
    ));
    list.add(
      PopupMenuDivider(
        height: ScreenUtil().setHeight(20),
      ),
    );
    list.add(PopupMenuItem(
      value: 3,
      child: Text(
        "${AppLocalizationHelper.of(context).translate("Logout")}",
        style: GoogleFonts.lato(
          fontSize: SizeHelper.isMobilePortrait
              ? 2 * SizeHelper.textMultiplier
              : 2 * SizeHelper.textMultiplier,
        ),
      ),
    ));
    return list;
  }

  static void pupupMenu_SuperAdminMenu_OnSelect(
      int value, BuildContext context, bool emailVerified) async {
    print("value:$value");
    if (value == 1) {
      pushNewScreen(
        context,
        screen: ProfilePage(),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    } else if (value == 2) {
      if (!emailVerified) {
        AlertMessageDialog(
          content: "Email is required in profile page before updating password",
          buttonTitle: "Okay",
          buttonEvent: () {
            Navigator.of(context).pop(true);
          },
          context: context,
        ).showAlert();
        return;
      }
      pushNewScreen(
        context,
        screen: UpdatePasswordPage(),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    } else if (value == 3) {
      // await Provider.of<CurrentStoresProvider>(context, listen: false)
      //     .removeStoreDevice(context);
      try {
        var hive = await Hive.openBox('store');
        await hive.delete('storeId');
      } catch (Exception) {
        print(Exception);
      }
      Helper.logout(context);
    } else if (value == 4) {
      pushNewScreen(
        context,
        screen: CampaignListScreen(),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    } else if (value == 5) {
      pushNewScreen(
        context,
        screen: AdminReportPagePortrait(),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    }
  }

  static List<PopupMenuEntry<Object>> pupupMenuSuperAdminMenu(
      bool emailVerified, BuildContext context) {
    var list = List<PopupMenuEntry<Object>>();
    list.add(
      PopupMenuItem(
        value: 1,
        child: Row(
          children: [
            Text(
              "${AppLocalizationHelper.of(context).translate("Profile")}",
              style: GoogleFonts.lato(
                fontSize: SizeHelper.isMobilePortrait
                    ? 2 * SizeHelper.textMultiplier
                    : 2 * SizeHelper.textMultiplier,
              ),
            ),
            WEmptyView(20),
            !emailVerified
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.red),
                    alignment: Alignment.topRight,
                    child: Text(
                      '1',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                      ),
                    ))
                : Container(),
          ],
        ),
      ),
    );
    list.add(
      PopupMenuDivider(
        height: ScreenUtil().setHeight(20),
      ),
    );
    list.add(PopupMenuItem(
      value: 2,
      child: Text(
        "${AppLocalizationHelper.of(context).translate("UpdatePassword")}",
        style: GoogleFonts.lato(
          fontSize: SizeHelper.isMobilePortrait
              ? 2 * SizeHelper.textMultiplier
              : 2 * SizeHelper.textMultiplier,
        ),
      ),
    ));
    list.add(
      PopupMenuDivider(
        height: ScreenUtil().setHeight(20),
      ),
    );
    list.add(PopupMenuItem(
      value: 4,
      child: Text(
        "Campaign manage",
        style: GoogleFonts.lato(
          fontSize: SizeHelper.isMobilePortrait
              ? 2 * SizeHelper.textMultiplier
              : 2 * SizeHelper.textMultiplier,
        ),
      ),
    ));
    list.add(
      PopupMenuDivider(
        height: ScreenUtil().setHeight(20),
      ),
    );
    list.add(PopupMenuItem(
      value: 5,
      child: Text(
        "Stores Report",
        style: GoogleFonts.lato(
          fontSize: SizeHelper.isMobilePortrait
              ? 2 * SizeHelper.textMultiplier
              : 2 * SizeHelper.textMultiplier,
        ),
      ),
    ));
    list.add(
      PopupMenuDivider(
        height: ScreenUtil().setHeight(20),
      ),
    );
    list.add(PopupMenuItem(
      value: 3,
      child: Text(
        "${AppLocalizationHelper.of(context).translate("Logout")}",
        style: GoogleFonts.lato(
          fontSize: SizeHelper.isMobilePortrait
              ? 2 * SizeHelper.textMultiplier
              : 2 * SizeHelper.textMultiplier,
        ),
      ),
    ));

    return list;
  }

  static Widget showLeftLogo(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        // margin: (ScreenHelper.isLandScape(context)?const EdgeInsets.fromLTRB(0, 10, 0, 0):const EdgeInsets.fromLTRB(0, 20, 0, 0)),
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          child: Image.asset(
            'assets/images/vm-icon-round.jpg',
            fit: BoxFit.contain,
            height: SizeHelper.isMobilePortrait
                ? 8 * SizeHelper.imageSizeMultiplier
                : 4.8 * SizeHelper.imageSizeMultiplier,
            width: SizeHelper.isMobilePortrait
                ? 8 * SizeHelper.imageSizeMultiplier
                : 6 * SizeHelper.imageSizeMultiplier,
          ),
          onTap: () async {
            await showDialog(
                context: context,
                builder: (ctx) {
                  return Container(
                    // height:SizeHelper.isMobilePortrait?2.5*SizeHelper.heightMultiplier:3.5*SizeHelper.widthMultiplier,
                    // width:SizeHelper.isMobilePortrait?25*SizeHelper.widthMultiplier:20*SizeHelper.heightMultiplier,
                    child: AlertDialog(
                      title: Text(
                          "${AppLocalizationHelper.of(context).translate("About Vplus")}",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: SizeHelper.isMobilePortrait
                                ? 2 * SizeHelper.textMultiplier
                                : 3 * SizeHelper.textMultiplier,
                          )),
                      content: Container(
                        height: SizeHelper.isMobilePortrait
                            ? 20 * SizeHelper.heightMultiplier
                            : 30 * SizeHelper.widthMultiplier,
                        width: SizeHelper.isMobilePortrait
                            ? SizeHelper.widthMultiplier
                            : SizeHelper.heightMultiplier,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                launch("http://www.vplus.com.au/privacy");
                              },
                              child: Text(
                                  "${AppLocalizationHelper.of(context).translate("Privacy Policy")}",
                                  style: GoogleFonts.lato(
                                    fontSize: SizeHelper.isMobilePortrait
                                        ? 1.5 * SizeHelper.textMultiplier
                                        : 2 * SizeHelper.textMultiplier,
                                  )),
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                launch("http://www.vplus.com.au/terms");
                              },
                              child: Text(
                                  "${AppLocalizationHelper.of(context).translate("Terms")}",
                                  style: GoogleFonts.lato(
                                    fontSize: SizeHelper.isMobilePortrait
                                        ? 1.5 * SizeHelper.textMultiplier
                                        : 2 * SizeHelper.textMultiplier,
                                  )),
                            ),
                            SizedBox(height: 10),
                            Text(
                                "${AppLocalizationHelper.of(context).translate("App Version")}" +
                                    " " +
                                    packageInfo.version,
                                style: GoogleFonts.lato(
                                  fontSize: SizeHelper.isMobilePortrait
                                      ? 1.5 * SizeHelper.textMultiplier
                                      : 2 * SizeHelper.textMultiplier,
                                )),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RaisedButton(
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop('dialog');
                                  },
                                  child: Text(
                                      "${AppLocalizationHelper.of(context).translate("Close")}",
                                      style: GoogleFonts.lato(
                                        fontSize: SizeHelper.isMobilePortrait
                                            ? 1.5 * SizeHelper.textMultiplier
                                            : 2 * SizeHelper.textMultiplier,
                                      )),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                });
          },
        ),
      ),
    );
  }

  static Widget showLeftBack(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: SizeHelper.isMobilePortrait
                  ? 3 * SizeHelper.textMultiplier
                  : 3 * SizeHelper.textMultiplier,
            ),
            onTap: () {
              Navigator.pop(context);
            }),
      ),
    );
  }

  static Widget showAppBarTitle(String title, BuildContext context) {
    return Expanded(
      flex: 4,
      child: Container(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            textStyle: GoogleFonts.lato(
              color: Colors.grey[800],
              fontSize: SizeHelper.isMobilePortrait
                  ? 2.5 * SizeHelper.textMultiplier
                  : 3 * SizeHelper.textMultiplier,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  static getAppBarWithBackButtonAndTitleOnly(BuildContext context, String title,
      {Function callBack}) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      elevation: 2,
      leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: SizeHelper.isMobilePortrait
                ? 1.5 * SizeHelper.textMultiplier
                : 3 * SizeHelper.textMultiplier,
          ),
          onPressed: () {
            if (callBack != null) {
              callBack();
            }
            Navigator.pop(context);
          }),
      backgroundColor: Colors.white,
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
            textStyle: GoogleFonts.lato(color: Colors.black, fontSize: 20)),
      ),
    );
  }

  // static getAppBarWithoutTitle(String title) {
  //   return AppBar(
  //     centerTitle: false,
  //     backgroundColor: Colors.white,
  //     elevation: 2,
  //     title: Text(
  //       'sss',
  //       style: GoogleFonts.lato(
  //         color: Colors.black,
  //       ),
  //     ),
  //   );
  // }
}
