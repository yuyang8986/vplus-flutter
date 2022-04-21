import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/appLocalizationHelper.dart';
import 'package:vplus/helper/fcmHelper.dart';
import 'package:vplus/providers/currentuser_provider.dart';
import 'package:vplus/screens/drivers/driver_order_list_screen.dart';
import 'package:vplus/screens/home/home_qr.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:vplus/screens/offers/rewards.dart';
import 'package:vplus/screens/order_list/order_list_screen.dart';
import 'package:vplus/screens/stores/storeListPage.dart';
import 'package:vplus/screens/stores/supermarketListPage.dart';
import 'package:vplus/styles/color.dart';

class HomeScreen extends StatefulWidget {
  final HomeScreenTabs initTab;
  HomeScreen({Key key, this.initTab = HomeScreenTabs.Stores}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int initTabIndex;
  PersistentTabController _controller;
  GlobalKey<RewardsScreenState> globalKey = GlobalKey();

  final List<String> pageTitles =
      List.from(HomeScreenTabs.values.map((e) => e.toString()));

  bool checkIfDriver(){
    List<dynamic> roleName = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser?.role_name;
    if(roleName == null) return false;
    for(int i =0;i<roleName.length;i++){
      if(roleName[i]=="Driver"){
        return true;
      }
    }
    return false;
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    if(checkIfDriver()) {
      return [
        // PersistentBottomNavBarItem(
        //   icon: Icon(
        //     Icons.store,
        //   ),
        //   title: ("${AppLocalizationHelper.of(context).translate("Stores")}"),
        //   titleFontSize: 14,
        //   activeColor: appThemeColor,
        //   inactiveColor: Colors.grey,
        //   contentPadding: 10.0,
        // ),
        PersistentBottomNavBarItem(
          icon: Icon(Icons.food_bank_sharp),
          title: ("${AppLocalizationHelper.of(context).translate("Groceries")}"),
          titleFontSize: 14,
          activeColor: appThemeColor,
          inactiveColor: Colors.grey,
          contentPadding: 10.0,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(
            Icons.receipt,
          ),
          titleFontSize: 14,
          title: ("${AppLocalizationHelper.of(context).translate("Orders")}"),
          activeColor: appThemeColor,
          inactiveColor: Colors.grey,
          contentPadding: 10.0,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(
            Icons.motorcycle,
          ),
          titleFontSize: 14,
          title: ("${AppLocalizationHelper.of(context).translate("Drivers")}"),
          activeColor: appThemeColor,
          inactiveColor: Colors.grey,
          contentPadding: 10.0,
        )
        // PersistentBottomNavBarItem(
        //   icon: Icon(
        //     Icons.style,
        //   ),
        //   title: ("ORDERS"),
        //   activeColor: Colors.black,
        //   inactiveColor: Colors.grey,
        //   contentPadding: 10.0,
        // )
      ];
    }else{
      return [
        // PersistentBottomNavBarItem(
        //   icon: Icon(
        //     Icons.store,
        //   ),
        //   title: ("${AppLocalizationHelper.of(context).translate("Stores")}"),
        //   titleFontSize: 14,
        //   activeColor: appThemeColor,
        //   inactiveColor: Colors.grey,
        //   contentPadding: 10.0,
        // ),
         PersistentBottomNavBarItem(
          icon: Icon(Icons.food_bank_sharp),
          title: ("${AppLocalizationHelper.of(context).translate("Groceries")}"),
          titleFontSize: 14,
          activeColor: appThemeColor,
          inactiveColor: Colors.grey,
          contentPadding: 10.0,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(
            Icons.receipt,
          ),
          titleFontSize: 14,
          title: ("${AppLocalizationHelper.of(context).translate("Orders")}"),
          activeColor: appThemeColor,
          inactiveColor: Colors.grey,
          contentPadding: 10.0,
        )
        // PersistentBottomNavBarItem(
        //   icon: Icon(
        //     Icons.style,
        //   ),
        //   title: ("ORDERS"),
        //   activeColor: Colors.black,
        //   inactiveColor: Colors.grey,
        //   contentPadding: 10.0,
        // )
      ];
    }
  }

  List<Widget> _buildScreens() {
    if(checkIfDriver()) {
      return [
        //StoreListPage(),
        SupermarketListPage(),
        OrderListScreen(),
        DriverOrderListScreen()
        // RewardsScreen(key: globalKey),
      ];
    }else{
      return [
       // StoreListPage(),
        SupermarketListPage(),
        OrderListScreen()
        // RewardsScreen(key: globalKey),
      ];
    }
  }

  int userId;
  @override
  void initState() {
    super.initState();
    initTabIndex = this.widget.initTab.index ?? 0;
    _controller = PersistentTabController(initialIndex: initTabIndex);
    userId = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser
        .userId;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await FCMHelper.init(context);
      await FCMHelper.registerDevice(userId, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 1080, height: 1920, allowFontScaling: true);
    return Scaffold(
      body: PersistentTabView(
        controller: _controller,
        onItemSelected: (value) {
          print(value);
        },
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset:
            true, // This needs to be true if you want to move up the screen when keyboard appears.
        stateManagement: true,
        hideNavigationBarWhenKeyboardShows:
            true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument.

        popAllScreensOnTapOfSelectedTab: true,

        navBarStyle:
            NavBarStyle.style3, // Choose the nav bar style with this property.
      ),
    );
  }

}

enum HomeScreenTabs { Stores,  Orders,Drivers }
